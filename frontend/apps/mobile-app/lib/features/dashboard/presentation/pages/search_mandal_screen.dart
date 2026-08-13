import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/features/authentication/presentation/widgets/auth_design_tokens.dart';
import 'package:pauti_pustak_mobile/features/dashboard/presentation/pages/mandal_details_screen.dart';
import 'package:pauti_pustak_mobile/features/dashboard/presentation/providers/mandal_search_providers.dart';

class SearchMandalScreen extends ConsumerStatefulWidget {
  const SearchMandalScreen({super.key});

  @override
  ConsumerState<SearchMandalScreen> createState() => _SearchMandalScreenState();
}

class _SearchMandalScreenState extends ConsumerState<SearchMandalScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(mandalSearchProvider.notifier).fetchMandals(query: query);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.authColors;
    final mandalsState = ref.watch(mandalSearchProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.card,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.text),
        title: Text(
          'Search Mandal',
          style: TextStyle(
            color: colors.text,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: colors.card,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(color: colors.text),
              decoration: InputDecoration(
                hintText: 'Search mandal or city...',
                hintStyle: TextStyle(color: colors.secondaryText),
                prefixIcon: Icon(Icons.search, color: colors.secondaryText),
                filled: true,
                fillColor: colors.surfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          Expanded(
            child: mandalsState.when(
              loading: () => Center(
                child: CircularProgressIndicator(color: colors.brandOrange),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_off,
                          size: 48, color: colors.secondaryText),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to load mandals',
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please check your connection and try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: colors.secondaryText, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.brandOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          ref
                              .read(mandalSearchProvider.notifier)
                              .fetchMandals(query: _searchController.text);
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (mandals) {
                if (mandals.isEmpty) {
                  final isSearching = _searchController.text.trim().isNotEmpty;
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.temple_hindu_outlined,
                            size: 48, color: colors.secondaryText),
                        const SizedBox(height: 16),
                        Text(
                          isSearching
                              ? 'No mandals found'
                              : 'No mandals available',
                          style: TextStyle(
                            color: colors.secondaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: mandals.length,
                  itemBuilder: (context, index) {
                    final mandal = mandals[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.border),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: colors.surfaceMuted,
                            radius: 24,
                            child: Icon(Icons.temple_hindu,
                                color: colors.brandOrange),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mandal.name,
                                  style: TextStyle(
                                    color: colors.text,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        size: 14, color: colors.secondaryText),
                                    const SizedBox(width: 4),
                                    Text(
                                      mandal.city.isNotEmpty
                                          ? mandal.city
                                          : 'Maharashtra',
                                      style: TextStyle(
                                        color: colors.secondaryText,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (mandal.code.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '(${mandal.code})',
                                        style: TextStyle(
                                          color: colors.secondaryText,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.brandOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MandalDetailsScreen(organization: mandal),
                                ),
                              );
                            },
                            child: const Text(
                              'Donate',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
