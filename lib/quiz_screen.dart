import 'package:flutter/material.dart';
import 'package:quiz_app/api_service.dart';
import 'package:quiz_app/question.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _answered = false;
  String? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final questions = await ApiService.fetchQuestions();
    setState(() {
      _questions = questions;
    });
  }

  void _checkAnswer(String selectedAnswer) {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selectedAnswer = selectedAnswer;
      if (selectedAnswer == _questions[_currentQuestionIndex].correctAnswer) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answered = false;
        _selectedAnswer = null;
      });
    } else {
      _showScoreDialog();
    }
  }

  void _showScoreDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Quiz Complete',
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Score: $_score out of ${_questions.length}',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentQuestionIndex = 0;
                _score = 0;
                _answered = false;
                _selectedAnswer = null;
              });
            },
            child: const Text(
              'Press to Restart',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // changed: shrinks question font only when needed so the full question stays visible
  double _getFittedQuestionFontSize({
    required String text,
    required double maxWidth,
    required double maxHeight,
  }) {
    const double maxFontSize = 28;
    const double minFontSize = 14;

    for (double fontSize = maxFontSize; fontSize >= minFontSize; fontSize--) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 8, // changed: allows more wrapped lines before shrinking further
      )..layout(maxWidth: maxWidth);

      if (!textPainter.didExceedMaxLines && textPainter.height <= maxHeight) {
        return fontSize;
      }
    }

    return minFontSize;
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Score: $_score',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Level: ${currentQuestion.difficulty.toUpperCase()}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Question:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFAEC6FF),
                        ),
                      ),
                    ),
                    Text(
                      '${_currentQuestionIndex + 1}/${_questions.length}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // changed: flexible question area so long questions can take more room without overflowing
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final fittedFontSize = _getFittedQuestionFontSize(
                      text: currentQuestion.questionText,
                      maxWidth: constraints.maxWidth,
                      maxHeight: constraints.maxHeight,
                    );

                    return Center(
                      child: Text(
                        currentQuestion.questionText,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        maxLines: 8, // changed: lets long questions fully wrap
                        style: TextStyle(
                          fontSize: fittedFontSize, // changed: auto-fit question text
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            // changed: answer section also flexible so the whole screen can rebalance instead of overflowing
            Expanded(
              flex: 3,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentQuestion.options.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.45, // changed: slightly shorter buttons to free up space for long questions
                ),
                itemBuilder: (context, index) {
                  final option = currentQuestion.options[index];
                  Color buttonColor = const Color(0xFFFFF3A3);
                  double scale = 1.0;

                  if (_answered) {
                    if (option ==
                        _questions[_currentQuestionIndex].correctAnswer) {
                      buttonColor = const Color(0xFFA8E6A3);
                      scale = 1.04;
                    } else if (option == _selectedAnswer) {
                      buttonColor = const Color(0xFFFFB6C1);
                      scale = 0.96;
                    }
                  }

                  return AnimatedScale(
                    scale: scale,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(10),
                          elevation: 3,
                        ),
                        onPressed: () => _checkAnswer(option),
                        child: Center(
                          child: Text(
                            option,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 220,
                height: 85, // changed: slightly smaller so it doesn't cause bottom overflow
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAEC6FF),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor:
                        const Color(0xFFAEC6FF).withValues(alpha: 0.45),
                    disabledForegroundColor: Colors.black54,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _answered ? _nextQuestion : null,
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8), // changed: reduced bottom spacing to prevent overflow
          ],
        ),
      ),
    );
  }
}
