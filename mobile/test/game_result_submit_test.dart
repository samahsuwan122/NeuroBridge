import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neurobridge_mobile/core/network/api_client.dart';
import 'package:neurobridge_mobile/core/storage/secure_storage_service.dart';
import 'package:neurobridge_mobile/features/games/application/game_result_controller.dart';
import 'package:neurobridge_mobile/features/games/data/game_results_api.dart';
import 'package:neurobridge_mobile/features/home/data/patient_api.dart';
import 'package:neurobridge_mobile/features/home/data/patient_profile_summary.dart';

class _FakeResultsApi extends GameResultsApi {
  _FakeResultsApi({this.shouldThrow = false}) : super(ApiClient());

  final bool shouldThrow;
  bool called = false;
  Map<String, Object?> captured = {};

  @override
  Future<void> submitResult({
    required String token,
    required String gameId,
    required String patientProfileId,
    required int score,
    required int maxScore,
    required int durationSeconds,
    required bool completed,
    required Map<String, dynamic> metrics,
  }) async {
    if (shouldThrow) throw Exception('network');
    called = true;
    captured = {
      'gameId': gameId,
      'patientProfileId': patientProfileId,
      'score': score,
      'maxScore': maxScore,
      'durationSeconds': durationSeconds,
      'completed': completed,
      'metrics': metrics,
    };
  }
}

class _FakePatientApi extends PatientApi {
  _FakePatientApi(this.profiles) : super(ApiClient());
  final List<PatientProfileSummary> profiles;
  @override
  Future<List<PatientProfileSummary>> listPatients(String token) async =>
      profiles;
}

class _FakeStorage extends SecureStorageService {
  _FakeStorage(this.token);
  final String? token;
  @override
  Future<String?> readAccessToken() async => token;
}

/// Captures the raw payload sent to the backend.
class _CapturingApiClient extends ApiClient {
  String? lastPath;
  String? lastToken;
  Map<String, dynamic>? lastData;

  @override
  Future<Response<dynamic>> postJson(
    String path,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    lastPath = path;
    lastToken = token;
    lastData = data;
    return Response<dynamic>(
      requestOptions: RequestOptions(path: path),
      statusCode: 201,
      data: <String, dynamic>{},
    );
  }
}

void main() {
  const profile = PatientProfileSummary(id: 'profile-1');
  const metrics = <String, dynamic>{
    'moves': 6,
    'mistakes': 0,
    'matched_pairs': 6,
    'total_pairs': 6,
  };

  test('submits performance payload and reaches saved', () async {
    final api = _FakeResultsApi();
    final controller = GameResultController(
      api,
      _FakePatientApi([profile]),
      _FakeStorage('token-123'),
    );
    await controller.submit(
      gameId: 'game-1',
      score: 6,
      maxScore: 6,
      durationSeconds: 12,
      completed: true,
      metrics: metrics,
    );
    expect(controller.status, SubmitStatus.saved);
    expect(api.called, isTrue);
    expect(api.captured['patientProfileId'], 'profile-1');
    expect(api.captured['score'], 6);
    expect(api.captured['metrics'], metrics);
  });

  test('missing token sets error and does not call the api', () async {
    final api = _FakeResultsApi();
    final controller = GameResultController(
      api,
      _FakePatientApi([profile]),
      _FakeStorage(null),
    );
    await controller.submit(
      gameId: 'g',
      score: 6,
      maxScore: 6,
      durationSeconds: 1,
      completed: true,
      metrics: metrics,
    );
    expect(controller.status, SubmitStatus.error);
    expect(api.called, isFalse);
  });

  test('no visible profile sets error', () async {
    final api = _FakeResultsApi();
    final controller = GameResultController(
      api,
      _FakePatientApi(const []),
      _FakeStorage('t'),
    );
    await controller.submit(
      gameId: 'g',
      score: 6,
      maxScore: 6,
      durationSeconds: 1,
      completed: true,
      metrics: metrics,
    );
    expect(controller.status, SubmitStatus.error);
    expect(api.called, isFalse);
  });

  test('backend error sets error state safely', () async {
    final controller = GameResultController(
      _FakeResultsApi(shouldThrow: true),
      _FakePatientApi([profile]),
      _FakeStorage('t'),
    );
    await controller.submit(
      gameId: 'g',
      score: 6,
      maxScore: 6,
      durationSeconds: 1,
      completed: true,
      metrics: metrics,
    );
    expect(controller.status, SubmitStatus.error);
  });

  test('submitted payload contains performance fields only (no diagnosis)',
      () async {
    final client = _CapturingApiClient();
    await GameResultsApi(client).submitResult(
      token: 't',
      gameId: 'g1',
      patientProfileId: 'p1',
      score: 6,
      maxScore: 6,
      durationSeconds: 12,
      completed: true,
      metrics: metrics,
    );
    expect(client.lastPath, '/games/g1/results');
    expect(client.lastToken, 't');

    final data = client.lastData!;
    expect(data.keys.toSet(), {
      'patient_profile_id',
      'score',
      'max_score',
      'duration_seconds',
      'completed',
      'metrics',
    });
    const forbidden = ['diagnosis', 'disease', 'dementia', 'alzheimer', 'interpretation'];
    for (final key in data.keys) {
      expect(forbidden.any((f) => key.toLowerCase().contains(f)), isFalse);
    }
    expect(
      (data['metrics'] as Map).keys.toSet(),
      {'moves', 'mistakes', 'matched_pairs', 'total_pairs'},
    );
  });
}
