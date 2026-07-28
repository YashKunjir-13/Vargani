import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/permissions/permission_guard.dart';
import '../../../core/permissions/user_role.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pauti_app_bar.dart';
import '../state/templates_notifier.dart';

class TemplateCalibrationScreen extends ConsumerStatefulWidget {
  const TemplateCalibrationScreen({super.key});

  @override
  ConsumerState<TemplateCalibrationScreen> createState() => _TemplateCalibrationScreenState();
}

class _TemplateCalibrationScreenState extends ConsumerState<TemplateCalibrationScreen> {
  String? selectedTemplateId;
  String? selectedMarkerId;

  @override
  Widget build(BuildContext context) {
    final templates = ref.watch(templatesProvider);
    final activeTemplate = ref.watch(activeTemplateProvider);
    final permissions = ref.watch(permissionsProvider);
    final theme = Theme.of(context);

    final currentTemplate = templates.firstWhere(
      (t) => t.id == (selectedTemplateId ?? activeTemplate.id),
      orElse: () => activeTemplate,
    );

    return Scaffold(
      appBar: PautiAppBar(
        title: L10n.tr(ref, 'template_calibration'),
        subtitle: 'Treasurer Portal',
        showBackButton: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;

          final canvasWidget = Column(
            children: [
              // Template Selector Dropdown & Action Toolbar
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: currentTemplate.id,
                      decoration: const InputDecoration(
                        labelText: 'Select Template',
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      items: templates
                          .map((t) => DropdownMenuItem(
                                value: t.id,
                                child: Text('${t.name} ${t.isActive ? "★ Active" : ""}'),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            selectedTemplateId = val;
                            selectedMarkerId = null;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Simulated template upload picker triggered')),
                      );
                    },
                    icon: const Icon(Icons.upload_file),
                    tooltip: L10n.tr(ref, 'upload_template'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Canvas Preview with Draggable Field Markers
              Expanded(
                child: AppCard(
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: LayoutBuilder(
                      builder: (context, canvasConstraints) {
                        final canvasWidth = canvasConstraints.maxWidth;
                        final canvasHeight = canvasConstraints.maxHeight;

                        return Stack(
                          children: [
                            // Simulated Receipt Paper Canvas
                            Container(
                              width: canvasWidth,
                              height: canvasHeight,
                              decoration: BoxDecoration(
                                color: theme.brightness == Brightness.dark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFFFFBEB),
                                border: Border.all(
                                  color: currentTemplate.isActive
                                      ? theme.colorScheme.primary
                                      : Colors.grey.shade400,
                                  width: currentTemplate.isActive ? 2 : 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // Header Banner Preview
                                  Positioned(
                                    top: 16,
                                    left: 20,
                                    right: 20,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            currentTemplate.mandalName,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.onPrimaryContainer,
                                            ),
                                          ),
                                          Text(
                                            'OFFICIAL PAUTI RECEIPT TEMPLATE',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              letterSpacing: 1.2,
                                              color: theme.colorScheme.onPrimaryContainer,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Watermark
                                  Center(
                                    child: Opacity(
                                      opacity: 0.08,
                                      child: Icon(
                                        Icons.account_balance,
                                        size: 160,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Draggable Field Marker Overlays
                            for (final marker in currentTemplate.markers) ...[
                              Positioned(
                                left: marker.position.dx * canvasWidth,
                                top: marker.position.dy * canvasHeight,
                                width: marker.size.width * canvasWidth,
                                height: marker.size.height * canvasHeight,
                                child: GestureDetector(
                                  onPanUpdate: (details) {
                                    final newDx = (marker.position.dx * canvasWidth + details.delta.dx) / canvasWidth;
                                    final newDy = (marker.position.dy * canvasHeight + details.delta.dy) / canvasHeight;

                                    final clampedDx = newDx.clamp(0.0, 1.0 - marker.size.width);
                                    final clampedDy = newDy.clamp(0.0, 1.0 - marker.size.height);

                                    ref.read(templatesProvider.notifier).updateMarkerPosition(
                                          currentTemplate.id,
                                          marker.id,
                                          Offset(clampedDx, clampedDy),
                                        );
                                  },
                                  onTap: () {
                                    setState(() {
                                      selectedMarkerId = marker.id;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 100),
                                    decoration: BoxDecoration(
                                      color: marker.color.withValues(alpha: 0.22),
                                      border: Border.all(
                                        color: selectedMarkerId == marker.id
                                            ? Colors.red
                                            : marker.color,
                                        width: selectedMarkerId == marker.id ? 2.5 : 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          marker.label,
                                          style: TextStyle(
                                            color: marker.color,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            // Instruction Hint Banner
                            Positioned(
                              bottom: 12,
                              left: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.touch_app, color: Colors.amber, size: 18),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Drag field boxes to align layout markers manually.',
                                        style: TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );

          final coordinatesPanel = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calibration Field Coordinates',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Precise bounding coordinates (X%, Y%) for print alignment.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: currentTemplate.markers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final m = currentTemplate.markers[index];
                    final isSelected = m.id == selectedMarkerId;

                    return Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? m.color.withValues(alpha: 0.12)
                            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? m.color : theme.colorScheme.outline,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(color: m.color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.label,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  'X: ${(m.position.dx * 100).toStringAsFixed(1)}% | Y: ${(m.position.dy * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Permission Gated Activate Button
              PermissionGuard(
                hasPermission: permissions.canActivateTemplate,
                fallbackTooltip: 'Admin or Auditor role required to activate receipt template',
                child: AppButton(
                  label: currentTemplate.isActive ? 'Template Active' : L10n.tr(ref, 'activate_template'),
                  variant: currentTemplate.isActive ? AppButtonVariant.secondary : AppButtonVariant.primary,
                  icon: currentTemplate.isActive ? Icons.check_circle : Icons.offline_pin,
                  onPressed: currentTemplate.isActive
                      ? null
                      : () {
                          ref.read(templatesProvider.notifier).activateTemplate(currentTemplate.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Activated template "${currentTemplate.name}" successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                ),
              ),
            ],
          );

          return Padding(
            padding: const EdgeInsets.all(16),
            child: isWide
                ? Row(
                    children: [
                      Expanded(flex: 3, child: canvasWidget),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: coordinatesPanel),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(flex: 3, child: canvasWidget),
                      const SizedBox(height: 16),
                      Expanded(flex: 2, child: coordinatesPanel),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
