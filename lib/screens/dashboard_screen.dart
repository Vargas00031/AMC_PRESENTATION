import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quadtalk/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
            ),
            const SizedBox(width: 8),
            const Text('HiveChat'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: Container(
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Welcome Section
              _buildWelcomeSection(context),
              
              const SizedBox(height: 48),
              
              // Get Started Button
              _buildGetStartedButton(context),
              
              const SizedBox(height: 48),
              
              // Features Showcase
              _buildFeaturesShowcase(context),
              
              const SizedBox(height: 48),
              
              // Recent Conversations
              _buildRecentConversations(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Column(
      children: [
        // App Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withAlpha(77),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // App Title
        Text(
          'Welcome to HiveChat',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        // Subtitle
        Text(
          'Experience AI conversations with specialized personas\nacross different domains and expertise',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withAlpha(77),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            try {
              final conversationId = const Uuid().v4();
              context.go('/chat/$conversationId');
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error navigating: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Get Started',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesShowcase(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why Choose HiveChat?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 24),
        
        // Feature Cards Grid
        LayoutBuilder(
          builder: (context, constraints) {
            // Responsive grid: 1 column for small screens, 2 for medium, 3 for large
            int crossAxisCount = 1;
            if (constraints.maxWidth > 600) {
              crossAxisCount = 2;
            }
            if (constraints.maxWidth > 900) {
              crossAxisCount = 3;
            }
            
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return _buildFeatureCard(
                  context,
                  _getFeatureData(index),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Map<String, dynamic> _getFeatureData(int index) {
    final features = [
      {
        'icon': Icons.person,
        'title': '5 AI Personas',
        'description': 'Specialized experts in different fields',
        'color': Colors.blue,
      },
      {
        'icon': Icons.chat,
        'title': 'Smart Chat',
        'description': 'Context-aware AI responses',
        'color': Colors.green,
      },
      {
        'icon': Icons.history,
        'title': 'Chat History',
        'description': 'Never lose your conversations',
        'color': Colors.orange,
      },
      {
        'icon': Icons.download,
        'title': 'Export',
        'description': 'Save chats as TXT or JSON',
        'color': Colors.purple,
      },
      {
        'icon': Icons.dark_mode,
        'title': 'Themes',
        'description': 'Light and dark mode support',
        'color': Colors.indigo,
      },
      {
        'icon': Icons.speed,
        'title': 'Fast',
        'description': 'Optimized for performance',
        'color': Colors.red,
      },
    ];
    return features[index];
  }

  Widget _buildFeatureCard(
    BuildContext context,
    Map<String, dynamic> feature,
  ) {
    final color = feature['color'] as Color;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            color.withAlpha(30),
            color.withAlpha(20),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: color.withAlpha(50),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              feature['icon'] as IconData,
              color: color,
              size: 28,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            feature['title'] as String,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            feature['description'] as String,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentConversations(BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('conversations').listenable(),
      builder: (context, box, _) {
        final conversations = box.values.toList().reversed.take(5).toList();
        
        if (conversations.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withAlpha(50),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.chat_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
                ),
                const SizedBox(height: 16),
                Text(
                  'No conversations yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start your first chat to see it here',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
                  ),
                ),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // Responsive layout based on screen width
            if (constraints.maxWidth > 800) {
              // Desktop/Tablet: Grid layout
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: constraints.maxWidth > 1200 ? 2 : 1,
                  childAspectRatio: 3.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  return _buildConversationCard(context, conversations[index]);
                },
              );
            } else {
              // Mobile: List layout
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  return _buildConversationCard(context, conversations[index]);
                },
              );
            }
          },
        );
      },
    );
  }

  Widget _buildConversationCard(BuildContext context, dynamic conversation) {
    final conversationId = conversation['id'];
    final persona = conversation['persona'] ?? 'Unknown';
    final lastMessage = conversation['lastMessage'] ?? 'No messages';
    final timestamp = conversation['timestamp'] as DateTime?;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          try {
            context.go('/chat/$conversationId');
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error navigating: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                radius: 24,
                child: Icon(
                  Icons.chat,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Chat with $persona',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastMessage.length > 50
                          ? '${lastMessage.substring(0, 50)}...'
                          : lastMessage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Timestamp
              if (timestamp != null) ...[
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${timestamp.day}/${timestamp.month}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
                      ),
                    ),
                    Text(
                      '${timestamp.year}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
