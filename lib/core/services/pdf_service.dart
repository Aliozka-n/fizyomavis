// lib/core/services/pdf_service.dart

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/models/exercise_model.dart';

class PdfService {
  static Future<File> generateExercisePdf(List<Exercise> exercises) async {
    final pdf = pw.Document();

    // Font yükleme
    final regularFont = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final boldFont = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');

    final ttfRegular = pw.Font.ttf(regularFont);
    final ttfBold = pw.Font.ttf(boldFont);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: ttfRegular,
          bold: ttfBold,
        ),
        build: (context) => [
          // Başlık
          pw.Header(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'Fizyoterapi Egzersiz Programı',
                  style: pw.TextStyle(
                    font: ttfBold,
                    fontSize: 24,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now()),
                  style: pw.TextStyle(
                    font: ttfRegular,
                    fontSize: 14,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Toplam ${exercises.length} Egzersiz',
                  style: pw.TextStyle(
                    font: ttfBold,
                    fontSize: 14,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.Divider(thickness: 2),
              ],
            ),
          ),

          // Egzersizler
          ...exercises.map((exercise) {
            return pw.Padding(
              padding: pw.EdgeInsets.only(bottom: 20),
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColors.grey300,
                    width: 0.5,
                  ),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Padding(
                  padding: pw.EdgeInsets.all(12),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Sol taraf - Fotoğraf
                      pw.Container(
                        width: 180,
                        height: 140,
                        child: _buildImage(exercise.imageUrl),
                      ),

                      pw.SizedBox(width: 16),

                      // Sağ taraf - Başlık ve Açıklama
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            // Başlık
                            pw.Text(
                              exercise.title,
                              style: pw.TextStyle(
                                font: ttfBold,
                                fontSize: 16,
                              ),
                            ),

                            pw.SizedBox(height: 8),

                            // Kategori
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
                                  font: ttfRegular,
                                  fontSize: 10,
                                  color: PdfColors.grey900,
                                ),
                              ),
                            ),

                            pw.SizedBox(height: 12),

                            // Açıklama
                            pw.Text(
                              exercise.description,
                              style: pw.TextStyle(
                                font: ttfRegular,
                                fontSize: 12,
                                color: PdfColors.grey800,
                                lineSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                font: ttfRegular,
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
    final fileName = 'Fizyoterapi_Egzersizleri_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');

    try {
      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e) {
      print('PDF kaydetme hatası: $e');
      rethrow;
    }
  }

  static pw.Widget _buildImage(String imagePath) {
    try {
      final imageFile = File(imagePath);
      if (imageFile.existsSync()) {
        final imageBytes = imageFile.readAsBytesSync();
        return pw.ClipRRect(
          horizontalRadius: 8,
          verticalRadius: 8,
          child: pw.Image(
            pw.MemoryImage(imageBytes),
            fit: pw.BoxFit.cover,
          ),
        );
      }
    } catch (e) {
      print('Resim yükleme hatası: $e');
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      padding: pw.EdgeInsets.all(8),
      child: pw.Center(
        child: pw.Text(
          'Resim yüklenemedi',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            color: PdfColors.grey700,
          ),
        ),
      ),
    );
  }
}
