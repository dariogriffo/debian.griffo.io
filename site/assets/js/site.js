/*
 * deb.griffo.io — behaviour.
 * Template interactions (nav, reveal, counters, ticker, side panels, FAQ) are
 * adapted from TemplateMo 621 "Luminary"; the tab switcher, copy buttons and
 * language menu are carried over from the current site.
 */
(function () {
  'use strict';

  // ── Nav: shrink on scroll ──
  var topNav = document.getElementById('topNav');
  // ── Side panels: progress + percentage readout ──
  var leftTrack = document.getElementById('leftTrack');
  var rightTrack = document.getElementById('rightTrack');
  var scrollPct = document.getElementById('scrollPct');
  var dots = document.querySelectorAll('.side-panel.left .side-dot');

  // This used to read scrollY, toggle a class on the nav, and then ask for
  // document.scrollHeight. That last read comes after a write, so the browser
  // had to flush layout synchronously to answer it — on every scroll event, on
  // a document 26,000px tall. Lighthouse measured 165ms of forced reflow, and
  // it was costing real scrolling, not only the audit.
  //
  // Two changes. The document's height cannot change while you scroll, so it is
  // measured once and re-measured only when something actually resizes; and the
  // handler now does all of its reading before any of its writing, so nothing
  // asks the browser a question it needs a fresh layout to answer.
  var scrollMax = 0;
  function measureDocument() {
    scrollMax = document.documentElement.scrollHeight - window.innerHeight;
  }

  var queued = false;
  function onScroll() {
    if (queued) { return; }
    queued = true;
    requestAnimationFrame(paintScrollState);
  }

  function paintScrollState() {
    queued = false;
    // reads
    if (!scrollMax) { measureDocument(); }
    var y = window.scrollY;
    var pct = scrollMax > 0 ? Math.min(100, (y / scrollMax) * 100) : 0;
    var active = dots.length
      ? Math.min(dots.length - 1, Math.floor((pct / 100) * dots.length))
      : -1;
    // writes
    if (topNav) { topNav.classList.toggle('scrolled', y > 40); }
    if (leftTrack) { leftTrack.style.height = pct + '%'; }
    if (rightTrack) { rightTrack.style.height = (100 - pct) + '%'; }
    if (scrollPct) { scrollPct.textContent = String(Math.round(pct)).padStart(2, '0'); }
    if (active >= 0) {
      dots.forEach(function (d, i) { d.classList.toggle('active', i === active); });
    }
  }

  window.addEventListener('scroll', onScroll, { passive: true });
  window.addEventListener('resize', measureDocument, { passive: true });
  if ('ResizeObserver' in window) {
    // images and fonts landing after first paint change the document's height
    new ResizeObserver(measureDocument).observe(document.body);
  }
  // Measuring the document is itself a layout, and the side panels it feeds are
  // decoration: nothing needs them before the page has painted. So the first
  // measurement waits for idle, and a scroll that arrives before that takes its
  // own measurement rather than showing zero.
  function initScrollState() { measureDocument(); paintScrollState(); }
  if ('requestIdleCallback' in window) {
    requestIdleCallback(initScrollState, { timeout: 2000 });
  } else {
    setTimeout(initScrollState, 200);
  }

  // ── Smooth scroll for in-page anchors ──
  // Nav links are written absolute ("/#pricing") so they work from sub-pages;
  // when we are already on that page they are still same-document jumps and
  // must be treated like a bare "#pricing".
  function sameDocumentHash(link) {
    var href = link.getAttribute('href');
    if (!href || href.indexOf('#') === -1) { return null; }
    if (href.charAt(0) === '#') { return href; }
    if (link.host !== window.location.host) { return null; }
    if (link.pathname !== window.location.pathname) { return null; }
    return link.hash;
  }

  // Trial buttons are #pricing links only as a fallback; where the dialog can
  // open, they open it instead (see the trial section below) and must not also
  // scroll the page behind it.
  var trialDialogWorks = !!document.getElementById('trialDialog')
    && typeof document.getElementById('trialDialog').showModal === 'function';

  document.querySelectorAll('a[href*="#"]').forEach(function (link) {
    link.addEventListener('click', function (e) {
      if (trialDialogWorks && link.hasAttribute('data-trial')) { return; }
      var hash = sameDocumentHash(link);
      if (!hash) { return; }
      if (hash === '#') {
        e.preventDefault(); window.scrollTo({ top: 0, behavior: 'smooth' }); closeMobileMenu(); return;
      }
      var target = document.querySelector(hash);
      if (target) { e.preventDefault(); target.scrollIntoView({ behavior: 'smooth' }); closeMobileMenu(); }
    });
  });

  // ── Reveal on scroll ──
  var reveals = document.querySelectorAll('.reveal');
  if ('IntersectionObserver' in window) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (en) {
        if (en.isIntersecting) { en.target.classList.add('visible'); io.unobserve(en.target); }
      });
    }, { threshold: 0.1, rootMargin: '0px 0px -30px 0px' });
    reveals.forEach(function (el) { io.observe(el); });
  } else {
    reveals.forEach(function (el) { el.classList.add('visible'); });
  }

  // ── Hero counters ──
  var counters = document.querySelectorAll('.counter');
  function runCounter(el) {
    var target = parseFloat(el.dataset.target);
    var decimals = parseInt(el.dataset.decimals || '0', 10);
    var start = performance.now();
    var duration = 1600;
    (function tick(now) {
      var p = Math.min(1, (now - start) / duration);
      var eased = 1 - Math.pow(1 - p, 3);
      el.textContent = (target * eased).toFixed(decimals);
      if (p < 1) { requestAnimationFrame(tick); }
    })(start);
  }
  if ('IntersectionObserver' in window) {
    var cio = new IntersectionObserver(function (entries) {
      entries.forEach(function (en) {
        if (en.isIntersecting) { runCounter(en.target); cio.unobserve(en.target); }
      });
    }, { threshold: 0.5 });
    counters.forEach(function (el) { cio.observe(el); });
  } else {
    counters.forEach(function (el) { el.textContent = el.dataset.target; });
  }

  // ── Mobile menu ──
  var navToggle = document.getElementById('navToggle');
  var mobileMenu = document.getElementById('mobileMenu');
  function closeMobileMenu() {
    if (!mobileMenu) { return; }
    mobileMenu.classList.remove('open');
    if (navToggle) { navToggle.classList.remove('active'); navToggle.setAttribute('aria-expanded', 'false'); }
    document.body.style.overflow = '';
  }
  if (navToggle && mobileMenu) {
    navToggle.addEventListener('click', function () {
      var open = mobileMenu.classList.toggle('open');
      navToggle.classList.toggle('active', open);
      navToggle.setAttribute('aria-expanded', String(open));
      document.body.style.overflow = open ? 'hidden' : '';
    });
    // Any link in the panel dismisses it — cross-page links too, so the panel
    // is not still open when the browser restores the page from bfcache.
    mobileMenu.addEventListener('click', function (e) {
      if (e.target.closest && e.target.closest('a')) { closeMobileMenu(); }
    });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') { closeMobileMenu(); }
    });
  }

  // ── Language menu ──
  var langButton = document.getElementById('langButton');
  var langMenu = document.getElementById('langMenu');
  if (langButton && langMenu) {
    langButton.addEventListener('click', function (e) {
      e.stopPropagation();
      var open = langMenu.classList.toggle('active');
      langButton.setAttribute('aria-expanded', String(open));
    });
    document.addEventListener('click', function (e) {
      if (!langMenu.contains(e.target) && e.target !== langButton) {
        langMenu.classList.remove('active');
        langButton.setAttribute('aria-expanded', 'false');
      }
    });
  }

  // ── sudo / root / extrepo toggle ──
  // One state for the whole page, held on <html> so CSS does the switching.
  // Every toggle instance reflects it, and the choice is remembered.
  var VARIANT_KEY = 'deb-griffo-install-variant';
  var variantButtons = document.querySelectorAll('.variant-btn');

  // "extrepo" only exists where the page offers it: Ubuntu and PPA pages have
  // no extrepo route at all, and a stored choice must not leave their switch
  // with no button pressed. It degrades to sudo there, without overwriting the
  // stored preference, so returning to a Debian page still honours it.
  function offered(variant) {
    if (variant !== 'root' && variant !== 'sudo' && variant !== 'extrepo') { return null; }
    if (variant === 'extrepo' && !document.querySelector('.variant-btn[data-variant="extrepo"]')) {
      return 'sudo';
    }
    return variant;
  }

  function applyVariant(variant, persist) {
    document.documentElement.dataset.installVariant = variant;
    variantButtons.forEach(function (b) {
      b.setAttribute('aria-pressed', String(b.dataset.variant === variant));
    });
    if (persist) {
      try { localStorage.setItem(VARIANT_KEY, variant); } catch (e) { /* private mode */ }
    }
  }

  if (variantButtons.length) {
    var stored = null;
    try { stored = localStorage.getItem(VARIANT_KEY); } catch (e) { /* private mode */ }
    var initial = offered(stored);
    if (initial) { applyVariant(initial, false); }
    variantButtons.forEach(function (btn) {
      btn.addEventListener('click', function () { applyVariant(btn.dataset.variant, true); });
    });
    // Keep other open tabs in step — the preference is per-visitor, not per-tab.
    window.addEventListener('storage', function (e) {
      if (e.key !== VARIANT_KEY) { return; }
      var next = offered(e.newValue);
      if (next) { applyVariant(next, false); }
    });
  }

  // ── Copy buttons on code blocks ──
  document.querySelectorAll('.code-block').forEach(function (block) {
    if (!block.querySelector('pre')) { return; }
    function visiblePre() {
      var v = document.documentElement.dataset.installVariant || 'sudo';
      return block.querySelector('.variant-' + v) || block.querySelector('pre');
    }
    var btn = document.createElement('button');
    btn.className = 'copy-btn';
    btn.type = 'button';
    btn.textContent = 'Copy';
    btn.addEventListener('click', function () {
      navigator.clipboard.writeText(visiblePre().innerText.trim()).then(function () {
        btn.textContent = 'Copied';
        btn.classList.add('copied');
        setTimeout(function () { btn.textContent = 'Copy'; btn.classList.remove('copied'); }, 1800);
      });
    });
    block.appendChild(btn);
  });

  // ── FAQ accordion ──
  document.querySelectorAll('.faq-question').forEach(function (q) {
    q.addEventListener('click', function () {
      var item = q.closest('.faq-item');
      var answer = item.querySelector('.faq-answer');
      var open = item.classList.toggle('open');
      answer.style.maxHeight = open ? answer.scrollHeight + 'px' : null;
    });
  });

  // ── Localised prices ──
  // The server picks the currency (IP -> country, matching how Stripe chooses
  // presentment currency) and renders it into the markup. That value wins, so
  // this only steps in when:
  //   - the page carries no marker at all: it was frozen to static HTML, so no
  //     server-side detection happened and the endpoint has to be asked; or
  //   - the server fell back to Accept-Language or the default, where a live
  //     lookup may still do better.
  // Never overrides a geoip result, and never guesses from the timezone — that
  // was the old heuristic and it is strictly worse than asking the server.
  var priceEls = document.querySelectorAll('[data-amount]');
  var source = document.body.dataset.currencySource;
  if (priceEls.length && source !== 'geoip') {
    fetch('/api/currency.php', { credentials: 'omit' })
      .then(function (r) { return r.ok ? r.json() : null; })
      .then(function (data) {
        if (!data || !data.symbol) { return; }
        if (data.currency === document.body.dataset.currency) { return; }
        priceEls.forEach(function (el) { el.textContent = data.symbol + el.dataset.amount; });
        document.body.dataset.currency = data.currency;
      })
      .catch(function () { /* keep whatever the markup shipped with */ });
  }

  // ── Long lists, folded ──
  // The version table and the package grid each list every tool, which is
  // most of the page's height. Script folds them to a preview with a button
  // to show the rest; the markup always carries every row, so search engines
  // and readers without script still get the whole list.
  document.querySelectorAll('[data-fold]').forEach(function (box) {
    var keep = parseInt(box.dataset.fold, 10);
    var items = box.querySelector('tbody')
      ? box.querySelectorAll('tbody tr')
      : box.children;
    if (!keep || items.length <= keep + 2) { return; }
    Array.prototype.forEach.call(items, function (el, i) {
      if (i >= keep) { el.setAttribute('data-folded', ''); }
    });
    box.classList.add('is-folded');
    var more = document.createElement('button');
    more.type = 'button';
    more.className = 'btn-secondary fold-toggle';
    more.textContent = box.dataset.foldLabel || 'Show all';
    more.addEventListener('click', function () {
      box.classList.remove('is-folded');
      more.remove();
    });
    box.insertAdjacentElement('afterend', more);
  });

  // ── "Under the hood" opens on its own anchor ──
  // The section is a collapsed <details>, so a nav link or a search result
  // landing on #source would otherwise arrive at a closed box.
  var deepDive = document.querySelector('#source details');
  function openDeepDive() {
    if (deepDive && location.hash === '#source') { deepDive.open = true; }
  }
  openDeepDive();
  window.addEventListener('hashchange', openDeepDive);

  // ── Checkout links ──
  // Stripe payment links leave the site, so the purchase itself is never seen
  // here: begin_checkout is counted on the click, in GA and in ttics, and the
  // gate matches the purchase to the trial that preceded it by email.
  // window.gtag comes from the loader in layout.html, window.ttics from
  // /assets/js/ttics.js; either is absent when blocked, and the link works
  // regardless.
  document.querySelectorAll('a[href^="https://buy.stripe.com/"]').forEach(function (link) {
    link.addEventListener('click', function () {
      var card = link.closest('.pricing-card');
      var price = card && card.querySelector('.price-value[data-amount]');
      var tier = card && card.querySelector('.pricing-tier');
      if (typeof window.gtag === 'function') {
        window.gtag('event', 'begin_checkout', {
          currency: 'EUR',
          value: price ? Number(price.dataset.amount) : undefined,
          items: [{ item_name: tier ? tier.textContent.trim() : link.href }]
        });
      }
      if (typeof window.ttics === 'function') { window.ttics('begin_checkout'); }
    });
  });

  // ── Free trial dialog ──
  // Every [data-trial] element is a real link to #pricing, where the trial card
  // makes the same offer; script upgrades it to this dialog. The captcha script
  // is only fetched the first time the dialog opens, so pages that never open
  // it never talk to Cloudflare.
  var trial = document.getElementById('trialDialog');
  if (trial && typeof trial.showModal === 'function') {
    var form = trial.querySelector('.trial-form');
    var email = trial.querySelector('#trialEmail');
    var submit = trial.querySelector('.trial-submit');
    var errorBox = trial.querySelector('[data-trial-error]');
    var captchaBox = trial.querySelector('[data-trial-captcha]');
    var messages = trial.querySelector('[data-trial-messages]');
    var token = null;
    var widget = null;
    var sending = false;

    // trial_dialog_open, trial_started and generate_lead, sent to GA and to
    // ttics (see the checkout links above).
    var track = function (name) {
      if (typeof window.gtag === 'function') { window.gtag('event', name); }
      if (typeof window.ttics === 'function') { window.ttics(name); }
    };
    // generate_lead is GA4's recommended name for a sign-up, the one Google Ads
    // imports as a conversion; trial_started stays for the reports already built
    // on it.
    var trackLead = function () {
      if (typeof window.gtag === 'function') {
        window.gtag('event', 'generate_lead', { lead_source: 'trial' });
      }
      if (typeof window.ttics === 'function') { window.ttics('generate_lead'); }
    };

    // Stricter than type="email", which accepts "d@d": a domain needs a dot and a
    // two-letter-or-longer top level. The API applies the same rule, and every
    // attempt it sees counts against the one-a-day limit, so a typo is caught here.
    var EMAIL_RULE = /^[^\s@]+@[^\s@.]+(\.[^\s@.]+)*\.[^\s@.]{2,}$/;
    var validEmail = function () {
      var address = email.value.trim();
      return address.length <= 256 && EMAIL_RULE.test(address);
    };

    var updateSubmit = function () {
      submit.disabled = sending || !token || !validEmail();
      email.setAttribute('aria-invalid', email.value.trim() && !validEmail() ? 'true' : 'false');
    };

    var showError = function (code) {
      var match = messages.content.querySelector('[data-code="' + code + '"]')
        || messages.content.querySelector('[data-code="GENERIC"]');
      errorBox.textContent = '';
      Array.prototype.forEach.call(match.childNodes, function (n) {
        errorBox.appendChild(n.cloneNode(true));
      });
      errorBox.hidden = false;
    };

    var renderCaptcha = function () {
      if (widget !== null || !window.turnstile) { return; }
      captchaBox.textContent = '';
      widget = window.turnstile.render(captchaBox, {
        sitekey: trial.dataset.sitekey,
        theme: 'dark',
        language: trial.dataset.lang || 'auto',
        callback: function (t) { token = t; updateSubmit(); },
        'expired-callback': function () { token = null; updateSubmit(); },
        'error-callback': function () { token = null; updateSubmit(); showError('CAPTCHA_FAILED'); }
      });
    };

    var loadCaptcha = function () {
      if (window.turnstile) { renderCaptcha(); return; }
      if (document.getElementById('turnstileScript')) { return; }
      window.__dagTurnstileReady = renderCaptcha;
      var script = document.createElement('script');
      script.id = 'turnstileScript';
      script.src = 'https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit&onload=__dagTurnstileReady';
      script.async = true;
      script.defer = true;
      script.onerror = function () { showError('GENERIC'); };
      document.head.appendChild(script);
    };

    var openTrial = function () {
      if (trial.open) { return; }
      trial.showModal();
      if (!trial.querySelector('[data-trial-step="done"]').hidden) { return; }
      loadCaptcha();
      // after the opening frame, or the browser scrolls the page to the input
      setTimeout(function () { email.focus({ preventScroll: true }); }, 60);
      track('trial_dialog_open');
    };

    document.addEventListener('click', function (e) {
      var opener = e.target.closest && e.target.closest('[data-trial]');
      if (opener) { e.preventDefault(); openTrial(); return; }
      var closer = e.target.closest && e.target.closest('[data-trial-close]');
      if (closer && trial.contains(closer)) { trial.close(); }
    });
    // a click on the backdrop lands on the <dialog> element itself
    trial.addEventListener('click', function (e) { if (e.target === trial) { trial.close(); } });
    email.addEventListener('input', function () { errorBox.hidden = true; updateSubmit(); });
    // Say what is wrong once they leave the field, not on every keystroke.
    email.addEventListener('blur', function () {
      if (email.value.trim() && !validEmail()) { showError('INVALID_EMAIL'); }
    });

    form.addEventListener('submit', function (e) {
      e.preventDefault();
      if (sending) { return; }
      var address = email.value.trim();
      if (!validEmail()) { showError('INVALID_EMAIL'); email.focus(); return; }
      if (!token) { showError('CAPTCHA_FAILED'); return; }

      sending = true;
      errorBox.hidden = true;
      submit.textContent = submit.dataset.sending;
      updateSubmit();

      var finish = function (code) {
        sending = false;
        submit.textContent = submit.dataset.label;
        // a Turnstile token is single use: whatever happened, get a fresh one
        token = null;
        if (widget !== null && window.turnstile) { window.turnstile.reset(widget); }
        updateSubmit();
        if (code) { showError(code); }
      };

      fetch(trial.dataset.api, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'omit',
        body: JSON.stringify({
          email: address,
          turnstile_token: token
        })
      }).then(function (r) {
        if (r.status === 202) {
          sending = false;
          var out = trial.querySelector('[data-trial-success]');
          var parts = out.dataset.template.split('{email}');
          out.textContent = parts[0];
          var strong = document.createElement('strong');
          strong.textContent = address;
          out.appendChild(strong);
          out.appendChild(document.createTextNode(parts.slice(1).join('{email}')));
          trial.querySelector('[data-trial-step="form"]').hidden = true;
          trial.querySelector('[data-trial-step="done"]').hidden = false;
          track('trial_started');
          trackLead();
          return;
        }
        if (r.status === 429) { finish('RATE_LIMITED'); return; }
        if (r.status === 422) {
          return r.json().then(function (errors) {
            finish(errors && errors[0] && errors[0].code ? errors[0].code : 'GENERIC');
          }, function () { finish('GENERIC'); });
        }
        finish('GENERIC');
      }).catch(function () { finish('GENERIC'); });
    });
  }
})();
