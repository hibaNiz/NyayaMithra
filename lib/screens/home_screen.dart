import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/app_provider.dart';
import '../widgets/feature_card.dart';
import '../widgets/language_selector.dart';
import 'civic_assistance_screen.dart';
import 'document_explainer/camera_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryColor, AppTheme.backgroundColor],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo and Title
                      Row(
                        children: [
                          Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.secondaryColor,
                                      AppTheme.secondaryColor.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.secondaryColor
                                          .withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.balance_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                              )
                              .animate()
                              .scale(
                                begin: const Offset(0.5, 0.5),
                                duration: 400.ms,
                                curve: Curves.elasticOut,
                              )
                              .fadeIn(),
                          const SizedBox(width: 14),
                          Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    provider.getString('home_title'),
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    provider.getString('home_subtitle'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              )
                              .animate(delay: 100.ms)
                              .fadeIn(duration: 400.ms)
                              .slideX(begin: -0.2, end: 0),
                        ],
                      ),

                      // Language Selector
                      const LanguageSelector(showLabel: false)
                          .animate(delay: 200.ms)
                          .fadeIn(duration: 400.ms)
                          .scale(begin: const Offset(0.8, 0.8)),
                    ],
                  ),
                ),
              ),

              // Welcome Section - Creative & Human
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Hello there,',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 4,
                                  left: 6,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text(
                                    '✨',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ],
                          )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .slideX(begin: -0.1, end: 0),
                      const SizedBox(height: 8),
                      const Text(
                            'Ready to simplify your\nlegal journey?',
                            style: TextStyle(
                              fontSize: 17,
                              height: 1.3,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                              fontFamily: 'Roboto',
                            ),
                          )
                          .animate(delay: 200.ms)
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: 0.2, end: 0),
                    ],
                  ),
                ),
              ),

              // Feature Cards Grid
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: size.width > 400 ? 0.90 : 0.80,
                  ),
                  delegate: SliverChildListDelegate([
                    // Document Explainer
                    FeatureCard(
                      title: provider.getString('document_explainer'),
                      description: provider.getString(
                        'document_explainer_desc',
                      ),
                      icon: Icons.document_scanner_rounded,
                      gradientColors: AppTheme.featureGradients[0],
                      isEnabled: true,
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const CameraScreen(),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  return SlideTransition(
                                    position:
                                        Tween<Offset>(
                                          begin: const Offset(1, 0),
                                          end: Offset.zero,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeOutCubic,
                                          ),
                                        ),
                                    child: child,
                                  );
                                },
                            transitionDuration: const Duration(
                              milliseconds: 400,
                            ),
                          ),
                        );
                      },
                      animationDelay: 500,
                    ),

                    // Civic Assistance - MOVED TO 2ND POSITION
                    FeatureCard(
                      title: provider.getString('civic_assistance'),
                      description: provider.getString('civic_assistance_desc'),
                      icon: Icons.support_agent_rounded,
                      gradientColors: AppTheme.featureGradients[2],
                      isEnabled: true,
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const CivicAssistanceScreen(),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  return SlideTransition(
                                    position:
                                        Tween<Offset>(
                                          begin: const Offset(1, 0),
                                          end: Offset.zero,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeOutCubic,
                                          ),
                                        ),
                                    child: child,
                                  );
                                },
                            transitionDuration: const Duration(
                              milliseconds: 400,
                            ),
                          ),
                        );
                      },
                      animationDelay: 600,
                    ),

                    // Document Maker
                    FeatureCard(
                      title: provider.getString('document_maker'),
                      description: provider.getString('document_maker_desc'),
                      icon: Icons.edit_document,
                      gradientColors: AppTheme.featureGradients[1],
                      isEnabled: false,
                      animationDelay: 700,
                    ),

                    // Public Grievance Portal
                    FeatureCard(
                      title: provider.getString('grievance_portal'),
                      description: provider.getString('grievance_portal_desc'),
                      icon: Icons.report_problem_rounded,
                      gradientColors: AppTheme.featureGradients[3],
                      isEnabled: false,
                      animationDelay: 800,
                    ),
                  ]),
                ),
              ),

              // Creative AI Insight Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    0,
                    24,
                    32,
                  ), // Reduced bottom padding
                  child:
                      Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF6A11CB), // Purple
                                  const Color(0xFF2575FC), // Blue
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  // Removed shadow as requested, keeping purely flat gradient for clean look
                                  color: Colors
                                      .transparent, // Effectively removing it
                                  blurRadius: 0,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Background patterns
                                Positioned(
                                  right: -20,
                                  top: -20,
                                  child: Icon(
                                    Icons.auto_awesome,
                                    size: 100,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.stars_rounded,
                                                  color: Colors.amber,
                                                  size: 16,
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  provider.getString(
                                                    'powered_by',
                                                  ),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        provider.getString(
                                          'legal_clarity_title',
                                        ),
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        provider.getString(
                                          'legal_clarity_desc',
                                        ),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.9),
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate(delay: 900.ms)
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: 0.1, end: 0),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CivicAssistanceScreen(),
                    ),
                  );
                },
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
                elevation: 6,
                child: const Icon(Icons.support_agent_rounded, size: 28),
              )
              .animate(delay: 1.seconds)
              .scale(
                duration: 400.ms,
                curve: Curves.elasticOut,
                begin: const Offset(0, 0),
              ),
    );
  }
}
