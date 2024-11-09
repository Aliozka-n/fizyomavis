// lib/presentation/widgets/add_exercise_form.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../viewmodels/exercise_viewmodel.dart';
import 'image_picker_widget.dart';

class AddExerciseForm extends StatefulWidget {
  @override
  _AddExerciseFormState createState() => _AddExerciseFormState();
}

class _AddExerciseFormState extends State<AddExerciseForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _selectedImage;
  String _selectedCategory = AppConstants.categories.first;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleImageSelected(File image) {
    setState(() {
      _selectedImage = image;
    });
  }

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen tüm alanları doldurun ve bir fotoğraf seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<ExerciseViewModel>().addExercise(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _selectedCategory,
            image: _selectedImage!,
          );

      Navigator.of(context).pop(); // Dialog'u kapat

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Egzersiz başarıyla eklendi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Egzersiz eklenirken bir hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Yeni ImagePicker widget'ı
            ImagePickerWidget(
              selectedImage: _selectedImage,
              onImageSelected: _handleImageSelected,
            ),
            SizedBox(height: 16),

            // Başlık alanı
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Başlık',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Lütfen bir başlık girin';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Açıklama alanı
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Açıklama',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Lütfen bir açıklama girin';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Kategori seçimi
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.category),
              ),
              items: AppConstants.categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            SizedBox(height: 24),

            // Kaydet butonu
            ElevatedButton(
              onPressed: _isLoading ? null : _saveExercise,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save),
                        SizedBox(width: 8),
                        Text('Kaydet'),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
