import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pauti_app_bar.dart';
import '../state/donation_flow_notifier.dart';
import '../state/payments_notifier.dart';

class SelectEventScreen extends ConsumerStatefulWidget {
  const SelectEventScreen({super.key});

  @override
  ConsumerState<SelectEventScreen> createState() => _SelectEventScreenState();
}

class _SelectEventScreenState extends ConsumerState<SelectEventScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    final dataSource = ref.read(paymentsRemoteDataSourceProvider);
    final list = await dataSource.fetchEvents();
    if (!mounted) return;
    setState(() {
      _events = list;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredEvents = _events.where((e) {
      final name = (e['name'] ?? e['title'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: const PautiAppBar(
        title: 'Collect Donation',
        subtitle: 'Step 1 of 10 • Select Event',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Demo Mode Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              color: Colors.amber.shade700,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lightbulb_outline, size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Demo Payment Mode • Mock Provider Active',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search festival / event...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredEvents.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.event_busy,
                                    size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text(
                                  'No active events found in database',
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Create an active event in Event Management or select a general festival fund to proceed.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13),
                                ),
                                const SizedBox(height: 24),
                                AppButton(
                                  label: 'Use Default Festival Fund',
                                  onPressed: () {
                                    final defaultEvent = {
                                      'id': 'general-festival-2026',
                                      'name': 'Ganesh Utsav 2026',
                                      'status': 'Active',
                                    };
                                    ref
                                        .read(donationFlowProvider.notifier)
                                        .selectEvent(defaultEvent);
                                    context.push('/donation/select-donor');
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = filteredEvents[index];
                            final eventName = (event['name'] ??
                                    event['title'] ??
                                    'Festival Event')
                                .toString();
                            final status =
                                (event['status'] ?? 'Active').toString();
                            final isSelected = ref
                                    .watch(donationFlowProvider)
                                    .selectedEvent?['id'] ==
                                event['id'];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: AppCard(
                                border: isSelected
                                    ? Border.all(
                                        color: theme.colorScheme.primary,
                                        width: 2)
                                    : null,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            eventName,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: status == 'Active'
                                                ? Colors.green.shade100
                                                : Colors.orange.shade100,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: status == 'Active'
                                                  ? Colors.green.shade800
                                                  : Colors.orange.shade800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    AppButton(
                                      label: isSelected
                                          ? 'Selected'
                                          : 'Select Event',
                                      variant: isSelected
                                          ? AppButtonVariant.secondary
                                          : AppButtonVariant.primary,
                                      onPressed: () {
                                        ref
                                            .read(donationFlowProvider.notifier)
                                            .selectEvent(event);
                                        context.push('/donation/select-donor');
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
