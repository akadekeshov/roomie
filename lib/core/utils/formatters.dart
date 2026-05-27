String formatDateRu(DateTime? value) {
  if (value == null) return 'Не указано';
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString();
  return '$day.$month.$year';
}

String formatMoneyKzt(int? amount) {
  if (amount == null) return 'Не указано';
  final raw = amount.toString();
  final reversed = raw.split('').reversed.join();
  final chunks = <String>[];
  for (var index = 0; index < reversed.length; index += 3) {
    final end = (index + 3).clamp(0, reversed.length);
    chunks.add(reversed.substring(index, end));
  }
  final formatted = chunks
      .map((chunk) => chunk.split('').reversed.join())
      .toList()
      .reversed
      .join(' ');
  return '$formatted KZT';
}
