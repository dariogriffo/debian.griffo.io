<?php
declare(strict_types=1);
/**
 * Currency for the requesting visitor, as JSON.
 *
 * The site is static; this is the one dynamic endpoint. Pages ship a euro
 * default and site.js corrects it from here, so the HTML stays cacheable.
 *
 * Self-contained on purpose — no includes, so there is no companion lib/
 * directory that the vhost has to be configured to deny.
 *
 * Requires on the server: php-fpm + a2enmod proxy_fcgi. Optional but
 * recommended: php-maxminddb plus a country database at the path in GEO_DB
 * (see tools/update-geoip.sh); without it, detection falls back to
 * Accept-Language and then USD.
 */

/**
 * Server-side currency detection, to match what Stripe will present at checkout.
 *
 * Stripe picks presentment currency from the customer's IP location, so the
 * page should decide the same way rather than from the browser timezone. Three
 * signals are tried in descending order of reliability:
 *
 *   1. IP -> country, via a MaxMind-format country database (php-maxminddb).
 *      Accurate, and the same input Stripe uses. Optional: if the extension or
 *      the database is absent, detection silently falls through.
 *   2. Accept-Language, e.g. "en-GB" -> GB. Weak — a British visitor running a
 *      US English build reports en-US — but free and always present.
 *   3. USD, the documented fallback.
 *
 * IMPORTANT: what we display must match what Stripe actually charges. This
 * assumes the Stripe Price carries explicit GBP/EUR/USD amounts at the same
 * nominal figure (15/15/15). If Stripe instead converts from a single base
 * currency, the checkout total will not be a round number and the page will be
 * lying. Verify the Price object before trusting this in production.
 */

/** Path to a MaxMind-format country DB. DB-IP Lite and GeoLite2 both work. */
const GEO_DB = '/var/lib/GeoIP/dbip-country-lite.mmdb';

/**
 * Trusted reverse proxies, as IP or CIDR. X-Forwarded-For is only honoured
 * when REMOTE_ADDR is in this list — otherwise any visitor could spoof their
 * country by sending the header. Empty means "no proxy, trust REMOTE_ADDR".
 */
const TRUSTED_PROXIES = [];

/** Countries billed in GBP: the UK and the Crown dependencies. */
const GBP_COUNTRIES = ['GB', 'IM', 'JE', 'GG'];

/** Euro-using countries: the euro area plus the states that adopted it. */
const EUR_COUNTRIES = [
    'AT', 'BE', 'HR', 'CY', 'EE', 'FI', 'FR', 'DE', 'GR', 'IE', 'IT', 'LV',
    'LT', 'LU', 'MT', 'NL', 'PT', 'SK', 'SI', 'ES',
    'AD', 'MC', 'SM', 'VA', 'ME', 'XK',
];

// NB: not CURRENCY_SYMBOL — ext/standard already defines that as an int
// (a localeconv grouping flag), and a colliding const is silently ignored,
// which quietly renders every price as a dollar amount.
const PRICE_SYMBOLS = ['GBP' => '£', 'EUR' => '€', 'USD' => '$'];

/** True when $ip falls inside $cidr (IPv4 or IPv6). */
function ip_in_cidr(string $ip, string $cidr): bool
{
    if (!str_contains($cidr, '/')) {
        return $ip === $cidr;
    }
    [$subnet, $bits] = explode('/', $cidr, 2);
    $ipBin = @inet_pton($ip);
    $subBin = @inet_pton($subnet);
    if ($ipBin === false || $subBin === false || strlen($ipBin) !== strlen($subBin)) {
        return false;
    }
    $bits = (int) $bits;
    $whole = intdiv($bits, 8);
    $rest = $bits % 8;
    if (substr($ipBin, 0, $whole) !== substr($subBin, 0, $whole)) {
        return false;
    }
    if ($rest === 0) {
        return true;
    }
    $mask = chr(0xFF << (8 - $rest) & 0xFF);
    return (($ipBin[$whole] & $mask) === ($subBin[$whole] & $mask));
}

/**
 * The visitor's IP. X-Forwarded-For is consulted only behind a trusted proxy;
 * otherwise the header is attacker-controlled and must be ignored.
 */
function client_ip(): ?string
{
    $remote = $_SERVER['REMOTE_ADDR'] ?? null;
    if ($remote === null) {
        return null;
    }
    $trusted = false;
    foreach (TRUSTED_PROXIES as $proxy) {
        if (ip_in_cidr($remote, $proxy)) {
            $trusted = true;
            break;
        }
    }
    if ($trusted && !empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
        // left-most entry is the original client
        $first = trim(explode(',', $_SERVER['HTTP_X_FORWARDED_FOR'])[0]);
        if (filter_var($first, FILTER_VALIDATE_IP)) {
            return $first;
        }
    }
    return filter_var($remote, FILTER_VALIDATE_IP) ? $remote : null;
}

/** ISO country code for an IP, or null when lookup is unavailable/inconclusive. */
function country_from_ip(?string $ip): ?string
{
    if ($ip === null || !class_exists('MaxMind\\Db\\Reader') || !is_readable(GEO_DB)) {
        return null;
    }
    // private/reserved addresses never resolve to a country
    if (!filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE)) {
        return null;
    }
    try {
        $reader = new MaxMind\Db\Reader(GEO_DB);
        $record = $reader->get($ip);
        $reader->close();
    } catch (Throwable) {
        return null;
    }
    $code = $record['country']['iso_code'] ?? $record['registered_country']['iso_code'] ?? null;
    return is_string($code) ? strtoupper($code) : null;
}

/** ISO country code from Accept-Language, e.g. "en-GB,en;q=0.9" -> "GB". */
function country_from_accept_language(): ?string
{
    $header = $_SERVER['HTTP_ACCEPT_LANGUAGE'] ?? '';
    if ($header === '') {
        return null;
    }
    // highest-weighted tag carrying a region subtag wins
    $best = null;
    $bestQ = -1.0;
    foreach (explode(',', $header) as $part) {
        $bits = explode(';', trim($part));
        $tag = trim($bits[0]);
        $q = 1.0;
        foreach (array_slice($bits, 1) as $param) {
            if (str_starts_with(trim($param), 'q=')) {
                $q = (float) substr(trim($param), 2);
            }
        }
        if (preg_match('/^[A-Za-z]{2,3}[-_]([A-Za-z]{2})$/', $tag, $m) && $q > $bestQ) {
            $best = strtoupper($m[1]);
            $bestQ = $q;
        }
    }
    return $best;
}

/** Currency for a country code. */
function currency_for_country(?string $country): ?string
{
    if ($country === null) {
        return null;
    }
    if (in_array($country, GBP_COUNTRIES, true)) {
        return 'GBP';
    }
    if (in_array($country, EUR_COUNTRIES, true)) {
        return 'EUR';
    }
    return 'USD';
}

/**
 * Detected currency plus the signal it came from.
 * @return array{currency: string, source: string, country: ?string}
 */
function detect_currency(): array
{
    static $result = null;
    if ($result !== null) {
        return $result;
    }

    $country = country_from_ip(client_ip());
    if ($country !== null) {
        return $result = ['currency' => currency_for_country($country), 'source' => 'geoip', 'country' => $country];
    }

    $country = country_from_accept_language();
    if ($country !== null) {
        return $result = ['currency' => currency_for_country($country), 'source' => 'language', 'country' => $country];
    }

    return $result = ['currency' => 'USD', 'source' => 'default', 'country' => null];
}

/** "£15" / "€120" / "$200". */
function format_price(int $amount, string $currency): string
{
    return (PRICE_SYMBOLS[$currency] ?? '$') . $amount;
}


/**
 * Currency for the requesting visitor, as JSON.
 *
 * Exists so the page can stay a cacheable static file once freeze.sh / the SEO
 * generator take over: the HTML ships with a neutral default and the browser
 * asks this endpoint for the right currency. While index.php is still dynamic
 * it renders server-side and this is just a second door onto the same logic.
 *
 * Never cached by shared caches — the answer is per-visitor.
 */


$detected = detect_currency();

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: private, no-store');
header('Vary: Accept-Language');

echo json_encode([
    'currency' => $detected['currency'],
    'symbol'   => PRICE_SYMBOLS[$detected['currency']] ?? '$',
    'source'   => $detected['source'],
], JSON_UNESCAPED_UNICODE), "\n";
