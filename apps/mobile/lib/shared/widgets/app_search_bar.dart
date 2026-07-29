import 'package:flutter/material.dart';

/// A simple search bar with no clear button.
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({super.key, this.hint = 'Search', this.onChanged});

  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_outlined),
      ),
    );
  }
}
