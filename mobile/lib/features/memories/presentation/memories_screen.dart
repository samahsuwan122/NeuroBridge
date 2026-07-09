import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_scope.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/emerald_panel.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/language_button.dart';
import '../../../core/widgets/loading_state.dart';
import '../application/memories_controller.dart';
import '../data/memory_entry.dart';

/// Memory Album list (read-only). Supportive/family-engagement content only —
/// no diagnosis, scoring, or medical interpretation. No create/edit here yet.
class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppScope.of(context).memories.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final memories = AppScope.of(context).memories;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.memoryAlbum),
        actions: const [LanguageButton()],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: AnimatedBuilder(
              animation: memories,
              builder: (context, _) => _body(context, memories, l10n),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    MemoriesController memories,
    AppLocalizations l10n,
  ) {
    switch (memories.status) {
      case MemoriesStatus.initial:
      case MemoriesStatus.loading:
        return Center(child: LoadingState(message: l10n.loadingMemories));
      case MemoriesStatus.error:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ErrorState(
            message: l10n.memoriesLoadFailed,
            retryLabel: l10n.retry,
            onRetry: memories.load,
          ),
        );
      case MemoriesStatus.empty:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _IntroNote(l10n: l10n),
              const SizedBox(height: 24),
              Center(child: Text(l10n.noMemoriesYet)),
            ],
          ),
        );
      case MemoriesStatus.loaded:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _IntroNote(l10n: l10n),
              const SizedBox(height: 12),
              for (final memory in memories.memories)
                _MemoryCard(
                  memory: memory,
                  l10n: l10n,
                  onTap: () =>
                      context.go('/memories/details', extra: memory),
                ),
            ],
          ),
        );
    }
  }
}

class _IntroNote extends StatelessWidget {
  const _IntroNote({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.memoryAlbumSubtitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(l10n.memoryAlbumNote, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({
    required this.memory,
    required this.l10n,
    required this.onTap,
  });

  final MemoryEntry memory;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const IconChip(icon: Icons.photo_library_rounded, size: 54),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(memory.title, style: theme.textTheme.titleLarge),
                    if ((memory.personDisplay ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(memory.personDisplay!,
                          style: theme.textTheme.bodyMedium),
                    ],
                    if ((memory.placeName ?? '').isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(memory.placeName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if ((memory.category ?? '').isNotEmpty)
                          _MetaChip(label: memory.category!),
                        if ((memory.mediaType ?? '').isNotEmpty)
                          _MetaChip(label: memory.mediaType!),
                        if ((memory.listDateDisplay ?? '').isNotEmpty)
                          _MetaChip(label: memory.listDateDisplay!),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}
