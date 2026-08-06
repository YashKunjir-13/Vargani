import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../../../shared/widgets/formatters.dart';
import '../models/vendor.dart';
import 'vendor_contract_status_badge.dart';

class VendorListItem extends StatelessWidget {
  const VendorListItem({super.key, required this.vendor, required this.onTap});

  final Vendor vendor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendor.name,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space4),
                        Text(
                          [vendor.category, vendor.contactPerson]
                              .whereType<String>()
                              .where((value) => value.isNotEmpty)
                              .join(' • '),
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.mutedTextFor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  VendorContractStatusBadge(status: vendor.contractStatus),
                ],
              ),
              const SizedBox(height: AppSpacing.space16),
              Row(
                children: [
                  Expanded(
                    child: _Metric(
                        label: 'Contract',
                        value: formatPaiseAsRupees(vendor.contractAmountPaise),
                        color: AppColors.mutedTextFor(context)),
                  ),
                  Expanded(
                    child: _Metric(
                        label: 'Paid',
                        value: formatPaiseAsRupees(vendor.paidAmountPaise),
                        color: AppColors.lightSuccess),
                  ),
                  Expanded(
                    child: _Metric(
                      label: 'Balance',
                      value: formatPaiseAsRupees(vendor.outstandingAmountPaise),
                      color: vendor.outstandingAmountPaise > 0
                          ? AppColors.lightError
                          : AppColors.lightSuccess,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(
      {required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.mutedTextFor(context),
          ),
        ),
        const SizedBox(height: AppSpacing.space4),
        Text(
          value,
          style: textTheme.bodyLarge?.copyWith(color: color),
        ),
      ],
    );
  }
}
