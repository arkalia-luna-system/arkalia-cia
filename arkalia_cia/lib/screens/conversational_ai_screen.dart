import 'package:flutter/material.dart';
import '../services/conversational_ai_service.dart';

class ConversationalAIScreen extends StatefulWidget {
  const ConversationalAIScreen({super.key});

  @override
  State<ConversationalAIScreen> createState() => _ConversationalAIScreenState();
}

class _ConversationalAIScreenState extends State<ConversationalAIScreen> {
  final ConversationalAIService _aiService = ConversationalAIService();
  final TextEditingController _questionController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _aiService.getConversationHistory(limit: 20);
    if (history.isNotEmpty && mounted) {
      setState(() {
        // Ajouter messages historiques (sans doublons)
        for (var conv in history.reversed) {
          if (!_messages.any((m) => m.text == conv['question'])) {
            _messages.insert(1, ChatMessage(
              text: conv['question'],
              isUser: true,
              timestamp: DateTime.parse(conv['created_at']),
            ));
            _messages.insert(2, ChatMessage(
              text: conv['answer'],
              isUser: false,
              timestamp: DateTime.parse(conv['created_at']),
            ));
          }
        }
      });
    }
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      text: 'Bonjour ! Je suis votre assistant santé intelligent. Posez-moi une question sur vos médecins, examens, douleurs ou médicaments.',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> _sendMessage() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    // Ajouter message utilisateur
    setState(() {
      _messages.add(ChatMessage(
        text: question,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _questionController.clear();
      _isLoading = true;
    });

    // Obtenir réponse IA
    try {
      final response = await _aiService.askQuestion(question);
      
      setState(() {
        _messages.add(ChatMessage(
          text: response.answer,
          isUser: false,
          timestamp: DateTime.now(),
          suggestions: response.suggestions,
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        final errorMessage = e.toString();
        String userMessage;
        
        if (errorMessage.contains('Backend non configuré')) {
          userMessage = '⚠️ Backend non configuré.\n\nVeuillez configurer l\'URL du backend dans les paramètres (⚙️ > Backend API).';
        } else if (errorMessage.contains('Failed host lookup') || errorMessage.contains('Connection refused')) {
          userMessage = '⚠️ Impossible de se connecter au backend.\n\nVérifiez que le backend est démarré et que l\'URL est correcte dans les paramètres.';
        } else {
          userMessage = '⚠️ Erreur: ${errorMessage.contains("Exception:") ? errorMessage.split("Exception:")[1].trim() : errorMessage}';
        }
        
        _messages.add(ChatMessage(
          text: userMessage,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant IA Santé'),
        actions: [
          IconButton(
            icon: Icon(_showHistory ? Icons.chat : Icons.history),
            onPressed: () {
              setState(() {
                _showHistory = !_showHistory;
              });
            },
            tooltip: _showHistory ? 'Masquer historique' : 'Afficher historique',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('À propos'),
                  content: const Text(
                    'Cet assistant analyse vos données de santé pour répondre à vos questions. '
                    'Vos données restent privées et sécurisées.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Liste messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // Indicateur chargement
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          
          // Barre saisie
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      hintText: 'Posez votre question...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.smart_toy,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                
                // Suggestions
                if (message.suggestions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: message.suggestions.map((suggestion) {
                      return ActionChip(
                        label: Text(suggestion),
                        onPressed: () {
                          _questionController.text = suggestion;
                          _sendMessage();
                        },
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String> suggestions;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestions = const [],
  });
}

