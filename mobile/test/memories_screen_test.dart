import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:neurobridge_mobile/core/app_scope.dart';
import 'package:neurobridge_mobile/core/localization/app_localizations.dart';
import 'package:neurobridge_mobile/core/localization/locale_controller.dart';
import 'package:neurobridge_mobile/core/network/api_client.dart';
import 'package:neurobridge_mobile/core/storage/secure_storage_service.dart';
import 'package:neurobridge_mobile/features/auth/application/auth_controller.dart';
import 'package:neurobridge_mobile/features/auth/data/auth_api.dart';
import 'package:neurobridge_mobile/features/auth/data/auth_repository.dart';
import 'package:neurobridge_mobile/features/games/application/game_result_controller.dart';
import 'package:neurobridge_mobile/features/games/application/games_controller.dart';
import 'package:neurobridge_mobile/features/games/data/game_results_api.dart';
import 'package:neurobridge_mobile/features/games/data/games_api.dart';
import 'package:neurobridge_mobile/features/home/application/home_controller.dart';
import 'package:neurobridge_mobile/features/home/data/patient_api.dart';
import 'package:neurobridge_mobile/features/memories/application/memories_controller.dart';
import 'package:neurobridge_mobile/features/memories/data/memories_api.dart';
import 'package:neurobridge_mobile/features/memories/data/memory_entry.dart';
import 'package:neurobridge_mobile/features/memories/data/memory_image.dart';
import 'package:neurobridge_mobile/features/memories/presentation/memories_screen.dart';
import 'package:neurobridge_mobile/features/memories/presentation/memory_create_screen.dart';
import 'package:neurobridge_mobile/features/memories/presentation/memory_details_screen.dart';
import 'package:neurobridge_mobile/features/memories/presentation/memory_image_view.dart';
import 'package:neurobridge_mobile/features/profile/application/profile_controller.dart';
import 'package:neurobridge_mobile/features/profile/data/profile_api.dart';
import 'package:neurobridge_mobile/features/progress/application/progress_controller.dart';
import 'package:neurobridge_mobile/features/progress/data/progress_api.dart';

/// Memories controller with a fixed status/list and no network.
class _FakeMemories extends MemoriesController {
  _FakeMemories(this._status, [this._memories = const []])
      : super(
          MemoriesApi(ApiClient()),
          PatientApi(ApiClient()),
          SecureStorageService(),
        );

  final MemoriesStatus _status;
  final List<MemoryEntry> _memories;

  /// Configurable create outcome (no network in tests).
  MemorySubmitResult submitResult = MemorySubmitResult.success;
  bool createCalled = false;
  MemoryCreateStatus _createStatusValue = MemoryCreateStatus.idle;
  PickedMemoryImage? selectedImageValue;

  @override
  MemoriesStatus get status => _status;
  @override
  List<MemoryEntry> get memories => _memories;
  @override
  MemoryCreateStatus get createStatus => _createStatusValue;
  @override
  PickedMemoryImage? get selectedImage => selectedImageValue;
  @override
  Future<void> load() async {}

  @override
  Future<MemorySubmitResult> createMemory({
    required String title,
    String? description,
    String? personName,
    String? relationship,
    String? placeName,
    String? memoryDate,
    String? category,
    String? mediaType,
    String? mediaUrl,
  }) async {
    createCalled = true;
    _createStatusValue = submitResult == MemorySubmitResult.createFailed
        ? MemoryCreateStatus.error
        : MemoryCreateStatus.success;
    notifyListeners();
    return submitResult;
  }
}

PickedMemoryImage _sampleImage() => PickedMemoryImage(
      bytes: Uint8List.fromList(const [1, 2, 3]),
      filename: 'pic.png',
      mimeType: 'image/png',
    );

ApiClient _c() => ApiClient();

Future<void> _wrap(
  WidgetTester tester,
  Widget child, {
  MemoriesController? memories,
}) async {
  final storage = SecureStorageService();
  await tester.pumpWidget(
    AppScope(
      auth: AuthController(AuthRepository(AuthApi(_c()), storage)),
      locale: LocaleController(),
      home: HomeController(PatientApi(_c()), storage),
      games: GamesController(GamesApi(_c()), storage),
      gameResults: GameResultController(
        GameResultsApi(_c()),
        PatientApi(_c()),
        storage,
      ),
      progress: ProgressController(ProgressApi(_c()), GamesApi(_c()), storage),
      profile: ProfileController(ProfileApi(_c()), storage),
      memories: memories ?? _FakeMemories(MemoriesStatus.empty),
      child: MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: child,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Router-based harness for flows that navigate (Add button, create → back).
Future<void> _pumpRouter(
  WidgetTester tester, {
  required MemoriesController memories,
  required String initialLocation,
}) async {
  final storage = SecureStorageService();
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/memories', builder: (c, s) => const MemoriesScreen()),
      GoRoute(
          path: '/memories/new', builder: (c, s) => const MemoryCreateScreen()),
    ],
  );
  await tester.pumpWidget(
    AppScope(
      auth: AuthController(AuthRepository(AuthApi(_c()), storage)),
      locale: LocaleController(),
      home: HomeController(PatientApi(_c()), storage),
      games: GamesController(GamesApi(_c()), storage),
      gameResults: GameResultController(
        GameResultsApi(_c()),
        PatientApi(_c()),
        storage,
      ),
      progress: ProgressController(ProgressApi(_c()), GamesApi(_c()), storage),
      profile: ProfileController(ProfileApi(_c()), storage),
      memories: memories,
      child: MaterialApp.router(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

MemoryEntry _sample() => MemoryEntry(
      id: 'm1',
      title: 'Family picnic at the park',
      description: 'A sunny afternoon by the lake with the whole family.',
      personName: 'Layla',
      relationship: 'daughter',
      placeName: 'City Park',
      memoryDate: DateTime(2020, 6, 1),
      category: 'family',
      mediaType: 'text',
      createdAt: DateTime(2026, 7, 10),
    );

void main() {
  testWidgets('memory album shows a friendly empty state', (tester) async {
    await _wrap(tester, const MemoriesScreen(),
        memories: _FakeMemories(MemoriesStatus.empty));
    expect(find.text('No memories yet.'), findsOneWidget);
  });

  testWidgets('memory album renders a memory card', (tester) async {
    await _wrap(
      tester,
      const MemoriesScreen(),
      memories: _FakeMemories(MemoriesStatus.loaded, [_sample()]),
    );
    expect(find.text('Family picnic at the park'), findsOneWidget);
    expect(find.textContaining('Layla'), findsOneWidget);
    expect(find.text('City Park'), findsOneWidget);
  });

  testWidgets('memory album error state shows a retry button', (tester) async {
    await _wrap(tester, const MemoriesScreen(),
        memories: _FakeMemories(MemoriesStatus.error));
    expect(
      find.text('Could not load memories. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('memory details shows the memory fields', (tester) async {
    await _wrap(tester, MemoryDetailsScreen(memory: _sample()));
    expect(find.text('Family picnic at the park'), findsOneWidget);
    expect(find.textContaining('sunny afternoon'), findsOneWidget);
    expect(find.text('Person'), findsOneWidget);
    expect(find.text('Layla'), findsOneWidget);
    expect(find.text('Relationship'), findsOneWidget);
    expect(find.text('Place'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Media type'), findsOneWidget);
  });

  testWidgets('memory album shows the supportive-only safe note',
      (tester) async {
    await _wrap(
      tester,
      const MemoriesScreen(),
      memories: _FakeMemories(MemoriesStatus.loaded, [_sample()]),
    );
    expect(
      find.textContaining('supportive recall activities only'),
      findsOneWidget,
    );
  });

  testWidgets('memory screens contain no diagnosis/medical text',
      (tester) async {
    await _wrap(tester, MemoryDetailsScreen(memory: _sample()));
    for (final word in [
      'diagnosis',
      'disease',
      'dementia',
      'alzheimer',
      'interpretation'
    ]) {
      expect(find.textContaining(word), findsNothing);
      expect(find.textContaining(word.toUpperCase()), findsNothing);
    }
  });

  // --- Add Memory form (Step 3B) ---------------------------------------------

  testWidgets('album shows an Add memory button', (tester) async {
    await _wrap(tester, const MemoriesScreen(),
        memories: _FakeMemories(MemoriesStatus.empty));
    expect(find.text('Add memory'), findsOneWidget);
  });

  testWidgets('add memory form renders', (tester) async {
    await _wrap(tester, const MemoryCreateScreen());
    expect(find.text('Title'), findsWidgets);
    expect(find.text('Description'), findsWidgets);
    expect(find.text('Save memory'), findsOneWidget);
    expect(find.textContaining('supportive recall activities only'),
        findsOneWidget);
  });

  testWidgets('add memory requires a title', (tester) async {
    final fake = _FakeMemories(MemoriesStatus.empty);
    await _wrap(tester, const MemoryCreateScreen(), memories: fake);
    await tester.ensureVisible(find.text('Save memory'));
    await tester.tap(find.text('Save memory'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a title.'), findsOneWidget);
    expect(fake.createCalled, isFalse); // validation blocked the call
  });

  testWidgets('create failure shows a friendly error', (tester) async {
    final fake = _FakeMemories(MemoriesStatus.empty)
      ..submitResult = MemorySubmitResult.createFailed;
    await _wrap(tester, const MemoryCreateScreen(), memories: fake);
    await tester.enterText(find.widgetWithText(TextFormField, 'Title').first,
        'Family picnic');
    await tester.ensureVisible(find.text('Save memory'));
    await tester.tap(find.text('Save memory'));
    await tester.pumpAndSettle();
    expect(fake.createCalled, isTrue);
    expect(
      find.text('Could not save the memory. Please try again.'),
      findsOneWidget,
    );
  });

  // --- Image upload (Step 18B) -----------------------------------------------

  testWidgets('create form shows a Choose image button and requirements',
      (tester) async {
    await _wrap(tester, const MemoryCreateScreen());
    expect(find.text('Choose image'), findsOneWidget);
    expect(find.textContaining('up to 5 MB'), findsOneWidget);
  });

  testWidgets('selected image shows its name and Change image', (tester) async {
    final fake = _FakeMemories(MemoriesStatus.empty)
      ..selectedImageValue = _sampleImage();
    await _wrap(tester, const MemoryCreateScreen(), memories: fake);
    expect(find.text('Change image'), findsOneWidget);
    expect(find.textContaining('pic.png'), findsOneWidget);
  });

  testWidgets('image upload failure after create shows a friendly message',
      (tester) async {
    final fake = _FakeMemories(MemoriesStatus.empty)
      ..submitResult = MemorySubmitResult.imageUploadFailed
      ..selectedImageValue = _sampleImage();
    await _pumpRouter(tester, memories: fake, initialLocation: '/memories/new');
    await tester.enterText(find.widgetWithText(TextFormField, 'Title').first,
        'Family picnic');
    await tester.ensureVisible(find.text('Save memory'));
    await tester.tap(find.text('Save memory'));
    await tester.pumpAndSettle();
    expect(fake.createCalled, isTrue);
    // Memory kept: returned to the album with a friendly message.
    expect(find.text('No memories yet.'), findsOneWidget);
    expect(
      find.textContaining('image could not be uploaded'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('list shows an Image attached chip for image memories',
      (tester) async {
    final imageMemory = MemoryEntry(
      id: 'm2',
      title: 'Beach day',
      mediaType: 'image',
      mediaUrl: '/media/memory_uploads/abc.png',
    );
    await _wrap(
      tester,
      const MemoriesScreen(),
      memories: _FakeMemories(MemoriesStatus.loaded, [imageMemory]),
    );
    expect(find.text('Image attached'), findsOneWidget);
  });

  testWidgets('Add memory button navigates to the form', (tester) async {
    await _pumpRouter(
      tester,
      memories: _FakeMemories(MemoriesStatus.empty),
      initialLocation: '/memories',
    );
    await tester.tap(find.text('Add memory'));
    await tester.pumpAndSettle();
    expect(find.text('Save memory'), findsOneWidget); // on the create screen
  });

  testWidgets('successful create returns to the album', (tester) async {
    final fake = _FakeMemories(MemoriesStatus.empty); // createResult = true
    await _pumpRouter(
      tester,
      memories: fake,
      initialLocation: '/memories/new',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Title').first,
        'Family picnic');
    await tester.ensureVisible(find.text('Save memory'));
    await tester.tap(find.text('Save memory'));
    await tester.pumpAndSettle();
    expect(fake.createCalled, isTrue);
    // Back on the album (empty state), not on the form.
    expect(find.text('No memories yet.'), findsOneWidget);
    expect(find.text('Save memory'), findsNothing);
    // Let the success SnackBar auto-dismiss timer elapse (avoids a pending
    // timer at teardown).
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  // --- Image display (Step 18C) ----------------------------------------------

  testWidgets('memory card with an image renders the image view',
      (tester) async {
    await _withMockedImages(() async {
      await _wrap(
        tester,
        const MemoriesScreen(),
        memories: _FakeMemories(MemoriesStatus.loaded, [_imageMemory()]),
      );
      expect(find.byType(MemoryImageView), findsOneWidget);
    });
  });

  testWidgets('memory card without an image renders the icon placeholder',
      (tester) async {
    await _wrap(
      tester,
      const MemoriesScreen(),
      memories: _FakeMemories(MemoriesStatus.loaded, [_sample()]),
    );
    expect(find.byType(MemoryImageView), findsNothing);
  });

  testWidgets('details with an image renders a large image view',
      (tester) async {
    await _withMockedImages(() async {
      await _wrap(tester, MemoryDetailsScreen(memory: _imageMemory()));
      expect(find.byType(MemoryImageView), findsOneWidget);
    });
  });

  testWidgets('details without an image renders an elegant placeholder',
      (tester) async {
    await _wrap(tester, MemoryDetailsScreen(memory: _sample()));
    expect(find.byType(MemoryImageView), findsNothing);
    expect(find.text('No image attached'), findsOneWidget);
  });
}

MemoryEntry _imageMemory() => MemoryEntry(
      id: 'm2',
      title: 'Beach day',
      mediaType: 'image',
      mediaUrl: '/media/memory_uploads/abc.png',
    );

/// A 1x1 PNG so mocked `Image.network` responses decode successfully.
final List<int> _kPngBytes = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
  0x00, 0x00, 0x03, 0x00, 0x01, 0x2A, 0x22, 0x4A, 0x99, 0x00, 0x00, 0x00,
  0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

/// Runs [body] with all `Image.network` requests served a tiny local PNG, so
/// image tests never touch the real network.
Future<void> _withMockedImages(Future<void> Function() body) {
  return HttpOverrides.runZoned(
    body,
    createHttpClient: (context) => _FakeHttpClient(),
  );
}

class _FakeHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpClientRequest();
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeHttpClientRequest implements HttpClientRequest {
  @override
  HttpHeaders get headers => _FakeHttpHeaders();
  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse();
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => _kPngBytes.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable(<List<int>>[_kPngBytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
