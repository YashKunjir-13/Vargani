String formatPaiseAsRupees(int paise) {
  final rupees = paise / 100;
  final absolute = rupees.abs();
  final whole = absolute.floor();
  final cents = ((absolute - whole) * 100).round();
  final display = '$whole.${cents.toString().padLeft(2, '0')}';
  final formatted = display.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]},',
  );
  return paise >= 0 ? '₹$formatted' : '-₹$formatted';
}
