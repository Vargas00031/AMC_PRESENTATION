import 'package:hive/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 0)
class ChatMessage extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String conversationId;

  @HiveField(2)
  final String text;

  @HiveField(3)
  final String role; // "user" or "model"

  @HiveField(4)
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.text,
    required this.role,
    required this.timestamp,
  });

  bool get isUserMessage => role == 'user';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'text': text,
      'role': role,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      conversationId: map['conversationId'],
      text: map['text'],
      role: map['role'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
