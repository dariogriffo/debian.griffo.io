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

  document.querySelectorAll('a[href*="#"]').forEach(function (link) {
    link.addEventListener('click', function (e) {
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

  // ── Review carousel ─────────────────────────────────────────────────────
  // Advances the reviews on a timer. Deliberately built on the container's own
  // scroll position rather than a transform: the track is a plain overflow-x
  // element, so with this script absent or failed it is still a swipeable row
  // of readable cards. The reviews back the Review nodes in the page's JSON-LD
  // and Google expects them visible, so they must never depend on JS to exist.
  var carousels = document.querySelectorAll('[data-review-carousel].review-rotates');
  var stillMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)');
  carousels.forEach(function (root) {
    var track = root.querySelector('.review-track');
    var cards = track ? track.querySelectorAll('.review-card') : [];
    var dots = root.querySelectorAll('.review-dot');
    if (!track || cards.length < 2) { return; }

    var index = 0;
    var timer = null;
    var DELAY = 7000;

    function show(i, smooth) {
      index = (i + cards.length) % cards.length;
      var card = cards[index];
      track.scrollTo({
        left: card.offsetLeft - (track.clientWidth - card.clientWidth) / 2,
        behavior: smooth === false ? 'auto' : 'smooth'
      });
      dots.forEach(function (d, n) { d.classList.toggle('active', n === index); });
    }

    function start() {
      // Someone who asked the OS for less motion gets the cards, not the ride.
      if (stillMotion && stillMotion.matches) { return; }
      stop();
      timer = setInterval(function () { show(index + 1); }, DELAY);
    }
    function stop() { if (timer) { clearInterval(timer); timer = null; } }

    dots.forEach(function (d) {
      d.addEventListener('click', function () { show(+d.dataset.index); start(); });
    });
    // Pause while it is being read or interacted with, and while the tab is
    // hidden — rotating in a background tab burns battery for nobody.
    root.addEventListener('mouseenter', stop);
    root.addEventListener('mouseleave', start);
    root.addEventListener('focusin', stop);
    root.addEventListener('focusout', start);
    track.addEventListener('touchstart', stop, { passive: true });
    document.addEventListener('visibilitychange', function () {
      if (document.hidden) { stop(); } else { start(); }
    });
    // Keep the dots honest when someone swipes the track by hand.
    var settle;
    track.addEventListener('scroll', function () {
      clearTimeout(settle);
      settle = setTimeout(function () {
        var mid = track.scrollLeft + track.clientWidth / 2;
        var nearest = 0, best = Infinity;
        cards.forEach(function (c, n) {
          var d = Math.abs(c.offsetLeft + c.clientWidth / 2 - mid);
          if (d < best) { best = d; nearest = n; }
        });
        index = nearest;
        dots.forEach(function (d, n) { d.classList.toggle('active', n === index); });
      }, 120);
    }, { passive: true });

    show(0, false);
    start();
  });
})();
