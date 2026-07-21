/* NeuroBridge — public website
   Progressive enhancement only. With JavaScript disabled, all content remains
   fully visible and usable (chips/links work, FAQ uses native <details>, the
   SVG illustration fallbacks show, and the Join form falls back to a mailto). */
(function () {
  "use strict";

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
      ".nav__links a", ".eyebrow", ".hero__sub-headline", ".lead",
      ".section__sub", "h2", ".mini-title", ".chip", ".btn", ".hero__note",
      ".hero__trust span", ".feat-chips span", ".mod h3", ".mod p", ".mtag",
      ".plat-card__body h3", ".ticks li", ".dash__head h3", ".tag", ".cm",
      ".quote", ".dash__note", ".ap-approve", ".pcard__spec", ".pcard__demo",
      ".pill", ".fbtn", ".dir-note", ".tree-note b", ".tree-note small",
      ".notice", ".card h3", ".card p", ".step h3", ".step p", ".game-card h3",
      ".game-card p", ".game-card__badge", ".quote-card blockquote",
      ".quote-card__who", ".quote-card__role", ".story-card figcaption h3",
      ".story-card figcaption p", ".vcard__cap b", ".vcard__cap span",
      ".fam__hero-cap b", ".fam__hero-cap span", ".join-card h3", ".join-card p",
      ".join-form h3", ".jf-legal", ".faq summary", ".faq p", ".cta p",
      ".cta__note", ".dev-card__role", ".footer__brand p", ".footer__proto",
      ".footer__col h4", ".footer__col a", ".footer__legal p"
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
    var phs = ["siteSearch", "jfName", "jfEmail", "jfOrg", "jfGov", "jfMsg"]
      .map(function (id) {
        var e = document.getElementById(id);
        return e ? { e: e, k: norm(e.getAttribute("placeholder")), o: e.getAttribute("placeholder") } : null;
      }).filter(Boolean);
    var opts = [];
    var roleSel = document.getElementById("jfRole");
    if (roleSel) Array.prototype.forEach.call(roleSel.options, function (o) {
      opts.push({ e: o, k: norm(o.textContent), o2: o.textContent });
    });

    var tr = function (lang, key) { return (DICT[lang] && DICT[lang][key]) || null; };

    function apply(lang) {
      if (LANGS.indexOf(lang) === -1) lang = "en";
      var h = document.documentElement;
      h.setAttribute("lang", lang);
      h.setAttribute("dir", lang === "ar" ? "rtl" : "ltr");
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
      var lbl = document.getElementById("langBtnLabel");
      if (lbl) lbl.textContent = CODE[lang] || lang.toUpperCase();
      document.querySelectorAll(".lang-opt").forEach(function (b) {
        var on = b.getAttribute("data-lang") === lang;
        b.classList.toggle("is-active", on);
        if (on) b.setAttribute("aria-current", "true"); else b.removeAttribute("aria-current");
      });
      try { localStorage.setItem("nb_lang", lang); } catch (e) {}
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
    { name: "Memory Tree", target: "#memory", hint: "Growing memories" },
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

  // -- Join form: build a mailto (no accounts, no localStorage) --------------
  if (joinForm) {
    joinForm.addEventListener("submit", function (e) {
      e.preventDefault();
      var val = function (id) {
        var el = document.getElementById(id);
        return el ? el.value.trim() : "";
      };
      var name = val("jfName");
      var email = val("jfEmail");
      var role = val("jfRole");
      if (!name || !email || !role) {
        if (jfNote) jfNote.textContent = "Please fill in your name, email, and role.";
        return;
      }
      var lines = [
        "Name: " + name,
        "Email: " + email,
        "Role: " + role,
        "Organization / clinic: " + (val("jfOrg") || "-"),
        "Governorate: " + (val("jfGov") || "-"),
        "",
        "Message:",
        val("jfMsg") || "-",
        "",
        "— Sent from the NeuroBridge prototype website (no account created)."
      ];
      var subject = "NeuroBridge access request — " + role;
      var mailto =
        "mailto:neurobridge.demo@example.com" +
        "?subject=" + encodeURIComponent(subject) +
        "&body=" + encodeURIComponent(lines.join("\n"));
      window.location.href = mailto;
      if (jfNote) {
        jfNote.textContent =
          "Opening your email app… If nothing happens, email neurobridge.demo@example.com.";
      }
    });
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
