import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/features/authentication/presentation/widgets/auth_design_tokens.dart';
import 'package:pauti_pustak_mobile/features/dashboard/presentation/widgets/action_sheets.dart';

class SearchMandalScreen extends ConsumerStatefulWidget {
  const SearchMandalScreen({super.key});

  @override
  ConsumerState<SearchMandalScreen> createState() => _SearchMandalScreenState();
}

class _SearchMandalScreenState extends ConsumerState<SearchMandalScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Mock data for Mandals
  final List<Map<String, String>> _allMandals = [
    {'name': 'Shree Siddhivinayak Ganpati Mandal', 'city': 'Mumbai'},
    {'name': 'Dagdusheth Halwai Ganpati', 'city': 'Pune'},
    {'name': 'Lalbaugcha Raja Sarvajanik Ganeshotsav Mandal', 'city': 'Mumbai'},
    {'name': 'Tulshibaug Ganpati Mandal', 'city': 'Pune'},
    {'name': 'Chintamani Ganpati Mandal', 'city': 'Mumbai'},
    {'name': 'Kasba Ganpati', 'city': 'Pune'},
    {'name': 'Guruji Talim Mandal', 'city': 'Pune'},
    {'name': 'Kesari Wada Ganpati', 'city': 'Pune'},
  ];

  List<Map<String, String>> _filteredMandals = [];

  @override
  void initState() {
    super.initState();
    _filteredMandals = List.from(_allMandals);
  }

  void _filterMandals(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredMandals = List.from(_allMandals);
      });
      return;
    }
    
    setState(() {
      _filteredMandals = _allMandals.where((mandal) {
        final nameLower = mandal['name']!.toLowerCase();
        final cityLower = mandal['city']!.toLowerCase();
        final searchLower = query.toLowerCase();
        return nameLower.contains(searchLower) || cityLower.contains(searchLower);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.authColors;
    
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
              onChanged: _filterMandals,
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          Expanded(
            child: _filteredMandals.isEmpty
                ? Center(
                    child: Text(
                      'No mandals found',
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredMandals.length,
                    itemBuilder: (context, index) {
                      final mandal = _filteredMandals[index];
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
                              child: Icon(Icons.temple_hindu, color: colors.brandOrange),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mandal['name']!,
                                    style: TextStyle(
                                      color: colors.text,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, size: 14, color: colors.secondaryText),
                                      const SizedBox(width: 4),
                                      Text(
                                        mandal['city']!,
                                        style: TextStyle(
                                          color: colors.secondaryText,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
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
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              onPressed: () {
                                DashboardActionSheets.showCollectDonationSheet(
                                  context,
                                  ref: ref,
                                  mandalName: mandal['name'],
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
                  ),
          ),
        ],
      ),
    );
  }
}
