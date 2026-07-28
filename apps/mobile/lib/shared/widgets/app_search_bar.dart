import 'package:flutter/material.dart';

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
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear_outlined),
          onPressed: () {},
        ),
      ),
    );
  }
}
