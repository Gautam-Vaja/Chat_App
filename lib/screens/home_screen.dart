import 'package:chat_app/core/app_images.dart';
import 'package:chat_app/core/app_strings.dart';
import 'package:chat_app/core/database/database_helper.dart';
import 'package:chat_app/widgets/animated_robot_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ============================================================
  // Animation Controller
  // ============================================================

  AnimationController? _entranceController;

  void _ensureAnimationInitialized() {
    if (_entranceController == null) {
      _entranceController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      );
      _entranceController!.forward();
    }
  }

  // ============================================================
  // Recent Chats
  // ============================================================

  List<Map<String, dynamic>> _recentChats = [];
  bool _isLoadingChats = true;

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();
    _ensureAnimationInitialized();

    // Load recent chats
    _loadRecentChats();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _entranceController?.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD RECENT CHATS
  // ============================================================

  Future<void> _loadRecentChats() async {
    try {
      final chats = await DatabaseHelper.instance.getRecentChats();

      if (mounted) {
        setState(() {
          _recentChats = chats;
          _isLoadingChats = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingChats = false;
        });
      }
    }
  }

  // ============================================================
  // FORMAT TIMESTAMP
  // ============================================================

  String _formatTimestamp(String? isoString) {
    if (isoString == null || isoString.isEmpty) {
      return '';
    }

    try {
      final dt = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dt);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24 && dt.day == now.day) {
        final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final period = dt.hour >= 12 ? 'PM' : 'AM';
        final minute = dt.minute.toString().padLeft(2, '0');

        return '$hour:$minute $period';
      } else if (difference.inDays == 1 ||
          (difference.inDays < 2 && dt.day == now.day - 1)) {
        return 'Yesterday';
      } else {
        return '${dt.day}/${dt.month}/${dt.year}';
      }
    } catch (_) {
      return '';
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    _ensureAnimationInitialized();
    final entranceController = _entranceController!;

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
        : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: cardColor.withValues(alpha: 0.85),
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        title: _buildAppBarTitle(isDark, textDarkColor),

        actions: [
          // ====================================================
          // HISTORY BUTTON
          // ====================================================
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: 'Chat History',

                onPressed: () async {
                  await context.push('/history');

                  // Reload chats when returning from history
                  _loadRecentChats();
                },

                icon: Icon(
                  Icons.history_rounded,
                  size: 24,
                  color: textDarkColor,
                ),
              ),

              // History badge
              if (_recentChats.isNotEmpty)
                Positioned(
                  top: 9,
                  right: 9,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF6366F1),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
            ],
          ),

          // ====================================================
          // SETTINGS BUTTON
          // ====================================================
          IconButton(
            tooltip: 'Settings',

            onPressed: () {
              context.push('/settings');
            },

            icon: Icon(
              Icons.settings_outlined,
              size: 22,
              color: textSecondaryColor,
            ),
          ),

          const SizedBox(width: 6),
        ],

        // Bottom border
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: borderColor, height: 1),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: SafeArea(
        child: Stack(
          children: [
            // ==================================================
            // AMBIENT BACKGROUND GLOW - TOP LEFT
            // ==================================================
            Positioned(
              top: -60,
              left: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primaryColor.withValues(alpha: isDark ? 0.22 : 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ==================================================
            // AMBIENT BACKGROUND GLOW - TOP RIGHT
            // ==================================================
            Positioned(
              top: 140,
              right: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(
                        0xFFA855F7,
                      ).withValues(alpha: isDark ? 0.18 : 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ==================================================
            // SCROLLABLE CONTENT
            // ==================================================
            RefreshIndicator(
              onRefresh: _loadRecentChats,
              color: primaryColor,

              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.only(
                  left: 18,
                  right: 18,
                  top: 14,
                  bottom: 100,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ==================================================
                    // 1. HERO SECTION
                    // ==================================================
                    const SizedBox(height: 50),
                    SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.15),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: entranceController,
                              curve: const Interval(
                                0.0,
                                0.6,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                          ),

                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: entranceController,
                          curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
                        ),

                        child: AnimatedRobotWidget(
                          size: 190,

                          onTap: () {
                            // Add mascot tap action here if needed
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 100),

                    // ==================================================
                    // 2. QUICK PROMPT SECTION
                    // ==================================================
                    SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: entranceController,
                              curve: const Interval(
                                0.25,
                                0.8,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                          ),

                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: entranceController,
                          curve: const Interval(
                            0.25,
                            0.8,
                            curve: Curves.easeIn,
                          ),
                        ),

                        child: _buildQuickPrompts(
                          isDark: isDark,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          textDarkColor: textDarkColor,
                          textSecondaryColor: textSecondaryColor,
                          primaryColor: primaryColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),
            // ==================================================
            // 4. BOTTOM FLOATING QUICK START BAR
            // ==================================================
            Positioned(
              left: 18,
              right: 18,
              bottom: 16,
              child: _buildBottomPromptBar(
                isDark: isDark,
                primaryColor: primaryColor,
                textDarkColor: textDarkColor,
                textSecondaryColor: textSecondaryColor,
                cardColor: cardColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // APP BAR TITLE
  // ============================================================

  Widget _buildAppBarTitle(bool isDark, Color textDarkColor) {
    return Row(
      children: [
        // Gemini logo
        Container(
          padding: const EdgeInsets.all(2.5),

          decoration: BoxDecoration(
            shape: BoxShape.circle,

            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
            ),

            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),

          child: const CircleAvatar(
            radius: 15,
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage(AppImages.geminiStar),
          ),
        ),

        const SizedBox(width: 10),

        // ======================================================
        // APP NAME + STATUS
        // ======================================================
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF9333EA)],
                ).createShader(bounds);
              },

              child: const Text(
                AppStrings.gemini,

                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                  color: Colors.white,
                  letterSpacing: 0.4,
                ),
              ),
            ),

            // Online status
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,

                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 4),

                Text(
                  'Online & Ready',

                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // RECENT CHATS
  // ============================================================

  // ============================================================
  // BOTTOM QUICK PROMPT BAR
  // ============================================================

  Widget _buildBottomPromptBar({
    required bool isDark,
    required Color primaryColor,
    required Color textDarkColor,
    required Color textSecondaryColor,
    required Color cardColor,
  }) {
    return Material(
      color: Colors.transparent,

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

        decoration: BoxDecoration(
          color: cardColor.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(20),

          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: InkWell(
          borderRadius: BorderRadius.circular(20),

          onTap: () async {
            await context.push('/newChat');
          },

          child: Row(
            children: [
              // AI icon
              Container(
                width: 40,
                height: 40,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                  ),
                ),

                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start a new conversation',

                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textDarkColor,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      'Ask anything to Gemini',

                      style: TextStyle(fontSize: 11, color: textSecondaryColor),
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(Icons.arrow_forward_rounded, color: primaryColor, size: 21),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // QUICK PROMPTS & WELCOME BANNER
  // ============================================================

  Widget _buildQuickPrompts({
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color textDarkColor,
    required Color textSecondaryColor,
    required Color primaryColor,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Text(
          "Welcome! Your AI assistant is ready to answer questions, solve problems, and create with you. 🤖✨",
          textAlign: TextAlign.center,
          style: GoogleFonts.sora(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textDarkColor,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RECENT CHATS SECTION
  // ============================================================
}
