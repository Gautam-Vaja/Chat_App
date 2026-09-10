import 'dart:async';
import 'package:chat_app/core/app_images.dart';
import 'package:chat_app/core/app_strings.dart';
import 'package:chat_app/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // Auto navigate to Home screen after 2.6 seconds
    _timer = Timer(const Duration(milliseconds: 2600), _navigateToHome);
  }

  void _navigateToHome() {
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    // Background gradient adapted to app theme
    final backgroundGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF080B1E), // Deep midnight navy
              Color(0xFF0D102E),
              Color(0xFF130E36),
              Color(0xFF1F0B38), // Dark purple glow at bottom
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF), // Clean white top
              Color(0xFFF8FAFC),
              Color(0xFFEEF2FF), // Soft indigo tint
              Color(0xFFF3E8FF), // Gentle purple glow at bottom
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          );

    final titleShader = (isDark
            ? const LinearGradient(
                colors: [Color(0xFF818CF8), Color(0xFFC084FC)],
              )
            : const LinearGradient(
                colors: [Color(0xFF3525CD), Color(0xFF7C3AED)],
              ))
        .createShader;

    final subtitleColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    final taglineColor = isDark
        ? const Color(0xFF64748B)
        : const Color(0xFF94A3B8);

    final starGlowShadows = isDark
        ? [
            BoxShadow(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
              blurRadius: 40,
              spreadRadius: 4,
            ),
            BoxShadow(
              color: const Color(0xFF818CF8).withValues(alpha: 0.25),
              blurRadius: 60,
              spreadRadius: 10,
            ),
          ]
        : [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.22),
              blurRadius: 36,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: const Color(0xFFA855F7).withValues(alpha: 0.18),
              blurRadius: 54,
              spreadRadius: 6,
            ),
          ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF080B1E) : const Color(0xFFF8FAFC),
      body: GestureDetector(
        onTap: _navigateToHome,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: backgroundGradient,
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Top-left ambient glow
                Positioned(
                  top: -50,
                  left: -50,
                  child: Container(
                    width: 220,
                    height: 220,
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

                // Bottom-right ambient glow
                Positioned(
                  bottom: 60,
                  right: -40,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFA855F7).withValues(alpha: isDark ? 0.20 : 0.10),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Main content
                Column(
                  children: [
                    const Spacer(flex: 3),

                    // Glowing Gemini Star Emblem & Title
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Gemini Glowing Sparkle Star
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: starGlowShadows,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(70),
                                child: Image.asset(
                                  AppImages.geminiStar,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 36),

                            // Title with gradient shader
                            ShaderMask(
                              shaderCallback: (bounds) => titleShader(bounds),
                              child: Text(
                                AppStrings.appName,
                                style: GoogleFonts.sora(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Subtitle
                            Text(
                              AppStrings.splashSubtitle,
                              style: GoogleFonts.inter(
                                color: subtitleColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Bottom Tagline & 3-dot indicator
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppStrings.splashTagline,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: taglineColor,
                              fontSize: 14,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (index == 1
                                          ? primaryColor
                                          : (isDark
                                              ? const Color(0xFF475569)
                                              : const Color(0xFFCBD5E1)))
                                      .withValues(alpha: 0.8),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
