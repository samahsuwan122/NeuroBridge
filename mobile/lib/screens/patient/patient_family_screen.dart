import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/patient_features_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/patient_page.dart';

class PatientFamilyScreen extends StatefulWidget {
  const PatientFamilyScreen({super.key});

  @override
  State<PatientFamilyScreen> createState() => _PatientFamilyScreenState();
}

class _PatientFamilyScreenState extends State<PatientFamilyScreen> {
  List<Map<String, dynamic>> _family = [];

  String _patientCode = '';
  String? _error;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFamily();
  }

  Future<void> _loadFamily() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await PatientFeaturesService.loadFamily();

      final familyData = response['family'];

      final family = familyData is List
          ? familyData
              .whereType<Map>()
              .map(
                (item) => Map<String, dynamic>.from(item),
              )
              .toList()
          : <Map<String, dynamic>>[];

      if (!mounted) return;

      setState(() {
        _patientCode = response['patient_code']?.toString() ?? '';
        _family = family;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = error
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  Future<void> _copyPatientCode() async {
    if (_patientCode.isEmpty) return;

    await Clipboard.setData(
      ClipboardData(
        text: _patientCode,
      ),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ كود المريض'),
      ),
    );
  }

  String _getFirstLetter(Map<String, dynamic> person) {
    final fullName = person['full_name']?.toString().trim() ?? '';

    if (fullName.isEmpty) {
      return '؟';
    }

    return fullName.substring(0, 1);
  }

  String _getName(Map<String, dynamic> person) {
    final fullName = person['full_name']?.toString().trim() ?? '';

    if (fullName.isEmpty) {
      return 'مستخدم';
    }

    return fullName;
  }

  String _getRelationship(Map<String, dynamic> person) {
    final relationship =
        person['relationship']?.toString().trim() ?? '';

    if (relationship.isEmpty) {
      return 'فرد من العائلة';
    }

    return relationship;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: PatientPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_loading)
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
                      'العائلة',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _loading ? null : _loadFamily,
                    icon: const Icon(
                      Icons.refresh_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              NeuroCard(
                color: const Color(0xFFF1E7D8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.link_rounded,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 9),
                        Text(
                          'كود ربط المريض',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'أرسلي هذا الكود لفرد العائلة حتى يتمكن من طلب الارتباط بحسابك.',
                      style: TextStyle(
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SelectableText(
                              _patientCode.isEmpty
                                  ? 'جارٍ إنشاء الكود...'
                                  : _patientCode,
                              textDirection: TextDirection.ltr,
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'نسخ الكود',
                            onPressed: _patientCode.isEmpty
                                ? null
                                : _copyPatientCode,
                            icon: const Icon(
                              Icons.copy_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const PatientSectionTitle(
                title: 'أفراد العائلة المرتبطون',
              ),

              const SizedBox(height: 12),

              if (_error != null)
                NeuroCard(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 42,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: _loadFamily,
                        icon: const Icon(
                          Icons.refresh_rounded,
                        ),
                        label: const Text(
                          'إعادة المحاولة',
                        ),
                      ),
                    ],
                  ),
                )
              else if (!_loading && _family.isEmpty)
                const NeuroCard(
                  child: Column(
                    children: [
                      Icon(
                        Icons.family_restroom_rounded,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'لا يوجد أفراد عائلة مرتبطون بعد',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'انسخي كود المريض وأرسليه لأحد أفراد العائلة حتى يرسل طلب ارتباط.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          height: 1.6,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ..._family.map(
                  (person) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: NeuroCard(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: const Color(
                                0xFFF1E7D8,
                              ),
                              child: Text(
                                _getFirstLetter(person),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getName(person),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getRelationship(person),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  if (person['email']
                                          ?.toString()
                                          .isNotEmpty ==
                                      true) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      person['email'].toString(),
                                      textDirection: TextDirection.ltr,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const Icon(
                              Icons.verified_rounded,
                              color: Color(0xFF71947A),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}