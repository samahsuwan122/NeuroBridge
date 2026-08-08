import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

// البداية
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';

// Auth
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/verification_code_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/password_changed_screen.dart';

// Legal
import 'screens/terms_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/medical_disclaimer_screen.dart';

// Help + main
import 'screens/main_shell.dart';
import 'screens/help_center_screen.dart';
import 'screens/ai_assistant_screen.dart';

// Patient
import 'screens/patient/patient_home_screen.dart';
import 'screens/patient/today_plan_screen.dart';
import 'screens/patient/exercises_screen.dart';
import 'screens/patient/daily_session_screen.dart';
import 'screens/patient/word_recall_screen.dart';
import 'screens/patient/card_matching_screen.dart';
import 'screens/patient/event_ordering_screen.dart';
import 'screens/patient/picture_recognition_screen.dart';
import 'screens/patient/spot_difference_screen.dart';
import 'screens/patient/categorization_screen.dart';
import 'screens/patient/sequence_screen.dart';
import 'screens/patient/audio_memory_screen.dart';
import 'screens/patient/emotion_recognition_screen.dart';
import 'screens/patient/break_screen.dart';
import 'screens/patient/progress_screen.dart';
import 'screens/patient/activity_history_screen.dart';
import 'screens/patient/achievements_screen.dart';
import 'screens/patient/memory_tree_screen.dart';
import 'screens/patient/memory_album_screen.dart';
import 'screens/patient/patient_family_screen.dart';
import 'screens/patient/encouragement_screen.dart';
import 'screens/patient/appointments_screen.dart';
import 'screens/patient/daily_check_in_screen.dart';
import 'screens/patient/patient_profile_screen.dart';
import 'screens/patient/accessibility_screen.dart';
import 'screens/patient/assistance_screen.dart';

// Caregiver
import 'screens/caregiver/caregiver_home_screen.dart';
import 'screens/caregiver/patient_switcher_screen.dart';
import 'screens/caregiver/link_patient_screen.dart';
import 'screens/caregiver/connection_requests_screen.dart';
import 'screens/caregiver/patient_summary_screen.dart';
import 'screens/caregiver/patient_activity_screen.dart';
import 'screens/caregiver/family_progress_screen.dart';
import 'screens/caregiver/send_encouragement_screen.dart';
import 'screens/caregiver/family_memory_album_screen.dart';
import 'screens/caregiver/add_memory_screen.dart';
import 'screens/caregiver/family_appointments_screen.dart';
import 'screens/caregiver/reminder_management_screen.dart';
import 'screens/caregiver/caregiver_alerts_screen.dart';
import 'screens/caregiver/caregiver_guide_screen.dart';
import 'screens/caregiver/caregiver_wellbeing_screen.dart';
import 'screens/caregiver/family_permissions_screen.dart';
import 'screens/caregiver/caregiver_profile_screen.dart';

void main() {
  runApp(const NeuroBridgeApp());
}

class NeuroBridgeApp extends StatelessWidget {
  const NeuroBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NeuroBridge',
      theme: AppTheme.light,

      // أول شاشة
      initialRoute: '/',

      routes: {
        // ============================
        // Start / Auth
        // ============================
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/role-selection': (context) =>
            const RoleSelectionScreen(),
        '/login': (context) => const LoginScreen(),

        // RegisterScreen يحتاج role
        '/register-patient': (context) =>
            const RegisterScreen(role: 'patient'),
        '/register-family': (context) =>
            const RegisterScreen(role: 'family'),

        '/forgot-password': (context) =>
            const ForgotPasswordScreen(),

        // هذه الشاشة تحتاج email
        '/verification': (context) =>
            const VerificationCodeScreen(
              email: 'patient@neurobridge.com',
            ),

        '/reset-password': (context) =>
            const ResetPasswordScreen(),
        '/password-changed': (context) =>
            const PasswordChangedScreen(),

        // ============================
        // Legal
        // ============================
        '/terms': (context) => const TermsScreen(),
        '/privacy': (context) =>
            const PrivacyPolicyScreen(),
        '/medical-disclaimer': (context) =>
            const MedicalDisclaimerScreen(),

        // ============================
        // Main / Help
        // ============================
        '/main': (context) => const MainShell(),
        '/help': (context) => const HelpCenterScreen(),
        '/ai': (context) => const AiAssistantScreen(),

        // ============================
        // Patient
        // ============================
        '/patient-home': (context) =>
            const PatientHomeScreen(),
        '/today-plan': (context) =>
            const TodayPlanScreen(),
        '/exercises': (context) =>
            const ExercisesScreen(),
        '/daily-session': (context) =>
            const DailySessionScreen(),

        '/word-recall': (context) =>
            const WordRecallScreen(),
        '/card-matching': (context) =>
            const CardMatchingScreen(),
        '/event-ordering': (context) =>
            const EventOrderingScreen(),
        '/picture-recognition': (context) =>
            const PictureRecognitionScreen(),
        '/spot-difference': (context) =>
            const SpotDifferenceScreen(),
        '/categorization': (context) =>
            const CategorizationScreen(),
        '/sequence': (context) =>
            const SequenceScreen(),
        '/audio-memory': (context) =>
            const AudioMemoryScreen(),
        '/emotion-recognition': (context) =>
            const EmotionRecognitionScreen(),

        '/break': (context) => const BreakScreen(),

        '/progress': (context) =>
            const ProgressScreen(),
        '/activity-history': (context) =>
            const ActivityHistoryScreen(),
        '/achievements': (context) =>
            const AchievementsScreen(),

        '/memory-tree': (context) =>
            const MemoryTreeScreen(),
        '/memory-album': (context) =>
            const MemoryAlbumScreen(),

        '/patient-family': (context) =>
            const PatientFamilyScreen(),
        '/encouragement': (context) =>
            const EncouragementScreen(),

        '/appointments': (context) =>
            const AppointmentsScreen(),

        '/daily-check-in': (context) =>
            const DailyCheckInScreen(),

        '/patient-profile': (context) =>
            const PatientProfileScreen(),
        '/accessibility': (context) =>
            const AccessibilityScreen(),
        '/assistance': (context) =>
            const AssistanceScreen(),

        // ============================
        // Caregiver
        // ============================
        '/caregiver-home': (context) =>
            const CaregiverHomeScreen(),

        '/patient-switcher': (context) =>
            const PatientSwitcherScreen(),

        '/link-patient': (context) =>
            const LinkPatientScreen(),

        '/connection-requests': (context) =>
            const ConnectionRequestsScreen(),

        '/patient-summary': (context) =>
            const PatientSummaryScreen(),

        '/patient-activity': (context) =>
            const PatientActivityScreen(),

        '/family-progress': (context) =>
            const FamilyProgressScreen(),

        '/send-encouragement': (context) =>
            const SendEncouragementScreen(),

        '/family-memory-album': (context) =>
            const FamilyMemoryAlbumScreen(),

        '/add-memory': (context) =>
            const AddMemoryScreen(),

        '/family-appointments': (context) =>
            const FamilyAppointmentsScreen(),

        '/reminders': (context) =>
            const ReminderManagementScreen(),

        '/caregiver-alerts': (context) =>
            const CaregiverAlertsScreen(),

        '/caregiver-guide': (context) =>
            const CaregiverGuideScreen(),

        '/caregiver-wellbeing': (context) =>
            const CaregiverWellbeingScreen(),

        '/family-permissions': (context) =>
            const FamilyPermissionsScreen(),

        '/caregiver-profile': (context) =>
            const CaregiverProfileScreen(),
      },

      // لو حاول التطبيق يفتح route غير موجود
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
      },
    );
  }
}