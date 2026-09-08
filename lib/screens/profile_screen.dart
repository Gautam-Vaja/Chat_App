import 'package:chat_app/core/app_images.dart';
import 'package:chat_app/core/app_strings.dart';
import 'package:chat_app/core/database/database_helper.dart';
import 'package:chat_app/core/router/app_router.dart';
import 'package:chat_app/core/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ProfileScreen({super.key, this.onBack});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _totalChats = 0;
  int _totalMessages = 0;
  String _userName = 'Gemini User';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final chatsCount = await DatabaseHelper.instance.getTotalChatsCount();
    final messagesCount = await DatabaseHelper.instance.getTotalMessagesCount();
    final savedName = await DatabaseHelper.instance.getSetting(
      'user_display_name',
      defaultValue: 'Gemini User',
    );

    if (mounted) {
      setState(() {
        _totalChats = chatsCount;
        _totalMessages = messagesCount;
        _userName = savedName ?? 'Gemini User';
        _isLoading = false;
      });
    }
  }

  void _showEditNameDialog() {
    final controller = TextEditingController(text: _userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Profile Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await DatabaseHelper.instance.setSetting(
                  'user_display_name',
                  newName,
                );
                if (mounted) {
                  setState(() => _userName = newName);
                }
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentTheme = ThemeController.instance.themeMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.theme,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E202B),
                  ),
                ),
                const SizedBox(height: 16),
                _buildThemeOption(
                  context: ctx,
                  title: 'Light Mode',
                  subtitle: 'Clean and bright appearance',
                  icon: Icons.light_mode_outlined,
                  isSelected: currentTheme == ThemeMode.light,
                  onTap: () {
                    ThemeController.instance.setThemeMode(ThemeMode.light);
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 10),
                _buildThemeOption(
                  context: ctx,
                  title: 'Dark Mode',
                  subtitle: 'Easy on the eyes in low light',
                  icon: Icons.dark_mode_outlined,
                  isSelected: currentTheme == ThemeMode.dark,
                  onTap: () {
                    ThemeController.instance.setThemeMode(ThemeMode.dark);
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 10),
                _buildThemeOption(
                  context: ctx,
                  title: 'System Default',
                  subtitle: 'Match your device appearance',
                  icon: Icons.settings_suggest_outlined,
                  isSelected: currentTheme == ThemeMode.system,
                  onTap: () {
                    ThemeController.instance.setThemeMode(ThemeMode.system);
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? Colors.grey[800]! : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.8 : 1,
          ),
          color: isSelected
              ? primaryColor.withValues(alpha: isDark ? 0.2 : 0.06)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? primaryColor
                  : (isDark ? Colors.grey[400] : const Color(0xFF64748B)),
              size: 24,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1E202B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: primaryColor, size: 22),
          ],
        ),
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 28),
            SizedBox(width: 10),
            Text('Clear Chat History'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete all chat history? This will permanently delete all conversations and messages on this device.',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await DatabaseHelper.instance.clearAllMessages();
              await _loadProfileData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All chat history cleared successfully'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showAboutGeminiDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF3525CD).withValues(alpha: 0.1),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFF3525CD),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.aboutGeminiApi,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E202B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppStrings.version,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF22C55E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Gemini is Google’s state-of-the-art AI model designed for multimodal reasoning, intelligent conversations, code generation, and rapid responses.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? Colors.grey[300] : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildInfoTile(
                    ctx,
                    title: 'Model Version',
                    value: 'Gemini 3.7 Flash / 3.6 Flash',
                    icon: Icons.memory_rounded,
                  ),
                  _buildInfoTile(
                    ctx,
                    title: 'API Provider',
                    value: 'Google Generative Language API',
                    icon: Icons.cloud_done_rounded,
                  ),
                  _buildInfoTile(
                    ctx,
                    title: 'Status',
                    value: 'Active & Connected',
                    icon: Icons.bolt_rounded,
                  ),
                  _buildInfoTile(
                    ctx,
                    title: 'Storage Architecture',
                    value: 'Local SQLite (sqflite) database',
                    icon: Icons.storage_rounded,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3525CD),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPrivacyPolicyDialog() {
    _showLegalSheet(
      title: AppStrings.privacyPolicy,
      icon: Icons.privacy_tip_rounded,
      content: '''
1. Local Data Storage
All your chats and message histories are saved entirely locally on your device in an encrypted SQLite database. No conversation history is uploaded or kept on remote application servers.

2. Gemini AI Processing
When you send a message, the text prompt is securely sent via HTTPS to the official Google Generative Language API endpoint. Google processes the prompt solely to generate the AI response.

3. No Personal Tracking
We do not track your location, contacts, device identifiers, or personal identity. We do not sell or monetize your conversation data.

4. Total Data Control
You are in complete control of your data. You can delete individual chats at any time, or permanently clear your entire chat history in one tap through the "Clear Chat History" option in Settings.
''',
    );
  }

  void _showTermsOfServiceDialog() {
    _showLegalSheet(
      title: AppStrings.termsOfService,
      icon: Icons.description_outlined,
      content: '''
1. Acceptance of Terms
By using Gemini Chat, you agree to these Terms of Service and to comply with Google’s Generative AI Prohibited Use Policy.

2. Permitted Use
You agree not to use Gemini Chat to generate hate speech, malware, illicit materials, harassment, or to impersonate any individual or entity.

3. AI Output Disclaimer
Gemini Chat provides responses generated by artificial intelligence. While powerful, AI can occasionally generate incorrect, outdated, or misleading information. Always verify crucial medical, legal, or financial information independently.

4. Service Availability
Access to AI responses relies on network connectivity and Google Generative Language API uptime. Service may be subject to standard Google API quotas and rate limits.
''',
    );
  }

  void _showLegalSheet({
    required String title,
    required IconData icon,
    required String content,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Icon(icon, color: const Color(0xFF3525CD), size: 26),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1E202B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Text(
                        content.trim(),
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.6,
                          color:
                              isDark ? Colors.grey[300] : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3525CD),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('I Understand'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF3525CD)),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1E202B),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of Gemini Chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              // Navigate back to the initial splash / login welcome screen
              context.go(AppRoutes.splash);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final primaryColor = theme.colorScheme.primary;
        final textDarkColor = isDark ? Colors.white : const Color(0xFF1E202B);
        final textSecondaryColor =
            isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        final backgroundColor = theme.scaffoldBackgroundColor;
        final cardColor = theme.cardColor;
        final borderColor =
            isDark ? const Color(0xFF334155) : const Color(0xFFEDF0F7);

        return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor, size: 24),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        centerTitle: true,
        title: Text(
          AppStrings.setting,
          style: TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Profile Avatar and Info Card
              _buildCard(
                cardColor: cardColor,
                borderColor: borderColor,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: const DecorationImage(
                                  image: AssetImage(AppImages.geminiStar),
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.3),
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          _userName,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: textDarkColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 18,
                                        ),
                                        color: primaryColor,
                                        tooltip: 'Edit name',
                                        onPressed: _showEditNameDialog,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF22C55E),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        AppStrings.version,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w500,
                                          color: textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Divider(height: 1),
                        const SizedBox(height: 14),

                        // Stats counters row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              label: 'Chats',
                              value: _isLoading ? '-' : '$_totalChats',
                              color: primaryColor,
                              textColor: textDarkColor,
                              subTextColor: textSecondaryColor,
                            ),
                            Container(
                              height: 30,
                              width: 1,
                              color: isDark
                                  ? Colors.grey[800]
                                  : const Color(0xFFE2E8F0),
                            ),
                            _buildStatItem(
                              label: 'Messages',
                              value: _isLoading ? '-' : '$_totalMessages',
                              color: const Color(0xFF22C55E),
                              textColor: textDarkColor,
                              subTextColor: textSecondaryColor,
                            ),
                            Container(
                              height: 30,
                              width: 1,
                              color: isDark
                                  ? Colors.grey[800]
                                  : const Color(0xFFE2E8F0),
                            ),
                            _buildStatItem(
                              label: 'Engine',
                              value: 'Flash',
                              color: const Color(0xFFEC4899),
                              textColor: textDarkColor,
                              subTextColor: textSecondaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Settings Action Menu List
              _buildCard(
                cardColor: cardColor,
                borderColor: borderColor,
                children: [
                  ListenableBuilder(
                    listenable: ThemeController.instance,
                    builder: (ctx, _) {
                      return _buildMenuItem(
                        context,
                        icon: Icons.palette_outlined,
                        title: AppStrings.theme,
                        subtitle: ThemeController.instance.themeName,
                        textColor: textDarkColor,
                        subTextColor: textSecondaryColor,
                        onTap: _showThemeDialog,
                      );
                    },
                  ),
                  _buildDivider(isDark),
                  _buildMenuItem(
                    context,
                    icon: Icons.delete_outline_rounded,
                    title: AppStrings.clearChatHistory,
                    textColor: textDarkColor,
                    subTextColor: textSecondaryColor,
                    onTap: _showClearHistoryDialog,
                  ),
                  _buildDivider(isDark),
                  _buildMenuItem(
                    context,
                    icon: Icons.auto_awesome_rounded,
                    title: AppStrings.aboutGeminiApi,
                    textColor: textDarkColor,
                    subTextColor: textSecondaryColor,
                    onTap: _showAboutGeminiDialog,
                  ),
                  _buildDivider(isDark),
                  _buildMenuItem(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    title: AppStrings.privacyPolicy,
                    textColor: textDarkColor,
                    subTextColor: textSecondaryColor,
                    onTap: _showPrivacyPolicyDialog,
                  ),
                  _buildDivider(isDark),
                  _buildMenuItem(
                    context,
                    icon: Icons.description_outlined,
                    title: AppStrings.termsOfService,
                    textColor: textDarkColor,
                    subTextColor: textSecondaryColor,
                    onTap: _showTermsOfServiceDialog,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Log Out Button
              Center(
                child: SizedBox(
                  width: 220,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _showLogoutDialog,
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    label: const Text(
                      AppStrings.logout,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF450A0A)
                          : const Color(0xFFFDECEC),
                      foregroundColor: const Color(0xFFDC2626),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: subTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required Color cardColor,
    required Color borderColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required Color textColor,
    required Color subTextColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF3525CD)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            if (subtitle != null) ...[
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: subTextColor,
                ),
              ),
              const SizedBox(width: 6),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? Colors.grey[850] : const Color(0xFFF1F4F9),
      indent: 16,
      endIndent: 16,
    );
  }
}
