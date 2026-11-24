import 'package:material_ui/material_ui.dart';

import 'app/app_theme.dart';
import 'data/quiz_history_repository.dart';
import 'presentation/home/home_screen.dart';

void main() {
  runApp(const TuringclidesApp());
}

class TuringclidesApp extends StatelessWidget {
  const TuringclidesApp({super.key, this.repository});

  final QuizHistoryRepository? repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Turingclides',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: HomeScreen(repository: repository),
    );
  }
}
