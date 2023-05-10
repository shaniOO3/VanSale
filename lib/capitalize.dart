extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

extension CapExtension on String {
  String get capitalizeFirstofEach =>
      split(" ").map((str) => str.capitalize).join(" ");
}
