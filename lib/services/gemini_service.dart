import 'dart:convert';

import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey = 'AQ.Ab8RN6IBFamc0yeDjuW3nGK3zKKuZvODyR71krWelrLLiNgHPg';
  Future<String> sendMessage(String message) async {
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
