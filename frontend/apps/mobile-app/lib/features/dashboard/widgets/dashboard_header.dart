import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/dashboard_models.dart';

class DashboardHeader extends StatelessWidget {
  final DashboardHeaderInfo info;

  const DashboardHeader({super.key, required this.info});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFB74D), Color(0xFFFF9933), Color(0xFFFB8500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$_greeting, ${info.userName} 🙏',
                  style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                tooltip: 'Notifications',
                onPressed: () => context.pushNamed('dashboard-notifications'),
                icon: Badge(
                  label: Text('${info.unreadNotificationCount}'),
                  isLabelVisible: info.unreadNotificationCount > 0,
                  child: const Icon(Icons.notifications_outlined,
                      color: Colors.white),
                ),
              ),
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white24,
                child:
                    Icon(Icons.person_outline, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            info.organizationName,
            style: theme.textTheme.headlineSmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            info.festivalName,
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Festival Day ${info.festivalDay} of ${info.festivalTotalDays}',
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
