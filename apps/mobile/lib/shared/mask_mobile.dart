String maskMobile(String mobile, {required bool canViewSensitive}) {
  if (canViewSensitive || mobile.length <= 4) {
    return mobile;
  }

  final trimmed = mobile.replaceAll(RegExp(r'\D'), '');
  if (trimmed.length <= 4) {
    return trimmed;
  }

  final start = trimmed.substring(0, 2);
  final end = trimmed.substring(trimmed.length - 2);
  final middle = List.filled(trimmed.length - 4, '•').join();
  return '$start$middle$end';
}
