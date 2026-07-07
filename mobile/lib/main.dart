import 'package:flutter/material.dart';

import 'app.dart';
import 'core/localization/locale_controller.dart';
import 'core/network/api_client.dart';
import 'core/storage/secure_storage_service.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/auth/data/auth_api.dart';
import 'features/auth/data/auth_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = SecureStorageService();
  final apiClient = ApiClient();
  final authRepository = AuthRepository(AuthApi(apiClient), storage);
  final authController = AuthController(authRepository);
  final localeController = LocaleController();

  // Resolve initial auth state from any stored token before the first frame.
  await authController.bootstrap();

  runApp(
    NeuroBridgeApp(auth: authController, locale: localeController),
  );
}
