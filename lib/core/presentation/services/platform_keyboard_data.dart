class PlatformKeyboardData {
  final bool visible;
  final double height;

  const PlatformKeyboardData({required this.visible, required this.height});

  static const hidden = PlatformKeyboardData(visible: false, height: 0);
}
