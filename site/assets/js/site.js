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

  function onScroll() {
    var y = window.scrollY;
    if (topNav) { topNav.classList.toggle('scrolled', y > 40); }

    var max = document.documentElement.scrollHeight - window.innerHeight;
    var pct = max > 0 ? Math.min(100, (y / max) * 100) : 0;
    if (leftTrack) { leftTrack.style.height = pct + '%'; }
    if (rightTrack) { rightTrack.style.height = (100 - pct) + '%'; }
    if (scrollPct) { scrollPct.textContent = String(Math.round(pct)).padStart(2, '0'); }
    if (dots.length) {
      var active = Math.min(dots.length - 1, Math.floor((pct / 100) * dots.length));
      dots.forEach(function (d, i) { d.classList.toggle('active', i === active); });
    }
  }
  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  // ── Smooth scroll for in-page anchors ──
  document.querySelectorAll('a[href^="#"]').forEach(function (link) {
    link.addEventListener('click', function (e) {
      var href = link.getAttribute('href');
      if (href === '#') { e.preventDefault(); window.scrollTo({ top: 0, behavior: 'smooth' }); return; }
      var target = document.querySelector(href);
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

  // ── sudo / root toggle ──
  // One state for the whole page, held on <html> so CSS does the switching.
  // Every toggle instance reflects it, and the choice is remembered.
  var VARIANT_KEY = 'deb-griffo-install-variant';
  var variantButtons = document.querySelectorAll('.variant-btn');

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
    if (stored === 'root' || stored === 'sudo') { applyVariant(stored, false); }
    variantButtons.forEach(function (btn) {
      btn.addEventListener('click', function () { applyVariant(btn.dataset.variant, true); });
    });
    // Keep other open tabs in step — the preference is per-visitor, not per-tab.
    window.addEventListener('storage', function (e) {
      if (e.key === VARIANT_KEY && (e.newValue === 'root' || e.newValue === 'sudo')) {
        applyVariant(e.newValue, false);
      }
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
})();
