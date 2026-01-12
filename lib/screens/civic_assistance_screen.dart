import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';
import '../providers/app_provider.dart';
import '../services/gemini_service.dart';

class CivicAssistanceScreen extends StatefulWidget {
  const CivicAssistanceScreen({super.key});

  @override
  State<CivicAssistanceScreen> createState() => _CivicAssistanceScreenState();
}

class _CivicAssistanceScreenState extends State<CivicAssistanceScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  static const String _chatHistoryKey = 'civic_chat_history';

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_chatHistoryKey);

      if (historyJson != null) {
        final List<dynamic> decoded = json.decode(historyJson);
        setState(() {
          _messages.clear();
          _messages.addAll(
            decoded.map((item) => ChatMessage.fromJson(item)).toList(),
          );
        });
      } else {
        // Add welcome message if no history
        _addWelcomeMessage();
      }
    } catch (e) {
      _addWelcomeMessage();
    }
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        ChatMessage(
          text:
              'Hello! 👋 I\'m your Civic Assistant AI.\n\nI can help you with:\n• Legal rights & procedures\n• Government schemes\n• RTI & public services\n• Consumer rights\n• Civic documentation\n\nAsk me anything!',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
    _saveChatHistory();
  }

  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(
        _messages.map((msg) => msg.toJson()).toList(),
      );
      await prefs.setString(_chatHistoryKey, encoded);
    } catch (e) {
      // Silent fail
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(
        ChatMessage(text: message, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    _messageController.clear();
    _saveChatHistory();
    _scrollToBottom();

    try {
      final provider = context.read<AppProvider>();
      final response = await GeminiService.instance.getCivicAssistanceResponse(
        message,
        provider.selectedLanguage,
      );

      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: response,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isLoading = false;
        });
        _saveChatHistory();
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: 'Sorry, I encountered an error. Please try again.',
              isUser: false,
              timestamp: DateTime.now(),
              isError: true,
            ),
          );
          _isLoading = false;
        });
        _saveChatHistory();
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // Dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.accentColor, AppTheme.secondaryColor],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.support_agent_rounded, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Civic Assistant',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _isLoading ? 'typing...' : 'AI-powered legal guide',
                    style: TextStyle(
                      color: _isLoading ? AppTheme.accentColor : Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Clear chat button
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.white70,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1C2128),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text(
                      'Clear Chat History?',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      'This will delete all messages. This action cannot be undone.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white60),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          setState(() {
                            _messages.clear();
                          });
                          _addWelcomeMessage();
                          await _saveChatHistory();
                        },
                        child: Text(
                          'Clear',
                          style: TextStyle(color: AppTheme.errorColor),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index], index);
              },
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF161B22).withValues(alpha: 0.95),
                  const Color(0xFF0D1117),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 80),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.4,
                          ),
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: 'Ask about legal rights, schemes...',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 8,
                              ),
                              child: Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: AppTheme.accentColor.withValues(
                                  alpha: 0.6,
                                ),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _isLoading ? null : _sendMessage,
                    child: Container(
                      width: 56,
                      height: 56,
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: _isLoading
                            ? Colors.grey.shade800
                            : AppTheme.accentColor,
                        shape: BoxShape.circle,
                        boxShadow: _isLoading
                            ? null
                            : [
                                BoxShadow(
                                  color: AppTheme.accentColor.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2128),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
        )
        .animate(
          onPlay: (controller) => controller.repeat(),
          delay: Duration(milliseconds: index * 150),
        )
        .scaleXY(
          begin: 0.7,
          end: 1.0,
          duration: 600.ms,
          curve: Curves.easeInOut,
        )
        .then()
        .scaleXY(
          begin: 1.0,
          end: 0.7,
          duration: 600.ms,
          curve: Curves.easeInOut,
        );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final isUser = message.isUser;
    final previousMessage = index > 0 ? _messages[index - 1] : null;
    final showTimestamp =
        previousMessage == null ||
        message.timestamp.difference(previousMessage.timestamp).inMinutes > 5;

    return Column(
      crossAxisAlignment: isUser
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (showTimestamp)
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _formatDate(message.timestamp),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
            ),
          ),
        Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isUser
                  ? AppTheme.accentColor
                  : message.isError
                  ? const Color(0xFF4A1C1C)
                  : const Color(0xFF1C2128),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUser
                    ? Colors.transparent
                    : message.isError
                    ? AppTheme.errorColor.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.08),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isUser)
                  _parseMessageContent(message.text)
                else
                  Text(
                    message.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        color: isUser
                            ? Colors.white.withValues(alpha: 0.7)
                            : Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                      ),
                    ),
                    if (isUser) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.done_all_rounded,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _parseMessageContent(String text) {
    // Parse sections and format
    final sections = _extractSections(text);

    if (sections.length <= 1) {
      return Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.95),
          fontSize: 15,
          height: 1.5,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((section) => _buildSection(section)).toList(),
    );
  }

  List<MessageSection> _extractSections(String text) {
    final sections = <MessageSection>[];
    final lines = text.split('\n');
    String? currentHeader;
    final currentBody = StringBuffer();

    for (final line in lines) {
      final trimmed = line.trim();

      // Check for bold headers or section markers
      if (trimmed.startsWith('**') && trimmed.endsWith('**') ||
          trimmed.endsWith(':') && trimmed.length < 50) {
        // Save previous section
        if (currentHeader != null) {
          sections.add(
            MessageSection(
              header: currentHeader,
              body: currentBody.toString().trim(),
            ),
          );
          currentBody.clear();
        }

        currentHeader = trimmed.replaceAll('**', '').replaceAll(':', '');
      } else if (currentHeader != null && trimmed.isNotEmpty) {
        if (currentBody.isNotEmpty) currentBody.writeln();
        currentBody.write(trimmed);
      } else if (currentHeader == null && trimmed.isNotEmpty) {
        // Content before any header
        sections.add(MessageSection(header: '', body: trimmed));
      }
    }

    // Add last section
    if (currentHeader != null) {
      sections.add(
        MessageSection(
          header: currentHeader,
          body: currentBody.toString().trim(),
        ),
      );
    }

    return sections;
  }

  Widget _buildSection(MessageSection section) {
    if (section.header.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _formatText(section.body),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getSectionIcon(section.header),
                color: AppTheme.accentColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  section.header,
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (section.body.isNotEmpty) ...[
            const SizedBox(height: 8),
            _formatText(section.body),
          ],
        ],
      ),
    );
  }

  IconData _getSectionIcon(String header) {
    final lower = header.toLowerCase();
    if (lower.contains('step') || lower.contains('how'))
      return Icons.list_alt_rounded;
    if (lower.contains('document')) return Icons.description_rounded;
    if (lower.contains('right') || lower.contains('law'))
      return Icons.gavel_rounded;
    if (lower.contains('scheme') || lower.contains('benefit'))
      return Icons.card_giftcard_rounded;
    if (lower.contains('contact') || lower.contains('office'))
      return Icons.contact_phone_rounded;
    return Icons.info_outline_rounded;
  }

  Widget _formatText(String text) {
    // Parse bullet points and bold text
    final widgets = <Widget>[];
    final lines = text.split('\n');

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Check for bullet points
      if (line.trim().startsWith('•') || line.trim().startsWith('-')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: AppTheme.accentColor)),
                Expanded(
                  child: _buildBoldText(line.trim().substring(1).trim()),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(_buildBoldText(line));
        if (i < lines.length - 1) {
          widgets.add(const SizedBox(height: 4));
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildBoldText(String text) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    var lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return RichText(
      text: TextSpan(
        children: spans.isEmpty ? [TextSpan(text: text)] : spans,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${time.day}/${time.month}/${time.year}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'isError': isError,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isError: (json['isError'] as bool?) ?? false,
    );
  }
}

class MessageSection {
  final String header;
  final String body;

  MessageSection({required this.header, required this.body});
}
