import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/patient_features_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/patient_page.dart';

class EncouragementScreen extends StatefulWidget {
  const EncouragementScreen({super.key});

  @override
  State<EncouragementScreen> createState() =>
      _EncouragementScreenState();
}

class _EncouragementScreenState
    extends State<EncouragementScreen> {
  List<Map<String, dynamic>> messages = [];

  final Set<String> likedMessages = {};

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  String getValue(
    Map<String, dynamic> item,
    String key,
  ) {
    return item[key]?.toString().trim() ?? '';
  }

  Future<void> loadMessages() async {
    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }

    try {
      final result =
          await PatientFeaturesService.loadEncouragements();

      if (!mounted) return;

      setState(() {
        messages = result;
        loading = false;
      });
    } catch (exception) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = exception
            .toString()
            .replaceFirst('Exception: ', '');
      });
    }
  }

  String formatTime(String value) {
    final DateTime? date =
        DateTime.tryParse(value)?.toLocal();

    if (date == null) {
      return value;
    }

    final Duration difference =
        DateTime.now().difference(date);

    if (difference.inMinutes < 1) {
      return 'الآن';
    }

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    }

    if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    }

    if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    }

    final String month =
        date.month.toString().padLeft(2, '0');

    final String day =
        date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  String senderFirstLetter(String senderName) {
    if (senderName.trim().isEmpty) {
      return 'ع';
    }

    return senderName.trim().substring(0, 1);
  }

  Future<void> openMedia(String mediaUrl) async {
    final Uri? uri = Uri.tryParse(mediaUrl);

    if (uri == null) {
      showMessage('رابط الملف غير صحيح');
      return;
    }

    final bool opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      showMessage('تعذر فتح الملف');
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget buildMediaButton({
    required Map<String, dynamic> message,
    required IconData icon,
    required String label,
  }) {
    final String mediaUrl =
        getValue(message, 'media_url');

    return InkWell(
      onTap: () {
        openMedia(mediaUrl);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E8DA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(
              Icons.open_in_new_rounded,
              size: 17,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMedia(
    Map<String, dynamic> message,
  ) {
    final String mediaType =
        getValue(message, 'media_type');

    final String mediaUrl =
        getValue(message, 'media_url');

    if (mediaUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    if (mediaType == 'image') {
      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.network(
            mediaUrl,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            loadingBuilder: (
              context,
              child,
              loadingProgress,
            ) {
              if (loadingProgress == null) {
                return child;
              }

              return const SizedBox(
                height: 250,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return buildMediaButton(
                message: message,
                icon: Icons.broken_image_outlined,
                label: 'فتح الصورة',
              );
            },
          ),
        ),
      );
    }

    if (mediaType == 'video') {
      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: buildMediaButton(
          message: message,
          icon: Icons.play_circle_fill_rounded,
          label: 'تشغيل الفيديو',
        ),
      );
    }

    if (mediaType == 'voice') {
      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: buildMediaButton(
          message: message,
          icon: Icons.play_arrow_rounded,
          label: 'تشغيل الرسالة الصوتية',
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget buildMessageCard(
    Map<String, dynamic> message,
  ) {
    final String id = getValue(message, 'id');

    final String senderName =
        getValue(message, 'sender_name').isEmpty
            ? 'العائلة'
            : getValue(message, 'sender_name');

    final String messageText =
        getValue(message, 'message');

    final String caption =
        getValue(message, 'caption');

    final String createdAt =
        getValue(message, 'created_at');

    final bool liked =
        likedMessages.contains(id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: NeuroCard(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor:
                      const Color(0xFFF1E7D8),
                  child: Text(
                    senderFirstLetter(senderName),
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        senderName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        formatTime(createdAt),
                        style: const TextStyle(
                          fontSize: 10,
                          color:
                              AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFFD59A8A),
                ),
              ],
            ),

            if (messageText.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                messageText,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.7,
                  color: AppColors.textPrimary,
                ),
              ),
            ],

            buildMedia(message),

            if (caption.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                caption,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],

            const SizedBox(height: 10),

            TextButton.icon(
              onPressed: () {
                setState(() {
                  if (liked) {
                    likedMessages.remove(id);
                  } else {
                    likedMessages.add(id);
                  }
                });
              },
              icon: Icon(
                liked
                    ? Icons.favorite_rounded
                    : Icons.favorite_outline_rounded,
                color: AppColors.primary,
                size: 19,
              ),
              label: Text(
                liked
                    ? 'أرسلت قلبًا'
                    : 'إرسال قلب',
                style: const TextStyle(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildError() {
    return NeuroCard(
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 44,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 10),
          Text(
            error ?? 'تعذر تحميل الرسائل',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: loadMessages,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label: const Text(
              'إعادة المحاولة',
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmpty() {
    return const NeuroCard(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 25,
        ),
        child: Column(
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 50,
              color: AppColors.primary,
            ),
            SizedBox(height: 12),
            Text(
              'لا توجد رسائل تشجيع بعد',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 7),
            Text(
              'ستظهر هنا الرسائل والصور التي ترسلها عائلتك.',
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              if (loading)
                const LinearProgressIndicator(
                  minHeight: 2,
                ),

              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'رسائل التشجيع',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'تحديث',
                    onPressed:
                        loading ? null : loadMessages,
                    icon: const Icon(
                      Icons.refresh_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              const Text(
                'رسائل وصور جميلة من الأشخاص الذين يدعمونك ❤️',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              if (loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50),
                    child:
                        CircularProgressIndicator(),
                  ),
                )
              else if (error != null)
                buildError()
              else if (messages.isEmpty)
                buildEmpty()
              else
                ...messages.map(buildMessageCard),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}