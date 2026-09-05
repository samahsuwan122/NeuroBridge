import 'package:flutter/material.dart';

import '../../core/services/caregiver_features_service.dart';
import '../../widgets/caregiver_ui.dart';

class CaregiverLiveData extends StatefulWidget {
  final String title;
  final Widget Function(
    BuildContext context,
    Map<String, dynamic> data,
    Future<void> Function() reload,
  ) builder;

  const CaregiverLiveData({super.key, required this.title, required this.builder});

  @override
  State<CaregiverLiveData> createState() => _CaregiverLiveDataState();
}

class _CaregiverLiveDataState extends State<CaregiverLiveData> {
  bool loading = true;
  String? error;
  Map<String, dynamic> data = {};

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await CaregiverFeaturesService.get('summary');
      if (mounted) setState(() => data = result);
    } catch (exception) {
      if (mounted) {
        setState(() => error = exception.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CaregiverPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CaregiverHeader(title: widget.title),
              const SizedBox(height: 20),
              if (loading)
                const Padding(
                  padding: EdgeInsets.all(50),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (error != null)
                CaregiverCard(
                  child: Column(
                    children: [
                      Text(error!),
                      OutlinedButton.icon(
                        onPressed: load,
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              else
                widget.builder(context, data, load),
            ],
          ),
        ),
      ),
    );
  }
}

int asInt(dynamic value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;
bool asBool(dynamic value) => value == true || value == 1 || value == '1';
List<Map<String, dynamic>> asRows(dynamic value) =>
    (value is List ? value : const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
Map<String, dynamic> asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : {};
