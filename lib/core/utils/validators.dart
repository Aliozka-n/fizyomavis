// lib/core/utils/validators.dart

class Validators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName alanı boş bırakılamaz';
    }
    return null;
  }

  static String? validateTitle(String? value) {
    return validateRequired(value, 'Başlık');
  }

  static String? validateDescription(String? value) {
    return validateRequired(value, 'Açıklama');
  }

  static String? validateCategory(String? value) {
    return validateRequired(value, 'Kategori');
  }
}
