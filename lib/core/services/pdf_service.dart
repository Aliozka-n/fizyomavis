// lib/core/services/pdf_service.dart

import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/models/exercise_model.dart';

class PdfService {
  static Future<File> generateProgramPdf({
    required String programName,
    required String programDescription,
    required List<Exercise> exercises,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (context) => [
          // Program başlığı
          pw.Header(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  programName,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now()),
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),

          // Program açıklaması
          pw.Container(
            padding: pw.EdgeInsets.all(16),
            margin: pw.EdgeInsets.symmetric(vertical: 20),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              programDescription,
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey900,
              ),
            ),
          ),

          pw.SizedBox(height: 20),

          // Egzersiz sayısı
          pw.Text(
            'Toplam ${exercises.length} Egzersiz',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),

          pw.SizedBox(height: 20),

          // Egzersizler
          ...exercises.map((exercise) {
            return pw.Container(
              margin: pw.EdgeInsets.only(bottom: 20),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColors.grey300,
                  width: 1,
                ),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Padding(
                padding: pw.EdgeInsets.all(16),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Egzersiz resmi
                    pw.Container(
                      width: 150,
                      height: 120,
                      child: pw.ClipRRect(
                        horizontalRadius: 8,
                        verticalRadius: 8,
                        child: pw.Image(
                          pw.MemoryImage(
                            File(exercise.imageUrl).readAsBytesSync(),
                          ),
                          fit: pw.BoxFit.cover,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 16),

                    // Egzersiz detayları
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Başlık ve kategori
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Expanded(
                                child: pw.Text(
                                  exercise.title,
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                              pw.Container(
                                padding: pw.EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.grey100,
                                  borderRadius: pw.BorderRadius.circular(4),
                                ),
                                child: pw.Text(
                                  exercise.category,
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    color: PdfColors.grey900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 8),
                          pw.Divider(color: PdfColors.grey300),
                          pw.SizedBox(height: 8),

                          // Açıklama
                          pw.Text(
                            exercise.description,
                            style: pw.TextStyle(
                              fontSize: 12,
                              color: PdfColors.grey800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
        footer: (context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: pw.EdgeInsets.only(top: 20),
            child: pw.Text(
              'Sayfa ${context.pageNumber} / ${context.pagesCount}',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          );
        },
      ),
    );

    // PDF dosyasını kaydet
    final output = await getTemporaryDirectory();
    final fileName = '${programName}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');

    try {
      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e) {
      print('PDF kaydetme hatası: $e');
      rethrow;
    }
  }
}
