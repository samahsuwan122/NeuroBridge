import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:neurobridge_mobile/core/network/api_client.dart';
import 'package:neurobridge_mobile/core/storage/secure_storage_service.dart';
import 'package:neurobridge_mobile/features/home/data/patient_api.dart';
import 'package:neurobridge_mobile/features/home/data/patient_profile_summary.dart';
import 'package:neurobridge_mobile/features/memories/application/memories_controller.dart';
import 'package:neurobridge_mobile/features/memories/data/memories_api.dart';
import 'package:neurobridge_mobile/features/memories/data/memory_entry.dart';
import 'package:neurobridge_mobile/features/memories/data/memory_image.dart';
import 'package:neurobridge_mobile/features/memories/data/memory_image_picker.dart';

/// Records API calls and lets tests control the upload outcome. No network.
class _RecordingApi extends MemoriesApi {
  _RecordingApi() : super(ApiClient());

  final List<String> calls = [];
  bool failUpload = false;

  @override
  Future<List<MemoryEntry>> listMemories(String token) async => const [];

  @override
  Future<MemoryEntry> createMemory({
    required String token,
    required String patientProfileId,
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
    calls.add('create');
    return MemoryEntry(id: 'm1', title: title);
  }

  @override
  Future<MemoryEntry> uploadMemoryImage({
    required String token,
    required String memoryId,
    required PickedMemoryImage image,
  }) async {
    calls.add('upload');
    if (failUpload) throw Exception('upload failed');
    return MemoryEntry(
      id: memoryId,
      title: 'm',
      mediaType: 'image',
      mediaUrl: '/media/memory_uploads/x.png',
    );
  }
}

class _FakeStorage extends SecureStorageService {
  @override
  Future<String?> readAccessToken() async => 'token';
}

class _FakePatientApi extends PatientApi {
  _FakePatientApi() : super(ApiClient());
  @override
  Future<List<PatientProfileSummary>> listPatients(String token) async =>
      const [PatientProfileSummary(id: 'p1')];
}

class _FakePicker implements MemoryImagePicker {
  PickedMemoryImage? next;
  @override
  Future<PickedMemoryImage?> pick() async => next;
}

PickedMemoryImage _png() => PickedMemoryImage(
      bytes: Uint8List.fromList(const [1, 2, 3]),
      filename: 'pic.png',
      mimeType: 'image/png',
    );

MemoriesController _controller(_RecordingApi api, _FakePicker picker) =>
    MemoriesController(api, _FakePatientApi(), _FakeStorage(), picker);

void main() {
  test('create without an image calls create only', () async {
    final api = _RecordingApi();
    final c = _controller(api, _FakePicker());
    final result = await c.createMemory(title: 'A day out');
    expect(result, MemorySubmitResult.success);
    expect(api.calls, ['create']);
  });

  test('create with an image calls create then upload', () async {
    final api = _RecordingApi();
    final picker = _FakePicker()..next = _png();
    final c = _controller(api, picker);
    await c.pickImage();
    expect(c.selectedImage, isNotNull);
    final result = await c.createMemory(title: 'A day out');
    expect(result, MemorySubmitResult.success);
    expect(api.calls, ['create', 'upload']); // ordering matters
    expect(c.selectedImage, isNull); // cleared after success
  });

  test('image upload failure keeps the created memory', () async {
    final api = _RecordingApi()..failUpload = true;
    final picker = _FakePicker()..next = _png();
    final c = _controller(api, picker);
    await c.pickImage();
    final result = await c.createMemory(title: 'A day out');
    expect(result, MemorySubmitResult.imageUploadFailed);
    expect(api.calls, ['create', 'upload']); // create succeeded, upload tried
  });

  test('an unsupported image is rejected before any upload', () async {
    final api = _RecordingApi();
    final picker = _FakePicker()
      ..next = PickedMemoryImage(
        bytes: Uint8List.fromList(const [1]),
        filename: 'note.txt',
        mimeType: 'text/plain',
      );
    final c = _controller(api, picker);
    await c.pickImage();
    expect(c.selectedImage, isNull);
    expect(c.imageError, MemoryImageError.unsupportedType);
  });

  test('an oversized image is rejected before any upload', () async {
    final api = _RecordingApi();
    final big = Uint8List(kMaxMemoryImageBytes + 1);
    final picker = _FakePicker()
      ..next = PickedMemoryImage(
          bytes: big, filename: 'big.png', mimeType: 'image/png');
    final c = _controller(api, picker);
    await c.pickImage();
    expect(c.selectedImage, isNull);
    expect(c.imageError, MemoryImageError.tooLarge);
  });
}
