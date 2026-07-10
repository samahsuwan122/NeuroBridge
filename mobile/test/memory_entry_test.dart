import 'package:flutter_test/flutter_test.dart';
import 'package:neurobridge_mobile/features/memories/data/memory_entry.dart';

MemoryEntry _entry({String? mediaType, String? mediaUrl}) =>
    MemoryEntry(id: 'm1', title: 't', mediaType: mediaType, mediaUrl: mediaUrl);

void main() {
  const base = 'http://127.0.0.1:8000';

  test('hasImage is true only for an image with a url', () {
    expect(_entry(mediaType: 'image', mediaUrl: '/media/x.png').hasImage, isTrue);
    expect(_entry(mediaType: 'text', mediaUrl: '/media/x.png').hasImage, isFalse);
    expect(_entry(mediaType: 'image', mediaUrl: '').hasImage, isFalse);
    expect(_entry(mediaType: 'image').hasImage, isFalse);
  });

  test('relative /media url is combined with the base url', () {
    final url = _entry(mediaUrl: '/media/memory_uploads/abc.png')
        .resolvedImageUrl(base);
    expect(url, 'http://127.0.0.1:8000/media/memory_uploads/abc.png');
  });

  test('a trailing slash on the base url does not double up', () {
    final url = _entry(mediaUrl: '/media/memory_uploads/abc.png')
        .resolvedImageUrl('$base/');
    expect(url, 'http://127.0.0.1:8000/media/memory_uploads/abc.png');
  });

  test('external http(s) urls are used as-is', () {
    expect(
      _entry(mediaUrl: 'https://cdn.example.com/p.jpg').resolvedImageUrl(base),
      'https://cdn.example.com/p.jpg',
    );
    expect(
      _entry(mediaUrl: 'http://cdn.example.com/p.jpg').resolvedImageUrl(base),
      'http://cdn.example.com/p.jpg',
    );
  });

  test('null or empty media url resolves to null', () {
    expect(_entry().resolvedImageUrl(base), isNull);
    expect(_entry(mediaUrl: '').resolvedImageUrl(base), isNull);
  });
}
