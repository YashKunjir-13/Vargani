import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/pauti_app_bar.dart';
import '../state/donation_flow_notifier.dart';
import '../state/payments_notifier.dart';

class SelectDonorScreen extends ConsumerStatefulWidget {
  const SelectDonorScreen({super.key});

  @override
  ConsumerState<SelectDonorScreen> createState() => _SelectDonorScreenState();
}

class _SelectDonorScreenState extends ConsumerState<SelectDonorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _donors = [];
  bool _isLoading = true;

  // New Donor Form
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _panCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _isCreatingDonor = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDonors(null);
  }

  Future<void> _loadDonors(String? query) async {
    setState(() => _isLoading = true);
    final dataSource = ref.read(paymentsRemoteDataSourceProvider);
    final list = await dataSource.fetchDonors(query);
    if (!mounted) return;
    setState(() {
      _donors = list;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _panCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitNewDonor() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isCreatingDonor = true);

    try {
      final dataSource = ref.read(paymentsRemoteDataSourceProvider);
      final created = await dataSource.createDonor(
        fullName: _nameCtrl.text.trim(),
        mobile: _mobileCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        pan: _panCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
      );

      if (!mounted) return;

      final newDonor = {
        'donorType': 'new',
        'id': created['id'],
        'name': created['fullName'] ?? _nameCtrl.text.trim(),
        'mobile': created['mobile'] ?? _mobileCtrl.text.trim(),
        'email': created['email'] ?? _emailCtrl.text.trim(),
        'pan': created['pan'] ?? _panCtrl.text.trim(),
        'address': created['address'] ?? _addressCtrl.text.trim(),
      };

      ref.read(donationFlowProvider.notifier).selectDonor(newDonor);
      context.push('/donation/amount');
    } catch (e) {
      if (!mounted) return;
      // Fallback: assign locally entered donor details for payment processing
      final newDonor = {
        'donorType': 'new',
        'name': _nameCtrl.text.trim(),
        'mobile': _mobileCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'pan': _panCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
      };
      ref.read(donationFlowProvider.notifier).selectDonor(newDonor);
      context.push('/donation/amount');
    } finally {
      if (mounted) setState(() => _isCreatingDonor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const PautiAppBar(
        title: 'Collect Donation',
        subtitle: 'Step 2 of 10 • Select Donor',
        showBackButton: true,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Existing Donor'),
              Tab(text: 'New Donor'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1: Existing Donor Live Search
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Search donor by Name or Mobile...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (val) {
                          _searchQuery = val;
                          _loadDonors(val);
                        },
                      ),
                    ),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _donors.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.person_search, size: 64, color: Colors.grey),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No registered donors found',
                                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Switch to "New Donor" tab to register a donor profile.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                        ),
                                        const SizedBox(height: 20),
                                        AppButton(
                                          label: 'Register New Donor',
                                          onPressed: () => _tabController.animateTo(1),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: _donors.length,
                                  itemBuilder: (context, index) {
                                    final donor = _donors[index];
                                    final name = (donor['fullName'] ?? donor['name'] ?? 'Donor').toString();
                                    final mobile = (donor['mobile'] ?? donor['contact'] ?? 'N/A').toString();
                                    final email = (donor['email'] ?? '').toString();

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: AppCard(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: theme.colorScheme.primaryContainer,
                                                  child: Text(
                                                    name.isNotEmpty ? name[0].toUpperCase() : 'D',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: theme.colorScheme.primary,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        name,
                                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                                      ),
                                                      Text(
                                                        'Mobile: $mobile${email.isNotEmpty ? ' • $email' : ''}',
                                                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            AppButton(
                                              label: 'Select Donor',
                                              onPressed: () {
                                                ref.read(donationFlowProvider.notifier).selectDonor({
                                                  'donorType': 'existing',
                                                  'id': donor['id'],
                                                  'name': name,
                                                  'mobile': mobile,
                                                  'email': email,
                                                });
                                                context.push('/donation/amount');
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

                // 2: New Donor Form
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          controller: _nameCtrl,
                          label: 'Full Name *',
                          hintText: 'Enter donor full name',
                          validator: (v) => v == null || v.trim().isEmpty ? 'Full name is required' : null,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _mobileCtrl,
                          label: 'Mobile Number *',
                          hintText: 'Enter 10-digit mobile number',
                          keyboardType: TextInputType.phone,
                          validator: (v) => v == null || v.trim().length < 10 ? 'Enter valid mobile number' : null,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _emailCtrl,
                          label: 'Email Address',
                          hintText: 'Enter email (optional)',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _panCtrl,
                          label: 'PAN Card (For 80G Tax Exemption)',
                          hintText: 'Enter 10-character PAN (optional)',
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _addressCtrl,
                          label: 'Address',
                          hintText: 'Enter donor address (optional)',
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          label: 'Save & Select Donor',
                          isLoading: _isCreatingDonor,
                          onPressed: _isCreatingDonor ? null : _submitNewDonor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
