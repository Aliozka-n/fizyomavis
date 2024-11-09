// lib/presentation/widgets/program_card.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/services/pdf_service.dart';
import '../../data/models/program_model.dart';
import '../viewmodels/exercise_viewmodel.dart';
import '../viewmodels/program_viewmodel.dart';

class ProgramCard extends StatelessWidget {
  final Program program;

  const ProgramCard({
    Key? key,
    required this.program,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ExerciseViewModel>(
      builder: (context, exerciseViewModel, child) {
        final exercises = exerciseViewModel.exercises.where((e) => program.exerciseIds.contains(e.id)).toList();

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Program başlığı ve menü
              ListTile(
                title: Text(
                  program.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                subtitle: Text(
                  '${exercises.length} egzersiz',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(context, value),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'pdf',
                      child: ListTile(
                        leading: Icon(Icons.picture_as_pdf),
                        title: Text('PDF Oluştur'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Sil', style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),

              // Program açıklaması
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  program.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

              // Egzersiz önizlemeleri
              if (exercises.isNotEmpty)
                Container(
                  height: 100,
                  margin: EdgeInsets.all(16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return Container(
                        width: 100,
                        margin: EdgeInsets.only(right: 8),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(exercise.imageUrl),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: Icon(Icons.image_not_supported),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              exercise.title,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              // Alt bilgi
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Oluşturulma: ${_formatDate(program.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _handleMenuAction(BuildContext context, String value) async {
    switch (value) {
      case 'pdf':
        await _generatePdf(context);
        break;
      case 'delete':
        await _confirmDelete(context);
        break;
    }
  }

  Future<void> _generatePdf(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('PDF oluşturuluyor...'),
                ],
              ),
            ),
          ),
        ),
      );

      final exercises = context.read<ExerciseViewModel>().exercises.where((e) => program.exerciseIds.contains(e.id)).toList();

      final pdfFile = await PdfService.generateProgramPdf(
        programName: program.name,
        programDescription: program.description,
        exercises: exercises,
      );

      if (context.mounted) Navigator.pop(context); // Loading dialog'unu kapat

      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        subject: program.name,
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Loading dialog'unu kapat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF oluşturulurken bir hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Programı Sil'),
        content: Text('Bu programı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<ProgramViewModel>().deleteProgram(program.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Program başarıyla silindi')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Program silinirken bir hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
