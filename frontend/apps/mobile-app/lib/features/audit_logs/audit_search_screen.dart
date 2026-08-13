import 'package:flutter/material.dart';

import '../../shared/ui_kit/surfaces/empty_state.dart';
import 'models/audit_models.dart';

/// Enterprise search across receipts, vendors, users, budgets and audit
/// IDs -- instant and debounced (debounce happens at the provider layer,
/// see Step 9), with matches highlighted so a result is scannable without
/// opening it.
class AuditSearchScreen extends StatefulWidget {
  final List<String> recentSearches;
  final Future<List<AuditSearchResult>> Function(String query) onSearch;

  const AuditSearchScreen(
      {super.key, required this.recentSearches, required this.onSearch});

  @override
  State<AuditSearchScreen> createState() => _AuditSearchScreenState();
}

class _AuditSearchScreenState extends State<AuditSearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  List<AuditSearchResult> _results = [];
  bool _searched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _runSearch(String query) async {
    setState(() => _query = query);
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _searched = false;
      });
      return;
    }
    final results = await widget.onSearch(query);
    if (!mounted) return;
    setState(() {
      _results = results;
      _searched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final moduleCount = _results.map((r) => r.moduleLabel).toSet().length;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search audit, users, receipts…',
            border: InputBorder.none,
          ),
          onChanged: _runSearch,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _query.isEmpty
            ? _RecentSearches(
                searches: widget.recentSearches,
                onTap: (s) {
                  _controller.text = s;
                  _runSearch(s);
                })
            : (_searched && _results.isEmpty)
                ? EmptyState(
                    icon: Icons.search_off,
                    title: 'No results for "$_query"',
                    message:
                        'Check spelling, or try a user name, receipt number, or Audit ID.',
                  )
                : ListView(
                    children: [
                      Text(
                        '${_results.length} results · $moduleCount modules',
                        style: textTheme.labelMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      for (final result in _results)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(result.icon,
                              color: colorScheme.onSurfaceVariant),
                          title: Text.rich(
                            TextSpan(
                              style: textTheme.bodyLarge,
                              children: [
                                TextSpan(text: result.beforeMatch),
                                TextSpan(
                                  text: result.matchText,
                                  style: TextStyle(
                                    backgroundColor:
                                        colorScheme.primaryContainer,
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(text: result.afterMatch),
                              ],
                            ),
                          ),
                          subtitle: Text(
                              '${result.moduleLabel} · ${result.timeLabel}'),
                        ),
                    ],
                  ),
      ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  final List<String> searches;
  final ValueChanged<String> onTap;

  const _RecentSearches({required this.searches, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENT SEARCHES',
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final search in searches)
              ActionChip(label: Text(search), onPressed: () => onTap(search)),
          ],
        ),
      ],
    );
  }
}
