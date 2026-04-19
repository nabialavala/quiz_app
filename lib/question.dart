//package to fully decode html
import 'package:html_unescape/html_unescape.dart';

class Question {
  final String questionText;
  final String correctAnswer;
  final List<String> options;
  final String difficulty;

  Question({
    required this.questionText,
    required this.correctAnswer,
    required this.options,
    required this.difficulty,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final unescape = HtmlUnescape();
    List<String> allOptions = List<String>.from(json['incorrect_answers'].map((answer) => unescape.convert(answer)));
    final decodedDifficulty = json['difficulty'];

    final decodedCorrectAnswer = unescape.convert(json['correct_answer']);
    allOptions.add(decodedCorrectAnswer);
    allOptions.shuffle();

    return Question(
      questionText: unescape.convert(json['question']),
      correctAnswer: decodedCorrectAnswer,
      options: allOptions,
      difficulty: decodedDifficulty,
    );
  }
}