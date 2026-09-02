/* NeuroBridge — public website
   Progressive enhancement only. With JavaScript disabled, all content remains
   fully visible and usable (chips/links work, FAQ uses native <details>, the
   SVG illustration fallbacks show, and the Join form falls back to a mailto). */
(function () {
  "use strict";

  // -- Shared light/dark theme ---------------------------------------------
  var themeStorageKey = "nb_theme";

  function getSavedTheme() {
    try {
      var saved = localStorage.getItem(themeStorageKey);
      if (saved === "dark" || saved === "light") return saved;
    } catch (e) {
      // Continue to the system preference fallback.
    }
    return window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
  }

  function updateThemeButton(theme) {
    var button = document.getElementById("Darkbutton");
    if (!button) return;
    var isDark = theme === "dark";
    button.innerHTML = isDark
      ? '<svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="4"/><path d="M12 2v2m0 16v2M4.9 4.9l1.4 1.4m11.4 11.4 1.4 1.4M2 12h2m16 0h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/></svg>'
      : '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M20.2 15.2A8.5 8.5 0 0 1 8.8 3.8 8.6 8.6 0 1 0 20.2 15.2Z"/></svg>';
    var language = document.documentElement.lang || "en";
    var labels = {
      ar: { light: "التبديل إلى الوضع الفاتح", dark: "التبديل إلى الوضع الداكن" },
      de: { light: "Zum hellen Modus wechseln", dark: "Zum dunklen Modus wechseln" }
    };
    var localized = labels[language];
    button.setAttribute("aria-label", localized ? (isDark ? localized.light : localized.dark) : (isDark ? "Switch to light mode" : "Switch to dark mode"));
    button.setAttribute("aria-pressed", isDark ? "true" : "false");
  }

  function applyTheme(theme, persist) {
    var selected = theme === "dark" ? "dark" : "light";
    if (selected === "dark") {
      document.documentElement.setAttribute("data-theme", "dark");
    } else {
      document.documentElement.setAttribute("data-theme", "light");
    }
    if (persist) {
      try { localStorage.setItem(themeStorageKey, selected); } catch (e) {}
    }
    updateThemeButton(selected);
  }

  function setupThemeButton() {
    var button = document.getElementById("Darkbutton");
    if (!button || button.dataset.nbThemeReady === "true") return;
    button.type = "button";
    button.dataset.nbThemeReady = "true";
    updateThemeButton(document.documentElement.getAttribute("data-theme") === "dark" ? "dark" : "light");
    button.addEventListener("click", function () {
      var nextTheme = document.documentElement.getAttribute("data-theme") === "dark"
        ? "light"
        : "dark";
      applyTheme(nextTheme, true);
    });
  }

  applyTheme(getSavedTheme(), false);
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", setupThemeButton);
  } else {
    setupThemeButton();
  }

  // -- Dynamic translation for user-generated content ----------------------
  // Static interface copy continues to use translations.js and data-i18n.
  // This separate path is intentionally conservative and currently falls
  // back to the exact source text until a trusted backend service is added.
  var dynamicTranslationCache = new Map();
  var dynamicTranslationPending = new Map();
  var dynamicProductName = "NeuroBridge";

  function isProtectedDynamicText(text) {
    var value = text.trim();
    var email = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    var phone = /^\+?[\d\s().-]{7,}$/;
    var date = /^(?:\d{1,4}[\/.\-]\d{1,2}[\/.\-]\d{1,4}|\d{1,2}\s+[A-Za-z]{3,9}\s+\d{2,4}|[A-Za-z]{3,9}\s+\d{1,2},?\s+\d{2,4})$/;
    var uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    var id = /^(?=.*\d)(?=.*[A-Za-z])[A-Za-z0-9_:#.-]{4,}$/;
    var latinName = /^(?:[A-ZÀ-ÖØ-Þ][A-Za-zÀ-ÖØ-öø-ÿ'’-]+)(?:\s+[A-ZÀ-ÖØ-Þ][A-Za-zÀ-ÖØ-öø-ÿ'’-]+){0,4}$/;
    var arabicName = /^(?:[\u0600-\u06FF'’-]+)(?:\s+[\u0600-\u06FF'’-]+){0,3}$/;

    return email.test(value) || phone.test(value) || date.test(value) ||
      uuid.test(value) || id.test(value) || latinName.test(value) ||
      arabicName.test(value);
  }

  function protectDynamicProductNames(text) {
    var products = [];
    var protectedText = text.replace(/NeuroBridge/gi, function (match) {
      var token = "__NB_PRODUCT_" + products.length + "__";
      products.push(match);
      return token;
    });
    return { text: protectedText, products: products };
  }

  function restoreDynamicProductNames(text, products) {
    return text.replace(/__NB_PRODUCT_(\d+)__/g, function (token, index) {
      return products[Number(index)] || dynamicProductName;
    });
  }

  function requestDynamicTranslation(protectedText, targetLang) {
    // TODO: Connect this function to an authenticated backend translation API.
    // Keep credentials on the server, validate language/size limits there, and
    // require translation-only behavior that never infers or adds medical advice.
    void targetLang;
    return Promise.resolve(protectedText);
  }

  window.translateDynamicText = function translateDynamicText(text, targetLang) {
    var source = typeof text === "string" ? text : "";
    var language = typeof targetLang === "string"
      ? targetLang.toLowerCase().split("-")[0]
      : "en";

    if (!source.trim() || language === "en" || isProtectedDynamicText(source)) {
      return Promise.resolve(source);
    }

    var cacheKey = language + "\u0000" + source;
    if (dynamicTranslationCache.has(cacheKey)) {
      return Promise.resolve(dynamicTranslationCache.get(cacheKey));
    }
    if (dynamicTranslationPending.has(cacheKey)) {
      return dynamicTranslationPending.get(cacheKey);
    }

    var protectedValue = protectDynamicProductNames(source);
    var request = requestDynamicTranslation(protectedValue.text, language)
      .then(function (translated) {
        var result = typeof translated === "string" && translated.trim()
          ? restoreDynamicProductNames(translated, protectedValue.products)
          : source;
        dynamicTranslationCache.set(cacheKey, result);
        return result;
      })
      .catch(function () {
        dynamicTranslationCache.set(cacheKey, source);
        return source;
      })
      .then(function (result) {
        dynamicTranslationPending.delete(cacheKey);
        return result;
      });
    dynamicTranslationPending.set(cacheKey, request);
    return request;
  };


  // -- Global language UI: injects the language button and modal on every page --
  (function ensureLanguageUi() {
    var navInner = document.querySelector(".nav__inner");
    var navToggle = document.getElementById("navToggle");

    if (navInner && !document.getElementById("langBtn")) {
      var langButton = document.createElement("button");
      langButton.type = "button";
      langButton.className = "langbtn";
      langButton.id = "langBtn";
      langButton.setAttribute("aria-haspopup", "dialog");
      langButton.setAttribute("aria-expanded", "false");
      langButton.setAttribute("aria-controls", "langModal");
      langButton.setAttribute("aria-label", "Choose your language");

      langButton.innerHTML =
        '<svg class="langbtn__globe" aria-hidden="true" viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round">' +
          '<circle cx="12" cy="12" r="9"></circle>' +
          '<path d="M3 12h18"></path>' +
          '<path d="M12 3c2.6 2.6 3.9 5.8 3.9 9s-1.3 6.4-3.9 9c-2.6-2.6-3.9-5.8-3.9-9S9.4 5.6 12 3z"></path>' +
        '</svg>' +
        '<span class="langbtn__label" id="langBtnLabel">EN</span>' +
        '<svg class="langbtn__chev" aria-hidden="true" viewBox="0 0 24 24" width="12" height="12" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">' +
          '<path d="M6 9l6 6 6-6"></path>' +
        '</svg>';

      if (navToggle) {
        navInner.insertBefore(langButton, navToggle);
      } else {
        navInner.appendChild(langButton);
      }
    }

    if (!document.getElementById("langModal")) {
      document.body.insertAdjacentHTML("beforeend", `
        <div
          class="lang-modal"
          id="langModal"
          role="dialog"
          aria-modal="true"
          aria-labelledby="langModalTitle"
          aria-describedby="langModalSub"
          hidden
        >
          <div class="lang-modal__overlay" data-close></div>

          <div class="lang-modal__card" role="document">
            <button
              class="lang-modal__x"
              type="button"
              data-close
              aria-label="Close language selector"
            >
              ✕
            </button>

            <h2 class="lang-modal__title" id="langModalTitle">Choose your language</h2>

            <p class="lang-modal__sub" id="langModalSub">
              Select the language you prefer for NeuroBridge.
            </p>

            <div class="lang-grid" role="listbox" aria-label="Available languages">
              <button class="lang-opt" type="button" role="option" data-lang="en">
                <span class="lang-opt__badge" aria-hidden="true">EN</span>
                <span class="lang-opt__name">English</span>
                <span class="lang-opt__code">EN</span>
              </button>

              <button class="lang-opt" type="button" role="option" data-lang="ar">
                <span class="lang-opt__badge" aria-hidden="true" lang="ar">ع</span>
                <span class="lang-opt__name" lang="ar">العربية</span>
                <span class="lang-opt__code">AR</span>
              </button>

              <button class="lang-opt" type="button" role="option" data-lang="fr">
                <span class="lang-opt__badge" aria-hidden="true">FR</span>
                <span class="lang-opt__name">Français</span>
                <span class="lang-opt__code">FR</span>
              </button>

              <button class="lang-opt" type="button" role="option" data-lang="es">
                <span class="lang-opt__badge" aria-hidden="true">ES</span>
                <span class="lang-opt__name">Español</span>
                <span class="lang-opt__code">ES</span>
              </button>

              <button class="lang-opt" type="button" role="option" data-lang="de">
                <span class="lang-opt__badge" aria-hidden="true">DE</span>
                <span class="lang-opt__name">Deutsch</span>
                <span class="lang-opt__code">DE</span>
              </button>
            </div>

            <p class="lang-soon__head">Coming soon</p>

            <div class="lang-soon" aria-label="Coming soon languages">
              <span class="lang-soon__item">Italiano <em>Soon</em></span>
              <span class="lang-soon__item">Português <em>Soon</em></span>
              <span class="lang-soon__item">Türkçe <em>Soon</em></span>
              <span class="lang-soon__item" lang="zh">中文 <em>Soon</em></span>
              <span class="lang-soon__item" lang="ja">日本語 <em>Soon</em></span>
              <span class="lang-soon__item">Nederlands <em>Soon</em></span>
              <span class="lang-soon__item">Polski <em>Soon</em></span>
              <span class="lang-soon__item" lang="ru">Русский <em>Soon</em></span>
            </div>
          </div>
        </div>
      `);
    }
  })();

  var reduceMotion =
    window.matchMedia &&
    window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  document.body.classList.add("js-reveal");

  // -- Language / i18n (EN default, AR/FR runtime translation) ---------------
  // English stays the source in the HTML; we cache each element's original
  // markup and swap text by looking its normalized English text up in the
  // dictionary. Missing keys gracefully stay English.
  (function () {
    var DICT = window.NB_I18N || {};
    var LANGS = ["en", "ar", "fr", "es", "de"];
    var CODE = { en: "EN", ar: "AR", fr: "FR", es: "ES", de: "DE" };
    var norm = function (s) { return (s || "").replace(/\s+/g, " ").trim(); };
    var SEL = [
      ".nav__links a",
      ".lang-modal__title",
      ".lang-modal__sub",
      ".lang-opt__name",
      ".lang-soon__head",
      ".lang-soon__item",

      "h1",
      "h2",
      "h3",
      "h4",
      "p",
      "li",
      "summary",

      ".eyebrow",
      ".hero__sub-headline",
      ".lead",
      ".section__sub",
      ".mini-title",
      ".chip",
      ".btn",
      ".hero__note",
      ".hero__trust span",

      ".feat-chips span",
      ".mod h3",
      ".mod p",
      ".mtag",
      ".plat-card__body h3",
      ".ticks li",
      ".dash__head h3",
      ".tag",
      ".cm",
      ".quote",
      ".dash__note",
      ".ap-approve",
      ".pcard__spec",
      ".pcard__demo",
      ".pill",
      ".fbtn",
      ".dir-note",
      ".tree-note b",
      ".tree-note small",
      ".notice",

      ".card h3",
      ".card p",
      ".step h3",
      ".step p",
      ".game-card h3",
      ".game-card p",
      ".game-card__badge",

      ".quote-card blockquote",
      ".quote-card__who",
      ".quote-card__role",
      ".story-card figcaption h3",
      ".story-card figcaption p",
      ".vcard__cap b",
      ".vcard__cap span",
      ".fam__hero-cap b",
      ".fam__hero-cap span",

      ".join-card h3",
      ".join-card p",
      ".join-form h3",
      ".jf-legal",
      ".faq summary",
      ".faq p",
      ".cta p",
      ".cta__note",
      ".dev-card__role",

      ".footer__brand p",
      ".footer__proto",
      ".footer__col h4",
      ".footer__col a",
      ".footer__legal p"
    ].join(",");

    var els = [];
    document.querySelectorAll(SEL).forEach(function (el) {
      el._k = norm(el.textContent); el._h = el.innerHTML; els.push(el);
    });
    var labels = [];
    document.querySelectorAll(".jf-field").forEach(function (lbl) {
      var tn = lbl.firstChild;
      if (tn && tn.nodeType === 3 && norm(tn.nodeValue)) {
        labels.push({ n: tn, k: norm(tn.nodeValue), o: tn.nodeValue });
      }
    });
    var phs = ["siteSearch", "jfName", "jfEmail", "jfOrg", "jfPhone", "jfMsg"]
      .map(function (id) {
        var e = document.getElementById(id);
        return e ? { e: e, k: norm(e.getAttribute("placeholder")), o: e.getAttribute("placeholder") } : null;
      }).filter(Boolean);
    var opts = [];
    var roleSel = document.getElementById("jfRole");
    if (roleSel) Array.from(roleSel.options).forEach(function (o) {
      opts.push({ e: o, k: norm(o.textContent), o2: o.textContent });
    });
    var dataI18nEls = [];
    document.querySelectorAll("[data-i18n]").forEach(function (el) {
      dataI18nEls.push({
        e: el,
        k: el.getAttribute("data-i18n"),
        o: el.textContent
      });
    });

    /* Keep translated typography inside the English composition. Long copy is
       reduced only when it would add a line and move the content below it. */
    var fitTextItems = dataI18nEls.map(function (item) {
      var el = item.e;
      var isCopy = el.matches("h1,h2,h3,blockquote,p.section__sub,.hero__description,.hero__subtitle,.ai-chat-intro__lead");
      var isNav = el.matches(".nav__links a");
      if (!isCopy && !isNav) return null;
      var rect = el.getBoundingClientRect();
      var computed = window.getComputedStyle(el);
      var size = parseFloat(computed.fontSize);
      if (rect.width < 2 || rect.height < 2 || !size) return null;
      return {
        e: el,
        copy: isCopy,
        nav: isNav,
        width: rect.width,
        height: rect.height,
        size: size,
        minSize: Math.max(isNav ? 11 : 13, size * (el.matches("h1,h2") ? 0.68 : 0.78))
      };
    }).filter(Boolean);

    function fitTranslatedText(lang) {
      fitTextItems.forEach(function (item) {
        var el = item.e;
        el.style.removeProperty("font-size");
        el.style.removeProperty("min-height");
        el.style.removeProperty("width");
        el.style.removeProperty("flex-basis");

        if (item.nav && window.matchMedia("(min-width: 901px)").matches) {
          el.style.width = item.width + "px";
          el.style.flexBasis = item.width + "px";
        }
        if (lang === "en") return;

        var size = item.size;
        var tooTall = function () {
          return item.copy && el.getBoundingClientRect().height > item.height + 1;
        };
        var tooWide = function () {
          return item.nav && el.scrollWidth > el.clientWidth + 1;
        };
        while ((tooTall() || tooWide()) && size > item.minSize) {
          size = Math.max(item.minSize, size - 0.5);
          el.style.setProperty("font-size", size + "px", "important");
        }
        if (item.copy) el.style.minHeight = item.height + "px";
      });
    }
    var dataI18nAttrs = [];
    ["placeholder", "aria-label", "title"].forEach(function (attr) {
      document.querySelectorAll("[data-i18n-" + attr + "]").forEach(function (el) {
        dataI18nAttrs.push({
          e: el,
          a: attr,
          k: el.getAttribute("data-i18n-" + attr),
          o: el.getAttribute(attr) || ""
        });
      });
    });

    var tr = function (lang, key) { return (DICT[lang] && DICT[lang][key]) || null; };

    function apply(lang) {
      if (LANGS.indexOf(lang) === -1) lang = "en";
      var h = document.documentElement;
      h.setAttribute("lang", lang);
      h.setAttribute("dir", lang === "ar" ? "rtl" : "ltr");
      updateThemeButton(h.getAttribute("data-theme") === "dark" ? "dark" : "light");
      els.forEach(function (el) {
        if (lang === "en") { el.innerHTML = el._h; return; }
        var t = tr(lang, el._k);
        if (t != null) el.textContent = t; else el.innerHTML = el._h;
      });
      labels.forEach(function (l) {
        var t = lang === "en" ? null : tr(lang, l.k);
        l.n.nodeValue = t != null ? t + " " : l.o;
      });
      phs.forEach(function (p) {
        var t = lang === "en" ? null : tr(lang, p.k);
        p.e.setAttribute("placeholder", t != null ? t : p.o);
      });
      opts.forEach(function (o) {
        var t = lang === "en" ? null : tr(lang, o.k);
        o.e.textContent = t != null ? t : o.o2;
      });
      dataI18nEls.forEach(function (item) {
        var translated = lang === "en" ? null : tr(lang, item.k);
        item.e.textContent = translated != null ? translated : item.o;
      });
      dataI18nAttrs.forEach(function (item) {
        var translated = lang === "en" ? null : tr(lang, item.k);
        item.e.setAttribute(item.a, translated != null ? translated : item.o);
      });
      fitTranslatedText(lang);
      var languageButton = document.getElementById("langBtn");
      var menuButton = document.getElementById("navToggle");
      var closeButton = document.querySelector(".lang-modal__x");
      var uiLabels = {
        ar: { language: "اختر لغتك", menu: "فتح أو إغلاق القائمة", close: "إغلاق اختيار اللغة" },
        de: { language: "Sprache auswählen", menu: "Menü öffnen oder schließen", close: "Sprachauswahl schließen" },
        en: { language: "Choose your language", menu: "Toggle menu", close: "Close language selector" }
      }[lang] || null;
      if (uiLabels && languageButton) languageButton.setAttribute("aria-label", uiLabels.language);
      if (uiLabels && menuButton) menuButton.setAttribute("aria-label", uiLabels.menu);
      if (uiLabels && closeButton) closeButton.setAttribute("aria-label", uiLabels.close);
      var lbl = document.getElementById("langBtnLabel");
      if (lbl) lbl.textContent = CODE[lang] || lang.toUpperCase();
      document.querySelectorAll(".lang-opt").forEach(function (b) {
        var on = b.getAttribute("data-lang") === lang;
        b.classList.toggle("is-active", on);
        if (on) b.setAttribute("aria-current", "true"); else b.removeAttribute("aria-current");
      });
      try { localStorage.setItem("nb_lang", lang); } catch (e) {}
      document.dispatchEvent(new CustomEvent("nb:languagechange", { detail: { lang: lang } }));
    }

    // -- Language modal ------------------------------------------------------
    var modal = document.getElementById("langModal");
    var langBtn = document.getElementById("langBtn");
    function openModal() {
      if (!modal) return;
      modal.hidden = false;
      document.body.style.overflow = "hidden";
      if (langBtn) langBtn.setAttribute("aria-expanded", "true");
      var a = modal.querySelector(".lang-opt.is-active") || modal.querySelector(".lang-opt");
      if (a) a.focus();
    }
    function closeModal() {
      if (!modal || modal.hidden) return;
      modal.hidden = true;
      document.body.style.overflow = "";
      if (langBtn) { langBtn.setAttribute("aria-expanded", "false"); langBtn.focus(); }
    }
    if (langBtn) langBtn.addEventListener("click", openModal);
    if (modal) {
      modal.querySelectorAll("[data-close]").forEach(function (el) {
        el.addEventListener("click", closeModal);
      });
      modal.querySelectorAll(".lang-opt").forEach(function (b) {
        b.addEventListener("click", function () {
          apply(b.getAttribute("data-lang"));
          closeModal();
        });
      });
      document.addEventListener("keydown", function (e) {
        if (modal.hidden) return;
        if (e.key === "Escape") { closeModal(); return; }
        if (e.key === "Tab") {
          var f = modal.querySelectorAll("button:not([disabled])");
          if (!f.length) return;
          var first = f[0], last = f[f.length - 1];
          if (e.shiftKey && document.activeElement === first) { e.preventDefault(); last.focus(); }
          else if (!e.shiftKey && document.activeElement === last) { e.preventDefault(); first.focus(); }
        }
      });
    }

    var saved = "en";
    try { saved = localStorage.getItem("nb_lang") || "en"; } catch (e) {}
    apply(saved);
  })();

  // -- Image slots: upgrade SVG fallback -> local JPG/PNG/WebP if present -----
  // Each slot ships the SVG as its src and names the optional photo in
  // data-upgrade. As a slot nears the viewport we preload that file and only
  // swap on success — so below-the-fold photos load lazily and a missing image
  // never breaks the page (the SVG fallback simply stays).
  var upgradeSlot = function (img) {
    var url = img.getAttribute("data-upgrade");
    if (!url || img.dataset.upgraded) return;
    img.dataset.upgraded = "1";
    var probe = new Image();
    probe.onload = function () { if (probe.naturalWidth > 0) img.src = url; };
    probe.onerror = function () { /* keep the SVG fallback */ };
    probe.src = url;
  };
  var imgSlots = document.querySelectorAll("img[data-upgrade]");
  if ("IntersectionObserver" in window && imgSlots.length) {
    var imgIO = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (e) {
          if (e.isIntersecting) { upgradeSlot(e.target); imgIO.unobserve(e.target); }
        });
      },
      { rootMargin: "300px 0px" }
    );
    imgSlots.forEach(function (img) { imgIO.observe(img); });
  } else {
    imgSlots.forEach(upgradeSlot);
  }

  // -- Mobile navigation toggle ---------------------------------------------
  var toggle = document.getElementById("navToggle");
  var links = document.getElementById("navLinks");
  if (toggle && links) {
    toggle.addEventListener("click", function () {
      var open = links.classList.toggle("open");
      toggle.classList.toggle("open", open);
      toggle.setAttribute("aria-expanded", open ? "true" : "false");
    });
    links.querySelectorAll("a").forEach(function (a) {
      a.addEventListener("click", function () {
        links.classList.remove("open");
        toggle.classList.remove("open");
        toggle.setAttribute("aria-expanded", "false");
      });
    });
  }

  // -- Reveal-on-scroll ------------------------------------------------------
  var reveals = document.querySelectorAll(".reveal");
  if ("IntersectionObserver" in window && reveals.length && !reduceMotion) {
    var io = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            entry.target.classList.add("in");
            io.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.1, rootMargin: "0px 0px -40px 0px" }
    );
    reveals.forEach(function (el) { io.observe(el); });
  } else {
    reveals.forEach(function (el) { el.classList.add("in"); });
  }

  // -- FAQ accordion: keep only one item open at a time ----------------------
  var faq = document.querySelectorAll(".faq details");
  faq.forEach(function (item) {
    item.addEventListener("toggle", function () {
      if (item.open) {
        faq.forEach(function (other) { if (other !== item) other.open = false; });
      }
    });
  });

  // -- Hero search: filter module suggestions --------------------------------
  var MODULES = [
    { name: "Patient App", target: "#patients", hint: "Daily therapy & games" },
    { name: "Family Portal", target: "#families", hint: "Messages & memories" },
    { name: "Family Messages", target: "#families", hint: "Provider chat" },
    { name: "Doctor Portal", target: "#care-teams", hint: "Performance-only review" },
    { name: "Care Teams", target: "#care-teams", hint: "Doctors & therapists" },
    { name: "Clinics", target: "#clinics", hint: "Medical centers" },
    { name: "Platform modules", target: "#modules", hint: "All modules" },
    { name: "Appointments", target: "#booking", hint: "Book a visit" },
    { name: "Provider Directory", target: "#booking", hint: "Demo providers" },
    { name: "Provider Chat", target: "#families", hint: "Two-way inquiries" },
    { name: "Supportive Review", target: "#ai", hint: "Pending care-team review" },
    { name: "Memory Album", target: "#memory", hint: "Memory Center" },
    { name: "Cognitive Games", target: "#games", hint: "Supportive exercises" },
    { name: "Reports", target: "#reports", hint: "Weekly & monthly" },
    { name: "Security", target: "#security", hint: "JWT · RBAC · audit logs" },
    { name: "How it works", target: "#resources", hint: "Resources" },
    { name: "Join / Request access", target: "#join", hint: "Register interest" },
    { name: "FAQ", target: "#faq", hint: "Common questions" }
  ];
  var input = document.getElementById("siteSearch");
  var results = document.getElementById("searchResults");

  function closeResults() {
    if (!results) return;
    results.hidden = true;
    results.innerHTML = "";
    if (input) input.setAttribute("aria-expanded", "false");
  }
  function renderResults(q) {
    if (!results) return;
    var query = q.trim().toLowerCase();
    if (!query) { closeResults(); return; }
    var matches = MODULES.filter(function (m) {
      return (m.name + " " + m.hint).toLowerCase().indexOf(query) !== -1;
    }).slice(0, 6);
    results.innerHTML = "";
    if (!matches.length) {
      var empty = document.createElement("li");
      empty.className = "search__empty";
      empty.textContent = "No modules match “" + q + "”.";
      results.appendChild(empty);
    } else {
      matches.forEach(function (m) {
        var li = document.createElement("li");
        li.setAttribute("role", "option");
        var a = document.createElement("a");
        a.href = m.target;
        a.innerHTML = "<span>" + m.name + "</span><small>" + m.hint + "</small>";
        a.addEventListener("click", closeResults);
        li.appendChild(a);
        results.appendChild(li);
      });
    }
    results.hidden = false;
    if (input) input.setAttribute("aria-expanded", "true");
  }
  if (input && results) {
    input.addEventListener("input", function () { renderResults(input.value); });
    input.addEventListener("focus", function () { if (input.value.trim()) renderResults(input.value); });
    var sform = document.getElementById("searchForm");
    if (sform) {
      sform.addEventListener("submit", function (e) {
        e.preventDefault();
        var first = results.querySelector("a");
        if (first) { window.location.hash = first.getAttribute("href"); closeResults(); }
      });
    }
    document.addEventListener("click", function (e) {
      if (!results.contains(e.target) && e.target !== input) closeResults();
    });
    input.addEventListener("keydown", function (e) { if (e.key === "Escape") closeResults(); });
  }

  // -- Provider directory: governorate filter --------------------------------
  var fbtns = document.querySelectorAll(".dir-filter .fbtn");
  var pcards = document.querySelectorAll("#providerGrid .pcard");
  if (fbtns.length && pcards.length) {
    fbtns.forEach(function (btn) {
      btn.addEventListener("click", function () {
        var gov = btn.getAttribute("data-gov");
        fbtns.forEach(function (b) { b.classList.remove("is-active"); });
        btn.classList.add("is-active");
        pcards.forEach(function (card) {
          var show = gov === "all" || card.getAttribute("data-gov") === gov;
          card.style.display = show ? "" : "none";
        });
      });
    });
  }

  // -- Join: pick a role from a card, focus the form -------------------------
  var roleSelect = document.getElementById("jfRole");
  var joinForm = document.getElementById("joinForm");
  var jfNote = document.getElementById("jfNote");
  var nameInput = document.getElementById("jfName");

  document.querySelectorAll(".join-pick").forEach(function (btn) {
    btn.addEventListener("click", function () {
      var role = btn.getAttribute("data-role");
      if (roleSelect && role) roleSelect.value = role;
      if (joinForm) joinForm.scrollIntoView({ behavior: reduceMotion ? "auto" : "smooth", block: "center" });
      if (nameInput) nameInput.focus({ preventScroll: true });
    });
  });

  // -- Join form: submit a real access request to the backend ----------------
  // POSTs to the access-requests API, which stores a PENDING request only — it
  // never creates an account. Localized status messages; graceful error if the
  // backend is unreachable. No mailto, no account creation from the website.
  var ACCESS_REQUESTS_URL = "http://127.0.0.1:8000/api/v1/access-requests";
  var EMAIL_RE = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;
  var JF_MSG = {
    submitting: {
      en: "Submitting…", ar: "جارٍ الإرسال…", fr: "Envoi…",
      es: "Enviando…", de: "Wird gesendet…"
    },
    invalid: {
      en: "Please enter your name, a valid email, and a role.",
      ar: "يرجى إدخال الاسم وبريد إلكتروني صحيح والدور.",
      fr: "Veuillez saisir votre nom, un e-mail valide et un rôle.",
      es: "Introduce tu nombre, un correo válido y un rol.",
      de: "Bitte Name, eine gültige E-Mail und eine Rolle eingeben."
    },
    success: {
      en: "Your request has been submitted successfully. The team will review it and contact you.",
      ar: "تم تسجيل طلبك بنجاح. سيقوم الفريق بمراجعته والتواصل معك.",
      fr: "Votre demande a été envoyée avec succès. L'équipe l'examinera et vous contactera.",
      es: "Tu solicitud se ha enviado correctamente. El equipo la revisará y te contactará.",
      de: "Ihre Anfrage wurde erfolgreich gesendet. Das Team prüft sie und meldet sich bei Ihnen."
    },
    error: {
      en: "Sorry, we couldn't submit your request right now. Please try again in a moment.",
      ar: "عذرًا، تعذّر إرسال طلبك الآن. يرجى المحاولة بعد قليل.",
      fr: "Désolé, l'envoi de votre demande a échoué. Veuillez réessayer dans un instant.",
      es: "Lo sentimos, no pudimos enviar tu solicitud ahora. Inténtalo de nuevo en un momento.",
      de: "Entschuldigung, Ihre Anfrage konnte nicht gesendet werden. Bitte versuchen Sie es gleich erneut."
    }
  };
  function jfLang() {
    var l = (document.documentElement.getAttribute("lang") || "en").slice(0, 2);
    return JF_MSG.success[l] ? l : "en";
  }
  if (joinForm) {
    joinForm.addEventListener("submit", function (e) {
      e.preventDefault();
      var val = function (id) {
        var el = document.getElementById(id);
        return el ? el.value.trim() : "";
      };
      var lang = jfLang();
      var name = val("jfName");
      var email = val("jfEmail");
      var role = val("jfRole");
      if (!name || !EMAIL_RE.test(email) || !role) {
        if (jfNote) jfNote.textContent = JF_MSG.invalid[lang];
        return;
      }
      var submitBtn = joinForm.querySelector('button[type="submit"]');
      if (submitBtn) submitBtn.disabled = true;
      if (jfNote) jfNote.textContent = JF_MSG.submitting[lang];

      fetch(ACCESS_REQUESTS_URL, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          full_name: name,
          email: email,
          requested_role: role,
          phone: val("jfPhone") || null,
          organization: val("jfOrg") || null,
          message: val("jfMsg") || null
        })
      })
        .then(function (res) {
          if (!res.ok) throw new Error("Request failed (" + res.status + ")");
          return res.json();
        })
        .then(function () {
          if (jfNote) jfNote.textContent = JF_MSG.success[lang];
          joinForm.reset();
        })
        .catch(function () {
          if (jfNote) jfNote.textContent = JF_MSG.error[lang];
        })
        .then(function () {
          if (submitBtn) submitBtn.disabled = false;
        });
    });
  }

  // -- Public AI Companion demo (local, deterministic, no external AI) -------
  var aiChatForm = document.getElementById("aiChatForm");
  var aiChatInput = document.getElementById("aiChatInput");
  var aiChatWindow = document.getElementById("aiChatWindow");
  var aiChatTimer = null;
  var AI_CHAT_KEYS = {
    safety: "I can provide supportive guidance only, not diagnosis, treatment decisions, medication advice, medical instructions, or risk prediction. Please contact your care team to review care-related concerns.",
    activities: "You can review your assigned daily cognitive activities from the patient dashboard.",
    family: "Families can share encouragement, memories, and supportive messages.",
    appointments: "You can check upcoming appointments inside the platform.",
    messages: "Use the Messages area to send non-urgent questions and follow up with the care team.",
    navigation: "Use the platform menu to open activities, appointments, messages, memories, and performance summaries.",
    progress: "NeuroBridge shows performance-only progress summaries for supportive follow-up and care-team review.",
    fallback: "I can help explain NeuroBridge features, daily activities, family support, appointments, and platform navigation. I provide supportive guidance only, not medical advice."
  };
  var AI_CHAT_TERMS = {
    safety: ["diagnos", "treatment", "medicine", "medication", "dose", "risk", "symptom", "medical", "تشخيص", "علاج", "دواء", "جرعة", "خطر", "أعراض", "طبي"],
    activities: ["activity", "activities", "exercise", "game", "نشاط", "أنشطة", "تمرين", "ألعاب", "activité", "ejercicio", "aktivität"],
    family: ["family", "memory", "encouragement", "عائلة", "العائلة", "ذكرى", "ذكريات", "تشجيع", "famille", "familia", "familie"],
    appointments: ["appointment", "booking", "موعد", "مواعيد", "حجز", "rendez-vous", "cita", "termin"],
    messages: ["message", "chat", "رسالة", "رسائل", "محادثة", "nachricht", "mensaje"],
    progress: ["progress", "summary", "performance", "report", "تقدم", "التقدم", "ملخص", "أداء", "تقرير", "progrès", "progreso", "fortschritt"],
    navigation: ["navigate", "navigation", "where", "find", "open", "استخدام", "أين", "افتح", "انتقل", "navigation", "navegación"]
  };

  function aiChatLang() {
    var lang = (document.documentElement.getAttribute("lang") || "en").slice(0, 2);
    return ["en", "ar", "fr", "es", "de"].indexOf(lang) >= 0 ? lang : "en";
  }

  function aiChatTranslate(key) {
    var lang = aiChatLang();
    return lang !== "en" && window.NB_I18N && window.NB_I18N[lang] && window.NB_I18N[lang][key]
      ? window.NB_I18N[lang][key]
      : key;
  }

  function aiChatResponse(message) {
    var normalized = message.toLocaleLowerCase();
    var categories = ["safety", "activities", "family", "appointments", "messages", "progress", "navigation"];
    for (var i = 0; i < categories.length; i += 1) {
      var category = categories[i];
      if (AI_CHAT_TERMS[category].some(function (term) { return normalized.indexOf(term) !== -1; })) {
        return aiChatTranslate(AI_CHAT_KEYS[category]);
      }
    }
    return aiChatTranslate(AI_CHAT_KEYS.fallback);
  }

  function appendAiChatMessage(text, type) {
    var bubble = document.createElement("div");
    bubble.className = "ai-chat-message ai-chat-message--" + type;
    bubble.textContent = text;
    aiChatWindow.appendChild(bubble);
    aiChatWindow.scrollTop = aiChatWindow.scrollHeight;
    return bubble;
  }

  if (aiChatForm && aiChatInput && aiChatWindow) {
    aiChatForm.addEventListener("submit", function (event) {
      event.preventDefault();
      var message = aiChatInput.value.trim();
      if (!message || aiChatTimer) return;

      appendAiChatMessage(message, "user");
      aiChatInput.value = "";
      aiChatInput.disabled = true;
      var sendButton = aiChatForm.querySelector(".ai-chat-send");
      if (sendButton) sendButton.disabled = true;

      var loading = document.createElement("div");
      loading.className = "ai-chat-message ai-chat-message--bot ai-chat-message--loading";
      loading.setAttribute("aria-label", aiChatTranslate("Preparing a response…"));
      loading.innerHTML = "<i></i><i></i><i></i>";
      aiChatWindow.appendChild(loading);
      aiChatWindow.scrollTop = aiChatWindow.scrollHeight;

      aiChatTimer = window.setTimeout(function () {
        loading.remove();
        appendAiChatMessage(aiChatResponse(message), "bot");
        aiChatInput.disabled = false;
        if (sendButton) sendButton.disabled = false;
        aiChatTimer = null;
        aiChatInput.focus();
      }, reduceMotion ? 150 : 650);
    });
  }

  // -- Homepage resource carousel -------------------------------------------
  var resourceRail = document.querySelector(".home-editorial .home-resources__grid");
  if (resourceRail) {
    var resourceCards = Array.prototype.slice.call(resourceRail.children);
    var resourcePrevious = document.querySelector(".resource-carousel__button--previous");
    var resourceNext = document.querySelector(".resource-carousel__button--next");
    var resourceActiveIndex = 0;
    var resourceAutoplayTimer = null;
    var resourceHovering = false;
    var resourcePointerId = null;
    var resourceDragStartX = 0;
    var resourceDragDelta = 0;
    var resourceDragged = false;
    var resourceSuppressClick = false;

    function resourceRelativePosition(index) {
      var difference = index - resourceActiveIndex;
      var half = resourceCards.length / 2;
      if (difference > half) difference -= resourceCards.length;
      if (difference < -half) difference += resourceCards.length;
      return difference;
    }

    function renderResourceCoverflow() {
      resourceCards.forEach(function (card, index) {
        var position = resourceRelativePosition(index);
        card.classList.remove("is-active", "is-previous", "is-next", "is-far-previous", "is-far-next", "is-coverflow-hidden");
        if (position === 0) card.classList.add("is-active");
        else if (position === -1) card.classList.add("is-previous");
        else if (position === 1) card.classList.add("is-next");
        else if (position === -2) card.classList.add("is-far-previous");
        else if (position === 2) card.classList.add("is-far-next");
        else card.classList.add("is-coverflow-hidden");
        card.setAttribute("aria-hidden", position === 0 ? "false" : "true");
        card.setAttribute("tabindex", position === 0 ? "0" : "-1");
      });
    }

    function scheduleResourceAutoplay(delay) {
      window.clearTimeout(resourceAutoplayTimer);
      if (reduceMotion || resourceHovering || document.hidden) return;
      resourceAutoplayTimer = window.setTimeout(function () {
        resourceActiveIndex = (resourceActiveIndex + 1) % resourceCards.length;
        renderResourceCoverflow();
        scheduleResourceAutoplay(4800);
      }, delay || 4800);
    }

    function moveResourcesByCard(direction, userInitiated) {
      resourceActiveIndex = (resourceActiveIndex + direction + resourceCards.length) % resourceCards.length;
      renderResourceCoverflow();
      if (userInitiated) scheduleResourceAutoplay(5200);
    }

    resourceRail.addEventListener("mouseenter", function () {
      resourceHovering = true;
      window.clearTimeout(resourceAutoplayTimer);
    });
    resourceRail.addEventListener("mouseleave", function () {
      resourceHovering = false;
      scheduleResourceAutoplay(1800);
    });
    resourceRail.addEventListener("dragstart", function (event) { event.preventDefault(); });
    resourceRail.addEventListener("pointerdown", function (event) {
      if (event.pointerType === "mouse" && event.button !== 0) return;
      resourcePointerId = event.pointerId;
      resourceDragStartX = event.clientX;
      resourceDragDelta = 0;
      resourceDragged = false;
      window.clearTimeout(resourceAutoplayTimer);
    });
    resourceRail.addEventListener("pointermove", function (event) {
      if (event.pointerId !== resourcePointerId) return;
      resourceDragDelta = event.clientX - resourceDragStartX;
      if (!resourceDragged && Math.abs(resourceDragDelta) > 10) {
        resourceDragged = true;
        resourceRail.classList.add("is-dragging");
        resourceRail.setPointerCapture(event.pointerId);
      }
      if (!resourceDragged) return;
      resourceRail.style.setProperty("--coverflow-drag", resourceDragDelta + "px");
    });

    function finishResourceCoverflowDrag(event) {
      if (resourcePointerId === null || (event && event.pointerId !== resourcePointerId)) return;
      if (event && resourceRail.hasPointerCapture(event.pointerId)) resourceRail.releasePointerCapture(event.pointerId);
      resourceRail.classList.remove("is-dragging");
      resourceRail.style.setProperty("--coverflow-drag", "0px");
      resourceSuppressClick = resourceDragged;
      if (resourceDragDelta < -45) moveResourcesByCard(1, false);
      else if (resourceDragDelta > 45) moveResourcesByCard(-1, false);
      resourcePointerId = null;
      resourceDragDelta = 0;
      scheduleResourceAutoplay(2200);
    }

    resourceRail.addEventListener("pointerup", finishResourceCoverflowDrag);
    resourceRail.addEventListener("pointercancel", finishResourceCoverflowDrag);
    resourceRail.addEventListener("lostpointercapture", function () {
      if (resourcePointerId !== null) finishResourceCoverflowDrag();
    });
    resourceRail.addEventListener("click", function (event) {
      if (!resourceSuppressClick) return;
      event.preventDefault();
      event.stopPropagation();
      resourceSuppressClick = false;
    }, true);
    if (resourcePrevious) resourcePrevious.addEventListener("click", function () { moveResourcesByCard(-1, true); });
    if (resourceNext) resourceNext.addEventListener("click", function () { moveResourcesByCard(1, true); });
    document.addEventListener("visibilitychange", function () { scheduleResourceAutoplay(2200); });
    renderResourceCoverflow();
    scheduleResourceAutoplay(4800);
  }

  // -- Subtle parallax on ambient orbs (skipped for reduced motion) ----------
  var orbs = document.querySelectorAll(".orb[data-parallax]");
  if (orbs.length && !reduceMotion) {
    var ticking = false;
    window.addEventListener(
      "scroll",
      function () {
        if (ticking) return;
        ticking = true;
        window.requestAnimationFrame(function () {
          var y = window.pageYOffset || 0;
          orbs.forEach(function (orb) {
            var f = parseFloat(orb.getAttribute("data-parallax")) || 0;
            orb.style.transform = "translateY(" + (y * f).toFixed(1) + "px)";
          });
          ticking = false;
        });
      },
      { passive: true }
    );
  }
})();
