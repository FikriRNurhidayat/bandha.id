isNull(dynamic value) {
  return value == null;
}

isZero(dynamic) {
  return isNull(dynamic) || dynamic == 0;
}
