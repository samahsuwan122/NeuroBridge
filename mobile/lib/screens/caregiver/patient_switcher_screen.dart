import 'package:flutter/material.dart';

import '../../core/services/caregiver_dashboard_service.dart';
import '../../widgets/caregiver_ui.dart';

class PatientSwitcherScreen extends StatefulWidget {
  final int? currentPatientId;

  const PatientSwitcherScreen({
    super.key,
    this.currentPatientId,
  });

  @override
  State<PatientSwitcherScreen> createState() {
    return _PatientSwitcherScreenState();
  }
}

class _PatientSwitcherScreenState
    extends State<PatientSwitcherScreen> {
  bool _isLoading = true;
  bool _isSelecting = false;

  String? _errorMessage;
  int? _selectedPatientId;

  List<Map<String, dynamic>> _patients = [];

  @override
  void initState() {
    super.initState();

    _selectedPatientId =
        widget.currentPatientId;

    _loadPatients();
  }

  Future<void> _loadPatients() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final Map<String, dynamic> dashboard =
          await CaregiverDashboardService.load(
        patientId: widget.currentPatientId,
      );

      final dynamic patientsValue =
          dashboard['linked_patients'];

      final List<Map<String, dynamic>>
          loadedPatients = [];

      if (patientsValue is List) {
        for (final dynamic item
            in patientsValue) {
          if (item is Map) {
            loadedPatients.add(
              Map<String, dynamic>.from(item),
            );
          }
        }
      }

      final Map<String, dynamic>? currentPatient =
          _readMap(dashboard['patient']);

      if (!mounted) {
        return;
      }

      setState(() {
        _patients = loadedPatients;

        if (_selectedPatientId == null &&
            currentPatient != null) {
          _selectedPatientId = _readId(
            currentPatient['id'],
          );
        }

        if (_selectedPatientId == null &&
            _patients.isNotEmpty) {
          _selectedPatientId = _readId(
            _patients.first['id'],
          );
        }

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  Map<String, dynamic>? _readMap(
    dynamic value,
  ) {
    if (value is Map) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    return null;
  }

  int? _readId(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
  }

  String _readName(
    Map<String, dynamic> patient,
  ) {
    final String name =
        patient['full_name']
                ?.toString()
                .trim() ??
            '';

    return name.isEmpty
        ? 'مريض بدون اسم'
        : name;
  }

  String _initials(
    Map<String, dynamic> patient,
  ) {
    final String name = _readName(patient);

    final List<String> words = name
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) {
      return '؟';
    }

    if (words.length == 1) {
      return words.first
          .substring(0, 1)
          .toUpperCase();
    }

    return (
      words.first.substring(0, 1) +
      words.last.substring(0, 1)
    ).toUpperCase();
  }

  String _patientSubtitle(
    Map<String, dynamic> patient,
  ) {
    final String relationship =
        patient['relationship']
                ?.toString()
                .trim() ??
            '';

    final String patientCode =
        patient['patient_code']
                ?.toString()
                .trim() ??
            '';

    if (
        relationship.isNotEmpty &&
        patientCode.isNotEmpty) {
      return '$relationship • $patientCode';
    }

    if (relationship.isNotEmpty) {
      return relationship;
    }

    if (patientCode.isNotEmpty) {
      return 'رمز المريض: $patientCode';
    }

    return 'حساب مريض مرتبط';
  }

  void _selectPatient(
    Map<String, dynamic> patient,
  ) {
    final int? patientId =
        _readId(patient['id']);

    if (patientId == null) {
      return;
    }

    setState(() {
      _selectedPatientId = patientId;
    });
  }

  Future<void> _confirmSelection() async {
    final int? patientId =
        _selectedPatientId;

    if (patientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'اختاري مريضًا أولًا',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isSelecting = true;
    });

    try {
      /*
       * نتأكد أن المريض ما زال مرتبطًا
       * بالحساب وأن الخادم يستطيع تحميله.
       */
      await CaregiverDashboardService.load(
        patientId: patientId,
      );

      if (!mounted) {
        return;
      }

      /*
       * نعيد رقم المريض المختار
       * إلى CaregiverHomeScreen.
       */
      Navigator.of(context).pop(patientId);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSelecting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            error.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CaregiverPage(
          child: Column(
            children: [
              const CaregiverHeader(
                title: 'اختيار المريض',
                subtitle:
                    'يمكنك التنقل بين الأشخاص المرتبطين بحسابك.',
              ),
              const SizedBox(height: 25),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text(
              'جارٍ تحميل المرضى المرتبطين...',
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: CaregiverCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 50,
                color: CaregiverColors.rose,
              ),
              const SizedBox(height: 12),
              const Text(
                'تعذر تحميل المرضى',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: CaregiverColors.brown,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CaregiverColors.muted,
                ),
              ),
              const SizedBox(height: 15),
              FilledButton.icon(
                onPressed: _loadPatients,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text(
                  'إعادة المحاولة',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_patients.isEmpty) {
      return Center(
        child: CaregiverCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.link_off_rounded,
                size: 52,
                color: CaregiverColors.gold,
              ),
              const SizedBox(height: 13),
              const Text(
                'لا يوجد مرضى مرتبطون',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: CaregiverColors.brown,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'اربط مريضًا بحساب العائلة أولًا.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CaregiverColors.muted,
                ),
              ),
              const SizedBox(height: 15),
              OutlinedButton.icon(
                onPressed: _loadPatients,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text(
                  'تحديث القائمة',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            physics:
                const BouncingScrollPhysics(),
            itemCount: _patients.length,
            separatorBuilder: (_, __) {
              return const SizedBox(height: 12);
            },
            itemBuilder: (context, index) {
              final Map<String, dynamic>
                  patient = _patients[index];

              final int? patientId =
                  _readId(patient['id']);

              final bool active =
                  patientId != null &&
                  patientId ==
                      _selectedPatientId;

              return CaregiverCard(
                color: active
                    ? const Color(0xFFF1E7D8)
                    : null,
                onTap: () {
                  _selectPatient(patient);
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          Colors.white,
                      child: Text(
                        _initials(patient),
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.w900,
                          color:
                              CaregiverColors.rose,
                        ),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            _readName(patient),
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.w900,
                              color:
                                  CaregiverColors
                                      .brown,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _patientSubtitle(
                              patient,
                            ),
                            style: const TextStyle(
                              fontSize: 11,
                              color:
                                  CaregiverColors
                                      .muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      active
                          ? Icons
                              .check_circle_rounded
                          : Icons
                              .radio_button_unchecked_rounded,
                      color: active
                          ? CaregiverColors.rose
                          : CaregiverColors.muted,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor:
                  CaregiverColors.rose,
            ),
            onPressed: _isSelecting
                ? null
                : _confirmSelection,
            child: _isSelecting
                ? const SizedBox(
                    width: 23,
                    height: 23,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'استخدام هذا الملف',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}