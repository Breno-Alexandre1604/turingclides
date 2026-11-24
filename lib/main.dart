import 'package:material_ui/material_ui.dart';

import 'presentation/quizzes/quiz_selection_screen.dart';

void main() {
  runApp(const TuringclidesApp());
}

class TuringclidesApp extends StatelessWidget {
  const TuringclidesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Turingclides',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF315C9B)),
        useMaterial3: true,
      ),
      home: const QuizSelectionScreen(),
    );
  }
}
