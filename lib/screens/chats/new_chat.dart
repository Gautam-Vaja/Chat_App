import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chat_app/core/app_images.dart';
import 'package:chat_app/core/app_strings.dart';
import 'package:chat_app/core/database/database_helper.dart';
import 'package:chat_app/services/gemini_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NewChat extends StatefulWidget {
  final String? userName;

  const NewChat({super.key, this.userName});

  @override
  State<NewChat> createState() => _NewChatState();
}

class _NewChatState extends State<NewChat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();

  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  String? _chatId;

  @override
  void initState() {
    super.initState();
    _chatId = widget.userName;
    // Only load previous messages if an existing chat was selected
    if (_chatId != null && _chatId!.isNotEmpty) {
      _loadMessages();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    if (_chatId == null) return;
    final savedMessages = await DatabaseHelper.instance.getMessage(_chatId!);
    if (mounted) {
      setState(() {
        _messages.clear();
        for (final row in savedMessages) {
          _messages.add({
            'sender': row['role'].toString(),
            'text': row['message'].toString(),
          });
        }
      });
      _scrollToBottom();
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    // For a brand new chat, generate a title/ID from the first question
    if (_chatId == null || _chatId!.isEmpty) {
      final cleanTitle = text.replaceAll('\n', ' ').trim();
      _chatId = cleanTitle.length > 25
          ? '${cleanTitle.substring(0, 25)}...'
          : cleanTitle;
    }

    final currentChatId = _chatId!;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    // 1. Save user message in database
    await DatabaseHelper.instance.insertMessage(
      chatId: currentChatId,
      role: 'user',
      message: text,
    );

    try {
      final stream = _geminiService.sendMessageStream(text);
      String fullResponse = '';
      bool isFirstChunk = true;

      await for (final chunk in stream) {
        if (!mounted) return;
        fullResponse += chunk;

        setState(() {
          if (isFirstChunk) {
            isFirstChunk = false;
            _isLoading = false;
            _messages.add({'sender': 'gemini', 'text': fullResponse});
          } else {
            _messages.last['text'] = fullResponse;
          }
        });
        _scrollToBottom();
      }

      if (isFirstChunk && mounted) {
        setState(() {
          _isLoading = false;
          _messages.add({
            'sender': 'gemini',
            'text': 'No response generated. Please try again.',
          });
        });
        _scrollToBottom();
      }

      // 2. Save Gemini response in database
      if (fullResponse.isNotEmpty) {
        await DatabaseHelper.instance.insertMessage(
          chatId: currentChatId,
          role: 'gemini',
          message: fullResponse,
        );
      }
    } catch (e) {
      if (mounted) {
        const errorText =
            'Failed to get response. Please check your network or API key.';
        setState(() {
          _isLoading = false;
          _messages.add({'sender': 'gemini', 'text': errorText});
        });
        _scrollToBottom();

        await DatabaseHelper.instance.insertMessage(
          chatId: currentChatId,
          role: 'gemini',
          message: errorText,
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    final displayName = _chatId ?? widget.userName ?? AppStrings.gemini;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textDarkColor = isDark ? Colors.white : const Color(0xFF1E202B);
    final textSecondaryColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF1F5F9);
    final aiBubbleColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.go('/home');
          },
          icon: Icon(Icons.arrow_back, color: primaryColor),
        ),
        backgroundColor: cardColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: _buildHeading(displayName, primaryColor, textSecondaryColor),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: borderColor, height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 36,
                          backgroundImage: AssetImage(AppImages.geminiStar),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Chat with $displayName",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textDarkColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Ask anything to start the conversation!",
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isLoading) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: aiBubbleColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Gemini is thinking...",
                                  style: TextStyle(
                                    color: textSecondaryColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final msg = _messages[index];
                      final isUser = msg['sender'] == 'user';

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isUser ? primaryColor : aiBubbleColor,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: isUser
                                  ? const Radius.circular(16)
                                  : const Radius.circular(4),
                              bottomRight: isUser
                                  ? const Radius.circular(4)
                                  : const Radius.circular(16),
                            ),
                          ),
                          child: AnimatedTextKit(
                            key: ValueKey(msg['text']),
                            isRepeatingAnimation: false,
                            animatedTexts: [
                              TypewriterAnimatedText(
                                msg['text'] ?? '',
                                speed: const Duration(milliseconds: 20),
                                textStyle: TextStyle(
                                  color: textDarkColor,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          _buildMessageSender(
            isDark,
            cardColor,
            borderColor,
            primaryColor,
            textDarkColor,
            textSecondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildHeading(
    String displayName,
    Color primaryColor,
    Color textSecondaryColor,
  ) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 15,
          backgroundImage: AssetImage(AppImages.geminiStar),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: primaryColor,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            context.push('/history');
          },
          icon: Icon(Icons.history, color: primaryColor),
        ),
      ],
    );
  }

  Widget _buildMessageSender(
    bool isDark,
    Color cardColor,
    Color borderColor,
    Color primaryColor,
    Color textDarkColor,
    Color textSecondaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 1. Plus / Attachment Button
            IconButton(
              onPressed: () {
                // Action for attachments / media
              },
              icon: Icon(
                Icons.add_circle_outline_rounded,
                color: textSecondaryColor,
                size: 28,
              ),
              splashRadius: 24,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 10),

            // 2. Rounded Message Input Field
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF475569)
                        : const Color(0xFFCBD5E1),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: TextStyle(color: textDarkColor, fontSize: 15),
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: "Message...",
                          hintStyle: TextStyle(
                            color: textSecondaryColor,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Open emoji picker
                      },
                      icon: Icon(
                        Icons.sentiment_satisfied_alt_outlined,
                        color: textSecondaryColor,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // 3. Circular Send Button
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
