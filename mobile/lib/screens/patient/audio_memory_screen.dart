import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/localization/patient_i18n.dart';
import '../../widgets/patient_page.dart';
import 'exercise_result_screen.dart';

class AudioMemoryScreen extends StatefulWidget {
  const AudioMemoryScreen({super.key});

  @override
  State<AudioMemoryScreen> createState() => _AudioMemoryScreenState();
}

class _AudioMemoryScreenState extends State<AudioMemoryScreen> {
  final FlutterTts _tts = FlutterTts();
  final Stopwatch _stopwatch = Stopwatch();

  static const _rounds = <_AudioRound>[
    _AudioRound(
      words: ['كتاب', 'شجرة', 'قمر'],
      options: [
        'كتاب، شجرة، قمر',
        'كتاب، سيارة، قمر',
        'بحر، شجرة، ساعة',
      ],
    ),
    _AudioRound(
      words: ['تفاحة', 'باب', 'ساعة'],
      options: [
        'تفاحة، كرسي، ساعة',
        'تفاحة، باب، ساعة',
        'برتقالة، باب، قلم',
      ],
    ),
    _AudioRound(
      words: ['بحر', 'وردة', 'مفتاح'],
      options: [
        'بحر، وردة، مفتاح',
        'نهر، وردة، كتاب',
        'بحر، شجرة، مفتاح',
      ],
    ),
    _AudioRound(
      words: ['سيارة', 'قلم', 'نافذة'],
      options: [
        'دراجة، قلم، نافذة',
        'سيارة، كتاب، باب',
        'سيارة، قلم، نافذة',
      ],
    ),
    _AudioRound(
      words: ['كرسي', 'شمس', 'برتقالة'],
      options: [
        'كرسي، قمر، تفاحة',
        'كرسي، شمس، برتقالة',
        'سرير، شمس، برتقالة',
      ],
    ),
  ];

  int _roundIndex = 0;
  int _correctAnswers = 0;
  double _speed = 1;
  String? _selected;
  bool _played = false;
  bool _speaking = false;
  bool _answered = false;

  _AudioRound get _round => _rounds[_roundIndex];

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _configureTts();
  }

  Future<void> _configureTts() async {
    await _tts.setLanguage('ar-SA');
    await _tts.setPitch(1);
    await _tts.setVolume(1);
    await _tts.awaitSpeakCompletion(true);
  }

  Future<void> _play() async {
    if (_speaking) return;
    setState(() {
      _played = true;
      _speaking = true;
      _selected = null;
      _answered = false;
    });

    try {
      await _tts.stop();
      await _tts.setSpeechRate(.42 * _speed);
      await _tts.speak(_round.words.join('،   '));
    } catch (_) {
      if (!mounted) return;
      _showMessage(context.tr('audioError'));
    } finally {
      if (mounted) setState(() => _speaking = false);
    }
  }

  void _checkAnswer() {
    if (_selected == null || _answered) return;
    final correct = _selected == _round.correctAnswer;
    if (correct) _correctAnswers++;

    setState(() => _answered = true);
    _showMessage(context.tr(correct ? 'correctAnswer' : 'tryAgain'));
  }

  void _next() {
    if (!_answered) {
      _checkAnswer();
      return;
    }

    if (_roundIndex == _rounds.length - 1) {
      _finish();
      return;
    }

    setState(() {
      _roundIndex++;
      _selected = null;
      _played = false;
      _answered = false;
      _speaking = false;
    });
  }

  void _finish() {
    _stopwatch.stop();
    final totalSeconds = _stopwatch.elapsed.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseResultScreen(
          correctAnswers: _correctAnswers,
          totalQuestions: _rounds.length,
          duration: '$minutes:${seconds.toString().padLeft(2, '0')}',
          extraText: 'أكملتِ ${_rounds.length} جولات من الذاكرة السمعية.',
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_roundIndex + 1) / _rounds.length;

    return Directionality(
      textDirection: context.patientI18n.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      await _tts.stop();
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                  ),
                  Expanded(
                    child: Text(
                      context.tr('audioMemory'),
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    context.tr('roundOf').replaceAll('{current}', '${_roundIndex + 1}').replaceAll('{total}', '${_rounds.length}'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFDDCFBD),
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Center(
                child: Semantics(
                  button: true,
                  label: context.tr(_played ? 'listenAgain' : 'listenWords'),
                  child: Container(
                    width: 118,
                    height: 118,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF1E7D8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: .12),
                          blurRadius: 24,
                          offset: const Offset(0, 9),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _speaking ? null : _play,
                      icon: _speaking
                          ? const SizedBox(
                              width: 35,
                              height: 35,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            )
                          : Icon(
                              _played
                                  ? Icons.replay_rounded
                                  : Icons.volume_up_rounded,
                              size: 54,
                              color: AppColors.primary,
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                _played
                    ? context.tr('chooseHeardWords')
                    : context.tr('listenInstruction'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    context.tr('readingSpeed'),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Expanded(
                    child: Slider(
                      value: _speed,
                      min: .75,
                      max: 1.25,
                      divisions: 2,
                      activeColor: AppColors.primary,
                      label: '${_speed.toStringAsFixed(2)}x',
                      onChanged: _speaking
                          ? null
                          : (value) => setState(() => _speed = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._round.options.map((option) {
                final isSelected = _selected == option;
                final isCorrect = option == _round.correctAnswer;
                Color? background;
                Color border = AppColors.border;

                if (_answered && isCorrect) {
                  background = const Color(0xFFE5F3E8);
                  border = const Color(0xFF71947A);
                } else if (_answered && isSelected && !isCorrect) {
                  background = const Color(0xFFFFE8EE);
                  border = AppColors.error;
                } else if (isSelected) {
                  background = const Color(0xFFF1E7D8);
                  border = AppColors.primary;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: background ?? Colors.white.withValues(alpha: .82),
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: !_played || _answered
                          ? null
                          : () => setState(() => _selected = option),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: border, width: 1.4),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _answered && isCorrect
                                  ? Icons.check_circle_rounded
                                  : isSelected
                                      ? Icons.radio_button_checked_rounded
                                      : Icons.radio_button_off_rounded,
                              color: _answered && isCorrect
                                  ? const Color(0xFF71947A)
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Text(
                                option,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 14),
              SizedBox(
                height: 58,
                child: FilledButton(
                  onPressed: _selected == null ? null : _next,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    !_answered
                        ? context.tr('checkAnswer')
                        : _roundIndex == _rounds.length - 1
                            ? context.tr('showResult')
                            : context.tr('nextRound'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AudioRound {
  final List<String> words;
  final List<String> options;

  const _AudioRound({required this.words, required this.options});

  String get correctAnswer => words.join('، ');
}

