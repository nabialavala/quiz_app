class Question {
  final String questionText;
  final String correctAnswer;
  final List<String> options;

  Question({
    required this.questionText,
    required this.correctAnswer,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    List<String> allOptions = List<String>.from(json['incorrect_answers']);
    allOptions.add(json['correct_answer']);
    allOptions.shuffle();

    return Question(
      questionText: json['question'],
      correctAnswer: json['correct_answer'],
      options: allOptions,
    );
  }
}