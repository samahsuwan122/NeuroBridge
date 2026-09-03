import 'package:flutter/material.dart';

import '../../core/services/exercise_service.dart';
import '../../models/exercise.dart';
import '../../widgets/patient_page.dart';
import 'exercise_details_screen.dart';

class ExercisesScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const ExercisesScreen({super.key, this.onBack});
  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  List<Exercise> _exercises = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final items = await ExerciseService.loadExercises();
      if (mounted) setState(() { _exercises = items; _loading = false; });
    } catch (error) {
      if (mounted) setState(() { _error = error.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      body: PatientPage(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconButton(onPressed: widget.onBack ?? () => Navigator.pop(context), icon: const Icon(Icons.arrow_forward_ios_rounded)),
            const Expanded(child: Text('التمارين', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900))),
            IconButton(onPressed: _loading ? null : _load, icon: const Icon(Icons.refresh_rounded)),
          ]),
          const SizedBox(height: 16),
          if (_loading) const Center(child: CircularProgressIndicator())
          else if (_error != null) Center(child: Text(_error!))
          else GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _exercises.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 190,
            ),
            itemBuilder: (_, index) =>
                _ExerciseCard(exercise: _exercises[index]),
          ),
        ]),
      ),
    ),
  );
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  const _ExerciseCard({required this.exercise});
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExerciseDetailsScreen(exercise: exercise))),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(exercise.icon, color: exercise.color), const SizedBox(height: 12),
          Text(exercise.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6), Text(exercise.description, maxLines: 2, overflow: TextOverflow.ellipsis),
          const Spacer(), Text('${exercise.durationMinutes} دقائق · ${exercise.difficultyTitle}'),
        ]),
      ),
    ),
  );
}
