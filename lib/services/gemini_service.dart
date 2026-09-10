import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  String get apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  Stream<String> sendMessageStream(String message) async* {
    if (apiKey.isEmpty) {
      yield 'Error: Gemini API key is missing. Please set GEMINI_API_KEY in your .env file.';
      return;
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:streamGenerateContent?alt=sse',
    );

    final client = http.Client();
    final request = http.Request('POST', url)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      })
      ..body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': message},
            ],
          },
        ],
      });

    try {
      final response = await client.send(request);

      if (response.statusCode == 200) {
        final stream = response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        await for (final line in stream) {
          final trimmed = line.trim();
          if (trimmed.startsWith('data:')) {
            final jsonStr = trimmed.substring(5).trim();
            if (jsonStr.isNotEmpty) {
              try {
                final data = jsonDecode(jsonStr);
                final candidates = data['candidates'] as List?;
                if (candidates != null && candidates.isNotEmpty) {
                  final parts = candidates[0]['content']?['parts'] as List?;
                  if (parts != null && parts.isNotEmpty) {
                    final text = parts[0]['text'];
                    if (text != null && text is String) {
                      yield text;
                    }
                  }
                }
              } catch (_) {}
            }
          }
        }
      } else if (response.statusCode == 401) {
        yield '🔑 Authentication Error (401): Invalid API key. Please check your GEMINI_API_KEY in .env.';
      } else if (response.statusCode == 429) {
        yield '⏳ Rate limit reached (429). Please wait a few seconds before trying again.';
      } else {
        final errorBody = await response.stream.bytesToString();
        yield 'Error: ${response.statusCode}\n$errorBody';
      }
    } catch (e) {
      yield '⚠️ Connection error: Please check your internet connection.';
    } finally {
      client.close();
    }
  }

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
