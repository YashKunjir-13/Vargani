import 'package:flutter/material.dart';

import '../../../shared/ui_kit/charts/mini_sparkline.dart';
import '../models/dashboard_models.dart';

class ChartCard extends StatelessWidget {
  final List<ChartTabData> tabs;

  const ChartCard({super.key, required this.tabs});

  @override
  Widget build(BuildContext context) {
    if (tabs.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return DefaultTabController(
      length: tabs.length,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              indicatorColor: theme.colorScheme.primary,
              dividerColor: Colors.transparent,
              tabs: tabs.map((tab) => Tab(text: tab.title)).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: TabBarView(
                children: tabs
                    .map(
                      (tab) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: MiniSparkline(
                          values: tab.values,
                          color: theme.colorScheme.primary,
                          style: SparklineStyle.bar,
                          labels: tab.labels,
                          height: 100,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
