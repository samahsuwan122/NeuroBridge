import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/emerald_panel.dart';
import '../../../core/widgets/language_button.dart';
import '../data/memory_entry.dart';

/// Read-only Memory Album detail. Shows a single memory's fields. Supportive/
/// family-engagement content only — no diagnosis, scoring, or interpretation.
/// No editing in this phase; media is shown as placeholder text, not an image.
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
                          Text(memory.description!,
                              style: theme.textTheme.bodyLarge),
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
