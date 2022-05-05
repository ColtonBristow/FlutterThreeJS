dynamic translateNumber(
  num? value,
  List<num?> comparison, {
  String trns = 'null',
}) {
  if (comparison.contains(value)) return trns;
  return value;
}
