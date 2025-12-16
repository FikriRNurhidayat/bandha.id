enum DateOption {
  today('Today'),
  yesterday('Yesterday'),
  oneWeek('1 Week'),
  oneMonth('1 Month'),
  specific('Specific');

  final String label;
  const DateOption(this.label);
}
