/// Lightweight date/time formatting so we don't pull in `intl` for three uses.
class Formatters {
  Formatters._();

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// `Feb 28`
  static String monthDay(DateTime d) => '${_months[d.month - 1]} ${d.day}';

  /// `6:00 PM`
  static String time(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  /// `28 Feb, 6:00 PM`
  static String dayMonthTime(DateTime d) =>
      '${d.day} ${_months[d.month - 1]}, ${time(d)}';

  /// Human relative label, e.g. `2h ago`, `Yesterday`, `3d ago`.
  static String relative(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return monthDay(d);
  }
}
