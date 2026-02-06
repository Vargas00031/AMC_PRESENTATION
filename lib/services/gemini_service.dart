import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quadtalk/models/chat_message.dart';

class GeminiService {
  // 2. IMPORTANT: Replace with your actual API key, preferably from a secure source.
  static const String apiKey = 'AIzaSyDszYGO5XYWwVe2huG_M82GlUU7nYnrB-c';
  static const String apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent'; // Using Gemini 2.0 Flash for latest capabilities

  // 3. New private method to format entire chat history for API.
  static List<Map<String, dynamic>> _formatMessages(
      List<ChatMessage> messages,
      ) {
    return messages.map((msg) {
      // Use the 'role' property from ChatMessage ("user" or "model")
      return {
        'role': msg.role,
        'parts': [
          {'text': msg.text}
        ],
      };
    }).toList();
  }

  // 4. Renamed and updated the main method to handle multi-turn conversations.
  static Future<String> sendChatHistory(
      List<ChatMessage> conversationHistory,
      String persona,
      ) async {
    try {
      // Format the entire history.
      final formattedMessages = _formatMessages(conversationHistory);

      final Map<String, dynamic> requestBody = {
        'contents': formattedMessages,
        'generationConfig': {
          'temperature': 0.7,
          'topK': 1,
          'topP': 1,
          'maxOutputTokens': 2048,
        }
      };

      if (persona.trim().isNotEmpty) {
        requestBody['systemInstruction'] = {
          'parts': [
            {'text': persona}
          ]
        };
      }

      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle cases where the model might return no content
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'];
        }
        return 'Error: No content from API.';
      } else {
        // Provide more detailed error information.
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Network Error: $e';
    }
  }
}
