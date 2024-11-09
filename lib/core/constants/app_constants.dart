// lib/core/constants/app_constants.dart

class AppConstants {
  // Uygulama adı
  static const String appName = 'Fizyoterapi Takip';

  // Veritabanı sabitleri
  static const String dbName = 'physio_exercises.db';
  static const int dbVersion = 1;
  static const String exercisesTable = 'exercises';

  // Dosya yolları
  static const String imagesFolder = 'exercise_images';

  // Kategori listesi
  static const List<String> categories = [
    'Genel',
    'Boyun',
    'Sırt',
    'Bel',
    'Omuz',
    'Diz',
    'Ayak Bileği',
  ];

  // Hata mesajları
  static const String errorLoadingExercises = 'Egzersizler yüklenirken bir hata oluştu';
  static const String errorSavingExercise = 'Egzersiz kaydedilirken bir hata oluştu';
  static const String errorDeletingExercise = 'Egzersiz silinirken bir hata oluştu';
  static const String errorGeneratingPdf = 'PDF oluşturulurken bir hata oluştu';

  // Başarı mesajları
  static const String exerciseAdded = 'Egzersiz başarıyla eklendi';
  static const String exerciseUpdated = 'Egzersiz başarıyla güncellendi';
  static const String exerciseDeleted = 'Egzersiz başarıyla silindi';
  static const String pdfGenerated = 'PDF başarıyla oluşturuldu';
}
