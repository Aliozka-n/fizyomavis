// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/exercise_repository.dart';
import 'presentation/viewmodels/exercise_viewmodel.dart';
import 'presentation/views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Repository instance'ını oluştur
  final repository = ExerciseRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ExerciseViewModel(repository),
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
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Sistem temasını kullan
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Tüm metinler için varsayılan stil
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(),
          child: child!,
        );
      },
    );
  }
}
