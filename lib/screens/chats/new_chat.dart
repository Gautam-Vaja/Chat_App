import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chat_app/core/app_images.dart';
import 'package:chat_app/core/app_strings.dart';
import 'package:chat_app/core/database/database_helper.dart';
import 'package:chat_app/services/gemini_service.dart';
import 'package:chat_app/widgets/animated_robot_widget.dart';
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
    _messageController.addListener(_onMessageChanged);
    _chatId = widget.userName;
    // Only load previous messages if an existing chat was selected
    if (_chatId != null && _chatId!.isNotEmpty) {
      _loadMessages();
    }
  }

  void _onMessageChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _messageController.removeListener(_onMessageChanged);
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
                        // const CircleAvatar(
                        //   radius: 36,
                        //   backgroundImage: AssetImage(AppImages.geminiStar),
                        // ),
                        AnimatedRobotWidget(),
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
                                  color: isUser ? Colors.white : textDarkColor,
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
    final hasText = _messageController.text.trim().isNotEmpty;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1F20) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark ? const Color(0xFF303134) : const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // ==================================================
              // PLUS BUTTON
              // ==================================================
              IconButton(
                onPressed: () {
                  // TODO: Open attachment picker
                },
                icon: Icon(
                  Icons.add_rounded,
                  color: isDark ? Colors.white70 : const Color(0xFF5F6368),
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                splashRadius: 20,
              ),

              const SizedBox(width: 4),

              // ==================================================
              // TEXT FIELD
              // ==================================================
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(
                    color: isDark ? Colors.white : textDarkColor,
                    fontSize: 14,
                  ),
                  cursorColor: primaryColor,
                  textInputAction: TextInputAction.send,
                  keyboardType: TextInputType.text,
                  onChanged: (_) {
                    setState(() {});
                  },
                  onSubmitted: (_) {
                    _sendMessage();
                  },
                  decoration: InputDecoration(
                    hintText: "Message...",
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white70 : textSecondaryColor,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              const SizedBox(width: 6),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: hasText
                      ? primaryColor
                      : (isDark
                            ? const Color(0xFF2D3748)
                            : const Color(0xFFE2E8F0)),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: hasText ? _sendMessage : null,
                  icon: Icon(
                    Icons.send_rounded,
                    color: hasText
                        ? Colors.white
                        : (isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  splashRadius: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
