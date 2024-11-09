// lib/presentation/views/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/services/pdf_service.dart';
import '../viewmodels/exercise_viewmodel.dart';
import '../widgets/add_exercise_form.dart';
import '../widgets/exercise_card.dart';
import '../widgets/filter_dialog_content.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fizyoterapi Takip'),
        actions: [
          Consumer<ExerciseViewModel>(
            builder: (context, viewModel, child) {
              final selectedCount = viewModel.selectedExercises.length;
              if (selectedCount > 0) {
                return Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '$selectedCount seçildi',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.picture_as_pdf),
                      tooltip: 'PDF Oluştur',
                      onPressed: () => _generatePdf(context),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      tooltip: 'Seçimi Temizle',
                      onPressed: () => viewModel.clearSelection(),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.filter_list),
                    tooltip: 'Filtrele',
                    onPressed: () => _showFilterDialog(context),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<ExerciseViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    viewModel.error!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.loadExercises(),
                    icon: Icon(Icons.refresh),
                    label: Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.exercises.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Henüz egzersiz eklenmemiş',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Yeni egzersiz eklemek için + butonuna dokunun',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.loadExercises(),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: viewModel.exercises.length,
              itemBuilder: (context, index) {
                final exercise = viewModel.exercises[index];
                return ExerciseCard(
                  exercise: exercise,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExerciseDialog(context),
        icon: Icon(Icons.add),
        label: Text('Yeni Egzersiz'),
        tooltip: 'Yeni Egzersiz Ekle',
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Kategoriye Göre Filtrele'),
        content: FilterDialogContent(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showAddExerciseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          child: AddExerciseForm(),
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
          margin: EdgeInsets.all(20),
        ),
      );
      return;
    }

    try {
      // Yükleniyor göstergesi
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'PDF oluşturuluyor...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8),
                Text(
                  '${selectedExercises.length} egzersiz işleniyor',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      );

      // PDF oluştur
      final pdfFile = await PdfService.generateExercisePdf(selectedExercises);

      // Yükleniyor dialogunu kapat
      if (context.mounted) Navigator.pop(context);

      if (!await pdfFile.exists()) {
        throw Exception('PDF dosyası oluşturulamadı');
      }

      // PDF'i paylaş
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        subject: 'Fizyoterapi Egzersizleri',
      );

      // Seçimi temizle
      if (context.mounted) {
        viewModel.clearSelection();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF başarıyla oluşturuldu'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(20),
          ),
        );
      }
    } catch (e) {
      // Hata durumunda yükleniyor dialogunu kapat
      if (context.mounted) Navigator.pop(context);

      // Hata mesajını göster
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF oluşturulurken bir hata oluştu: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(20),
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Tekrar Dene',
              textColor: Colors.white,
              onPressed: () => _generatePdf(context),
            ),
          ),
        );
      }
    }
  }
}
