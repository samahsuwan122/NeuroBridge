import 'package:flutter/material.dart';

import '../../core/services/patient_features_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/patient_page.dart';
import 'add_memory_screen.dart';
import 'memory_album_screen.dart';
import 'memory_details_screen.dart';

class MemoryTreeScreen extends StatefulWidget {
  const MemoryTreeScreen({super.key});

  @override
  State<MemoryTreeScreen> createState() => _MemoryTreeScreenState();
}

class _MemoryTreeScreenState extends State<MemoryTreeScreen> {
  List<Map<String, dynamic>> memories = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    if (mounted) setState(() { loading = true; error = null; });
    try {
      final rows = await PatientFeaturesService.loadMemories();
      if (mounted) setState(() => memories = rows);
    } catch (exception) {
      if (mounted) {
        setState(() => error = exception.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> add() async {
    final changed = await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => const AddMemoryScreen()));
    if (changed == true) await load();
  }

  Future<void> open(Map<String, dynamic> memory) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => MemoryDetailsScreen(
          title: memory['title']?.toString() ?? '',
          date: memory['memory_date']?.toString() ?? '',
          emoji: memory['emoji']?.toString() ?? '📷',
          description: memory['description']?.toString() ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                ),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('شجرة الذاكرة',
                          style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900)),
                      Text('كل صورة تضيف ورقة جديدة إلى شجرتك 🌿',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(onPressed: load, icon: const Icon(Icons.refresh_rounded)),
              ]),
              const SizedBox(height: 20),
              if (loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(45),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (error != null)
                NeuroCard(
                  child: Column(children: [
                    Text(error!, textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    OutlinedButton(onPressed: load, child: const Text('إعادة المحاولة')),
                  ]),
                )
              else ...[
                NeuroCard(
                  featured: true,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth > 700;
                      const horizontalSpots = <double>[
                        -.75, -.45, 0, -.75, .65, -.1, .45, .9, -.35, .25,
                      ];
                      return SizedBox(
                        height: wide ? 470 : 410,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Positioned(
                              bottom: 0,
                              child: Icon(Icons.park_rounded,
                                  size: wide ? 360 : 280,
                                  color: const Color(0xFF789981)),
                            ),
                            ...List.generate(
                              memories.length > 10 ? 10 : memories.length,
                              (index) => _MemoryLeaf(
                                memory: memories[index],
                                alignment: Alignment(horizontalSpots[index],
                                    index.isEven ? -.35 : 0),
                                onTap: () => open(memories[index]),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
                NeuroCard(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF243128) : const Color(0xFFEAF4ED),
                  child: Row(children: [
                    const Icon(Icons.eco_rounded, color: Color(0xFF71947A)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        memories.isEmpty
                            ? 'شجرتك فارغة الآن. أضيفي أول ذكرى وصورة.'
                            : 'تحتوي شجرتك على ${memories.length} ذكريات جميلة.',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 15),
                Row(children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: add,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: const Text('إضافة ذكرى وصورة'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const MemoryAlbumScreen()))
                          .then((_) => load()),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('فتح الألبوم'),
                    ),
                  ),
                ]),
              ],
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemoryLeaf extends StatelessWidget {
  const _MemoryLeaf({required this.memory, required this.alignment, required this.onTap});

  final Map<String, dynamic> memory;
  final Alignment alignment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final url = memory['image_url']?.toString() ?? '';
    return Align(
      alignment: alignment,
      child: Tooltip(
        message: memory['title']?.toString() ?? '',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 62,
            height: 62,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: AppColors.secondary, width: 3),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
            ),
            child: url.isEmpty
                ? Center(child: Text(memory['emoji']?.toString() ?? '📷',
                    style: const TextStyle(fontSize: 27)))
                : Image.network(url, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_not_supported_outlined)),
          ),
        ),
      ),
    );
  }
}
