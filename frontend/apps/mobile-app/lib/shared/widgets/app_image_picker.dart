import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppImagePicker extends StatelessWidget {
  final String label;
  final String? imagePath;
  final VoidCallback onPickImage;
  final VoidCallback? onRemoveImage;
  final String hintText;
  final IconData icon;

  const AppImagePicker({
    super.key,
    required this.label,
    required this.imagePath,
    required this.onPickImage,
    this.onRemoveImage,
    this.hintText = 'Tap to attach document / photo',
    this.icon = Icons.add_a_photo_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onPickImage,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasImage
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
                  : theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasImage
                    ? theme.colorScheme.primary
                    : AppColors.borderLight,
                width: hasImage ? 1.5 : 1,
                style: BorderStyle.solid,
              ),
            ),
            child: hasImage
                ? Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.description,
                            color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attachment Attached',
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              imagePath!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (onRemoveImage != null)
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: onRemoveImage,
                        ),
                    ],
                  )
                : Column(
                    children: [
                      Icon(icon, size: 36, color: theme.colorScheme.primary),
                      const SizedBox(height: 8),
                      Text(
                        hintText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Supports PNG, JPG, PDF up to 10MB',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
