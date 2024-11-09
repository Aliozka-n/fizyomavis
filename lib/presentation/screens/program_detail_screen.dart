// lib/presentation/screens/program_detail_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/exercise_model.dart';
import '../../data/models/exercise_program.dart';
import '../viewmodels/exercise_viewmodel.dart';

class ProgramDetailScreen extends StatefulWidget {
  final ExerciseProgram program;

  const ProgramDetailScreen({
    Key? key,
    required this.program,
  }) : super(key: key);

  @override
  _ProgramDetailScreenState createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends State<ProgramDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.program.weekDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.program.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Program düzenleme ekranına git
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Programı paylaş
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: List.generate(
            widget.program.weekDuration,
            (index) => Tab(text: '${index + 1}. Hafta'),
          ),
        ),
      ),
      body: Column(
        children: [
          // Program bilgileri
          Container(
            padding: EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Program başlığı
                Text(
                  widget.program.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 8),

                // Program açıklaması
                Text(
                  widget.program.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                SizedBox(height: 16),

                // Program özeti
                Row(
                  children: [
                    _buildInfoCard(
                      context,
                      Icons.calendar_today,
                      '${widget.program.weekDuration} Hafta',
                    ),
                    SizedBox(width: 16),
                    _buildInfoCard(
                      context,
                      Icons.fitness_center,
                      '${_getTotalExercises()} Egzersiz',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Haftalık egzersiz listesi
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(
                widget.program.weekDuration,
                (weekIndex) => _buildWeekView(weekIndex + 1),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startProgram(context),
        icon: Icon(Icons.play_arrow),
        label: Text('Programa Başla'),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView(int weekNumber) {
    final exerciseIds = widget.program.weeklyExercises[weekNumber] ?? [];

    if (exerciseIds.isEmpty) {
      return Center(
        child: Text('Bu hafta için egzersiz bulunmuyor'),
      );
    }

    return Consumer<ExerciseViewModel>(
      builder: (context, viewModel, child) {
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: exerciseIds.length,
          itemBuilder: (context, index) {
            final exerciseId = exerciseIds[index];
            final exercise = viewModel.exercises.firstWhere(
              (e) => e.id == exerciseId,
              orElse: () => Exercise(
                id: 'unknown',
                title: 'Bilinmeyen Egzersiz',
                description: '',
                category: '',
                imageUrl: '',
              ),
            );

            if (exercise.id == 'unknown') {
              return SizedBox(); // Egzersiz bulunamadıysa gösterme
            }

            return Card(
              margin: EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () {
                  // Egzersiz detay sayfasına git
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Egzersiz fotoğrafı
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          image: DecorationImage(
                            image: FileImage(File(exercise.imageUrl)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    // Egzersiz bilgileri
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  exercise.title,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  exercise.category,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            exercise.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  int _getTotalExercises() {
    int total = 0;
    widget.program.weeklyExercises.forEach((week, exercises) {
      total += exercises.length;
    });
    return total;
  }

  void _startProgram(BuildContext context) {
    // Program başlatma mantığını ekle
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Program Başlat'),
        content: Text('Bu programı başlatmak istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Program başlatma işlemleri
            },
            child: Text('Başlat'),
          ),
        ],
      ),
    );
  }
}
