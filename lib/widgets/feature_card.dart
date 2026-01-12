import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FeatureCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final bool isEnabled;
  final VoidCallback? onTap;
  final int animationDelay;

  const FeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    this.isEnabled = true,
    this.onTap,
    this.animationDelay = 0,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.isEnabled ? widget.onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.isEnabled
                          ? widget.gradientColors
                          : [
                              const Color(0xFF2A2D3E), // Dark muted slate
                              const Color(0xFF1F2133), // Deeper muted
                            ],
                    ),
                    border: widget.isEnabled
                        ? null
                        : Border.all(
                            color: Colors.white.withOpacity(0.05),
                            width: 1,
                          ),
                    boxShadow: widget.isEnabled
                        ? [
                            BoxShadow(
                              color: widget.gradientColors[0].withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: widget.isEnabled
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              widget.icon,
                              color: widget.isEnabled
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.4),
                              size: 26,
                            ),
                          ),
                          if (!widget.isEnabled)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.lock_outline_rounded,
                                    color: Colors.white.withOpacity(0.5),
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Soon',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white.withOpacity(0.7),
                              size: 20,
                            ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: widget.isEnabled
                              ? Colors.white
                              : Colors.white.withOpacity(0.6),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.description,
                        style: TextStyle(
                          color: widget.isEnabled
                              ? Colors.white.withOpacity(0.9)
                              : Colors.white.withOpacity(0.35),
                          fontSize: 13,
                          height: 1.3,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: widget.animationDelay))
        .fadeIn(duration: 500.ms)
        .slideY(
          begin: 0.3,
          end: 0,
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
