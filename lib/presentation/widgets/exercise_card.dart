// lib/presentation/widgets/exercise_card.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/exercise_model.dart';
import '../viewmodels/exercise_viewmodel.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;

  const ExerciseCard({
    Key? key,
    required this.exercise,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // PDF için seçim
          context.read<ExerciseViewModel>().toggleExercise(exercise.id);
        },
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fotoğraf
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.file(
                          File(exercise.imageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Icon(Icons.image_not_supported, size: 50),
                            );
                          },
                        ),
                      ),
                    ),
                    if (exercise.isSelected)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                  ],
                ),

                // İçerik
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Text(
                        exercise.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 8),
                      Chip(
                        label: Text(exercise.category),
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Seçim göstergesi
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    exercise.isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: exercise.isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                  ),
                  onPressed: () {
                    context.read<ExerciseViewModel>().toggleExercise(exercise.id);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
