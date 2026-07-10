import 'package:image_picker/image_picker.dart';

import 'memory_image.dart';

/// Abstraction over image selection so the picker can be faked in tests.
abstract class MemoryImagePicker {
  /// Returns the picked image, or null if the user cancelled.
  Future<PickedMemoryImage?> pick();
}

/// Default picker backed by the `image_picker` plugin (gallery). Works on
/// mobile and web; reads the file as bytes so no local path is exposed/logged.
class ImagePickerMemoryPicker implements MemoryImagePicker {
  ImagePickerMemoryPicker([ImagePicker? picker])
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<PickedMemoryImage?> pick() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2000,
      imageQuality: 85,
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return PickedMemoryImage(
      bytes: bytes,
      filename: file.name,
      mimeType: file.mimeType,
    );
  }
}
