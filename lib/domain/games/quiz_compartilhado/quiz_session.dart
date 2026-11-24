import 'quiz_question.dart';

class QuizSession {
  QuizSession(this.question);

  final QuizQuestion question;
  int? selectedOptionIndex;
  int? confirmedOptionIndex;

  bool get isConfirmed => confirmedOptionIndex != null;

  bool get canConfirm => selectedOptionIndex != null && !isConfirmed;

  bool get isCorrect =>
      confirmedOptionIndex == question.correctOptionIndex;

  void selectOption(int index) {
    RangeError.checkValidIndex(index, question.options);
    if (isConfirmed) {
      return;
    }

    selectedOptionIndex = index;
  }

  bool confirmSelection() {
    if (!canConfirm) {
      return false;
    }

    confirmedOptionIndex = selectedOptionIndex;
    return true;
  }
}
