import 'package:flutter/material.dart';

/// Displays a Memory Album image from a full URL, with rounded corners, a
/// loading placeholder, and an error placeholder. Supportive/family-engagement
/// content only — never analyzed or interpreted.
///
/// Use a small [width]/[height] for a thumbnail, or a large size for the detail
/// hero. Pass [unavailableLabel] (large mode) to show text under the error icon.
class MemoryImageView extends StatelessWidget {
  const MemoryImageView({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.borderRadius = 16,
    this.semanticLabel,
    this.unavailableLabel,
  });

  final String imageUrl;
  final double width;
  final double height;
  final double borderRadius;
  final String? semanticLabel;
  final String? unavailableLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          semanticLabel: semanticLabel,
          loadingBuilder: (context, child, progress) =>
              progress == null ? child : _Placeholder(child: _spinner()),
          errorBuilder: (context, error, stack) => _Placeholder(
            child: _error(context),
          ),
        ),
      ),
    );
  }

  Widget _spinner() => const Center(
        child: SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );

  Widget _error(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image_outlined,
              color: theme.colorScheme.onSurfaceVariant),
          if (unavailableLabel != null) ...[
            const SizedBox(height: 6),
            Text(unavailableLabel!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: child,
    );
  }
}
