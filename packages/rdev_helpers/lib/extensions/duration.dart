/// Extension to handle parses from dart.Duration to other types
extension DurationExtension on Duration {
  /// Parses Duration to a readable format
  /// if >= 1h -> HH:mm:ss
  /// if < 1h -> mm:ss
  /// if < 1m -> 00:ss
  String toPrettySimpleFormat() {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    if (inSeconds < 60) {
      return "00:${twoDigits(inSeconds)}";
    } else if (inMinutes < 60) {
      return "${twoDigits(inMinutes)}:${twoDigits(inSeconds.remainder(60))}";
    } else {
      return "${twoDigits(inHours)}:${twoDigits(inMinutes.remainder(60))}:${twoDigits(inSeconds.remainder(60))}";
    }
  }

  String toDetailsPageFormat() {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    if (inSeconds < 60) {
      return "00:${twoDigits(inSeconds)} sec";
    } else if (inMinutes < 60) {
      return "${twoDigits(inMinutes)} min";
    } else {
      return "${twoDigits(inHours)}} hr";
    }
  }
}
