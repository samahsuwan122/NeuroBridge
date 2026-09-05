import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../core/services/caregiver_features_service.dart';
import '../../widgets/caregiver_ui.dart';

class SendEncouragementScreen extends StatefulWidget {
  const SendEncouragementScreen({super.key});

  @override
  State<SendEncouragementScreen> createState() =>
      _SendEncouragementScreenState();
}

class _SendEncouragementScreenState extends State<SendEncouragementScreen> {
  final TextEditingController controller = TextEditingController();
  final AudioRecorder _recorder = AudioRecorder();

  final templates = const [
    'نحن فخورون بك ❤️',
    'أحسنت جلسة اليوم 🌷',
    'خذ وقتك، أنت تقوم بعمل رائع.',
    'سعيدون بتقدّمك.',
  ];

  String emoji = '❤️';
  Uint8List? _mediaBytes;
  String? _mediaName;
  String? _mediaType;
  bool _recording = false;
  bool _saving = false;
  DateTime? _recordingStartedAt;
  int? _voiceDuration;

  @override
  void dispose() {
    controller.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1800,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _mediaBytes = bytes;
      _mediaName = file.name;
      _mediaType = 'image';
      _voiceDuration = null;
    });
  }

  Future<void> _toggleRecording() async {
    try {
      if (_recording) {
        final path = await _recorder.stop();
        if (path == null) return;
        final bytes = await File(path).readAsBytes();
        final seconds = DateTime.now()
            .difference(_recordingStartedAt ?? DateTime.now())
            .inSeconds;
        if (!mounted) return;
        setState(() {
          _recording = false;
          _mediaBytes = bytes;
          _mediaName = path.split(Platform.pathSeparator).last;
          _mediaType = 'voice';
          _voiceDuration = seconds < 1 ? 1 : seconds;
        });
        return;
      }

      if (!await _recorder.hasPermission()) {
        throw Exception('يجب السماح للتطبيق باستخدام الميكروفون');
      }
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/encouragement_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
      if (mounted) {
        setState(() {
          _recording = true;
          _recordingStartedAt = DateTime.now();
          _mediaBytes = null;
          _mediaName = null;
          _mediaType = null;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  void _removeMedia() {
    setState(() {
      _mediaBytes = null;
      _mediaName = null;
      _mediaType = null;
      _voiceDuration = null;
    });
  }

  Future<void> _send() async {
    final text = controller.text.trim();
    if (text.isEmpty && _mediaBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتبي رسالة أو أضيفي صورة أو تسجيلًا صوتيًا')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final message = text.isEmpty ? emoji : '$text $emoji';
      final result = await CaregiverFeaturesService.sendEncouragement(
        message: message.trim(),
        media: _mediaBytes,
        mediaName: _mediaName,
        mediaType: _mediaType,
        mediaDuration: _voiceDuration,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']?.toString() ?? 'تم إرسال التشجيع ❤️')),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _review() async {
    if (_recording) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أوقفي التسجيل الصوتي أولًا')),
      );
      return;
    }
    if (controller.text.trim().isEmpty && _mediaBytes == null) {
      await _send();
      return;
    }
    final attachment = _mediaType == 'image'
        ? '\n\n📷 صورة مرفقة'
        : _mediaType == 'voice'
            ? '\n\n🎙️ تسجيل صوتي (${_voiceDuration ?? 0} ثانية)'
            : '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('مراجعة الرسالة'),
          content: Text('${controller.text.trim()}\n\n$emoji$attachment'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('تعديل'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('إرسال'),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) await _send();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CaregiverPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CaregiverHeader(
                title: 'إرسال تشجيع',
                subtitle: 'ستصل الرسالة إلى المريض المحدد حاليًا.',
              ),
              const SizedBox(height: 25),
              const Text('رسائل جاهزة', style: TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: templates.map((message) => ActionChip(
                  label: Text(message),
                  onPressed: () => setState(() => controller.text = message),
                )).toList(),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                maxLength: 180,
                maxLines: 4,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'رسالتك',
                  hintText: 'اكتب رسالة قصيرة...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                ),
              ),
              const SizedBox(height: 10),
              const Text('رمز تعبيري', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['❤️', '🌷', '👏', '😊', '⭐'].map((item) => ChoiceChip(
                  selected: emoji == item,
                  label: Text(item, style: const TextStyle(fontSize: 20)),
                  onSelected: (_) => setState(() => emoji = item),
                )).toList(),
              ),
              if (_mediaBytes != null) ...[
                const SizedBox(height: 14),
                CaregiverCard(
                  child: Row(
                    children: [
                      Icon(_mediaType == 'image' ? Icons.image : Icons.mic),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_mediaType == 'image'
                          ? 'تم إرفاق صورة'
                          : 'تم تسجيل ${_voiceDuration ?? 0} ثانية')),
                      IconButton(onPressed: _removeMedia, icon: const Icon(Icons.close)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _recording ? null : _pickImage,
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('إضافة صورة'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _toggleRecording,
                      icon: Icon(_recording ? Icons.stop_circle_outlined : Icons.mic_none_rounded),
                      label: Text(_recording ? 'إيقاف التسجيل' : 'تسجيل صوتي'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: CaregiverColors.brown),
                  onPressed: _saving ? null : _review,
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('مراجعة قبل الإرسال', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
