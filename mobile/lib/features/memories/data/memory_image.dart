import 'dart:typed_data';

/// Maximum accepted Memory Album image size (5 MB), matching the backend.
const int kMaxMemoryImageBytes = 5 * 1024 * 1024;

/// Allowed image file extensions (matches the backend allow-list).
const Set<String> kAllowedImageExtensions = {'jpg', 'jpeg', 'png', 'webp'};

/// Allowed image MIME types (matches the backend allow-list).
const Set<String> kAllowedImageMimeTypes = {
  'image/jpeg',
  'image/png',
  'image/webp',
};

/// An image the user picked, held in memory (bytes) so it works on web and
/// mobile. Supportive/family-engagement content only — never analyzed.
class PickedMemoryImage {
  const PickedMemoryImage({
    required this.bytes,
    required this.filename,
    this.mimeType,
  });

  final Uint8List bytes;
  final String filename;
  final String? mimeType;

  /// Lower-case file extension without the dot (empty if none).
  String get extension {
    final dot = filename.lastIndexOf('.');
    return dot == -1 ? '' : filename.substring(dot + 1).toLowerCase();
  }

  bool get isAllowedType {
    final mt = mimeType?.toLowerCase();
    if (mt != null && kAllowedImageMimeTypes.contains(mt)) return true;
    return kAllowedImageExtensions.contains(extension);
  }

  bool get isWithinSize => bytes.length <= kMaxMemoryImageBytes;
}
