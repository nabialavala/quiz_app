import 'dart:convert';
import 'package:http/http.dart' as http;
import 'question.dart';

class ApiService {
  static Future<List<Question>> fetchQuestions() async{
    try {
      //API endpoint
      final String url = 'https://opentdb.com/api_config.php';
      final response = await http.get(Uri.parse(url));
      //stores JSON text
      final data = jsonDecode(response.body);
      final List<Question> questions = (data['results'] as List)
        .map((item) => Question.fromJson(item))
        .toList();
      return questions;
    } catch (e) {
      throw Exception("Couldn't load questions");
    }
  }
}