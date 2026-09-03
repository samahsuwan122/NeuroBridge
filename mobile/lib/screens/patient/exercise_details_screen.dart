import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/exercise.dart';
import '../../widgets/patient_page.dart';
import 'exercise_play_resolver.dart';

class ExerciseDetailsScreen extends StatelessWidget {
  final Exercise exercise;
  const ExerciseDetailsScreen({super.key, required this.exercise});
  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(body: PatientPage(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
      const SizedBox(height: 18),
      Center(child: Container(width: 105, height: 105, decoration: BoxDecoration(color: exercise.color.withValues(alpha: .13), shape: BoxShape.circle), child: Icon(exercise.icon, size: 50, color: exercise.color))),
      const SizedBox(height: 20),
      Center(child: Text(exercise.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary))),
      const SizedBox(height: 7), Center(child: Text(exercise.description, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary))),
      if (exercise.sourceTitle.isNotEmpty) ...[const SizedBox(height: 9), Center(child: Chip(avatar: Icon(exercise.source == 'ai' ? Icons.auto_awesome_rounded : Icons.admin_panel_settings_outlined, size: 17), label: Text(exercise.sourceTitle)))],
      const SizedBox(height: 24),
      NeuroCard(child: _TextSection(title: 'الهدف العام', text: exercise.goal)), const SizedBox(height: 12),
      NeuroCard(child: _TextSection(title: 'التعليمات', text: exercise.instructions)), const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _InfoBox(icon: Icons.signal_cellular_alt_rounded, label: 'المستوى', value: exercise.difficultyTitle)), const SizedBox(width: 10),
        Expanded(child: _InfoBox(icon: Icons.schedule_rounded, label: 'المدة', value: '${exercise.durationMinutes} دقائق')), const SizedBox(width: 10),
        Expanded(child: _InfoBox(icon: Icons.volume_up_outlined, label: 'الصوت', value: exercise.soundEnabled ? 'متاح' : 'غير مطلوب')),
      ]), const SizedBox(height: 24),
      SizedBox(width: double.infinity, height: 58, child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), onPressed: exercise.type == ExerciseType.unsupported ? null : () => Navigator.push(context, exercisePlayRoute(exercise)), icon: const Icon(Icons.play_arrow_rounded), label: Text(exercise.type == ExerciseType.unsupported ? 'هذا المحرك غير متوفر بعد' : 'ابدأ التمرين', style: const TextStyle(fontWeight: FontWeight.w900)))),
    ]))));
  }
}

class _TextSection extends StatelessWidget {
  final String title; final String text;
  const _TextSection({required this.title, required this.text});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary)), const SizedBox(height: 7), Text(text.isEmpty ? 'لا توجد تفاصيل إضافية.' : text, style: const TextStyle(height: 1.7, color: AppColors.textSecondary))]);
}

class _InfoBox extends StatelessWidget {
  final IconData icon; final String label; final String value;
  const _InfoBox({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .75), borderRadius: BorderRadius.circular(17), border: Border.all(color: AppColors.border)), child: Column(children: [Icon(icon, size: 20, color: AppColors.primary), const SizedBox(height: 6), Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)), const SizedBox(height: 3), Text(value, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimary))]));
}
