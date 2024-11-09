// lib/presentation/screens/program_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/program_viewmodel.dart';
import '../widgets/program_card.dart';
import 'add_program_screen.dart';

class ProgramListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Egzersiz Programları'),
      ),
      body: Consumer<ProgramViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(
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
                    size: 48,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(viewModel.error!),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.loadPrograms(),
                    icon: Icon(Icons.refresh),
                    label: Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.programs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.playlist_add,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Henüz program eklenmemiş',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: viewModel.programs.length,
            itemBuilder: (context, index) {
              final program = viewModel.programs[index];
              return ProgramCard(program: program);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProgramScreen(),
            ),
          );
        },
        icon: Icon(Icons.add),
        label: Text('Program Ekle'),
      ),
    );
  }
}
