import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/localization/patient_i18n.dart';
import '../../core/services/patient_care_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/patient_page.dart';

class PatientCareScreen extends StatelessWidget {
  final VoidCallback? onBack;
  const PatientCareScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) => PatientPage(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            if (onBack != null)
              IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_ios_new_rounded)),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(context.tr('careCenter'), style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(context.tr('careSubtitle'), style: const TextStyle(color: AppColors.textSecondary)),
            ])),
          ]),
          const SizedBox(height: 24),
          _CareTile(
            icon: Icons.medical_services_outlined,
            title: context.tr('providers'),
            subtitle: '${context.tr('doctors')} • ${context.tr('therapists')}',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientProvidersScreen())),
          ),
          const SizedBox(height: 12),
          _CareTile(
            icon: Icons.chat_bubble_outline_rounded,
            title: context.tr('messages'),
            subtitle: context.tr('conversation'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientMessagesScreen())),
          ),
          const SizedBox(height: 12),
          _CareTile(
            icon: Icons.calendar_month_outlined,
            title: context.tr('appointments'),
            subtitle: context.tr('newAppointment'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientAppointmentsScreen())),
          ),
        ]),
      );
}

class _CareTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _CareTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) => NeuroCard(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            Container(width: 58, height: 58, decoration: BoxDecoration(color: AppColors.secondarySoft, borderRadius: BorderRadius.circular(18)), child: Icon(icon, color: AppColors.primary, size: 30)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
            ])),
            const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
          ]),
        ),
      );
}

class PatientProvidersScreen extends StatefulWidget {
  const PatientProvidersScreen({super.key});
  @override
  State<PatientProvidersScreen> createState() => _PatientProvidersScreenState();
}

class _PatientProvidersScreenState extends State<PatientProvidersScreen> {
  bool _loading = true;
  String? _error;
  String? _role;
  List<Map<String, dynamic>> _providers = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final rows = await PatientCareService.providers(role: _role);
      if (mounted) setState(() => _providers = rows);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _message(Map<String, dynamic> provider) async {
    final sent = await showDialog<bool>(context: context, builder: (_) => _NewMessageDialog(provider: provider));
    if (sent == true && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('sent'))));
  }

  Future<void> _book(Map<String, dynamic> provider) async {
    final sent = await showDialog<bool>(context: context, barrierDismissible: false, builder: (_) => _BookDialog(initialProvider: provider));
    if (sent == true && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('sent'))));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: PatientPage(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _PageHeader(title: context.tr('providers'), refresh: _load),
          const SizedBox(height: 14),
          Wrap(spacing: 8, children: [
            ChoiceChip(label: Text(context.tr('all')), selected: _role == null, onSelected: (_) { _role = null; _load(); }),
            ChoiceChip(label: Text(context.tr('doctors')), selected: _role == 'doctor', onSelected: (_) { _role = 'doctor'; _load(); }),
            ChoiceChip(label: Text(context.tr('therapists')), selected: _role == 'therapist', onSelected: (_) { _role = 'therapist'; _load(); }),
          ]),
          const SizedBox(height: 16),
          if (_loading) const Center(child: CircularProgressIndicator())
          else if (_error != null) _ErrorBox(message: _error!, retry: _load)
          else if (_providers.isEmpty) _EmptyBox(icon: Icons.medical_services_outlined, text: context.tr('noProviders'))
          else ..._providers.map((provider) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NeuroCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CircleAvatar(radius: 27, backgroundColor: AppColors.secondarySoft, child: Text(_providerInitial(provider), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(provider['full_name']?.toString() ?? '', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                  Text(context.tr(provider['role'] == 'doctor' ? 'doctor' : 'therapist'), style: const TextStyle(color: AppColors.secondaryDark)),
                  if ((provider['specialty']?.toString() ?? '').isNotEmpty) Text(provider['specialty'].toString(), style: const TextStyle(color: AppColors.textSecondary)),
                ])),
              ]),
              if ((provider['bio_short']?.toString() ?? '').isNotEmpty) ...[const SizedBox(height: 12), Text(provider['bio_short'].toString())],
              if ((provider['clinic_name']?.toString() ?? '').isNotEmpty) ...[const SizedBox(height: 8), Text('${provider['clinic_name']} • ${provider['location'] ?? ''}', style: const TextStyle(color: AppColors.textSecondary))],
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: OutlinedButton.icon(onPressed: () => _message(provider), icon: const Icon(Icons.chat_bubble_outline), label: Text(context.tr('message')))),
                const SizedBox(width: 8),
                Expanded(child: FilledButton.icon(onPressed: () => _book(provider), icon: const Icon(Icons.event_available), label: Text(context.tr('book')))),
              ]),
            ])),
          )),
        ])),
      );
}

class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({super.key});
  @override
  State<PatientAppointmentsScreen> createState() => _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends State<PatientAppointmentsScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final rows = await PatientCareService.appointments();
      if (mounted) setState(() => _items = rows);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally { if (mounted) setState(() => _loading = false); }
  }

  String _status(BuildContext context, String value) => context.tr(switch (value) { 'approved' => 'approved', 'completed' => 'completed', 'cancelled' => 'cancelled', _ => 'pending' });

  Future<void> _openZoom(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('zoomError'))));
    }
  }

  Future<void> _cancel(int id) async { await PatientCareService.cancelAppointment(id); await _load(); }

  Future<void> _book() async {
    final created = await showDialog<bool>(context: context, barrierDismissible: false, builder: (_) => const _BookDialog());
    if (created == true) await _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(onPressed: _book, icon: const Icon(Icons.add), label: Text(context.tr('newAppointment'))),
    body: PatientPage(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _PageHeader(title: context.tr('appointments'), refresh: _load),
      const SizedBox(height: 18),
      if (_loading) const Center(child: CircularProgressIndicator())
      else if (_error != null) _ErrorBox(message: _error!, retry: _load)
      else if (_items.isEmpty) _EmptyBox(icon: Icons.event_available_outlined, text: context.tr('noAppointments'))
      else ..._items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 12), child: NeuroCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(item['reason']?.toString() ?? '', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900))),
          Chip(label: Text(_status(context, item['status']?.toString() ?? 'pending'))),
        ]),
        Text('${item['preferred_date']} • ${_shortTime(item['preferred_time'])}'),
        const SizedBox(height: 5),
        Text('${item['provider_name'] ?? context.tr('provider')} • ${context.tr(item['appointment_mode'] == 'online' ? 'online' : 'inPerson')}', style: const TextStyle(color: AppColors.textSecondary)),
        if ((item['meeting_url']?.toString() ?? '').isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => _openZoom(item['meeting_url'].toString()), icon: const Icon(Icons.videocam), label: Text(context.tr('zoom')))),
        ],
        if (item['status'] == 'pending' || item['status'] == 'approved') ...[
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => _cancel(int.parse(item['id'].toString())), icon: const Icon(Icons.close), label: Text(context.tr('cancel')))),
        ],
      ])))),
      const SizedBox(height: 90),
    ])),
  );

  String _shortTime(dynamic value) {
    final text = value?.toString() ?? '';
    return text.length >= 5 ? text.substring(0, 5) : text;
  }
}

class PatientMessagesScreen extends StatefulWidget {
  const PatientMessagesScreen({super.key});
  @override
  State<PatientMessagesScreen> createState() => _PatientMessagesScreenState();
}

class _PatientMessagesScreenState extends State<PatientMessagesScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _threads = [];

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try { final rows = await PatientCareService.threads(); if (mounted) setState(() => _threads = rows); }
    catch (e) { if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', '')); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _newMessage() async {
    final providers = await PatientCareService.providers();
    if (!mounted) return;
    final sent = await showDialog<bool>(context: context, builder: (_) => _NewMessageDialog(providers: providers));
    if (sent == true) await _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(onPressed: _newMessage, icon: const Icon(Icons.edit), label: Text(context.tr('newMessage'))),
    body: PatientPage(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _PageHeader(title: context.tr('messages'), refresh: _load),
      const SizedBox(height: 18),
      if (_loading) const Center(child: CircularProgressIndicator())
      else if (_error != null) _ErrorBox(message: _error!, retry: _load)
      else if (_threads.isEmpty) _EmptyBox(icon: Icons.chat_bubble_outline, text: context.tr('noMessages'))
      else ..._threads.map((thread) => Padding(padding: const EdgeInsets.only(bottom: 10), child: NeuroCard(
        onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => PatientThreadScreen(threadId: int.parse(thread['id'].toString())))); await _load(); },
        child: Row(children: [
          const CircleAvatar(child: Icon(Icons.medical_services_outlined)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(thread['provider_name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(thread['latest_reply']?.toString() ?? thread['message']?.toString() ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary)),
          ])),
          const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
        ]),
      ))),
      const SizedBox(height: 90),
    ])),
  );
}

class PatientThreadScreen extends StatefulWidget {
  final int threadId;
  const PatientThreadScreen({super.key, required this.threadId});
  @override
  State<PatientThreadScreen> createState() => _PatientThreadScreenState();
}

class _PatientThreadScreenState extends State<PatientThreadScreen> {
  final _reply = TextEditingController();
  Map<String, dynamic>? _thread;
  List<Map<String, dynamic>> _replies = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override void initState() { super.initState(); _load(); }
  @override void dispose() { _reply.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final data = await PatientCareService.thread(widget.threadId);
      if (mounted) setState(() {
        _thread = data['thread'] is Map ? Map<String, dynamic>.from(data['thread']) : null;
        _replies = (data['replies'] as List? ?? const []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        _loading = false; _error = null;
      });
    } catch (e) { if (mounted) setState(() { _loading = false; _error = e.toString(); }); }
  }

  Future<void> _send() async {
    final text = _reply.text.trim(); if (text.isEmpty) return;
    setState(() => _sending = true);
    try { await PatientCareService.reply(widget.threadId, text); _reply.clear(); await _load(); }
    finally { if (mounted) setState(() => _sending = false); }
  }

  Widget _bubble(String text, bool mine) => Align(
    alignment: mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
    child: Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(13), constraints: const BoxConstraints(maxWidth: 310), decoration: BoxDecoration(color: mine ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(17)), child: Text(text, style: TextStyle(color: mine ? Colors.white : AppColors.textPrimary))),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_thread?['provider_name']?.toString() ?? context.tr('conversation'))),
    body: SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _error != null ? _ErrorBox(message: _error!, retry: _load) : ListView(children: [
        _bubble(_thread?['message']?.toString() ?? '', true),
        ..._replies.map((r) => _bubble(r['body']?.toString() ?? '', r['sender_type'] == 'patient')),
      ])),
      Row(children: [
        Expanded(child: TextField(controller: _reply, minLines: 1, maxLines: 4, decoration: InputDecoration(hintText: context.tr('reply'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18))))),
        const SizedBox(width: 8),
        IconButton.filled(onPressed: _sending ? null : _send, icon: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send_rounded)),
      ]),
    ]))),
  );
}

class _NewMessageDialog extends StatefulWidget {
  final Map<String, dynamic>? provider;
  final List<Map<String, dynamic>>? providers;
  const _NewMessageDialog({this.provider, this.providers});
  @override State<_NewMessageDialog> createState() => _NewMessageDialogState();
}

class _NewMessageDialogState extends State<_NewMessageDialog> {
  final _message = TextEditingController();
  int? _providerId;
  bool _saving = false;
  @override void initState() { super.initState(); _providerId = int.tryParse(widget.provider?['id']?.toString() ?? ''); }
  @override void dispose() { _message.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) => AlertDialog(
    title: Text(context.tr('newMessage')),
    content: Column(mainAxisSize: MainAxisSize.min, children: [
      if (widget.provider == null) DropdownButtonFormField<int>(value: _providerId, decoration: InputDecoration(labelText: context.tr('provider')), items: (widget.providers ?? const []).map((p) => DropdownMenuItem(value: int.parse(p['id'].toString()), child: Text(p['full_name']?.toString() ?? ''))).toList(), onChanged: (v) => setState(() => _providerId = v)),
      if (widget.provider == null) const SizedBox(height: 12),
      TextField(controller: _message, minLines: 4, maxLines: 8, decoration: InputDecoration(labelText: context.tr('writeMessage'), border: const OutlineInputBorder())),
    ]),
    actions: [
      TextButton(onPressed: _saving ? null : () => Navigator.pop(context, false), child: Text(context.tr('cancel'))),
      FilledButton(onPressed: _saving ? null : () async {
        if (_providerId == null || _message.text.trim().isEmpty) return;
        setState(() => _saving = true);
        try { await PatientCareService.sendMessage(_providerId!, _message.text.trim()); if (context.mounted) Navigator.pop(context, true); }
        catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
        finally { if (mounted) setState(() => _saving = false); }
      }, child: Text(context.tr('send'))),
    ],
  );
}

class _BookDialog extends StatefulWidget {
  final Map<String, dynamic>? initialProvider;
  const _BookDialog({this.initialProvider});
  @override State<_BookDialog> createState() => _BookDialogState();
}

class _BookDialogState extends State<_BookDialog> {
  final _reason = TextEditingController();
  List<Map<String, dynamic>> _providers = [];
  int? _providerId;
  DateTime? _date;
  TimeOfDay? _time;
  String _mode = 'in_person';
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override void initState() { super.initState(); _providerId = int.tryParse(widget.initialProvider?['id']?.toString() ?? ''); _loadProviders(); }
  @override void dispose() { _reason.dispose(); super.dispose(); }
  Future<void> _loadProviders() async {
    try { final rows = await PatientCareService.providers(); if (mounted) setState(() => _providers = rows); }
    catch (e) { if (mounted) setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _submit() async {
    if (_providerId == null || _date == null || _time == null || _reason.text.trim().isEmpty) { setState(() => _error = context.tr('selectAll')); return; }
    setState(() { _saving = true; _error = null; });
    try { await PatientCareService.createAppointment(providerId: _providerId!, date: _date!, time: _time!, mode: _mode, reason: _reason.text.trim()); if (mounted) Navigator.pop(context, true); }
    catch (e) { if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', '')); }
    finally { if (mounted) setState(() => _saving = false); }
  }

  @override Widget build(BuildContext context) => AlertDialog(
    title: Text(context.tr('newAppointment')),
    content: _loading ? const SizedBox(height: 90, child: Center(child: CircularProgressIndicator())) : SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(_error!, style: const TextStyle(color: Colors.red))),
      DropdownButtonFormField<int>(value: _providerId, isExpanded: true, decoration: InputDecoration(labelText: context.tr('provider')), items: _providers.map((p) => DropdownMenuItem(value: int.parse(p['id'].toString()), child: Text(p['full_name']?.toString() ?? ''))).toList(), onChanged: (v) => setState(() => _providerId = v)),
      const SizedBox(height: 10),
      SegmentedButton<String>(segments: [ButtonSegment(value: 'in_person', label: Text(context.tr('inPerson'))), ButtonSegment(value: 'online', label: Text(context.tr('online')), icon: const Icon(Icons.videocam_outlined))], selected: {_mode}, onSelectionChanged: (s) => setState(() => _mode = s.first)),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: OutlinedButton.icon(onPressed: () async { final v = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365))); if (v != null) setState(() => _date = v); }, icon: const Icon(Icons.calendar_today), label: Text(_date == null ? context.tr('date') : '${_date!.year}-${_date!.month}-${_date!.day}'))),
        const SizedBox(width: 8),
        Expanded(child: OutlinedButton.icon(onPressed: () async { final v = await showTimePicker(context: context, initialTime: TimeOfDay.now()); if (v != null) setState(() => _time = v); }, icon: const Icon(Icons.schedule), label: Text(_time == null ? context.tr('time') : _time!.format(context)))),
      ]),
      const SizedBox(height: 10),
      TextField(controller: _reason, minLines: 2, maxLines: 4, decoration: InputDecoration(labelText: context.tr('reason'), border: const OutlineInputBorder())),
    ])),
    actions: [
      TextButton(onPressed: _saving ? null : () => Navigator.pop(context, false), child: Text(context.tr('cancel'))),
      FilledButton(onPressed: _saving ? null : _submit, child: Text(context.tr('save'))),
    ],
  );
}

class _PageHeader extends StatelessWidget {
  final String title; final VoidCallback refresh;
  const _PageHeader({required this.title, required this.refresh});
  @override Widget build(BuildContext context) => Row(children: [
    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
    Expanded(child: Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900))),
    IconButton(onPressed: refresh, icon: const Icon(Icons.refresh_rounded)),
  ]);
}

String _providerInitial(Map<String, dynamic> provider) {
  final name = provider['full_name']?.toString().trim() ?? '';
  return name.isEmpty ? '?' : name.characters.first.toUpperCase();
}

class _EmptyBox extends StatelessWidget {
  final IconData icon; final String text;
  const _EmptyBox({required this.icon, required this.text});
  @override Widget build(BuildContext context) => NeuroCard(child: Padding(padding: const EdgeInsets.symmetric(vertical: 35), child: Column(children: [Icon(icon, size: 45, color: AppColors.secondaryDark), const SizedBox(height: 12), Text(text, textAlign: TextAlign.center)])));
}

class _ErrorBox extends StatelessWidget {
  final String message; final VoidCallback retry;
  const _ErrorBox({required this.message, required this.retry});
  @override Widget build(BuildContext context) => NeuroCard(child: Column(children: [Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)), const SizedBox(height: 10), OutlinedButton(onPressed: retry, child: Text(context.tr('retry')))]));
}
