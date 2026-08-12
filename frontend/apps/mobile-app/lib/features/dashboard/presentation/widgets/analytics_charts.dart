import 'package:flutter/material.dart';
import 'package:pauti_pustak_mobile/features/authentication/presentation/widgets/auth_design_tokens.dart';
import 'package:pauti_pustak_mobile/features/dashboard/data/models/dashboard_models.dart';

class IncomeVsExpenseCard extends StatelessWidget {
  const IncomeVsExpenseCard({
    super.key,
    required this.incomePaise,
    required this.expensePaise,
  });

  final int incomePaise;
  final int expensePaise;

  String _formatAmount(int paise) {
    final rupees = (paise / 100).floor();
    return '₹${rupees.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.authColors;
    final total = incomePaise + expensePaise;
    final incomeRatio = total == 0 ? 0.5 : (incomePaise / total);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Income vs Expense',
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Ganpati 2025',
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 14,
              child: Row(
                children: [
                  Expanded(
                    flex: (incomeRatio * 100).round(),
                    child: Container(color: colors.brandOrange),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    flex: ((1 - incomeRatio) * 100).round(),
                    child: Container(color: Colors.redAccent),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 12,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors.brandOrange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Income',
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _formatAmount(incomePaise),
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Expense',
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _formatAmount(expensePaise),
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TopDonorsWidget extends StatelessWidget {
  const TopDonorsWidget({super.key, required this.topDonors});

  final List<TopDonorItem> topDonors;

  String _formatAmount(int paise) {
    final rupees = (paise / 100).floor();
    return '₹${rupees.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.authColors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Donors',
            style: TextStyle(
              color: colors.text,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          ...topDonors.map((donor) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: donor.rank == 1
                          ? colors.gold
                          : (donor.rank == 2
                              ? const Color(0xFFC0C0C0)
                              : (donor.rank == 3
                                  ? const Color(0xFFCD7F32)
                                  : colors.surfaceMuted)),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '#${donor.rank}',
                      style: TextStyle(
                        color: donor.rank <= 3 ? Colors.white : colors.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      donor.name,
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    _formatAmount(donor.amountPaise),
                    style: TextStyle(
                      color: colors.brandOrange,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class BudgetUtilizationWidget extends StatelessWidget {
  const BudgetUtilizationWidget({super.key, required this.budgets});

  final List<BudgetItem> budgets;

  @override
  Widget build(BuildContext context) {
    final colors = context.authColors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget Utilization',
            style: TextStyle(
              color: colors.text,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          ...budgets.map((b) {
            final percentage = b.spentPercentage;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        b.category,
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color:
                              percentage > 85 ? Colors.red : colors.brandOrange,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 8,
                      backgroundColor: colors.surfaceMuted,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentage > 85 ? Colors.red : colors.brandOrange,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
