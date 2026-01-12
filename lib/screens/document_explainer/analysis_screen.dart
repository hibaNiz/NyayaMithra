import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../services/gemini_service.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/glass_container.dart';

class AnalysisScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final String language;

  const AnalysisScreen({
    super.key,
    required this.imageBytes,
    required this.language,
  });

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _analysisResult;
  String? _errorMessage;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _analyzeDocument();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _analyzeDocument() async {
    try {
      final result = await GeminiService.instance.analyzeDocumentRaw(
        widget.imageBytes,
        widget.language,
      );

      if (mounted) {
        setState(() {
          _analysisResult = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      provider.getString('analysis_result'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (!_isLoading && _analysisResult != null)
                    GestureDetector(
                      onTap: () async {
                        await Clipboard.setData(
                          ClipboardData(text: _analysisResult!),
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Analysis copied to clipboard!'),
                                ],
                              ),
                              backgroundColor: AppTheme.successColor,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.accentColor.withOpacity(0.3),
                          ),
                        ),
                        child: Icon(
                          Icons.content_copy_rounded,
                          color: AppTheme.accentColor,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? _buildLoadingView()
                  : _errorMessage != null
                  ? _buildErrorView(provider)
                  : _buildResultView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Document Icon
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.secondaryColor.withOpacity(
                          0.3 + (_pulseController.value * 0.2),
                        ),
                        AppTheme.accentColor.withOpacity(
                          0.2 + (_pulseController.value * 0.1),
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondaryColor.withOpacity(
                          0.2 + (_pulseController.value * 0.2),
                        ),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 40),

          const Text(
                'Analyzing your document...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                duration: 2000.ms,
                color: AppTheme.secondaryColor.withOpacity(0.5),
              ),

          const SizedBox(height: 12),

          Text(
            'AI is processing the document',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.secondaryColor,
              ),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 60),

          // Tips while loading
          GlassContainer(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppTheme.secondaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Tip: Make sure the document is clear and well-lit for better analysis',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate(delay: 500.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildErrorView(AppProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Icon(
                  Icons.error_outline_rounded,
                  color: AppTheme.errorColor,
                  size: 50,
                ),
              ),
            ),

            const SizedBox(height: 32),

            Text(
              provider.getString('error_occurred'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 40),

            GradientButton(
              text: provider.getString('try_again'),
              icon: Icons.refresh_rounded,
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _analyzeDocument();
              },
              width: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document Preview
          Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.memory(widget.imageBytes, fit: BoxFit.cover),
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.95, 0.95)),

          const SizedBox(height: 24),

          // Success Badge
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.successColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Analysis Complete',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
              .animate(delay: 100.ms)
              .fadeIn(duration: 400.ms)
              .slideX(begin: -0.2, end: 0),

          const SizedBox(height: 24),

          // Analysis Result
          _buildMarkdownContent(_analysisResult ?? '')
              .animate(delay: 200.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 32),

          // Action Buttons
          Row(
                children: [
                  Expanded(
                    child: OutlinedGradientButton(
                      text: 'New Analysis',
                      icon: Icons.add_a_photo_rounded,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      height: 54,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GradientButton(
                      text: 'Save',
                      icon: Icons.save_rounded,
                      onPressed: () {
                        // TODO: Implement save functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Analysis saved successfully!'),
                            backgroundColor: AppTheme.successColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      height: 54,
                    ),
                  ),
                ],
              )
              .animate(delay: 400.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildMarkdownContent(String content) {
    // Parse sections properly
    final sections = <Map<String, String>>[];
    final lines = content.split('\n');

    String? currentHeader;
    final currentBody = StringBuffer();

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // Check if this is a header line (starts with **)
      if (line.startsWith('**') && line.contains('**')) {
        // Save previous section if exists
        if (currentHeader != null) {
          sections.add({
            'header': currentHeader,
            'body': currentBody.toString().trim(),
          });
          currentBody.clear();
        }

        // Extract new header (remove ** markers)
        currentHeader = line.replaceAll('**', '').trim();
      } else if (currentHeader != null && line.isNotEmpty) {
        // This is body content for the current section
        if (currentBody.isNotEmpty) {
          currentBody.writeln();
        }
        currentBody.write(line);
      }
    }

    // Don't forget the last section
    if (currentHeader != null) {
      sections.add({
        'header': currentHeader,
        'body': currentBody.toString().trim(),
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((section) {
        return _buildSection(section['header'] ?? '', section['body'] ?? '');
      }).toList(),
    );
  }

  Widget _buildSection(String header, String body) {
    if (header.isEmpty) return const SizedBox.shrink();

    IconData icon;
    Color iconColor;

    // Determine icon based on header content
    if (header.toLowerCase().contains('type') ||
        header.toLowerCase().contains('തരം')) {
      icon = Icons.description_rounded;
      iconColor = AppTheme.accentColor;
    } else if (header.toLowerCase().contains('explanation') ||
        header.toLowerCase().contains('വിശദീകരണം')) {
      icon = Icons.lightbulb_outline_rounded;
      iconColor = AppTheme.secondaryColor;
    } else if (header.toLowerCase().contains('key') ||
        header.toLowerCase().contains('information') ||
        header.toLowerCase().contains('വിവരങ്ങൾ')) {
      icon = Icons.key_rounded;
      iconColor = const Color(0xFF64B5F6);
    } else if (header.toLowerCase().contains('legal') ||
        header.toLowerCase().contains('implications') ||
        header.toLowerCase().contains('നിയമ')) {
      icon = Icons.gavel_rounded;
      iconColor = const Color(0xFFBA68C8);
    } else if (header.toLowerCase().contains('completeness') ||
        header.toLowerCase().contains('check') ||
        header.toLowerCase().contains('പൂർണ്ണത')) {
      icon = Icons.checklist_rounded;
      iconColor = AppTheme.successColor;
    } else if (header.toLowerCase().contains('warning') ||
        header.toLowerCase().contains('മുന്നറിയിപ്പ്')) {
      icon = Icons.warning_rounded;
      iconColor = AppTheme.warningColor;
    } else if (header.toLowerCase().contains('recommendation') ||
        header.toLowerCase().contains('ശുപാർശ')) {
      icon = Icons.recommend_rounded;
      iconColor = const Color(0xFF4DD0E1);
    } else if (header.toLowerCase().contains('see') ||
        header.toLowerCase().contains('കാണുന്നത്')) {
      icon = Icons.visibility_rounded;
      iconColor = const Color(0xFF81C784);
    } else {
      icon = Icons.info_outline_rounded;
      iconColor = AppTheme.accentColor;
    }

    // Parse body for bullet points and formatting
    final lines = body.split('\n');
    final bodyWidgets = <Widget>[];

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      // Check if it's a bullet point
      if (trimmedLine.startsWith('•') ||
          trimmedLine.startsWith('-') ||
          trimmedLine.startsWith('*')) {
        final text = trimmedLine.substring(1).trim();
        bodyWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _parseFormattedText(
                    text,
                    Colors.white.withValues(alpha: 0.9),
                    14,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Regular text with formatting
        bodyWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _parseFormattedText(
              trimmedLine,
              Colors.white.withValues(alpha: 0.9),
              14,
            ),
          ),
        );
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            iconColor.withValues(alpha: 0.15),
            iconColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  header,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (bodyWidgets.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...bodyWidgets,
          ],
        ],
      ),
    );
  }

  Widget _parseFormattedText(String text, Color color, double fontSize) {
    // Parse **bold** text
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    var lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      // Add text before the match (normal text)
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: TextStyle(color: color, fontSize: fontSize, height: 1.6),
          ),
        );
      }

      // Add the bold text
      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            height: 1.6,
          ),
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining text after last match
    if (lastIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex),
          style: TextStyle(color: color, fontSize: fontSize, height: 1.6),
        ),
      );
    }

    // If no bold markers found, return simple text
    if (spans.isEmpty) {
      return Text(
        text,
        style: TextStyle(color: color, fontSize: fontSize, height: 1.6),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }
}
