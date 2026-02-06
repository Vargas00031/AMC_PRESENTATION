import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:quadtalk/models/chat_message.dart';
import 'package:quadtalk/models/persona.dart';
import 'package:quadtalk/services/gemini_service.dart';
import 'package:uuid/uuid.dart';

class ChatProvider with ChangeNotifier {
  final _messagesBox = Hive.box('messages');
  final _conversationsBox = Hive.box('conversations');
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> sendMessage(
    String text,
    String conversationId,
    String personaName,
  ) async {
    // Find the persona by name to get the system prompt
    final persona = personas.firstWhere(
      (p) => p.name == personaName,
      orElse: () => personas.first, // Fallback to first persona
    );

    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      conversationId: conversationId,
      text: text,
      role: 'user',
      timestamp: DateTime.now(),
    );
    await _messagesBox.add(userMessage.toMap());

    // Update conversation metadata
    await _conversationsBox.put(conversationId, {
      'id': conversationId,
      'persona': personaName,
      'lastMessage': text,
      'timestamp': DateTime.now(),
    });

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Fetch and prepare the conversation history
      final List<ChatMessage> conversationHistory = _messagesBox.values
          .map(
            (dynamic msg) =>
                ChatMessage.fromMap(Map<String, dynamic>.from(msg)),
          )
          .where((msg) => msg.conversationId == conversationId)
          .toList();

      // Sort messages by timestamp to ensure correct order
      conversationHistory.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // 2. Call the updated Gemini service method with system prompt
      final response = await GeminiService.sendChatHistory(
        conversationHistory,
        persona.systemPrompt,
      );

      final modelMessage = ChatMessage(
        id: const Uuid().v4(),
        conversationId: conversationId,
        text: response,
        role: 'model',
        timestamp: DateTime.now(),
      );
      await _messagesBox.add(modelMessage.toMap());
    } catch (e) {
      final errorMessage = ChatMessage(
        id: const Uuid().v4(),
        conversationId: conversationId,
        text: 'Error: ${e.toString()}',
        role: 'model',
        timestamp: DateTime.now(),
      );
      await _messagesBox.add(errorMessage.toMap());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
