import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/local_database.dart';
import 'screens/main_shell.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  await Hive.initFlutter();
  await LocalDatabase().init();

  runApp(const TrueGiftApp());
}

class TrueGiftApp extends StatelessWidget {
  const TrueGiftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'True Gift',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          
          // --- СВЕТЛАЯ ТЕМА ---
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            primaryColor: const Color(0xFF6366F1),
            scaffoldBackgroundColor: Colors.grey[100], 
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6366F1),
              brightness: Brightness.light,
              surface: Colors.white, // Цвет карточек светлой темы
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5)),
            ),
          ),
          
          // --- ТЁМНАЯ ТЕМА (ИСПРАВЛЕНА) ---
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF818CF8),
            scaffoldBackgroundColor: const Color(0xFF121212),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF818CF8),
              brightness: Brightness.dark,
              surface: const Color(0xFF1E1E1E), // Цвет карточек тёмной темы
            ),
            // Добавили стили полей для тёмной темы!
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF2C2C2C), // Тёмный фон у полей ввода
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF818CF8), width: 1.5)),
              hintStyle: const TextStyle(color: Colors.white38),
              labelStyle: const TextStyle(color: Colors.white70),
            ),
          ),
          home: const MainShell(), 
        );
      },
    );
  }
}