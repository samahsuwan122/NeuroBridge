import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/family_appointment_service.dart';
import '../../widgets/caregiver_ui.dart';

class FamilyAppointmentsLiveScreen extends StatefulWidget {
  final int patientId;
  final String patientName;

  const FamilyAppointmentsLiveScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<FamilyAppointmentsLiveScreen> createState() =>
      _FamilyAppointmentsLiveScreenState();
}

class _FamilyAppointmentsLiveScreenState
    extends State<FamilyAppointmentsLiveScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await FamilyAppointmentService.appointments(widget.patientId);
      if (mounted) setState(() => _appointments = rows);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _status(String value) => switch (value) {
        'approved' => 'مؤكد',
        'completed' => 'مكتمل',
        'cancelled' => 'ملغي',
        _ => 'بانتظار الموافقة',
      };

  String _mode(String value) => value == 'online' ? 'عن بُعد' : 'حضوري';

  String _time(dynamic value) {
    final text = value?.toString() ?? '';
    return text.length >= 5 ? text.substring(0, 5) : text;
  }

  Future<void> _cancel(Map<String, dynamic> item) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الموعد'),
        content: const Text('هل تريدين إلغاء طلب الموعد؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('تراجع')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('إلغاء الموعد')),
        ],
      ),
    );
    if (accepted != true) return;
    try {
      await FamilyAppointmentService.cancel(
        patientId: widget.patientId,
        appointmentId: int.parse(item['id'].toString()),
      );
      await _load();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _book() async {
    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _BookAppointmentDialog(patientId: widget.patientId),
    );
    if (created == true) {
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال طلب الموعد لمقدم الرعاية')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _book,
          icon: const Icon(Icons.add),
          label: const Text('حجز موعد جديد'),
        ),
        body: CaregiverPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CaregiverHeader(title: 'مواعيد ${widget.patientName}'),
              const SizedBox(height: 20),
              if (_loading)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
              else if (_error != null)
                CaregiverCard(
                  child: Column(children: [
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: _load, child: const Text('إعادة المحاولة')),
                  ]),
                )
              else if (_appointments.isEmpty)
                CaregiverCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 35),
                    child: Column(children: [
                      const Icon(Icons.event_available_rounded, size: 46, color: CaregiverColors.gold),
                      const SizedBox(height: 12),
                      const Text('لا توجد مواعيد بعد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 7),
                      const Text('اضغطي «حجز موعد جديد» لإرسال طلب لمقدم الرعاية.'),
                      const SizedBox(height: 15),
                      FilledButton.icon(onPressed: _book, icon: const Icon(Icons.add), label: const Text('حجز موعد جديد')),
                    ]),
                  ),
                )
              else
                ..._appointments.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CaregiverCard(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(child: Text(item['reason']?.toString() ?? 'موعد متابعة', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: CaregiverColors.brown))),
                            Chip(label: Text(_status(item['status']?.toString() ?? 'pending'))),
                          ]),
                          const SizedBox(height: 9),
                          Text('${item['preferred_date']} • ${_time(item['preferred_time'])}'),
                          const SizedBox(height: 5),
                          Text('${item['provider_name'] ?? 'مقدم الرعاية'} • ${_mode(item['appointment_mode']?.toString() ?? 'in_person')}', style: const TextStyle(color: CaregiverColors.muted)),
                          if (item['clinic_name'] != null) ...[
                            const SizedBox(height: 4),
                            Text(item['clinic_name'].toString(), style: const TextStyle(color: CaregiverColors.muted)),
                          ],
                          if ((item['meeting_url']?.toString() ?? '').isNotEmpty) ...[
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: () async {
                                final uri = Uri.tryParse(item['meeting_url'].toString());
                                if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('تعذر فتح رابط Zoom')),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.videocam_rounded),
                              label: const Text('الدخول إلى جلسة Zoom'),
                            ),
                          ],
                          if (item['status'] == 'pending' || item['status'] == 'approved') ...[
                            const SizedBox(height: 12),
                            OutlinedButton.icon(onPressed: () => _cancel(item), icon: const Icon(Icons.close), label: const Text('إلغاء الموعد')),
                          ],
                        ]),
                      ),
                    )),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookAppointmentDialog extends StatefulWidget {
  final int patientId;
  const _BookAppointmentDialog({required this.patientId});

  @override
  State<_BookAppointmentDialog> createState() => _BookAppointmentDialogState();
}

class _BookAppointmentDialogState extends State<_BookAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reason = TextEditingController();
  List<Map<String, dynamic>> _providers = [];
  int? _providerId;
  DateTime? _date;
  TimeOfDay? _time;
  String _mode = 'in_person';
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _loadProviders() async {
    try {
      final rows = await FamilyAppointmentService.providers();
      if (mounted) setState(() => _providers = rows);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _providerId == null || _date == null || _time == null) {
      setState(() => _error = 'اختاري مقدم الرعاية والتاريخ والوقت');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await FamilyAppointmentService.create(
        patientId: widget.patientId,
        providerId: _providerId!,
        date: _date!,
        time: _time!,
        mode: _mode,
        reason: _reason.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('حجز موعد جديد'),
      content: SizedBox(
        width: 520,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    DropdownButtonFormField<int>(
                      value: _providerId,
                      decoration: const InputDecoration(labelText: 'مقدم الرعاية', border: OutlineInputBorder()),
                      items: _providers.map((provider) => DropdownMenuItem<int>(
                            value: int.parse(provider['id'].toString()),
                            child: Text('${provider['full_name']} — ${provider['specialty'] ?? (provider['role'] == 'doctor' ? 'طبيب' : 'معالج')}'),
                          )).toList(),
                      onChanged: (value) => setState(() => _providerId = value),
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: OutlinedButton.icon(
                        onPressed: () async {
                          final value = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 1)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                          if (value != null) setState(() => _date = value);
                        },
                        icon: const Icon(Icons.calendar_month),
                        label: Text(_date == null ? 'اختيار التاريخ' : '${_date!.year}-${_date!.month}-${_date!.day}'),
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: OutlinedButton.icon(
                        onPressed: () async {
                          final value = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 10, minute: 0));
                          if (value != null) setState(() => _time = value);
                        },
                        icon: const Icon(Icons.schedule),
                        label: Text(_time == null ? 'اختيار الوقت' : _time!.format(context)),
                      )),
                    ]),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _mode,
                      decoration: const InputDecoration(labelText: 'نوع الموعد', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'in_person', child: Text('حضوري')),
                        DropdownMenuItem(value: 'online', child: Text('عن بُعد')),
                      ],
                      onChanged: (value) => setState(() => _mode = value ?? 'in_person'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _reason,
                      maxLength: 500,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'سبب الموعد', hintText: 'مثال: جلسة متابعة', border: OutlineInputBorder()),
                      validator: (value) => (value?.trim().isEmpty ?? true) ? 'اكتبي سبب الموعد' : null,
                    ),
                    if (_providers.isEmpty) const Text('لا يوجد مقدمو رعاية متاحون حاليًا.'),
                    if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: Colors.red))),
                  ]),
                ),
              ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context, false), child: const Text('إلغاء')),
        FilledButton(onPressed: _saving || _loading || _providers.isEmpty ? null : _submit, child: Text(_saving ? 'جارٍ الإرسال...' : 'إرسال الطلب')),
      ],
    );
  }
}
