(function () {
  "use strict";

  var mode = "signin", role = "patient", step = "form";
  var fields = document.getElementById("authFields"), form = document.getElementById("publicAccessForm");
  var notice = document.getElementById("adminNotice"), forgot = document.getElementById("forgotRow");
  var title = document.getElementById("authTitle"), eyebrow = document.getElementById("authEyebrow");
  var lead = document.getElementById("authLead"), submitLabel = document.getElementById("submitLabel");

  function tr(key, fallback) {
    var lang = document.documentElement.lang || "en";
    var dictionary = window.NB_I18N && window.NB_I18N[lang];
    return lang !== "en" && dictionary && dictionary[key] != null ? dictionary[key] : fallback;
  }

  function input(name, labelKey, label, type, autocomplete, wide) {
    return '<label class="' + (wide ? "is-wide" : "") + '"><span>' + tr(labelKey, label) +
      '</span><input name="' + name + '" type="' + type + '" autocomplete="' + autocomplete + '" required></label>';
  }

  function sync() {
    document.querySelectorAll("[data-auth-mode]").forEach(function (button) {
      var active = button.dataset.authMode === mode;
      button.classList.toggle("is-active", active);
      button.setAttribute("aria-selected", String(active));
    });
    document.querySelectorAll("[data-role]").forEach(function (button) {
      button.classList.toggle("is-selected", button.dataset.role === role);
    });
  }

  function patientMobile() {
    var creating = mode === "register";
    eyebrow.textContent = creating ? tr("access.patientCreateEyebrow", "Create your patient account") : tr("access.patientEyebrow", "Patient access");
    title.textContent = creating ? tr("access.patientCreateTitle", "Continue registration in the mobile app.") : tr("access.patientTitle", "Continue in the NeuroBridge mobile app.");
    lead.textContent = creating ? tr("access.patientCreateLead", "Patient registration and verification continue securely in the NeuroBridge mobile application.") : tr("access.patientLead", "A calm mobile experience created around the patient’s daily care journey.");
    fields.innerHTML = '<div class="public-auth__patient-mobile is-wide"><span class="public-auth__mobile-orbit" aria-hidden="true"><span class="public-auth__mobile-icon"><svg viewBox="0 0 24 24"><rect x="6.5" y="2.5" width="11" height="19" rx="2.3"/><path d="M10 5.5h4m-3 12.5h2"/><circle cx="12" cy="11.5" r="2.4"/><path d="M8.8 16c.4-1.7 1.5-2.6 3.2-2.6s2.8.9 3.2 2.6"/></svg></span></span>' +
      '<span class="public-auth__mobile-label">' + tr("access.mobileOnly", "Mobile-only patient experience") + '</span><h3>' + tr("access.mobileTitle", "Your care journey, gently within reach.") + '</h3><p>' + tr("access.mobileText", "Daily cognitive practice, appointments, memories, family encouragement, and progress follow-up live together in the NeuroBridge Patient App.") + '</p><div><a href="patients.html">' + tr("access.explorePatient", "Explore the Patient App") + '</a><a href="index.html">' + tr("access.backHome", "Back to home") + '</a></div><small>' + tr("access.mobileSecure", "Secure access continues on your mobile device.") + '</small></div>';
    forgot.hidden = true; notice.hidden = true;
    form.querySelector(".public-auth__primary").hidden = true;
    form.querySelector(".public-auth__handoff").hidden = true;
  }

  function otp() {
    eyebrow.textContent = tr("access.verifyEyebrow", "Verify your email");
    title.textContent = tr("access.verifyTitle", "One secure step.");
    lead.innerHTML = tr("access.verifyLead", "We sent a 6-digit verification code to:") + "<br><strong>s***@example.com</strong>";
    fields.innerHTML = '<div class="public-auth__otp is-wide">' + Array(6).fill('<input inputmode="numeric" maxlength="1" aria-label="' + tr("access.verificationDigit", "Verification digit") + '">').join("") + '</div><p class="public-auth__resend is-wide">' + tr("access.resend", "Resend code in 00:42") + "</p>";
    forgot.hidden = true; notice.hidden = true; submitLabel.textContent = tr("access.verifyEmail", "Verify email");
    var boxes = [].slice.call(fields.querySelectorAll(".public-auth__otp input"));
    boxes.forEach(function (box, index) {
      box.addEventListener("input", function () { box.value = box.value.replace(/\D/g, "").slice(-1); if (box.value && boxes[index + 1]) boxes[index + 1].focus(); });
      box.addEventListener("keydown", function (event) { if (event.key === "Backspace" && !box.value && boxes[index - 1]) boxes[index - 1].focus(); });
      box.addEventListener("paste", function (event) { var code = event.clipboardData.getData("text").replace(/\D/g, "").slice(0, 6); if (!code) return; event.preventDefault(); boxes.forEach(function (item, number) { item.value = code[number] || ""; }); });
    });
  }

  function pending() {
    eyebrow.textContent = tr("access.verifiedEyebrow", "Email verified"); title.textContent = tr("access.pendingTitle", "Pending approval.");
    lead.textContent = tr("access.pendingLead", "Your professional access is awaiting administrator approval.");
    fields.innerHTML = '<div class="public-auth__pending is-wide"><span class="public-auth__pending-icon" aria-hidden="true">✓</span><dl><div><dt>' + tr("access.status", "Status") + '</dt><dd>' + tr("access.pending", "Pending approval") + '</dd></div><div><dt>' + tr("access.role", "Role") + '</dt><dd>' + (role === "doctor" ? tr("access.doctor", "Doctor") : tr("access.therapist", "Therapist")) + '</dd></div><div><dt>' + tr("access.email", "Email") + '</dt><dd>s***@example.com</dd></div></dl><div><button type="button" data-back-signin>' + tr("access.backSignin", "Back to sign in") + '</button><a href="index.html">' + tr("access.backHome", "Back to home") + '</a></div></div>';
    forgot.hidden = true; notice.hidden = true;
    form.querySelector(".public-auth__primary").hidden = true; form.querySelector(".public-auth__handoff").hidden = true;
    fields.querySelector("[data-back-signin]").onclick = function () { mode = "signin"; step = "form"; render(); };
  }

  function render() {
    sync(); form.querySelector(".public-auth__primary").hidden = false; form.querySelector(".public-auth__handoff").hidden = false;
    if (step === "otp") return otp(); if (step === "pending") return pending();
    var registering = mode === "register"; notice.hidden = !(registering && role === "admin"); forgot.hidden = registering;
    eyebrow.textContent = registering ? tr("access.begin", "Begin securely") : tr("access.welcome", "Welcome back");
    title.textContent = registering ? tr("access.createTitle", "Create your account.") : tr("access.signinTitle", "Enter your secure space.");
    lead.textContent = registering ? tr("access.createLead", "A few details, then we’ll verify your email.") : tr("access.signinLead", "Choose your role and continue to the right NeuroBridge experience.");
    if (!registering || role === "admin") {
      fields.innerHTML = input("email", "access.email", "Email", "email", "username", true) + input("password", "access.password", "Password", "password", "current-password", true);
      submitLabel.textContent = tr("access.signin", "Sign in"); return;
    }
    var professional = role === "doctor" || role === "therapist";
    var html = input("full_name", "access.fullName", "Full name", "text", "name") + input("email", professional ? "access.professionalEmail" : "access.email", professional ? "Professional email" : "Email", "email", "email") + input("phone", "access.phone", "Phone", "tel", "tel");
    if (role === "patient") html += input("date_of_birth", "access.birthDate", "Date of birth", "date", "bday");
    if (professional) html += input("specialty", "access.specialty", "Specialty", "text", "organization-title");
    html += input("password", "access.password", "Password", "password", "new-password") + input("confirm", "access.confirmPassword", "Confirm password", "password", "new-password"); fields.innerHTML = html;
    submitLabel.textContent = role === "patient" ? tr("access.createPatient", "Create patient account") : role === "family" ? tr("access.createFamily", "Create family account") : tr("access.continueVerify", "Continue to verification");
  }

  document.querySelectorAll("[data-auth-mode]").forEach(function (button) { button.onclick = function () { mode = button.dataset.authMode; step = "form"; render(); if (role === "patient") patientMobile(); }; });
  document.querySelectorAll("[data-role]").forEach(function (button) { button.onclick = function () { role = button.dataset.role; step = "form"; render(); if (role === "patient") patientMobile(); }; });
  form.onsubmit = function (event) { event.preventDefault(); if (role === "patient") return; if (step === "otp") { step = role === "doctor" || role === "therapist" ? "pending" : "form"; if (step === "form") mode = "signin"; render(); return; } if (mode === "register" && role !== "admin") { step = "otp"; render(); return; } form.classList.add("is-previewed"); setTimeout(function () { form.classList.remove("is-previewed"); }, 650); };
  document.addEventListener("nb:languagechange", function () { render(); if (role === "patient" && step === "form") patientMobile(); });
  render(); patientMobile();
})();
