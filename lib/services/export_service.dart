import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:quadtalk/models/chat_message.dart';

class ExportService {
  static Future<String> exportConversation(String conversationId) async {
    try {
      final messagesBox = Hive.box('messages');
      final conversationsBox = Hive.box('conversations');
      
      // Get conversation metadata
      final conversation = conversationsBox.get(conversationId);
      final persona = conversation?['persona'] ?? 'Unknown';
      
      // Get all messages for this conversation
      final messages = messagesBox.values
          .where((msg) => msg['conversationId'] == conversationId)
          .toList()
          ..sort((a, b) => DateTime.parse(a['timestamp'])
              .compareTo(DateTime.parse(b['timestamp'])));

      if (messages.isEmpty) {
        return 'No messages to export.';
      }

      // Create export content
      final buffer = StringBuffer();
      buffer.writeln('=== Chat Export ===');
      buffer.writeln('Persona: $persona');
      buffer.writeln('Date: ${DateTime.now().toString().split('.')[0]}');
      buffer.writeln('Total Messages: ${messages.length}');
      buffer.writeln('');
      
      for (final msg in messages) {
        final chatMessage = ChatMessage.fromMap(Map<String, dynamic>.from(msg));
        final sender = chatMessage.isUserMessage ? 'User' : persona;
        final timestamp = chatMessage.timestamp.toString().split('.')[0];
        
        buffer.writeln('[$timestamp] $sender:');
        buffer.writeln(chatMessage.text);
        buffer.writeln('');
        buffer.writeln('---');
        buffer.writeln('');
      }

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'chat_${conversationId}_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(buffer.toString());
      
      return file.path;
    } catch (e) {
      throw Exception('Failed to export chat: $e');
    }
  }

  static Future<String> exportConversationAsJson(String conversationId) async {
    try {
      final messagesBox = Hive.box('messages');
      final conversationsBox = Hive.box('conversations');
      
      // Get conversation metadata
      final conversation = conversationsBox.get(conversationId);
      final persona = conversation?['persona'] ?? 'Unknown';
      
      // Get all messages for this conversation
      final messages = messagesBox.values
          .where((msg) => msg['conversationId'] == conversationId)
          .toList()
          ..sort((a, b) => DateTime.parse(a['timestamp'])
              .compareTo(DateTime.parse(b['timestamp'])));

      // Create JSON export
      final exportData = {
        'conversationId': conversationId,
        'persona': persona,
        'exportDate': DateTime.now().toIso8601String(),
        'totalMessages': messages.length,
        'messages': messages,
      };

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'chat_${conversationId}_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(exportData));
      
      return file.path;
    } catch (e) {
      throw Exception('Failed to export chat as JSON: $e');
    }
  }
}
