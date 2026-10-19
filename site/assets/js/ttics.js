/* ttics: first-party analytics for deb.griffo.io and deb-free.griffo.io.
 *
 * Cookieless, and it stores nothing on the device: no cookies, no
 * localStorage, no sessionStorage. Each page view (and the few events site.js
 * reports through window.ttics) is one beacon to https://ttics.griffo.io/e
 * carrying the path, the referrer, the page language, the viewport width, the
 * host and, on the page view only, any utm_* tags in the address. The service
 * and what it keeps live in debian-apt-gate, src/Debian.AptGate.Analytics. */
(function () {
  var ENDPOINT = 'https://ttics.griffo.io/e';

  function send(body) {
    var json = JSON.stringify(body);
    try {
      // text/plain keeps it a "simple" request: no CORS preflight.
      if (navigator.sendBeacon && navigator.sendBeacon(ENDPOINT, new Blob([json], { type: 'text/plain' }))) { return; }
    } catch (e) { /* fall through to fetch */ }
    try {
      fetch(ENDPOINT, {
        method: 'POST', body: json, keepalive: true, mode: 'no-cors', credentials: 'omit',
        headers: { 'Content-Type': 'text/plain' }
      });
    } catch (e) { /* analytics never breaks the page */ }
  }

  function beacon(type) {
    return {
      t: type,
      p: location.pathname,
      r: document.referrer,
      l: document.documentElement.lang || '',
      w: window.innerWidth,
      h: location.hostname
    };
  }

  // Events carry no utm: the report attributes them to the visitor's landing
  // that day.
  window.ttics = function (event) { send(beacon(event)); };

  var params = new URLSearchParams(location.search), utm = {}, hasUtm = false;
  ['source', 'medium', 'campaign', 'content', 'term'].forEach(function (k) {
    var v = params.get('utm_' + k);
    if (v) { utm[k] = v; hasUtm = true; }
  });
  var pageview = beacon('pageview');
  if (hasUtm) { pageview.u = utm; }
  send(pageview);
})();
