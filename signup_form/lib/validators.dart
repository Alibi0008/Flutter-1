String? validateName(String? v) {
  final value = (v ?? '').trim();
  if (value.length < 2) return 'Name is too short';
  return null;
}

String? validateEmail(String? v) {
  final value = (v ?? '').trim();
  final at = value.indexOf('@');
  if (at < 0) return 'Email looks wrong';
  if (!value.substring(at + 1).contains('.')) return 'Email looks wrong';
  return null;
}

String? validatePassword(String? v) {
  if (v == null || v.length < 8) return 'Password is too short';
  return null;
}

String? validateConfirm(String? v, String password) {
  final value = v ?? '';
  if (value.isEmpty || value != password) return 'Passwords do not match';
  return null;
}

String? validateGroup(String? g) => g == null ? 'Choose a group' : null;

String? validateBirth(DateTime? birth) {
  return birth == null ? 'Choose a date of birth' : null;
}
