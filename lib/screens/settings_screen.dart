import 'package:flutter/material.dart';
import '../main.dart'; // Импортируем для доступа к themeNotifier

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
              ],
            ),
            child: ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, currentMode, child) {
                final isDark = currentMode == ThemeMode.dark;
                return SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  title: const Text('Тёмная тема', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Меньше нагрузки на глаза ночью'),
                  secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: Colors.indigo),
                  value: isDark,
                  activeThumbColor: Colors.indigo,
                  onChanged: (bool value) {
                    themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}