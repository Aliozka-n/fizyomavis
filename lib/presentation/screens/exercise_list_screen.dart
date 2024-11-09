// lib/presentation/screens/exercise_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/exercise_viewmodel.dart';
import '../widgets/exercise_card.dart';
import '../widgets/filter_dialog_content.dart';
import 'add_exercise_screen.dart';

class ExerciseListScreen extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Egzersizler'),
        actions: [
          Consumer<ExerciseViewModel>(
            builder: (context, viewModel, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.filter_list),
                    onPressed: () => _showFilterDialog(context),
                  ),
                  if (viewModel.selectedCategory != null)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
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
            return Center(child: CircularProgressIndicator());
          }

          if (viewModel.exercises.isEmpty) {
            // Eğer filtreleme aktifse ve sonuç boşsa
            if (viewModel.selectedCategory != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.filter_list_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '${viewModel.selectedCategory} kategorisinde egzersiz bulunamadı',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        viewModel.filterByCategory(null);
                      },
                      child: Text('Filtreyi Temizle'),
                    ),
                  ],
                ),
              );
            }

            // Hiç egzersiz yoksa
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Henüz egzersiz eklenmemiş',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddExerciseScreen(),
                        ),
                      );
                    },
                    child: Text('Egzersiz Ekle'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Aktif filtre göstergesi
              if (viewModel.selectedCategory != null)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Row(
                    children: [
                      Icon(Icons.filter_list),
                      SizedBox(width: 8),
                      Text(
                        'Kategori: ${viewModel.selectedCategory}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: () {
                          viewModel.filterByCategory(null);
                        },
                        child: Text('Temizle'),
                      ),
                    ],
                  ),
                ),

              // Egzersiz listesi
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: viewModel.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = viewModel.exercises[index];
                    return ExerciseCard(exercise: exercise);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExerciseScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Yeni Egzersiz',
      ),
    );
  }
}
