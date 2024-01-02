extension StringExtension on String {
  String toCapitalized() {
    return '${substring(0, 1).toUpperCase()}${substring(1)}';
  }

  String toInitials() {
    if (this.isEmpty) return '';
    var initials = '';
    final nameParts = this.split(' ');
    if (nameParts.length > 1) {
      initials = nameParts[0][0] + nameParts[1][0];
    } else {
      initials = nameParts[0][0];
    }
    return initials;
  }
}
