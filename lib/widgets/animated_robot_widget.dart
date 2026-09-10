import 'dart:async';
import 'dart:math' as math;
import 'package:chat_app/core/app_images.dart';
import 'package:flutter/material.dart';

class AnimatedRobotWidget extends StatefulWidget {
  final double size;
  final VoidCallback? onTap;

  const AnimatedRobotWidget({super.key, this.size = 220, this.onTap});

  @override
  State<AnimatedRobotWidget> createState() => _AnimatedRobotWidgetState();
}

class _AnimatedRobotWidgetState extends State<AnimatedRobotWidget>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  late AnimationController _blinkController;
  late AnimationController _tapReactionController;

  late Animation<double> _floatAnimation;
  late Animation<double> _tiltAnimation;
  late Animation<double> _breatheAnimation;
  late Animation<double> _shadowScaleAnimation;
  late Animation<double> _shadowOpacityAnimation;
  late Animation<double> _glowPulseAnimation;
  late Animation<double> _sparkleRotationAnimation;
  late Animation<double> _sparkleScaleAnimation;
  late Animation<double> _blinkAnimation;
  late Animation<double> _tapScaleAnimation;

  Timer? _blinkTimer;
  Timer? _speechBubbleTimer;
  // int _currentGreetingIndex = 0;

  // final List<String> _greetings = [
  //   "Hi there! How can I help you today? ✨",
  //   "Ready to brainstorm or write something great?",
  //   "Need code help, answers, or creative ideas?",
  //   "Tap a quick prompt or start a new chat! 🚀",
  //   "I'm Gemini, your personal AI assistant 💡",
  // ];

  bool _isInitialized = false;

  void _ensureInitialized() {
    if (_isInitialized) return;
    _isInitialized = true;

    // 1. Floating & Hovering physics (smooth sine curve)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    // Subtle 3D tilt while hovering
    _tiltAnimation = Tween<double>(begin: -0.028, end: 0.028).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    // Subtle breathing scale
    _breatheAnimation = Tween<double>(begin: 0.985, end: 1.015).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    // Dynamic ground shadow: shrinks & lightens when floating up, expands & darkens when down
    _shadowScaleAnimation = Tween<double>(begin: 0.78, end: 1.05).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    _shadowOpacityAnimation = Tween<double>(begin: 0.18, end: 0.38).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    // 2. Ambient Energy Glow Pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat(reverse: true);

    _glowPulseAnimation = Tween<double>(begin: 0.45, end: 0.95).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutQuad),
    );

    // 3. Sparkle Stars Twinkle & Rotation
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _sparkleRotationAnimation = Tween<double>(begin: -0.08, end: 0.12).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );

    _sparkleScaleAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOutBack),
    );

    // 4. Eye Blinking & Pulsing
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.08).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    _startBlinkTimer();

    // 5. Tap reaction (squash & stretch bounce)
    _tapReactionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _tapScaleAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 1.08),
            weight: 35,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.08, end: 0.94),
            weight: 35,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.94, end: 1.0),
            weight: 30,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _tapReactionController,
            curve: Curves.easeOutBack,
          ),
        );

    // Auto rotate speech bubble
    _speechBubbleTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (mounted) {
        setState(() {
          // _currentGreetingIndex =
          // (_currentGreetingIndex + 1) % _greetings.length;
        });
      }
    });
  }

  void _startBlinkTimer() {
    _blinkTimer?.cancel();
    // Random blink every 3 to 6 seconds
    final randomSeconds = 3 + math.Random().nextInt(4);
    _blinkTimer = Timer(Duration(seconds: randomSeconds), () async {
      if (!mounted) return;
      await _blinkController.forward();
      if (!mounted) return;
      await _blinkController.reverse();
      _startBlinkTimer();
    });
  }

  void _onRobotTapped() {
    _tapReactionController.forward(from: 0.0);
    setState(() {
      // _currentGreetingIndex = (_currentGreetingIndex + 1) % _greetings.length;
    });
    widget.onTap?.call();
  }

  @override
  void initState() {
    super.initState();
    _ensureInitialized();
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _blinkTimer?.cancel();
      _speechBubbleTimer?.cancel();
      _floatController.dispose();
      _pulseController.dispose();
      _sparkleController.dispose();
      _blinkController.dispose();
      _tapReactionController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _ensureInitialized();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final size = widget.size;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Interactive Speech Bubble
        _buildSpeechBubble(isDark, primaryColor),

        const SizedBox(height: 12),

        // Robot Mascot Canvas with Ambient Aura and Shadow
        GestureDetector(
          onTap: _onRobotTapped,
          child: SizedBox(
            width: size * 1.35,
            height: size * 1.45,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Ambient Pulsing Energy Glow
                _buildAmbientAura(size, isDark),

                // 2. Dynamic Floor Shadow
                Positioned(
                  bottom: size * 0.06,
                  child: _buildDynamicShadow(size, isDark),
                ),

                // 3. Floating Animated Robot Body + Face Overlays
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _floatController,
                    _pulseController,
                    _sparkleController,
                    _blinkController,
                    _tapReactionController,
                  ]),
                  builder: (context, child) {
                    final floatY = _floatAnimation.value;
                    final tilt = _tiltAnimation.value;
                    final breath = _breatheAnimation.value;
                    final tapScale = _tapScaleAnimation.value;

                    return Transform.translate(
                      offset: Offset(0, floatY),
                      child: Transform.rotate(
                        angle: tilt,
                        child: Transform.scale(
                          scale: breath * tapScale,
                          child: SizedBox(
                            width: size,
                            height: size * 1.35,
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                // Robot Image Base
                                Positioned.fill(
                                  child: Image.asset(
                                    AppImages.robotMascot,
                                    fit: BoxFit.contain,
                                  ),
                                ),

                                // Eye Blink & Glow Overlays
                                _buildGlowingEyesOverlay(size),

                                // Twinkling Sparkle Stars (Top-Right)
                                _buildTwinklingSparkles(size),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeechBubble(bool isDark, Color primaryColor) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.25),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      // child: Container(
      //   key: ValueKey<int>(_currentGreetingIndex),
      //   margin: const EdgeInsets.symmetric(horizontal: 24),
      //   padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      //   decoration: BoxDecoration(
      //     color: isDark
      //         ? const Color(0xFF1E293B).withValues(alpha: 0.9)
      //         : Colors.white.withValues(alpha: 0.95),
      //     borderRadius: BorderRadius.circular(20),
      //     border: Border.all(
      //       color: isDark
      //           ? const Color(0xFF6366F1).withValues(alpha: 0.3)
      //           : const Color(0xFF3525CD).withValues(alpha: 0.18),
      //       width: 1.4,
      //     ),
      //     boxShadow: [
      //       BoxShadow(
      //         color: isDark
      //             ? const Color(0xFF6366F1).withValues(alpha: 0.15)
      //             : const Color(0xFF3525CD).withValues(alpha: 0.09),
      //         blurRadius: 16,
      //         offset: const Offset(0, 6),
      //       ),
      //     ],
      //   ),
      //   // child: Row(
      //   //   mainAxisSize: MainAxisSize.min,
      //   //   children: [
      //   //     // Container(
      //   //     //   padding: const EdgeInsets.all(4),
      //   //     //   decoration: const BoxDecoration(
      //   //     //     gradient: LinearGradient(
      //   //     //       colors: [Color(0xFF818CF8), Color(0xFFA855F7)],
      //   //     //     ),
      //   //     //     shape: BoxShape.circle,
      //   //     //   ),
      //   //     //   child: const Icon(
      //   //     //     Icons.auto_awesome,
      //   //     //     size: 13,
      //   //     //     color: Colors.white,
      //   //     //   ),
      //   //     // ),
      //   //     // const SizedBox(width: 8),
      //   //     // Flexible(
      //   //     //   // child: Text(
      //   //     //   //   _greetings[_currentGreetingIndex],
      //   //     //   //   textAlign: TextAlign.center,
      //   //     //   //   style: TextStyle(
      //   //     //   //     fontSize: 13.5,
      //   //     //   //     fontWeight: FontWeight.w600,
      //   //     //   //     color: isDark ? Colors.white : const Color(0xFF1E293B),
      //   //     //   //     letterSpacing: 0.1,
      //   //     //   //   ),
      //   //     //   // ),
      //   //     // ),
      //   //   ],
      //   // ),
      // ),
    );
  }

  Widget _buildAmbientAura(double size, bool isDark) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glow = _glowPulseAnimation.value;
        return Container(
          width: size * (1.05 + 0.12 * glow),
          height: size * (1.05 + 0.12 * glow),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                (isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1))
                    .withValues(alpha: 0.28 * glow),
                (isDark ? const Color(0xFFA855F7) : const Color(0xFF9333EA))
                    .withValues(alpha: 0.12 * glow),
                Colors.transparent,
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDynamicShadow(double size, bool isDark) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final scale = _shadowScaleAnimation.value;
        final opacity = _shadowOpacityAnimation.value;
        final shadowColor = isDark
            ? Colors.black.withValues(alpha: opacity * 1.3)
            : const Color(0xFF3525CD).withValues(alpha: opacity * 0.45);

        return Container(
          width: size * 0.58 * scale,
          height: 14 * scale,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.elliptical(size * 0.58, 14)),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 16 * scale,
                spreadRadius: 2 * scale,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlowingEyesOverlay(double size) {
    final robotHeight = size * 1.35;
    final eyeBlink = _blinkAnimation.value;
    final eyeGlow = _glowPulseAnimation.value;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Stack(
        children: [
          // Left Eye Overlay
          Positioned(
            left: size * 0.315,
            top: robotHeight * 0.278,
            child: _buildEyePulse(
              width: size * 0.145,
              height: size * 0.145,
              blinkFactor: eyeBlink,
              glowFactor: eyeGlow,
            ),
          ),

          // Right Eye Overlay
          Positioned(
            left: size * 0.635,
            top: robotHeight * 0.270,
            child: _buildEyePulse(
              width: size * 0.145,
              height: size * 0.145,
              blinkFactor: eyeBlink,
              glowFactor: eyeGlow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEyePulse({
    required double width,
    required double height,
    required double blinkFactor,
    required double glowFactor,
  }) {
    if (blinkFactor < 0.2) {
      return Container(
        width: width,
        height: 2.5,
        margin: EdgeInsets.only(top: height * 0.45),
        decoration: BoxDecoration(
          color: const Color(0xFFC084FC).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }

    return Transform.scale(
      scaleY: blinkFactor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFFA855F7,
              ).withValues(alpha: 0.35 * glowFactor),
              blurRadius: 10 * glowFactor,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: const Color(
                0xFFC084FC,
              ).withValues(alpha: 0.25 * glowFactor),
              blurRadius: 18 * glowFactor,
              spreadRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTwinklingSparkles(double size) {
    return Positioned(
      right: size * 0.02,
      top: size * 0.01,
      child: AnimatedBuilder(
        animation: _sparkleController,
        builder: (context, child) {
          final scale = _sparkleScaleAnimation.value;
          final rotation = _sparkleRotationAnimation.value;

          return Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: scale,
              child: SizedBox(
                width: size * 0.32,
                height: size * 0.36,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        AppImages.robotSparkles,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 10,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFC084FC),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
