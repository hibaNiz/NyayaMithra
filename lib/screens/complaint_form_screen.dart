import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:signature/signature.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../config/theme.dart';

class ComplaintFormScreen extends StatefulWidget {
  final String issueType;
  final String reason;
  final String legalContext;
  final String actionSteps;

  const ComplaintFormScreen({
    super.key,
    required this.issueType,
    required this.reason,
    required this.legalContext,
    required this.actionSteps,
  });

  @override
  State<ComplaintFormScreen> createState() => _ComplaintFormScreenState();
}

class _ComplaintFormScreenState extends State<ComplaintFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _authorityController = TextEditingController();

  late SignatureController _signatureController;
  bool _isGenerating = false;
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.transparent,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _authorityController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() => _isFetchingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.',
        );
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final addressStr =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea} - ${place.postalCode}';

        setState(() {
          _addressController.text = addressStr;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address autofilled via GPS!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not fetch location: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingLocation = false);
      }
    }
  }

  Future<Uint8List> _createPdfDocument({
    required String date,
    required Uint8List? signatureBytes,
  }) async {
    final pdf = pw.Document();

    final ttfBase = await PdfGoogleFonts.tinosRegular();
    final ttfBold = await PdfGoogleFonts.tinosBold();
    // Fallback for Indian Languages (Malayalam, Hindi, etc) and Currency (₹)
    final fallbackDevanagari =
        await PdfGoogleFonts.notoSerifDevanagariRegular();
    final fallbackMalayalam = await PdfGoogleFonts.notoSerifMalayalamRegular();

    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final contact = _contactController.text.trim();
    final authority = _authorityController.text.trim();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(60),
        theme:
            pw.ThemeData.withFont(
              base: ttfBase,
              bold: ttfBold,
              fontFallback: [fallbackDevanagari, fallbackMalayalam],
            ).copyWith(
              defaultTextStyle: pw.TextStyle(
                font: ttfBase,
                fontFallback: [fallbackDevanagari, fallbackMalayalam],
                fontSize: 12,
                lineSpacing: 1.5,
              ),
            ),
        build: (pw.Context context) {
          return [
            pw.Text(
              'FORMAL PUBLIC GRIEVANCE',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                decoration: pw.TextDecoration.underline,
              ),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 30),
            pw.Text(
              'Date: $date',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 15),
            pw.Text('To,', style: const pw.TextStyle()),
            pw.Text(
              authority,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'The Concerned Municipal Authority',
              style: const pw.TextStyle(),
            ),

            pw.SizedBox(height: 25),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Subject: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Expanded(
                  child: pw.Text(
                    'Formal grievance regarding the civic issue of ${widget.issueType}.',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text('Respected Sir/Madam,', style: const pw.TextStyle()),
            pw.SizedBox(height: 10),
            pw.Text(
              'I am writing to bring to your immediate attention a severe civic issue strictly observed recently in our locality. '
              'As a responsible citizen and resident, I am submitting this formal grievance regarding the following public nuisance:',
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 15),
            pw.Text(
              'Nature of Issue:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(widget.issueType),

            pw.SizedBox(height: 10),
            pw.Text(
              'Details and Observations:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(widget.reason, textAlign: pw.TextAlign.justify),

            pw.SizedBox(height: 15),
            pw.Text(
              'Based on Indian law and prevailing municipal regulations, it is the bounden duty of the authorities to maintain public infrastructure and ensure citizen safety. Accordingly, I humbly request you to take immediate action.',
              textAlign: pw.TextAlign.justify,
            ),

            pw.SizedBox(height: 15),
            pw.Text(
              'Applicable Legal Provisions:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(widget.legalContext, textAlign: pw.TextAlign.justify),

            pw.SizedBox(height: 20),
            pw.Text(
              'I urgently request your prompt intervention to resolve this matter to ensure public safety and appropriate civic maintenance. '
              'I look forward to a formal acknowledgment of this complaint and a speedy resolution of the issue.',
              textAlign: pw.TextAlign.justify,
            ),

            pw.SizedBox(height: 30),
            pw.Text('Yours faithfully,'),
            pw.SizedBox(height: 10),

            if (signatureBytes != null && signatureBytes.isNotEmpty)
              pw.Container(
                height: 60,
                child: pw.Image(pw.MemoryImage(signatureBytes)),
                alignment: pw.Alignment.centerLeft,
              )
            else
              pw.SizedBox(height: 60),

            pw.Text(
              '_________________________',
              style: pw.TextStyle(color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 5),
            pw.Text('(Signature of Complainant)'),
            pw.SizedBox(height: 10),
            pw.Text(name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(address),
            pw.Text('Contact: $contact'),
          ];
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _generateAndPreview() async {
    if (!_formKey.currentState!.validate()) return;

    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide your signature before generating.'),
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final now = DateTime.now();
      final dateStr = '${now.day}/${now.month}/${now.year}';
      final sigBytes = await _signatureController.toPngBytes();

      final pdfBytes = await _createPdfDocument(
        date: dateStr,
        signatureBytes: sigBytes,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(
                title: const Text('Formal Complaint Preview'),
                backgroundColor: AppTheme.primaryColor,
              ),
              body: PdfPreview(
                build: (format) => pdfBytes,
                pdfFileName:
                    'Formal_Complaint_${_nameController.text.trim()}.pdf',
                canChangePageFormat: false,
                allowPrinting: true,
                allowSharing: true,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Draft Formal Complaint',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Complainant Details',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Provide your contact and submission details. GPS and E-Signature are enabled below to fast-track your form.',
                  style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 24),

                _buildTextField(
                  controller: _nameController,
                  label: 'Full Legal Name',
                  icon: Icons.person,
                  validator: (val) => val == null || val.isEmpty
                      ? 'Please enter your name'
                      : null,
                ),

                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    _buildTextField(
                      controller: _addressController,
                      label: 'Full Address',
                      icon: Icons.home,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Please enter your address'
                          : null,
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: IconButton(
                        icon: _isFetchingLocation
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.accentColor,
                                ),
                              )
                            : const Icon(
                                Icons.my_location,
                                color: AppTheme.accentColor,
                              ),
                        onPressed: _isFetchingLocation ? null : _fetchLocation,
                        tooltip: 'Use Current GPS Location',
                      ),
                    ),
                  ],
                ),

                _buildTextField(
                  controller: _contactController,
                  label: 'Contact Number / Email',
                  icon: Icons.phone,
                  validator: (val) => val == null || val.isEmpty
                      ? 'Please enter a contact method'
                      : null,
                ),

                _buildTextField(
                  controller: _authorityController,
                  label: 'Authority Addressed to (e.g. Municipal Commissioner)',
                  icon: Icons.account_balance,
                  validator: (val) => val == null || val.isEmpty
                      ? 'Please enter the addressed authority'
                      : null,
                ),

                const SizedBox(height: 24),
                const Text(
                  'Digital Signature',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please sign in the box below. This will be embedded in the final PDF.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.surfaceColor, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Signature(
                      controller: _signatureController,
                      height: 150,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _signatureController.clear(),
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear Signature'),
                  ),
                ),

                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateAndPreview,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.picture_as_pdf_outlined),
                  label: Text(
                    _isGenerating ? 'Generating...' : 'Review & Download PDF',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textMuted),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(icon, color: AppTheme.accentColor, size: 22),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 50),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.03),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppTheme.accentColor,
              width: 1.5,
            ),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
