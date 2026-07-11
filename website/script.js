/* NeuroBridge AI — landing website
   Progressive enhancement only. With JavaScript disabled, all content remains
   fully visible and the page stays usable. */
(function () {
  "use strict";

  // Mark that JS is active so reveal animations can start hidden.
  document.body.classList.add("js-reveal");

  // -- Mobile navigation toggle --
  var toggle = document.getElementById("navToggle");
  var links = document.getElementById("navLinks");
  if (toggle && links) {
    toggle.addEventListener("click", function () {
      var open = links.classList.toggle("open");
      toggle.classList.toggle("open", open);
      toggle.setAttribute("aria-expanded", open ? "true" : "false");
    });
    // Close the menu after tapping a link (mobile).
    links.querySelectorAll("a").forEach(function (a) {
      a.addEventListener("click", function () {
        links.classList.remove("open");
        toggle.classList.remove("open");
        toggle.setAttribute("aria-expanded", "false");
      });
    });
  }

  // -- Reveal-on-scroll --
  var reveals = document.querySelectorAll(".reveal");
  if ("IntersectionObserver" in window && reveals.length) {
    var io = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            entry.target.classList.add("in");
            io.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.12, rootMargin: "0px 0px -40px 0px" }
    );
    reveals.forEach(function (el) { io.observe(el); });
  } else {
    // Fallback: show everything.
    reveals.forEach(function (el) { el.classList.add("in"); });
  }

  // -- FAQ: keep only one item open at a time --
  var faq = document.querySelectorAll(".faq details");
  faq.forEach(function (item) {
    item.addEventListener("toggle", function () {
      if (item.open) {
        faq.forEach(function (other) {
          if (other !== item) other.open = false;
        });
      }
    });
  });
})();
