import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/emerald_panel.dart';
import '../../../core/widgets/language_button.dart';
import '../data/memory_entry.dart';
import 'memory_image_view.dart';

/// Read-only Memory Album detail. Shows a single memory's fields and, when one
/// exists, a large image. Supportive/family-engagement content only — no
/// diagnosis, scoring, or interpretation. No editing in this phase.
class MemoryDetailsScreen extends StatelessWidget {
  const MemoryDetailsScreen({super.key, this.memory});

  final MemoryEntry? memory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final memory = this.memory;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.memoryDetails),
        actions: const [LanguageButton()],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: memory == null
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text(l10n.noMemoriesYet)),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HeroImage(memory: memory, l10n: l10n),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const IconChip(
                                icon: Icons.photo_library_rounded, size: 56),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(memory.title,
                                  style: theme.textTheme.headlineSmall),
                            ),
                          ],
                        ),
                        if ((memory.description ?? '').isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(memory.description!,
                                  style: theme.textTheme.bodyLarge),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _InfoRow(
                                    label: l10n.personName,
                                    value: memory.personName,
                                    l10n: l10n),
                                const Divider(),
                                _InfoRow(
                                    label: l10n.relationship,
                                    value: memory.relationship,
                                    l10n: l10n),
                                const Divider(),
                                _InfoRow(
                                    label: l10n.place,
                                    value: memory.placeName,
                                    l10n: l10n),
                                const Divider(),
                                _InfoRow(
                                    label: l10n.memoryDate,
                                    value: memory.memoryDateDisplay,
                                    l10n: l10n),
                                const Divider(),
                                _InfoRow(
                                    label: l10n.category,
                                    value: memory.category,
                                    l10n: l10n),
                                const Divider(),
                                _InfoRow(
                                    label: l10n.mediaType,
                                    value: memory.mediaType,
                                    l10n: l10n),
                                const Divider(),
                                _InfoRow(
                                    label: l10n.mediaUrl,
                                    value: memory.mediaUrl,
                                    l10n: l10n),
                                const Divider(),
                                _InfoRow(
                                    label: l10n.createdAt,
                                    value: memory.createdAtDisplay,
                                    l10n: l10n),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(l10n.memoryAlbumNote,
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Large hero image when the memory has one, else an elegant placeholder box.
class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.memory, required this.l10n});

  final MemoryEntry memory;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = memory.resolvedImageUrl(AppConfig.baseUrl);
    if (memory.hasImage && imageUrl != null) {
      return MemoryImageView(
        imageUrl: imageUrl,
        width: double.infinity,
        height: 220,
        borderRadius: 20,
        semanticLabel: l10n.imagePreview,
        unavailableLabel: l10n.imageUnavailable,
      );
    }
    // Elegant placeholder (no broken UI) when there is no image.
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_outlined,
              size: 40, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(l10n.noImageAttached,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, required this.l10n});

  final String label;
  final String? value;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = (value == null || value!.isEmpty) ? l10n.notProvided : value!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium
                ?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 2),
          Text(display, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
