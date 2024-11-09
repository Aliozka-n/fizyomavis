# Fizyoterapi Takip Uygulaması

Bu Flutter uygulaması, fizyoterapistlerin hastalarına özel egzersiz programları oluşturmasını ve yönetmesini sağlayan bir mobil uygulamadır.

## Özellikler

### Egzersiz Yönetimi
- ✨ Egzersiz ekleme ve düzenleme
- 📱 Kamera veya galeriden fotoğraf ekleme
- 🏷️ Kategori bazlı sınıflandırma
- 🔍 Egzersiz arama ve filtreleme

### Program Oluşturma
- 📋 Özel egzersiz programları oluşturma
- ✅ Egzersiz seçme ve düzenleme
- 📑 Program detayları ve açıklamalar
- 📤 PDF olarak dışa aktarma

### PDF Çıktı
- 📄 Profesyonel PDF raporları
- 🖼️ Egzersiz görselleri ve açıklamaları
- 📱 Kolay paylaşım seçenekleri

## Kurulum

1. Flutter'ı yükleyin (https://flutter.dev/docs/get-started/install)
2. Projeyi klonlayın:
```bash
git clone https://github.com/Aliozka-n/fizyomavis.git
```
3. Bağımlılıkları yükleyin:
```bash
flutter pub get
```
4. Uygulamayı çalıştırın:
```bash
flutter run
```

## Kullanılan Teknolojiler

- 🎯 Flutter & Dart
- 💾 SQLite veritabanı
- 🖼️ Image Picker
- 📄 PDF oluşturma
- 🗄️ Provider state management

## Proje Yapısı

```
lib/
  ├── core/
  │   ├── constants/
  │   ├── theme/
  │   └── services/
  ├── data/
  │   ├── models/
  │   └── repositories/
  └── presentation/
      ├── screens/
      ├── widgets/
      └── viewmodels/
```

## Teşekkürler

- [Flutter](https://flutter.dev)
- [Provider](https://pub.dev/packages/provider)
- [SQLite](https://pub.dev/packages/sqflite)
- [Image Picker](https://pub.dev/packages/image_picker)
- [PDF](https://pub.dev/packages/pdf)
- [Share Plus](https://pub.dev/packages/share_plus)
