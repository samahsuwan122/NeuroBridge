import 'package:flutter/material.dart';

import 'app.dart';
import 'core/localization/locale_controller.dart';
import 'core/network/api_client.dart';
import 'core/storage/secure_storage_service.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/auth/data/auth_api.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/home/application/home_controller.dart';
import 'features/home/data/patient_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = SecureStorageService();
  final apiClient = ApiClient();
  final authRepository = AuthRepository(AuthApi(apiClient), storage);
  final authController = AuthController(authRepository);
  final localeController = LocaleController();
  final homeController = HomeController(PatientApi(apiClient), storage);

  // Resolve initial auth state from any stored token before the first frame.
  await authController.bootstrap();

  runApp(
    NeuroBridgeApp(
      auth: authController,
      locale: localeController,
      home: homeController,
    ),
  );
}
