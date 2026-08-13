import 'package:flutter/material.dart';

import '../../shared/ui_kit/cards/alert_card.dart';
import 'models/notification_models.dart';

/// Per-category channel control, quiet hours, and digest frequency -- with
/// an explicit banner whenever a setting is organization-locked, so a
/// Volunteer never wonders why a toggle won't move.
class NotificationSettingsScreen extends StatefulWidget {
  final List<NotificationCategorySetting> categories;
  final String quietHoursStart;
  final String quietHoursEnd;
  final bool quietHoursEnabled;
  final String digestFrequency;
  final bool weeklySummaryEnabled;

  const NotificationSettingsScreen({
    super.key,
    required this.categories,
    required this.quietHoursStart,
    required this.quietHoursEnd,
    required this.quietHoursEnabled,
    required this.digestFrequency,
    required this.weeklySummaryEnabled,
  });

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final List<NotificationCategorySetting> _categories = [];
  late bool _quietHoursEnabled = widget.quietHoursEnabled;
  late String _digestFrequency = widget.digestFrequency;
  late bool _weeklySummaryEnabled = widget.weeklySummaryEnabled;

  static const _digestOptions = ['Immediate', 'Hourly digest', 'Daily digest'];

  @override
  void initState() {
    super.initState();
    _categories.addAll(widget.categories);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AlertCard(
            icon: Icons.info_outline,
            title: 'Some settings are organization-managed',
            subtitle: 'Security Alerts cannot be muted by any role.',
            tone: AlertTone.info,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Categories', style: textTheme.titleMedium),
              Text('E · Email  P · Push  A · In-App',
                  style: textTheme.labelSmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < _categories.length; i++) ...[
                  _CategoryRow(
                    setting: _categories[i],
                    onChanged: (updated) =>
                        setState(() => _categories[i] = updated),
                  ),
                  if (i != _categories.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Quiet hours', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: SwitchListTile(
              title:
                  Text('${widget.quietHoursStart} – ${widget.quietHoursEnd}'),
              value: _quietHoursEnabled,
              onChanged: (value) => setState(() => _quietHoursEnabled = value),
            ),
          ),
          const SizedBox(height: 24),
          Text('Reminder frequency', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: _digestOptions
                .map((o) => ButtonSegment(value: o, label: Text(o)))
                .toList(),
            selected: {_digestFrequency},
            showSelectedIcon: false,
            onSelectionChanged: (s) =>
                setState(() => _digestFrequency = s.first),
          ),
          const SizedBox(height: 24),
          Card(
            margin: EdgeInsets.zero,
            child: SwitchListTile(
              title: const Text('Weekly summary email'),
              subtitle: const Text('Every Monday, 8 AM'),
              value: _weeklySummaryEnabled,
              onChanged: (value) =>
                  setState(() => _weeklySummaryEnabled = value),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final NotificationCategorySetting setting;
  final ValueChanged<NotificationCategorySetting> onChanged;

  const _CategoryRow({required this.setting, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(setting.name),
      subtitle: Text(setting.description),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ChannelDot(
            label: 'E',
            enabled: setting.emailEnabled,
            onTap: setting.isLocked
                ? null
                : () => onChanged(
                    setting.copyWith(emailEnabled: !setting.emailEnabled)),
          ),
          _ChannelDot(
            label: 'P',
            enabled: setting.pushEnabled,
            onTap: setting.isLocked
                ? null
                : () => onChanged(
                    setting.copyWith(pushEnabled: !setting.pushEnabled)),
          ),
          _ChannelDot(
            label: 'A',
            enabled: setting.inAppEnabled,
            onTap: setting.isLocked
                ? null
                : () => onChanged(
                    setting.copyWith(inAppEnabled: !setting.inAppEnabled)),
          ),
        ],
      ),
    );
  }
}

class _ChannelDot extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  const _ChannelDot(
      {required this.label, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: enabled
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
          ),
          child: Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: enabled
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
