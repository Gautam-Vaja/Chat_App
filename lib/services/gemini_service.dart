import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  String get apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<String> sendMessage(String message) async {
    if (apiKey.isEmpty) {
      return 'Error: Gemini API key is missing. Please set GEMINI_API_KEY in your .env file.';
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent',
    );
    final response = await http.post(
      url,
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': message},
            ],
          },
        ],
      }),
      headers: {'Content-Type': 'application/json', 'x-goog-api-key': apiKey},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      return 'Error: ${response.statusCode}\n${response.body}';
    }
  }
}
