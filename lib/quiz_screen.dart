import 'package:flutter/material.dart';
import 'package:quiz_app/api_service.dart';
import 'package:quiz_app/question.dart';

class QuizScreen extends StatefulWidget{
    const QuizScreen({super.key});

    @override
    State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
    List<Question> _questions = [];
    int _currentQuestionIndex = 0;
    int _score = 0;
    bool _answered = false;

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
        //question already answered
        if (_answered) return;
        setState(() {
          _answered = true;
          //answer is checked
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
            });
        } else {
            _showScoreDialog();
        }
    }

    void _showScoreDialog() {
        showDialog(
            context: context,
            //Prevents user from closing unless the press the button
            barrierDismissible: false,
            builder: (context) => AlertDialog(
                title: const Text('Quiz Complete'),
                content: Text('Your Score: $_score out of ${_questions.length}'),
                actions: [
                    TextButton(
                        onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                                _currentQuestionIndex = 0;
                                _score = 0;
                                _answered = false;
                            });
                        },
                        child: const Text('Press to Restart'),
                    ),
                ],
            ),
        );
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

        return Scaffold(
            appBar: AppBar(
                title: const Text('Quiz App'),
            ),
            body: Padding(
                padding: const EdgeInsetsGeometry.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                        Text(
                            'Current Score: $_score',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                            ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                            currentQuestion.questionText, 
                            style: const TextStyle(fontSize: 22), 
                        ),
                        const SizedBox(height: 20),
                        //
                        ...currentQuestion.options.map((option) {
                            return Padding(
                                padding: const EdgeInsetsGeometry.symmetric(vertical: 5),
                                child: ElevatedButton(
                                    onPressed: _answered ? null : () => _checkAnswer(option),
                                    child: Text(option),
                                ),
                            );
                        }).toList(),
                        const SizedBox(height: 20),
                        ElevatedButton(
                            onPressed: _answered ? _nextQuestion : null,
                            child: const Text('Next'),
                        )
                    ],
                ),
            ),
        );
    }
}