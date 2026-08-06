import 'app_language.dart';

class AppStrings {
  final AppLanguage language;

  const AppStrings(this.language);

  String get title {
    switch (language) {
      case AppLanguage.arabic:
        return 'خطوتك نحو تعافٍ أفضل';

      case AppLanguage.french:
        return 'Votre chemin vers une meilleure récupération';

      case AppLanguage.spanish:
        return 'Tu camino hacia una mejor recuperación';

      case AppLanguage.german:
        return 'Ihr Weg zu einer besseren Genesung';

      case AppLanguage.turkish:
        return 'Daha iyi bir iyileşmeye doğru';

      case AppLanguage.english:
        return 'Your path to better recovery';
    }
  }

  String get description {
    switch (language) {
      case AppLanguage.arabic:
        return 'NeuroBridge منصة ذكية تساعد المرضى وعائلاتهم على متابعة رحلة التأهيل، التمارين والتقدم بطريقة بسيطة وداعمة.';

      case AppLanguage.french:
        return 'NeuroBridge aide les patients et leurs familles à suivre la rééducation, les exercices et les progrès simplement.';

      case AppLanguage.spanish:
        return 'NeuroBridge ayuda a pacientes y familias a seguir la rehabilitación, los ejercicios y el progreso de forma sencilla.';

      case AppLanguage.german:
        return 'NeuroBridge unterstützt Patienten und Familien dabei, Rehabilitation, Übungen und Fortschritte einfach zu verfolgen.';

      case AppLanguage.turkish:
        return 'NeuroBridge, hastaların ve ailelerinin rehabilitasyon sürecini, egzersizleri ve ilerlemeyi kolayca takip etmesine yardımcı olur.';

      case AppLanguage.english:
        return 'NeuroBridge helps patients and their families follow rehabilitation, exercises and progress in a simple and supportive way.';
    }
  }

  String get featuresTitle {
    switch (language) {
      case AppLanguage.arabic:
        return 'كل ما تحتاجه في مكان واحد';

      case AppLanguage.french:
        return 'Tout ce dont vous avez besoin';

      case AppLanguage.spanish:
        return 'Todo lo que necesitas';

      case AppLanguage.german:
        return 'Alles, was Sie brauchen';

      case AppLanguage.turkish:
        return 'İhtiyacınız olan her şey';

      case AppLanguage.english:
        return 'Everything you need in one place';
    }
  }

  String get exercises {
    switch (language) {
      case AppLanguage.arabic:
        return 'تمارين تأهيلية';

      case AppLanguage.french:
        return 'Exercices';

      case AppLanguage.spanish:
        return 'Ejercicios';

      case AppLanguage.german:
        return 'Übungen';

      case AppLanguage.turkish:
        return 'Egzersizler';

      case AppLanguage.english:
        return 'Rehabilitation exercises';
    }
  }

  String get exercisesDescription {
    switch (language) {
      case AppLanguage.arabic:
        return 'تمارين بسيطة للذاكرة والتركيز والقدرات الذهنية.';

      case AppLanguage.french:
        return 'Des exercices simples pour la mémoire et la concentration.';

      case AppLanguage.spanish:
        return 'Ejercicios simples para memoria y concentración.';

      case AppLanguage.german:
        return 'Einfache Übungen für Gedächtnis und Konzentration.';

      case AppLanguage.turkish:
        return 'Hafıza ve odaklanma için basit egzersizler.';

      case AppLanguage.english:
        return 'Simple exercises for memory, focus and cognitive skills.';
    }
  }

  String get progress {
    switch (language) {
      case AppLanguage.arabic:
        return 'متابعة التقدم';

      case AppLanguage.french:
        return 'Suivi des progrès';

      case AppLanguage.spanish:
        return 'Seguimiento';

      case AppLanguage.german:
        return 'Fortschritt';

      case AppLanguage.turkish:
        return 'İlerleme takibi';

      case AppLanguage.english:
        return 'Progress tracking';
    }
  }

  String get progressDescription {
    switch (language) {
      case AppLanguage.arabic:
        return 'شاهد تطور أدائك وإنجازاتك خطوة بخطوة.';

      case AppLanguage.french:
        return 'Suivez vos progrès étape par étape.';

      case AppLanguage.spanish:
        return 'Observa tu progreso paso a paso.';

      case AppLanguage.german:
        return 'Verfolgen Sie Ihren Fortschritt Schritt für Schritt.';

      case AppLanguage.turkish:
        return 'İlerlemenizi adım adım takip edin.';

      case AppLanguage.english:
        return 'See your progress and achievements step by step.';
    }
  }

  String get family {
    switch (language) {
      case AppLanguage.arabic:
        return 'دعم العائلة';

      case AppLanguage.french:
        return 'Soutien familial';

      case AppLanguage.spanish:
        return 'Apoyo familiar';

      case AppLanguage.german:
        return 'Familienunterstützung';

      case AppLanguage.turkish:
        return 'Aile desteği';

      case AppLanguage.english:
        return 'Family support';
    }
  }

  String get familyDescription {
    switch (language) {
      case AppLanguage.arabic:
        return 'ابقَ على تواصل مع الأشخاص الذين يدعمون رحلة تعافيك.';

      case AppLanguage.french:
        return 'Restez connecté avec ceux qui vous accompagnent.';

      case AppLanguage.spanish:
        return 'Mantente conectado con quienes apoyan tu recuperación.';

      case AppLanguage.german:
        return 'Bleiben Sie mit Ihren Unterstützern verbunden.';

      case AppLanguage.turkish:
        return 'İyileşme yolculuğunuzu destekleyen kişilerle bağlantıda kalın.';

      case AppLanguage.english:
        return 'Stay connected with the people supporting your recovery.';
    }
  }

  String get chooseLanguage {
    switch (language) {
      case AppLanguage.arabic:
        return 'اللغة';

      case AppLanguage.french:
        return 'Langue';

      case AppLanguage.spanish:
        return 'Idioma';

      case AppLanguage.german:
        return 'Sprache';

      case AppLanguage.turkish:
        return 'Dil';

      case AppLanguage.english:
        return 'Language';
    }
  }

  String get createAccount {
    switch (language) {
      case AppLanguage.arabic:
        return 'إنشاء حساب';

      case AppLanguage.french:
        return 'Créer un compte';

      case AppLanguage.spanish:
        return 'Crear una cuenta';

      case AppLanguage.german:
        return 'Konto erstellen';

      case AppLanguage.turkish:
        return 'Hesap oluştur';

      case AppLanguage.english:
        return 'Create account';
    }
  }

  String get login {
    switch (language) {
      case AppLanguage.arabic:
        return 'تسجيل الدخول';

      case AppLanguage.french:
        return 'Se connecter';

      case AppLanguage.spanish:
        return 'Iniciar sesión';

      case AppLanguage.german:
        return 'Anmelden';

      case AppLanguage.turkish:
        return 'Giriş yap';

      case AppLanguage.english:
        return 'Sign in';
    }
  }
}