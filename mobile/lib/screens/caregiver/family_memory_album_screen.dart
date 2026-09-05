import 'package:flutter/material.dart';

import '../../core/services/family_memories_service.dart';
import '../../widgets/caregiver_ui.dart';

class FamilyMemoryAlbumScreen extends StatefulWidget {
  final int patientId;
  final String patientName;

  const FamilyMemoryAlbumScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<FamilyMemoryAlbumScreen> createState() => _FamilyMemoryAlbumScreenState();
}

class _FamilyMemoryAlbumScreenState extends State<FamilyMemoryAlbumScreen> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> memories = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() { loading = true; error = null; });
    try {
      final rows = await FamilyMemoriesService.load(widget.patientId);
      if (mounted) setState(() => memories = rows);
    } catch (exception) {
      if (mounted) setState(() => error = exception.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void openMemory(Map<String, dynamic> memory) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FamilyMemoryDetails(memory: memory),
    );
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      body: CaregiverPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CaregiverHeader(title: 'ذكريات ${widget.patientName}'),
            const SizedBox(height: 8),
            const Text(
              'تظهر هنا الذكريات التي شاركها المريض مع العائلة',
              style: TextStyle(color: CaregiverColors.muted),
            ),
            const SizedBox(height: 18),
            if (loading)
              const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator()))
            else if (error != null)
              CaregiverCard(
                child: Column(children: [
                  Text(error!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: load,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('إعادة المحاولة'),
                  ),
                ]),
              )
            else if (memories.isEmpty)
              const CaregiverCard(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 38),
                  child: Column(children: [
                    Icon(Icons.photo_library_outlined, size: 55),
                    SizedBox(height: 12),
                    Text('لا توجد ذكريات مشاركة بعد', style: TextStyle(fontWeight: FontWeight.w900)),
                  ]),
                ),
              )
            else
              LayoutBuilder(builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900 ? 4 : constraints.maxWidth >= 620 ? 3 : 2;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: memories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 245,
                  ),
                  itemBuilder: (_, index) => _MemoryCard(
                    memory: memories[index],
                    onTap: () => openMemory(memories[index]),
                  ),
                );
              }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    ),
  );
}

class _MemoryCard extends StatelessWidget {
  final Map<String, dynamic> memory;
  final VoidCallback onTap;
  const _MemoryCard({required this.memory, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = memory['image_url']?.toString() ?? '';
    return CaregiverCard(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
            child: imageUrl.isEmpty
                ? Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: Text(memory['emoji']?.toString() ?? '📷', style: const TextStyle(fontSize: 58)),
                  )
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined, size: 42)),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(memory['title']?.toString() ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(memory['memory_date']?.toString() ?? '', style: const TextStyle(fontSize: 11, color: CaregiverColors.muted)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _FamilyMemoryDetails extends StatelessWidget {
  final Map<String, dynamic> memory;
  const _FamilyMemoryDetails({required this.memory});

  @override
  Widget build(BuildContext context) {
    final imageUrl = memory['image_url']?.toString() ?? '';
    return DraggableScrollableSheet(
      initialChildSize: .82,
      maxChildSize: .94,
      minChildSize: .55,
      builder: (_, controller) => Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: ListView(controller: controller, padding: const EdgeInsets.all(20), children: [
          Center(child: Container(width: 48, height: 5, decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: SizedBox(
              height: 300,
              child: imageUrl.isEmpty
                  ? Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: Text(memory['emoji']?.toString() ?? '📷', style: const TextStyle(fontSize: 90)),
                    )
                  : Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 18),
          Text(memory['title']?.toString() ?? '', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
          if ((memory['memory_date']?.toString() ?? '').isNotEmpty)
            Text(memory['memory_date'].toString(), style: const TextStyle(color: CaregiverColors.muted)),
          if ((memory['description']?.toString() ?? '').isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(memory['description'].toString()),
          ],
          if ((memory['people']?.toString() ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('الأشخاص: ${memory['people']}'),
          ],
          if ((memory['location']?.toString() ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('المكان: ${memory['location']}'),
          ],
        ]),
      ),
    );
  }
}
