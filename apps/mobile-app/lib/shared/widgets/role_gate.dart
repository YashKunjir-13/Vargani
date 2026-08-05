import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/core.dart';

class RoleGate extends ConsumerWidget {
  const RoleGate({
    super.key,
    required this.allowedRoles,
    required this.child,
  });

  final List<Role> allowedRoles;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRole = ref.watch(roleProvider);
    return allowedRoles.contains(currentRole) ? child : const SizedBox.shrink();
  }
}
