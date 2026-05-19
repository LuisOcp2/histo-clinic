String? requiredField(Object? value) {
  if (value == null) return 'Campo obligatorio';
  if (value is String && value.trim().isEmpty) return 'Campo obligatorio';
  return null;
}

String? emailField(Object? value) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty) return 'Campo obligatorio';
  final valid = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(text);
  return valid ? null : 'Email invalido';
}

String? minLengthField(Object? value, int min) {
  final text = value?.toString() ?? '';
  if (text.length < min) return 'Minimo $min caracteres';
  return null;
}
