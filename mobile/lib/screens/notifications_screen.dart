import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/services/notification_service.dart';
import '../core/localization/patient_i18n.dart';
import '../core/theme/app_colors.dart';
import '../widgets/patient_page.dart';

class UserNotificationsScreen extends StatefulWidget {
  const UserNotificationsScreen({super.key});
  @override State<UserNotificationsScreen> createState() => _UserNotificationsScreenState();
}

class _UserNotificationsScreenState extends State<UserNotificationsScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];
  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try { final rows = await NotificationService.load(); if (mounted) setState(() => _items = rows); }
    catch (e) { if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', '')); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _open(Map<String, dynamic> item) async {
    try {
      await NotificationService.markRead(int.parse(item['id'].toString()));
      final url = item['action_url']?.toString() ?? '';
      if (url.isNotEmpty) await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      await _load();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))));
    }
  }

  @override Widget build(BuildContext context) => Directionality(
    textDirection: context.patientI18n.isRtl ? TextDirection.rtl : TextDirection.ltr,
    child: Scaffold(
      body: PatientPage(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Builder(builder: (context) {
          final scheme = Theme.of(context).colorScheme;
          final dark = Theme.of(context).brightness == Brightness.dark;
          return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(color: dark ? const Color(0xFF241B16) : AppColors.surface.withValues(alpha: .88), borderRadius: BorderRadius.circular(24), border: Border.all(color: dark ? const Color(0xFF5A4031) : AppColors.borderStrong)),
          child: Row(children: [
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(context.tr('notifications'), style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: scheme.onSurface)),
              const SizedBox(height: 3),
              Text(context.tr('notificationSubtitle'), style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
            ])),
            Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.secondarySoft, borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.notifications_active_outlined, color: AppColors.primary)),
            IconButton(tooltip: 'تحديد الكل كمقروء', onPressed: () async { await NotificationService.markAllRead(); await _load(); }, icon: const Icon(Icons.done_all_rounded)),
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
          ]),
        ); }),
        const SizedBox(height: 18),
        if (_loading) const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
        else if (_error != null) NeuroCard(child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error)))
        else if (_items.isEmpty) NeuroCard(child: Padding(padding: const EdgeInsets.symmetric(vertical: 36), child: Column(children: [const Icon(Icons.notifications_none_rounded, size: 48, color: AppColors.secondaryDark), const SizedBox(height: 12), Text(context.tr('noNotifications'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))])))
        else ..._items.map((item) {
          final unread = item['read_at'] == null;
          final hasUrl = (item['action_url']?.toString() ?? '').isNotEmpty;
          final dark = Theme.of(context).brightness == Brightness.dark;
          final scheme = Theme.of(context).colorScheme;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NeuroCard(
              onTap: () => _open(item),
              color: unread
                  ? (dark ? const Color(0xFF38281F) : AppColors.secondarySoft)
                  : (dark ? const Color(0xFF241B16) : AppColors.surface),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 50, height: 50, decoration: BoxDecoration(color: unread ? AppColors.primary : AppColors.surfaceMuted, borderRadius: BorderRadius.circular(16)), child: Icon(Icons.videocam_outlined, color: unread ? Colors.white : AppColors.primary)),
                const SizedBox(width: 13),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item['title']?.toString() ?? '', style: TextStyle(fontSize: 16, fontWeight: unread ? FontWeight.w900 : FontWeight.w700, color: scheme.onSurface)),
                  const SizedBox(height: 6),
                  Text(item['body']?.toString() ?? '', style: TextStyle(height: 1.55, color: scheme.onSurfaceVariant)),
                  if (hasUrl) ...[const SizedBox(height: 10), Text(context.tr('openSession'), style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w800))],
                ])),
                if (unread) Container(width: 9, height: 9, decoration: const BoxDecoration(color: AppColors.secondaryDark, shape: BoxShape.circle)),
              ]),
            ),
          );
        }),
      ])),
    ),
  );
}
