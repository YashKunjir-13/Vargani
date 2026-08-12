import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// Where an [ApprovalStep] stands relative to the current step.
enum StepState { done, current, pending }

/// One step in an [ApprovalStepper], e.g. "Submitted" or "President".
@immutable
class ApprovalStep {
  final String label;
  final StepState state;

  const ApprovalStep({required this.label, required this.state});
}

/// A horizontal multi-level approval progress indicator (Budget's
/// Submitted -> Treasurer -> President -> Active flow).
///
/// Each step owns an equal-width [Expanded] slot containing both its dot
/// (with the connector line split across the slot's left/right halves) and
/// its label directly beneath -- this keeps the label always centered under
/// its dot regardless of step count, rather than trying to align two
/// independently-sized rows.
class ApprovalStepper extends StatelessWidget {
  final List<ApprovalStep> steps;

  const ApprovalStepper({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color connectorColorAfter(int index) {
      if (index < 0 || index >= steps.length) return Colors.transparent;
      return steps[index].state == StepState.done
          ? colorScheme.primary
          : colorScheme.outlineVariant;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          Expanded(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Container(
                            height: 2,
                            color: i == 0
                                ? Colors.transparent
                                : connectorColorAfter(i - 1))),
                    _StepDot(step: steps[i], index: i + 1),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i == steps.length - 1
                            ? Colors.transparent
                            : connectorColorAfter(i),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  steps[i].label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final ApprovalStep step;
  final int index;

  const _StepDot({required this.step, required this.index});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (Color background, Color foreground, Border? border) =
        switch (step.state) {
      StepState.done => (colorScheme.primary, colorScheme.onPrimary, null),
      StepState.current => (colorScheme.primary, colorScheme.onPrimary, null),
      StepState.pending => (
          colorScheme.surfaceContainerHighest,
          colorScheme.onSurfaceVariant,
          Border.all(color: colorScheme.outlineVariant),
        ),
    };

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
          color: background, shape: BoxShape.circle, border: border),
      alignment: Alignment.center,
      child: step.state == StepState.done
          ? Icon(Icons.check, size: 14, color: foreground)
          : Text('$index',
              style: textTheme.labelSmall
                  ?.copyWith(color: foreground, fontWeight: FontWeight.w800)),
    );
  }
}
