import 'package:material_ui/material_ui.dart';

// Tema da interface de Leonardo, adaptado do protótipo da equipe.
final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4255D4)),
  scaffoldBackgroundColor: const Color(0xFFF5F6FA),
  appBarTheme: const AppBarThemeData(
    backgroundColor: Color(0xFFF5F6FA),
    foregroundColor: Color(0xFF20243A),
    centerTitle: false,
  ),
);
