# NeuroBridge Mobile

نسخة البداية لتطبيق NeuroBridge باستخدام Flutter وDart. يدعم العربية والإنجليزية والفرنسية والإسبانية والألمانية، ويتحوّل تلقائيًا بين RTL وLTR. يحتوي حاليًا على بيانات تجريبية بدون Backend.

## المتطلبات على Windows

1. ثبّت Git وFlutter SDK وAndroid Studio وVS Code.
2. أضف مسار `flutter/bin` إلى متغير Path في Windows.
3. من Android Studio ثبّت Android SDK وأنشئ Android Emulator.
4. شغّل:

```bash
flutter doctor
flutter doctor --android-licenses
```

## تجهيز وتشغيل المشروع

فك ضغط المشروع ثم افتح Terminal داخل مجلد `neurobridge_mobile` وشغّل:

```bash
flutter create .
flutter pub get
flutter run
```

أمر `flutter create .` يولّد مجلدات Android وiOS والمنصات الأخرى دون حذف ملفات `lib` الحالية.

## بيانات الدخول التجريبية

- البريد: `patient@neurobridge.com`
- كلمة المرور: `123456`

زر تسجيل الدخول يعمل محليًا حاليًا ولا يتحقق من البيانات. سنربطه لاحقًا بالـAPI.

## الهوية البصرية

- Cream: `#F4EEE4`
- Gold: `#CBA46E`
- Therapy green: `#568E77`
- Dark brown: `#3F3028`
- Card beige: `#E8DCCB`

جميع الألوان موجودة في `lib/core/theme/app_colors.dart`.

## الخطوة التالية

1. بناء لعبة تذكّر الكلمات فعليًا.
2. بناء لعبة مطابقة البطاقات.
3. إضافة نماذج `User` و`ExerciseResult`.
4. ربط تسجيل الدخول والنتائج مع NeuroBridge API.
5. إضافة حساب المرافق وصلاحياته.

## نظام اللغات

جميع الترجمات موجودة في:

```text
lib/core/localization/app_language.dart
```

قائمة اختيار اللغة موجودة في كل شاشة. لإضافة نص جديد، أضف المفتاح نفسه داخل خرائط اللغات الخمس ثم استخدم `tr('key')` بدل كتابة النص مباشرة.
