import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pauti_pustak_mobile/core/localization/localization_extensions.dart';

import 'auth_design_tokens.dart';
import 'auth_text_fields.dart';
import 'auth_validators.dart';
import 'language_selector.dart';

class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AuthAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.step,
  });

  final String title;
  final VoidCallback? onBack;
  final int? step;

  @override
  Size get preferredSize => const Size.fromHeight(82);

  @override
  Widget build(BuildContext context) {
    final colors = context.authColors;
    return AppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: colors.card,
      elevation: 0,
      leading: onBack == null
          ? null
          : IconButton(
              onPressed: onBack,
              icon: Icon(Icons.arrow_back_ios_new, color: colors.text, size: 20),
              tooltip: context.l10n.back,
            ),
      titleSpacing: onBack == null ? AuthSpacing.page : 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(color: colors.text, fontWeight: FontWeight.w800)),
          if (step != null) ...[
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                  3,
                  (index) => Container(
                        width: 20,
                        height: 3,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: index < step!
                              ? colors.brandOrange
                              : colors.border,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )),
            ),
          ],
        ],
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: AuthLanguageSelector(),
        )
      ],
    );
  }
}

class RegistrationIntroCard extends StatelessWidget {
  const RegistrationIntroCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.authColors;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.introCardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: colors.introCardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.brandOrange,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: colors.iconShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: colors.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                Text(description,
                    style: TextStyle(
                        color: colors.secondaryText, fontSize: 16, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RegistrationTypeCard extends StatelessWidget {
  const RegistrationTypeCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.authColors;
    return Semantics(
      button: true,
      label: '$title. $description',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: isSelected ? colors.typeCardBackground : colors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: isSelected ? colors.brandOrange : colors.border,
                  width: isSelected ? 2 : 1),
              boxShadow: isSelected
                  ? [BoxShadow(color: colors.cardShadow, blurRadius: 8, offset: const Offset(0, 4))]
                  : [],
            ),
            child: Row(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                    color: isSelected ? colors.brandOrange : colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: isSelected ? Colors.white : colors.secondaryText, size: 39),
              ),
              const SizedBox(width: 22),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(title,
                        style: TextStyle(
                            color: colors.text,
                            fontSize: 22,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 5),
                    Text(description,
                        style: TextStyle(
                            color: colors.secondaryText,
                            fontSize: 16,
                            height: 1.3)),
                  ])),
              Icon(Icons.chevron_right,
                  color: isSelected ? colors.brandOrange : colors.border, size: 30),
            ]),
          ),
        ),
      ),
    );
  }
}

class FormSectionCard extends StatelessWidget {
  const FormSectionCard({super.key, required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.authColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
              color: colors.cardShadow, blurRadius: 8, offset: const Offset(0, 3))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title.toUpperCase(),
            style: TextStyle(
                color: colors.secondaryText,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2)),
        const SizedBox(height: 24),
        child,
      ]),
    );
  }
}

class YearSelectionControl extends StatelessWidget {
  const YearSelectionControl(
      {super.key, required this.selectedYear, required this.onChanged});
  final int? selectedYear;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.authColors;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _years.map((year) {
        final selected = year == selectedYear;
        return ChoiceChip(
          label: SizedBox(width: 58, child: Center(child: Text('$year'))),
          selected: selected,
          onSelected: (_) => onChanged(year),
          selectedColor: colors.brandOrange,
          backgroundColor: colors.card,
          labelStyle: TextStyle(
              color: selected ? Colors.white : colors.secondaryText,
              fontWeight: FontWeight.w800),
          side: BorderSide(color: colors.border),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      }).toList(),
    );
  }
}

class LocationFormSection extends StatelessWidget {
  const LocationFormSection({
    super.key,
    required this.addressController,
    required this.cityController,
    required this.pinCodeController,
    this.onChanged,
    this.pinCodeOptional = true,
    this.extraField,
  });

  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController pinCodeController;
  final ValueChanged<String>? onChanged;
  final bool pinCodeOptional;
  final Widget? extraField;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cityField = AuthTextField(
      label: l10n.city,
      hint: l10n.cityHint,
      controller: cityController,
      onChanged: onChanged,
      validator: AuthValidators.required(l10n),
    );
    final pinCodeField = AuthTextField(
      label: l10n.pinCode,
      hint: l10n.pinCodeHint,
      controller: pinCodeController,
      onChanged: onChanged,
      optional: pinCodeOptional,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      validator: pinCodeOptional ? AuthValidators.pinCode(l10n) : AuthValidators.pinCodeRequired(l10n),
    );
    return FormSectionCard(
      title: l10n.location,
      child: Column(
        children: [
          AuthTextField(
            label: l10n.address,
            hint: l10n.addressHint,
            controller: addressController,
            onChanged: onChanged,
            optional: true,
          ),
          if (extraField != null) ...[
            const SizedBox(height: AuthSpacing.field),
            extraField!,
          ],
          const SizedBox(height: AuthSpacing.field),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 390) {
                return Column(
                  children: [
                    cityField,
                    const SizedBox(height: AuthSpacing.field),
                    pinCodeField,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: cityField),
                  const SizedBox(width: 16),
                  Expanded(child: pinCodeField),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

const _years = [2023, 2024, 2025, 2026];
