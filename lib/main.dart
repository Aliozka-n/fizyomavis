// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/exercise_repository.dart';
import 'data/repositories/program_repository.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/viewmodels/exercise_viewmodel.dart';
import 'presentation/viewmodels/program_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Repository'leri oluştur
  final exerciseRepository = ExerciseRepository();
  final programRepository = ProgramRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ExerciseViewModel(exerciseRepository),
        ),
        ChangeNotifierProvider(
          create: (context) => ProgramViewModel(programRepository),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fizyoterapi Takip',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
      ),
      home: HomeScreen(),
    );
  }
}
