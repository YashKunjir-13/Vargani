import 'package:flutter/material.dart';

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.label = 'Loading...'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 12),
        Text(label),
      ],
    );
  }
}
