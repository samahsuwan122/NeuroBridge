import 'package:flutter/material.dart';

/// لوحة ألوان NeuroBridge — بيج/ذهبي دافئ (بدون أخضر وبدون زهري)
/// الأسماء القديمة (green, brown, surface...) موجودة هون كـ "أسماء توافقية"
/// حتى ما تضطري تعدّلي كل شاشة، بس قيمها صارت من نفس عائلة الذهبي/البيج.
class AppColors {
  AppColors._();

  // ===== الألوان الأساسية الجديدة =====
  static const Color gold       = Color(0xFFB68A46); // اللون الأساسي - ذهبي دافئ
  static const Color goldDark   = Color(0xFF8B6239); // نهاية تدرّج الزر / تركيز
  static const Color goldLight  = Color(0xFFE7D2A8); // توهج/خلفيات فاتحة
  static const Color cream      = Color(0xFFF7EFE2); // خلفية الشاشة
  static const Color cardCream  = Color(0xFFFBF7EF); // خلفية البطاقات
  static const Color borderTan  = Color(0xFFE3D5B8); // حدود
  static const Color brownDeep  = Color(0xFF4A3B2A); // نص أساسي
  static const Color brownMuted = Color(0xFF8A7860); // نص ثانوي
  static const Color beige      = Color(0xFFEFE0BE); // خلفيات الأيقونات/البطاقات البيج
  static const Color errorRed   = Color(0xFFC0564D); // لون التنبيه/الخطأ

  // ===== أسماء توافقية مع الشاشات الحالية =====
  // (بدل ما تعدّلي كل استدعاء AppColors.green بكل شاشة، هي بس بتوجّه لنفس لون الذهبي)
  static const Color green      = gold;       // كان أخضر، صار ذهبي
  static const Color greenLight = goldLight;  // كان أخضر فاتح، صار ذهبي فاتح
  static const Color surface    = cardCream;  // خلفية العناصر/الحقول
  static const Color background = cream;      // خلفية الشاشة العامة
  static const Color brown      = brownDeep;  // النص الأساسي
  static const Color mutedBrown = brownMuted; // النص الثانوي
  static const Color border     = borderTan;  // لون الحدود
  static const Color cardBeige  = beige;      // خلفية بطاقات/شعار
  static const Color error      = errorRed;   // لون الخطأ

  static const Color coldPink = Color(0xFFFFF8FA);
static const Color coldPink2 = Color(0xFFFCEFF3);
static const Color coldPink3 = Color(0xFFF7E7EC);

static const Color rose = Color(0xFFC98291);
static const Color roseDark = Color(0xFF9D6170);

static const Color softWhite = Color(0xFFFFFCFD);
static const Color textDark = Color(0xFF4E3D3A);
static const Color textMuted = Color(0xFF8B7975);
}