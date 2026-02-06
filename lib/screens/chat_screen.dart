import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quadtalk/models/chat_message.dart';
import 'package:quadtalk/models/persona.dart'; // Import personas
import 'package:quadtalk/providers/chat_provider.dart';
import 'package:quadtalk/widgets/input_bar.dart';
import 'package:quadtalk/widgets/message_bubble.dart';
import 'package:quadtalk/services/export_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String? initialPersona;

  const ChatScreen({super.key, required this.conversationId, this.initialPersona});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? _selectedPersonaName;

  @override
  void initState() {
    super.initState();
    
    // Set initial persona if provided
    if (widget.initialPersona != null) {
      setState(() {
        _selectedPersonaName = widget.initialPersona;
      });
      // Save persona to Hive for persistence
      _savePersonaToConversation(widget.initialPersona!);
    } else {
      _loadPersona();
    }
  }

  void _loadPersona() {
    final conversationBox = Hive.box('conversations');
    final conversation = conversationBox.get(widget.conversationId);
    if (conversation != null && conversation['persona'] != null) {
      setState(() {
        _selectedPersonaName = conversation['persona'];
      });
    }
  }

  void _savePersonaToConversation(String personaName) {
    final conversationBox = Hive.box('conversations');
    conversationBox.put(widget.conversationId, {
      'id': widget.conversationId,
      'persona': personaName,
      'lastMessage': '',
      'timestamp': DateTime.now(),
    });
  }

  void _selectPersona(Persona persona) {
    _savePersonaToConversation(persona.name);
    setState(() {
      _selectedPersonaName = persona.name;
    });
  }

  Future<void> _exportChat(bool asJson) async {
    try {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export not available on web platform'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      String filePath;
      if (asJson) {
        filePath = await ExportService.exportConversationAsJson(widget.conversationId);
      } else {
        filePath = await ExportService.exportConversation(widget.conversationId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chat exported to: $filePath'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedPersonaName ?? 'Select a Persona'),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        actions: _selectedPersonaName != null ? [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'export_txt') {
                await _exportChat(false);
              } else if (value == 'export_json') {
                await _exportChat(true);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_txt',
                child: Row(
                  children: [
                    Icon(Icons.description),
                    SizedBox(width: 8),
                    Text('Export as TXT'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_json',
                child: Row(
                  children: [
                    Icon(Icons.code),
                    SizedBox(width: 8),
                    Text('Export as JSON'),
                  ],
                ),
              ),
            ],
          ),
        ] : null,
      ),
      body: _selectedPersonaName == null
          ? _buildPersonaSelection()
          : _buildChatView(chatProvider),
    );
  }

  Widget _buildPersonaSelection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withAlpha(230),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withAlpha(77),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_search,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Choose Your AI Persona',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Select a specialized AI assistant for your conversation',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Persona Grid
            LayoutBuilder(
              builder: (context, constraints) {
                // Responsive grid: 1 column for small screens, 2 for medium, 3 for large
                int crossAxisCount = 1;
                if (constraints.maxWidth > 600) {
                  crossAxisCount = 2;
                }
                if (constraints.maxWidth > 1200) {
                  crossAxisCount = 3;
                }
                
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: personas.length,
                  itemBuilder: (context, index) {
                    final persona = personas[index];
                    return _buildPersonaCard(context, persona);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonaCard(BuildContext context, Persona persona) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            _selectPersona(persona);
            // Force rebuild to show chat view after persona selection
            setState(() {});
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  persona.primaryColor.withAlpha(200),
                  persona.secondaryColor.withAlpha(220),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: persona.primaryColor.withAlpha(51),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: persona.primaryColor.withAlpha(100),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Persona Icon with Animation
                  Hero(
                    tag: 'persona-${persona.name}',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: persona.primaryColor.withAlpha(50),
                        boxShadow: [
                          BoxShadow(
                            color: persona.primaryColor.withAlpha(77),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        persona.icon,
                        size: 36,
                        color: persona.primaryColor,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Persona Name
                  Text(
                    persona.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Persona Role
                  Text(
                    persona.role,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Domain Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withAlpha(30),
                    ),
                    child: Text(
                      persona.domain,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatView(ChatProvider chatProvider) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface.withAlpha(230),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<Box>(
              valueListenable: Hive.box('messages').listenable(),
              builder: (context, box, _) {
                final messages = box.values
                    .where(
                        (msg) => msg['conversationId'] == widget.conversationId)
                    .toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = ChatMessage.fromMap(
                        Map<String, dynamic>.from(messages[index]));
                    return MessageBubble(
                      message: message.text,
                      isMe: message.isUserMessage,
                    );
                  },
                );
              },
            ),
          ),
          if (chatProvider.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          InputBar(
            onSendMessage: (message) {
              if (_selectedPersonaName != null) {
                chatProvider.sendMessage(
                    message, widget.conversationId, _selectedPersonaName!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select a persona first'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
