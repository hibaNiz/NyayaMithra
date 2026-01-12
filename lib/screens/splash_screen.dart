import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _navigateToHome();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(AppConstants.splashDuration);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              const Color(0xFF1a1d29),
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Static background artifacts
            ...List.generate(20, (index) {
              final random = Random(index);
              final iconData = index % 3 == 0
                  ? Icons.balance_rounded
                  : index % 3 == 1
                  ? Icons.gavel_rounded
                  : Icons.article_rounded;

              return Positioned(
                left: random.nextDouble() * 400,
                top: random.nextDouble() * 800,
                child: Opacity(
                  opacity: 0.03 + (random.nextDouble() * 0.04),
                  child: Icon(
                    iconData,
                    size: 40 + random.nextDouble() * 60,
                    color: Colors.white,
                  ),
                ),
              );
            }),

            // Static floating orbs
            ...List.generate(8, (index) {
              return Positioned(
                left: (index * 50.0) % 350,
                top: (index * 80.0) % 700,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accentColor.withValues(alpha: 0.15),
                  ),
                ),
              );
            }),

            // Main content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Pulsing rings behind logo
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer ring
                            Container(
                              width: 200 + (_pulseController.value * 40),
                              height: 200 + (_pulseController.value * 40),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.accentColor.withValues(
                                    alpha: 0.3 - (_pulseController.value * 0.2),
                                  ),
                                  width: 2,
                                ),
                              ),
                            ),
                            // Middle ring
                            Container(
                              width: 180 + (_pulseController.value * 30),
                              height: 180 + (_pulseController.value * 30),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.secondaryColor.withValues(
                                    alpha:
                                        0.2 - (_pulseController.value * 0.15),
                                  ),
                                  width: 2,
                                ),
                              ),
                            ),
                            // Logo
                            child!,
                          ],
                        );
                      },
                      child:
                          Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.accentColor,
                                      AppTheme.secondaryColor,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(35),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.accentColor.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 40,
                                      spreadRadius: 5,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.balance_rounded,
                                    size: 75,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                              .animate()
                              .scale(
                                begin: const Offset(0.3, 0.3),
                                duration: 800.ms,
                                curve: Curves.elasticOut,
                              )
                              .fadeIn(duration: 400.ms)
                              .then()
                              .shimmer(
                                duration: 2000.ms,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                    ),

                    const SizedBox(height: 50),

                    // App Name with gradient text
                    ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.white,
                              AppTheme.accentColor,
                              Colors.white,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ).createShader(bounds),
                          child: const Text(
                            'NyayaMithra',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        )
                        .animate(delay: 300.ms)
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.3, end: 0)
                        .then()
                        .shimmer(
                          duration: 2500.ms,
                          color: AppTheme.accentColor.withValues(alpha: 0.5),
                        ),

                    const SizedBox(height: 16),

                    // Tagline with typewriter effect
                    const Text(
                          'Your Legal & Civic Companion',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                        .animate(delay: 600.ms)
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),

                    const Spacer(flex: 2),

                    // Animated features with icons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildAnimatedFeature(
                            Icons.flash_on_rounded,
                            'Instant',
                            AppTheme.accentColor,
                            700,
                          ),
                          _buildAnimatedFeature(
                            Icons.translate_rounded,
                            'Multilingual',
                            AppTheme.secondaryColor,
                            850,
                          ),
                          _buildAnimatedFeature(
                            Icons.verified_user_rounded,
                            'Secure',
                            AppTheme.accentColor,
                            1000,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Custom loading indicator
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.accentColor,
                            ),
                          ),
                        ),
                        Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppTheme.accentColor.withValues(alpha: 0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            )
                            .animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .scaleXY(begin: 0.5, end: 1.5, duration: 1500.ms)
                            .fadeOut(),
                      ],
                    ).animate(delay: 1100.ms).fadeIn().scale(),

                    const SizedBox(height: 20),

                    // Loading text
                    Text(
                          'Initializing...',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 13,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w300,
                          ),
                        )
                        .animate(delay: 1200.ms)
                        .fadeIn()
                        .then()
                        .shimmer(duration: 1500.ms),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedFeature(
    IconData icon,
    String label,
    Color color,
    int delayMs,
  ) {
    return Column(
      children: [
        Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.2),
                    color.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 26),
            )
            .animate(delay: Duration(milliseconds: delayMs))
            .scale(begin: const Offset(0, 0), curve: Curves.elasticOut)
            .fadeIn()
            // .then(onPlay: (controller) => controller.repeat(reverse: true))
            .scaleXY(begin: 1.0, end: 1.1, duration: 1500.ms),
        const SizedBox(height: 10),
        Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            )
            .animate(delay: Duration(milliseconds: delayMs + 100))
            .fadeIn()
            .slideY(begin: 0.5, end: 0),
      ],
    );
  }
}
