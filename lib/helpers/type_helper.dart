isNull(dynamic value) {
  return value == null;
}

isZero(dynamic) {
  return isNull(dynamic) || dynamic == 0;
}

isEmpty(List<dynamic>? value) {
  return isNull(value) || value!.isEmpty;
}
