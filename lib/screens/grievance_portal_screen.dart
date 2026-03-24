import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../config/theme.dart';
import '../services/nvidia_grievance_service.dart';
import 'complaint_form_screen.dart';

class GrievancePortalScreen extends StatefulWidget {
  const GrievancePortalScreen({super.key});

  @override
  State<GrievancePortalScreen> createState() => _GrievancePortalScreenState();
}

class _GrievancePortalScreenState extends State<GrievancePortalScreen> {
  final ImagePicker _picker = ImagePicker();
  final NvidiaGrievanceService _service = NvidiaGrievanceService();
  final TextEditingController _textController = TextEditingController();

  File? _image;
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  // ── Image picking ──
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _result = null;
          _textController.clear();
        });
      }
    } catch (e) {
      _showError('Failed to capture image: $e');
    }
  }

  // ── Analysis ──
  Future<void> _analyze() async {
    final textInput = _textController.text.trim();
    if (_image == null && textInput.isEmpty) {
      _showError('Please upload an image or describe the issue.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      Map<String, dynamic>? result;
      final language = context.read<AppProvider>().selectedLanguage; // Fetch selected language
      
      if (_image != null) {
        final bytes = await _image!.readAsBytes();
        result = await _service.analyzeImageForGrievance(bytes, language: language); // Pass language
      } else {
        result = await _service.analyzeTextForGrievance(textInput, language: language); // Pass language
      }

      setState(() {
        _isLoading = false;
        _result = result;
      });
      
    } catch (e) {
      setState(() { _isLoading = false; });
      _showError('Error analyzing issue: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  void _reset() {
    setState(() {
      _image = null;
      _result = null;
      _textController.clear();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grievance Portal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          if (_result != null || _image != null || _textController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _reset,
            ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Match the home screen exactly
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryColor, AppTheme.backgroundColor],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const Text(
                  'Report a Civic Issue',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn().slideY(begin: -0.2),
                const SizedBox(height: 8),
                Text(
                  'Upload a photo or describe the problem. Powered by Qwen 3.5 to determine Indian legal steps.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.5,
                  ),
                ).animate(delay: 200.ms).fadeIn(),
                
                const SizedBox(height: 32),

                // Main Input Section (Only show if no result is present)
                if (_result == null) ...[
                  // Image Uploader
                  GestureDetector(
                    onTap: () => _pickImage(ImageSource.camera),
                    child: Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _image != null 
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(_image!, fit: BoxFit.cover),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: IconButton(
                                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                                    onPressed: () => setState(() => _image = null),
                                    style: IconButton.styleFrom(backgroundColor: Colors.black54),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo_outlined, 
                                  size: 56, 
                                  color: AppTheme.accentColor.withOpacity(0.8),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Tap to capture photo',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () => _pickImage(ImageSource.gallery),
                                  icon: const Icon(Icons.photo_library_rounded, size: 16),
                                  label: const Text('Or choose from gallery'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white.withOpacity(0.7),
                                  ),
                                )
                              ],
                            ),
                    ),
                  ).animate(delay: 300.ms).scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 24),
                  
                  // Text Input
                  if (_image == null) ...[
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Colors.white24)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('OR', style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold)),
                        ),
                        const Expanded(child: Divider(color: Colors.white24)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: TextField(
                        controller: _textController,
                        maxLines: 4,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Describe the issue (e.g., deep pothole on Main St)',
                          hintStyle: TextStyle(color: AppTheme.textMuted),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                      ),
                    ).animate(delay: 400.ms).fadeIn(),
                  ],

                  const SizedBox(height: 32),

                  // Analyze Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _analyze,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: _isLoading 
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                              SizedBox(width: 12),
                              Text('Analysing with Qwen 3.5...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          )
                        : const Text(
                            'Analyse Issue',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                    ),
                  ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2),
                ],

                // Results Section
                if (_result != null) ...[
                  _buildResultView().animate().fadeIn().slideY(begin: 0.1),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultView() {
    final isCivic = _result!['is_civic_issue']?.toString().toLowerCase() == 'true';
    final issueType = _result!['issue_type']?.toString() ?? 'Unknown';
    final reason = _result!['reason']?.toString() ?? '';
    final legalContext = _result!['legal_context']?.toString() ?? '';
    final actionSteps = _result!['action_steps']?.toString() ?? '';

    if (!isCivic) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
          ],
          border: Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppTheme.warningColor, size: 48),
            const SizedBox(height: 16),
            const Text(
              'No Civic Issue Detected',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.warningColor),
            ),
            const SizedBox(height: 12),
            Text(
              reason,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _reset,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Try Another'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // AI Tag
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.cardColor.withOpacity(0.7), borderRadius: BorderRadius.circular(10)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, size: 12, color: AppTheme.secondaryColor),
                  SizedBox(width: 4),
                  Text('Qwen 3.5 AI', style: TextStyle(color: AppTheme.secondaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Main Result Container
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.15),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_rounded, color: AppTheme.accentColor, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Issue Identified', style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(issueType, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (reason.isNotEmpty) ...[
                      _buildResultSection('Details', Icons.description_outlined, reason),
                      const SizedBox(height: 24),
                    ],
                    
                    _buildResultSection('Indian Law Context', Icons.gavel_rounded, legalContext),
                    const SizedBox(height: 24),

                    _buildResultSection('Action Steps', Icons.format_list_numbered_rounded, actionSteps),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ComplaintFormScreen(
                                issueType: issueType,
                                reason: reason,
                                legalContext: legalContext,
                                actionSteps: actionSteps,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.send_rounded),
                        label: const Text('Draft Formal Complaint', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultSection(String title, IconData icon, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.accentColor),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          ],
        ),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(fontSize: 15, height: 1.6, color: AppTheme.textSecondary)),
      ],
    );
  }
}
