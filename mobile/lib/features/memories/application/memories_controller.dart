import 'package:flutter/foundation.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../../home/data/patient_api.dart';
import '../data/memories_api.dart';
import '../data/memory_entry.dart';
import '../data/memory_image.dart';
import '../data/memory_image_picker.dart';

enum MemoriesStatus { initial, loading, loaded, empty, error }

enum MemoryCreateStatus { idle, submitting, success, error }

/// Result of submitting the Add Memory form.
enum MemorySubmitResult { success, createFailed, imageUploadFailed }

/// Why a picked image was rejected client-side (before any upload).
enum MemoryImageError { unsupportedType, tooLarge }

/// Loads the caller's Memory Album entries, creates new ones, and uploads an
/// optional real image.
///
/// Never throws to the UI and never logs tokens or local file paths. Missing
/// token/profile or backend errors map to safe states.
class MemoriesController extends ChangeNotifier {
  MemoriesController(
    this._api,
    this._patientApi,
    this._storage, [
    MemoryImagePicker? picker,
  ]) : _picker = picker ?? ImagePickerMemoryPicker();

  final MemoriesApi _api;
  final PatientApi _patientApi;
  final SecureStorageService _storage;
  final MemoryImagePicker _picker;

  MemoriesStatus _status = MemoriesStatus.initial;
  List<MemoryEntry> _memories = const [];
  MemoryCreateStatus _createStatus = MemoryCreateStatus.idle;
  PickedMemoryImage? _selectedImage;
  MemoryImageError? _imageError;

  MemoriesStatus get status => _status;
  List<MemoryEntry> get memories => _memories;
  MemoryCreateStatus get createStatus => _createStatus;
  PickedMemoryImage? get selectedImage => _selectedImage;
  MemoryImageError? get imageError => _imageError;

  Future<void> load() async {
    _status = MemoriesStatus.loading;
    notifyListeners();
    try {
      final token = await _storage.readAccessToken();
      if (token == null || token.isEmpty) {
        _status = MemoriesStatus.error;
        notifyListeners();
        return;
      }
      _memories = await _api.listMemories(token);
      _status =
          _memories.isEmpty ? MemoriesStatus.empty : MemoriesStatus.loaded;
    } catch (_) {
      _status = MemoriesStatus.error;
    }
    notifyListeners();
  }

  /// Pick an image from the gallery and validate it client-side. A cancelled
  /// pick is a no-op; an unsupported type or oversized file sets [imageError].
  Future<void> pickImage() async {
    try {
      final picked = await _picker.pick();
      if (picked == null) return; // cancelled
      if (!picked.isAllowedType) {
        _selectedImage = null;
        _imageError = MemoryImageError.unsupportedType;
        notifyListeners();
        return;
      }
      if (!picked.isWithinSize) {
        _selectedImage = null;
        _imageError = MemoryImageError.tooLarge;
        notifyListeners();
        return;
      }
      _selectedImage = picked;
      _imageError = null;
      notifyListeners();
    } catch (_) {
      // Never crash the UI because the picker failed.
    }
  }

  void clearSelectedImage() {
    _selectedImage = null;
    _imageError = null;
    notifyListeners();
  }

  /// Create a memory for the caller's first visible patient profile, then (if
  /// an image is selected) upload it.
  ///
  /// Returns [MemorySubmitResult.success] when everything succeeds,
  /// [MemorySubmitResult.createFailed] (with [createStatus] == error) if the
  /// memory could not be created, or [MemorySubmitResult.imageUploadFailed] if
  /// the memory was created but the image upload failed (the memory is kept).
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
    _createStatus = MemoryCreateStatus.submitting;
    notifyListeners();
    try {
      final token = await _storage.readAccessToken();
      if (token == null || token.isEmpty) {
        _createStatus = MemoryCreateStatus.error;
        notifyListeners();
        return MemorySubmitResult.createFailed;
      }
      final profiles = await _patientApi.listPatients(token);
      if (profiles.isEmpty) {
        _createStatus = MemoryCreateStatus.error;
        notifyListeners();
        return MemorySubmitResult.createFailed;
      }
      final created = await _api.createMemory(
        token: token,
        patientProfileId: profiles.first.id,
        title: title,
        description: description,
        personName: personName,
        relationship: relationship,
        placeName: placeName,
        memoryDate: memoryDate,
        category: category,
        mediaType: mediaType,
        mediaUrl: mediaUrl,
      );

      final image = _selectedImage;
      if (image != null) {
        try {
          await _api.uploadMemoryImage(
            token: token,
            memoryId: created.id,
            image: image,
          );
        } catch (_) {
          // The memory was created; only the image failed.
          _selectedImage = null;
          _createStatus = MemoryCreateStatus.success;
          notifyListeners();
          await load();
          return MemorySubmitResult.imageUploadFailed;
        }
      }

      _selectedImage = null;
      _createStatus = MemoryCreateStatus.success;
      notifyListeners();
      // Refresh the list so the new memory is visible when returning.
      await load();
      return MemorySubmitResult.success;
    } catch (_) {
      _createStatus = MemoryCreateStatus.error;
      notifyListeners();
      return MemorySubmitResult.createFailed;
    }
  }

  /// Reset transient create state (e.g. when opening the Add Memory form).
  void resetCreate() {
    _createStatus = MemoryCreateStatus.idle;
    _selectedImage = null;
    _imageError = null;
    notifyListeners();
  }
}
