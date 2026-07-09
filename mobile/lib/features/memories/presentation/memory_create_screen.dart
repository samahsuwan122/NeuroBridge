import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_scope.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/language_button.dart';
import '../application/memories_controller.dart';

/// Add Memory form. Creates a supportive/family-engagement memory via
/// POST /api/v1/memories. No file upload — `media_url` is a text placeholder.
/// No diagnosis, scoring, or medical interpretation.
class MemoryCreateScreen extends StatefulWidget {
  const MemoryCreateScreen({super.key});

  @override
  State<MemoryCreateScreen> createState() => _MemoryCreateScreenState();
}

class _MemoryCreateScreenState extends State<MemoryCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _personName = TextEditingController();
  final _relationship = TextEditingController();
  final _place = TextEditingController();
  final _memoryDate = TextEditingController();
  final _category = TextEditingController();
  final _mediaType = TextEditingController();
  final _mediaUrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Clear any stale create status from a previous attempt.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppScope.of(context).memories.resetCreate();
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _personName.dispose();
    _relationship.dispose();
    _place.dispose();
    _memoryDate.dispose();
    _category.dispose();
    _mediaType.dispose();
    _mediaUrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    final memories = AppScope.of(context).memories;
    final ok = await memories.createMemory(
      title: _title.text,
      description: _description.text,
      personName: _personName.text,
      relationship: _relationship.text,
      placeName: _place.text,
      memoryDate: _memoryDate.text,
      category: _category.text,
      mediaType: _mediaType.text,
      mediaUrl: _mediaUrl.text,
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.memorySaved)),
      );
      context.go('/memories');
    }
    // On failure the inline error message is shown via createStatus.
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final memories = AppScope.of(context).memories;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addMemory),
        actions: const [LanguageButton()],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.memoryAlbumNote,
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _title,
                      decoration: InputDecoration(labelText: l10n.memoryTitle),
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? l10n.memoryTitleRequired
                              : null,
                    ),
                    const SizedBox(height: 12),
                    _OptionalField(
                        controller: _description,
                        label: l10n.memoryDescription,
                        l10n: l10n,
                        maxLines: 3),
                    _OptionalField(
                        controller: _personName,
                        label: l10n.personName,
                        l10n: l10n),
                    _OptionalField(
                        controller: _relationship,
                        label: l10n.relationship,
                        l10n: l10n),
                    _OptionalField(
                        controller: _place, label: l10n.place, l10n: l10n),
                    _OptionalField(
                        controller: _memoryDate,
                        label: l10n.memoryDate,
                        l10n: l10n,
                        hintText: l10n.memoryDateHint),
                    _OptionalField(
                        controller: _category,
                        label: l10n.category,
                        l10n: l10n),
                    _OptionalField(
                        controller: _mediaType,
                        label: l10n.mediaType,
                        l10n: l10n),
                    _OptionalField(
                        controller: _mediaUrl,
                        label: l10n.mediaUrl,
                        l10n: l10n,
                        hintText: l10n.mediaUrlHint),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: memories,
                      builder: (context, _) {
                        final submitting =
                            memories.createStatus == MemoryCreateStatus.submitting;
                        final error =
                            memories.createStatus == MemoryCreateStatus.error;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (error) ...[
                              Text(
                                l10n.memorySaveFailed,
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.error),
                              ),
                              const SizedBox(height: 8),
                            ],
                            FilledButton.icon(
                              onPressed: submitting ? null : _submit,
                              icon: submitting
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.save_outlined),
                              label: Text(
                                  submitting ? l10n.submitting : l10n.saveMemory),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed:
                                  submitting ? null : () => context.go('/memories'),
                              child: Text(l10n.cancel),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionalField extends StatelessWidget {
  const _OptionalField({
    required this.controller,
    required this.label,
    required this.l10n,
    this.hintText,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final AppLocalizations l10n;
  final String? hintText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          helperText: l10n.optional,
          hintText: hintText,
        ),
      ),
    );
  }
}
