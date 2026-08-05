import 'package:flutter/foundation.dart';

@immutable
class ReportCategoryItem {
  final String title;
  final String description;
  final String routeId;
  final String formatBadge;

  const ReportCategoryItem({
    required this.title,
    required this.description,
    required this.routeId,
    required this.formatBadge,
  });
}
