// lib/presentation/widgets/filter_dialog_content.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../viewmodels/exercise_viewmodel.dart';

class FilterDialogContent extends StatelessWidget {
  const FilterDialogContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ExerciseViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tüm egzersizler seçeneği
            ListTile(
              leading: Radio<String?>(
                value: null,
                groupValue: viewModel.selectedCategory,
                onChanged: (value) {
                  viewModel.filterByCategory(value);
                  Navigator.pop(context);
                },
              ),
              title: Text('Tüm Egzersizler'),
              onTap: () {
                viewModel.filterByCategory(null);
                Navigator.pop(context);
              },
            ),

            // Kategori listesi
            ...AppConstants.categories.map(
              (category) => ListTile(
                leading: Radio<String?>(
                  value: category,
                  groupValue: viewModel.selectedCategory,
                  onChanged: (value) {
                    viewModel.filterByCategory(value);
                    Navigator.pop(context);
                  },
                ),
                title: Text(category),
                onTap: () {
                  viewModel.filterByCategory(category);
                  Navigator.pop(context);
                },
              ),
            ),

            SizedBox(height: 16),

            // Alt butonlar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      viewModel.filterByCategory(null);
                      Navigator.pop(context);
                    },
                    child: Text('Filtreyi Temizle'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Kapat'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
