// lib/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/services/pdf_service.dart';
import '../screens/exercise_list_screen.dart';
import '../screens/program_list_screen.dart';
import '../viewmodels/exercise_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fizyoterapi Takip'),
        actions: [
          Consumer<ExerciseViewModel>(
            builder: (context, viewModel, child) {
              final selectedCount = viewModel.selectedExercises.length;
              return selectedCount > 0
                  ? Row(
                      children: [
                        Text(
                          '$selectedCount seçili',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        IconButton(
                          icon: Icon(Icons.picture_as_pdf),
                          tooltip: 'PDF Oluştur',
                          onPressed: () => _generatePdf(context),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          tooltip: 'Seçimi Temizle',
                          onPressed: () {
                            viewModel.clearSelection();
                          },
                        ),
                      ],
                    )
                  : SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Egzersizler butonu
            Card(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExerciseListScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.fitness_center,
                          size: 32,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Egzersizler',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tüm egzersizleri görüntüle ve yönet',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Programlar butonu
            Card(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProgramListScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.calendar_month,
                          size: 32,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Programlar',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Egzersiz programları oluştur ve takip et',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generatePdf(BuildContext context) async {
    final viewModel = context.read<ExerciseViewModel>();
    final selectedExercises = viewModel.selectedExercises;

    if (selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen en az bir egzersiz seçin'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
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
      );

      final pdfFile = await PdfService.generateProgramPdf(
        programName: 'Seçili Egzersizler',
        programDescription: 'Seçilmiş egzersiz listesi',
        exercises: selectedExercises,
      );

      if (context.mounted) Navigator.pop(context); // Loading dialog'unu kapat

      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        subject: 'Fizyoterapi Egzersizleri',
      );

      viewModel.clearSelection();
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Loading dialog'unu kapat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF oluşturulurken bir hata oluştu'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
