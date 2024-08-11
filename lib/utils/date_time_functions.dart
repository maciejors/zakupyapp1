/// DD/MM/YYYY, godz. HH:mm
String dateTimeToPolishString(DateTime dateTime) {
  return '${dateTime.day.toString().padLeft(2, '0')}/'
      '${dateTime.month.toString().padLeft(2, '0')}/'
      '${dateTime.year}, godz. ${dateTime.hour}:'
      '${dateTime.minute.toString().padLeft(2, '0')}';
}
