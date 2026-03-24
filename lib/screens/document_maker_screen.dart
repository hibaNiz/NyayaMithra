import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../config/theme.dart';

class DocumentMakerScreen extends StatelessWidget {
  const DocumentMakerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Maker', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
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
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Generate Legal Documents',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().fadeIn().slideY(begin: -0.2),
              const SizedBox(height: 8),
              Text(
                'Select a template below to auto-generate a government-compliant document tailored to your needs.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.5,
                ),
              ).animate(delay: 200.ms).fadeIn(),
              
              const SizedBox(height: 32),
              
              _TemplateCard(
                title: 'Rental Agreement',
                description: 'Standard 11-month residential rent agreement suitable for landlords and tenants.',
                icon: Icons.home_work_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DocumentFormScreen(
                        templateName: 'Rental Agreement',
                      ),
                    ),
                  );
                },
              ).animate(delay: 400.ms).fadeIn().slideX(begin: 0.1),
              
              const SizedBox(height: 16),
              
              _TemplateCard(
                title: 'Name Change Affidavit',
                description: 'Legal document required for publishing name change in the official Gazette.',
                icon: Icons.badge_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DocumentFormScreen(
                        templateName: 'Name Change Affidavit',
                      ),
                    ),
                  );
                },
              ).animate(delay: 600.ms).fadeIn().slideX(begin: 0.1),
              
              const SizedBox(height: 16),
              
              _TemplateCard(
                title: 'General Power of Attorney',
                description: 'Legally authorize another person to act on your behalf in general matters.',
                icon: Icons.gavel_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DocumentFormScreen(
                        templateName: 'General Power of Attorney',
                      ),
                    ),
                  );
                },
              ).animate(delay: 800.ms).fadeIn().slideX(begin: 0.1),

              const SizedBox(height: 16),

              _TemplateCard(
                title: 'Non-Disclosure Agreement',
                description: 'Secure your trade secrets and confidential information with a standard NDA.',
                icon: Icons.security_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DocumentFormScreen(
                        templateName: 'Non-Disclosure Agreement',
                      ),
                    ),
                  );
                },
              ).animate(delay: 1000.ms).fadeIn().slideX(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppTheme.accentColor, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class DocumentFormScreen extends StatefulWidget {
  final String templateName;

  const DocumentFormScreen({super.key, required this.templateName});

  @override
  State<DocumentFormScreen> createState() => _DocumentFormScreenState();
}

class _DocumentFormScreenState extends State<DocumentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  bool _isGenerating = false;

  List<Widget> _buildFields() {
    if (widget.templateName == 'Rental Agreement') {
      return [
        _buildTextField('landlordName', 'Landlord Name', 'Enter full legal name of landlord', Icons.person),
        _buildTextField('tenantName', 'Tenant Name', 'Enter full legal name of tenant', Icons.person_outline),
        _buildTextField('propertyAddress', 'Property Address', 'Full address of the rental property', Icons.location_on),
        _buildDropdownField('monthlyRent', 'Monthly Rent Amount', ['₹5,000 - ₹10,000', '₹10,000 - ₹20,000', '₹20,000 - ₹50,000', '₹50,000+'], Icons.currency_rupee),
        _buildTextField('deposit', 'Security Deposit', 'E.g. ₹50,000 (Refundable)', Icons.account_balance_wallet),
      ];
    } else if (widget.templateName == 'Name Change Affidavit') {
      return [
        _buildTextField('oldName', 'Current Name (Old Name)', 'Enter your exact current legal name', Icons.person_off),
        _buildTextField('newName', 'Proposed New Name', 'Enter your desired new name', Icons.person),
        _buildTextField('guardianName', 'Father/Husband Name', 'For identification purposes', Icons.family_restroom),
        _buildTextField('address', 'Permanent Address', 'Your current residence address', Icons.home),
        _buildDropdownField('reason', 'Reason for Name Change', ['Marriage', 'Astrology/Numerology', 'Divorce', 'Personal Preference', 'Religion Change'], Icons.question_mark),
      ];
    } else if (widget.templateName == 'General Power of Attorney') {
      return [
        _buildTextField('principalName', 'Principal (Executant) Name', 'Your full legal name', Icons.person),
        _buildTextField('principalAddress', 'Principal Address', 'Your current residence address', Icons.home),
        _buildTextField('attorneyName', 'Attorney (Agent) Name', 'Name of the person you are authorizing', Icons.person_outline),
        _buildTextField('relation', 'Relationship with Attorney', 'E.g., Brother, Friend, Business Partner', Icons.people),
        _buildDropdownField('purpose', 'Primary Scope of Authority', ['Property Management', 'Bank Operations', 'Court Matters', 'General/All Scope'], Icons.assignment),
      ];
    } else { // Non-Disclosure Agreement
      return [
        _buildTextField('disclosingParty', 'Disclosing Party Name', 'Name of individual/company sharing info', Icons.business),
        _buildTextField('receivingParty', 'Receiving Party Name', 'Name of individual/company receiving info', Icons.business_center),
        _buildDropdownField('duration', 'NDA Duration', ['1 Year', '2 Years', '3 Years', '5 Years', 'Indefinite'], Icons.timer),
        _buildTextField('purpose', 'Purpose of Agreement', 'E.g., Software Discussion, M&A, Business Partnership', Icons.handshake),
        _buildTextField('jurisdiction', 'Governing State Jurisdiction', 'E.g., Karnataka, Maharashtra, Delhi', Icons.balance),
      ];
    }
  }

  Widget _buildTextField(String key, String label, String hint, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textMuted),
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textMuted),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(icon, color: AppTheme.accentColor, size: 22),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 50),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          filled: true,
          fillColor: Colors.white.withOpacity(0.03),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.accentColor, width: 1.5)),
        ),
        validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
        onSaved: (value) => _formData[key] = value,
      ),
    );
  }

  Widget _buildDropdownField(String key, String label, List<String> items, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        style: const TextStyle(color: AppTheme.textPrimary),
        dropdownColor: AppTheme.cardColor,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textMuted),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(icon, color: AppTheme.accentColor, size: 22),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 50),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          filled: true,
          fillColor: Colors.white.withOpacity(0.03),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.accentColor, width: 1.5)),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        validator: (value) => value == null ? 'Please select an option' : null,
        onChanged: (val) {},
        onSaved: (value) => _formData[key] = value,
      ),
    );
  }

  Future<void> _generateDocument() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    setState(() => _isGenerating = true);

    try {
      final pdfBytes = await _createPdfDocument();
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GeneratedDocumentScreen(
              title: widget.templateName,
              pdfBytes: pdfBytes,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<Uint8List> _createPdfDocument() async {
    final pdf = pw.Document();

    final ttfBase = await PdfGoogleFonts.tinosRegular();
    final ttfBold = await PdfGoogleFonts.tinosBold();
    final ttfItalic = await PdfGoogleFonts.tinosItalic();
    final fallback = await PdfGoogleFonts.notoSerifDevanagariRegular();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(60),
        theme: pw.ThemeData.withFont(
          base: ttfBase,
          bold: ttfBold,
          italic: ttfItalic,
          fontFallback: [fallback],
        ).copyWith(
          defaultTextStyle: pw.TextStyle(
            font: ttfBase,
            fontFallback: [fallback],
            fontSize: 12,
            lineSpacing: 2,
          ),
        ),
        build: (pw.Context context) {
          if (widget.templateName == 'Rental Agreement') {
            return _buildRentalPdf();
          } else if (widget.templateName == 'Name Change Affidavit') {
            return _buildAffidavitPdf();
          } else if (widget.templateName == 'General Power of Attorney') {
            return _buildPoAPdf();
          } else {
            return _buildNdaPdf();
          }
        },
      ),
    );

    return pdf.save();
  }

  List<pw.Widget> _buildRentalPdf() {
    return [
      pw.Text('RENTAL AGREEMENT', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline), textAlign: pw.TextAlign.center),
      pw.SizedBox(height: 30),
      pw.Text('This Rent Agreement is made and executed on this ______ day of _____________, 20___, between:', textAlign: pw.TextAlign.justify),
      pw.SizedBox(height: 15),
      pw.Text('${_formData['landlordName']}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      pw.Text('(Hereinafter called the "Landlord" which expression shall mean and include his legal heirs, successors, and assigns) of the FIRST PART.', textAlign: pw.TextAlign.justify),
      pw.SizedBox(height: 15),
      pw.Text('AND', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14), textAlign: pw.TextAlign.center),
      pw.SizedBox(height: 15),
      pw.Text('${_formData['tenantName']}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      pw.Text('(Hereinafter called the "Tenant" which expression shall mean and include his legal heirs, successors, and assigns) of the SECOND PART.', textAlign: pw.TextAlign.justify),
      pw.SizedBox(height: 25),
      pw.Text('WHEREAS the Landlord is the absolute owner of the property located at:'),
      pw.SizedBox(height: 5),
      pw.Padding(
        padding: const pw.EdgeInsets.only(left: 20),
        child: pw.Text('${_formData['propertyAddress']}', style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontWeight: pw.FontWeight.bold)),
      ),
      pw.SizedBox(height: 25),
      pw.Text('AND WHEREAS the Tenant has approached the Landlord to let out the said premises on rent, terms and conditions are as follows:', textAlign: pw.TextAlign.justify),
      pw.SizedBox(height: 15),
      _buildLegalClause('1. Monthly Rent', 'The monthly rent for the premises shall be ${_formData['monthlyRent']}, payable strictly on or before the 5th of every month.'),
      _buildLegalClause('2. Security Deposit', 'The Tenant has paid an interest-free security deposit of ${_formData['deposit']} to the Landlord, which shall be refundable at the time of vacating the premises.'),
      _buildLegalClause('3. Lock-in Period', 'The tenancy will be valid for a period of 11 months starting from the date of this agreement.'),
      _buildLegalClause('4. Purpose of Use', 'The Tenant shall purely use the premises for residential purposes only and shall not use it for any commercial or illegal activities.'),
      pw.SizedBox(height: 40),
      pw.Text('IN WITNESS WHEREOF both the parties have signed this agreement in the presence of witnesses on the date and year aforementioned.', textAlign: pw.TextAlign.justify),
      pw.SizedBox(height: 60),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('_________________________', style: pw.TextStyle(color: PdfColors.grey600)),
              pw.SizedBox(height: 5),
              pw.Text('Signature of Landlord', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('${_formData['landlordName']}'),
            ]
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('_________________________', style: pw.TextStyle(color: PdfColors.grey600)),
              pw.SizedBox(height: 5),
              pw.Text('Signature of Tenant', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('${_formData['tenantName']}'),
            ]
          ),
        ]
      )
    ];
  }

  pw.Widget _buildLegalClause(String title, String body) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10, left: 10),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('• ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Expanded(
            child: pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(text: '$title: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.TextSpan(text: body),
                ],
              ),
              textAlign: pw.TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  List<pw.Widget> _buildAffidavitPdf() {
    return [
      pw.Text('AFFIDAVIT FOR NAME CHANGE', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline), textAlign: pw.TextAlign.center),
      pw.SizedBox(height: 40),
      pw.Text('I, ${_formData['oldName']}, S/O, D/O, W/O ${_formData['guardianName']}, presently residing at:', textAlign: pw.TextAlign.justify),
      pw.SizedBox(height: 5),
      pw.Padding(
        padding: const pw.EdgeInsets.only(left: 20),
        child: pw.Text('${_formData['address']}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ),
      pw.SizedBox(height: 20),
      pw.Text('Do hereby solemnly affirm and declare on oath as under:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.justify),
      pw.SizedBox(height: 20),
      _buildLegalClause('Previous Identity', 'That my previous name was ${_formData['oldName']} as recorded in my official documents.'),
      _buildLegalClause('New Identity', 'That I have absolutely renounced, relinquished, and abandoned the use of my former name and assumed the name of ${_formData['newName']}.'),
      _buildLegalClause('Reason for Change', 'That this change of name is executed due to ${_formData['reason']}.'),
      _buildLegalClause('Declaration', 'That henceforth, I shall be known, identified, and addressed as ${_formData['newName']} for all intents and purposes.'),
      _buildLegalClause('Truthfulness', 'That the facts stated above are true and correct to the best of my knowledge and belief, and nothing material has been concealed therefrom.'),
      pw.SizedBox(height: 40),
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text('_________________________', style: pw.TextStyle(color: PdfColors.grey600)),
            pw.SizedBox(height: 5),
            pw.Text('DEPONENT', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
      pw.SizedBox(height: 30),
      pw.Text('VERIFICATION', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
      pw.SizedBox(height: 15),
      pw.Text('Verified at __________________ on this ______ day of ___________, 20___, that the contents of this affidavit are true and correct.', textAlign: pw.TextAlign.justify),
      pw.SizedBox(height: 50),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('_________________________', style: pw.TextStyle(color: PdfColors.grey600)),
              pw.SizedBox(height: 5),
              pw.Text('Sign of Magistrate/Notary', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ]
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('_________________________', style: pw.TextStyle(color: PdfColors.grey600)),
              pw.SizedBox(height: 5),
              pw.Text('DEPONENT (Signature)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ]
          ),
        ]
      ),
    ];
  }

  List<pw.Widget> _buildPoAPdf() {
    return [
      pw.Text('GENERAL POWER OF ATTORNEY', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline), textAlign: pw.TextAlign.center),
      pw.SizedBox(height: 30),
      pw.Text('KNOW ALL MEN BY THESE PRESENTS that I, ${_formData['principalName']}, presently residing at:', textAlign: pw.TextAlign.justify),
      pw.SizedBox(height: 5),
      pw.Padding(
        padding: const pw.EdgeInsets.only(left: 20),
        child: pw.Text('${_formData['principalAddress']}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ),
      pw.SizedBox(height: 15),
      pw.Text('Hereinafter referred to as the "Principal" (which expression shall, unless repugnant to the context or meaning thereof, mean and include my heirs, executors, administrators, and assigns).', textAlign: pw.TextAlign.justify),
      pw.SizedBox(height: 25),
      pw.Text('DO HEREBY NOMINATE, CONSTITUTE AND APPOINT:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
      pw.SizedBox(height: 25),
      pw.Text('Mr./Ms. ${_formData['attorneyName']}, who is my ${_formData['relation']}, hereinafter referred to as the "Attorney".', textAlign: pw.TextAlign.justify),
      pw.SizedBox(height: 25),
      pw.Text('WHEREAS I am unable to personally attend to my affairs regarding ${_formData['purpose']}, I hereby authorize the said Attorney to act on my behalf and perform all or any of the following acts, deeds, and things:', textAlign: pw.TextAlign.justify),
      pw.SizedBox(height: 15),
      _buildLegalClause('Authority to Act', 'To represent me and act on my behalf in all matters concerning ${_formData['purpose']}.'),
      _buildLegalClause('Sign and Execute', 'To sign, execute, and deliver any documents, forms, deeds, or applications necessary for the aforesaid purpose.'),
      _buildLegalClause('Representation', 'To appear before any Government Authority, Registration Office, Bank, or Court as required under the scope of this authority.'),
      pw.SizedBox(height: 25),
      pw.Text('AND I HEREBY AGREE to ratify and confirm all and whatsoever the said Attorney shall lawfully do or cause to be done by virtue of these presents.', textAlign: pw.TextAlign.justify),
      pw.SizedBox(height: 60),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('_________________________', style: pw.TextStyle(color: PdfColors.grey600)),
              pw.SizedBox(height: 5),
              pw.Text('Signature of Principal', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('${_formData['principalName']}'),
            ]
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('_________________________', style: pw.TextStyle(color: PdfColors.grey600)),
              pw.SizedBox(height: 5),
              pw.Text('Accepted by Attorney', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('${_formData['attorneyName']}'),
            ]
          ),
        ]
      )
    ];
  }

  List<pw.Widget> _buildNdaPdf() {
    return [
      pw.Text('CONFIDENTIALITY AND NON-DISCLOSURE AGREEMENT', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline), textAlign: pw.TextAlign.center),
      pw.SizedBox(height: 30),
      pw.Text('This Non-Disclosure Agreement (the "Agreement") is entered into on this ______ day of _____________, 20___, by and between:', textAlign: pw.TextAlign.justify),
      pw.SizedBox(height: 15),
      pw.Text('${_formData['disclosingParty']}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      pw.Text('(Hereinafter referred to as the "Disclosing Party")', textAlign: pw.TextAlign.justify),
      pw.SizedBox(height: 15),
      pw.Text('AND', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14), textAlign: pw.TextAlign.center),
      pw.SizedBox(height: 15),
      pw.Text('${_formData['receivingParty']}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      pw.Text('(Hereinafter referred to as the "Receiving Party")', textAlign: pw.TextAlign.justify),
      pw.SizedBox(height: 25),
      pw.Text('WHEREAS the parties intend to engage in discussions concerning ${_formData['purpose']} (the "Purpose"). In the course of such activities, the Disclosing Party may share confidential information with the Receiving Party.', textAlign: pw.TextAlign.justify),
      pw.SizedBox(height: 15),
      pw.Text('NOW THEREFORE, in consideration of the mutual covenants set forth herein, the parties agree as follows:', textAlign: pw.TextAlign.justify),
      pw.SizedBox(height: 15),
      _buildLegalClause('1. Definition', 'Confidential Information means any non-public, proprietary information shared under this Purpose.'),
      _buildLegalClause('2. Non-Disclosure', 'The Receiving Party agrees to hold the Confidential Information in strict confidence and shall not disclose it to any third party without written consent.'),
      _buildLegalClause('3. Duration', 'The obligations of confidentiality under this Agreement shall survive for a period of ${_formData['duration']} from the date of disclosure.'),
      _buildLegalClause('4. Governing Law', 'This Agreement shall be governed by and construed in accordance with the laws of the State of ${_formData['jurisdiction']}, India.'),
      pw.SizedBox(height: 40),
      pw.Text('IN WITNESS WHEREOF, the parties hereto have executed this Agreement as of the date first written above.', textAlign: pw.TextAlign.justify),
      pw.SizedBox(height: 60),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('_________________________', style: pw.TextStyle(color: PdfColors.grey600)),
              pw.SizedBox(height: 5),
              pw.Text('For Disclosing Party', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('${_formData['disclosingParty']}'),
            ]
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('_________________________', style: pw.TextStyle(color: PdfColors.grey600)),
              pw.SizedBox(height: 5),
              pw.Text('For Receiving Party', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('${_formData['receivingParty']}'),
            ]
          ),
        ]
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fill Template: ${widget.templateName}', style: const TextStyle(fontSize: 16)),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: Container(
        color: AppTheme.backgroundColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
              ],
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Document Details',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please fill out the following fields. All information will be placed securely in the final PDF document.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  
                  ..._buildFields(),
                  
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generateDocument,
                    icon: _isGenerating 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.picture_as_pdf_outlined),
                    label: Text(_isGenerating ? 'Generating...' : 'Generate Format', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
      ),
    );
  }
}

class GeneratedDocumentScreen extends StatelessWidget {
  final String title;
  final Uint8List pdfBytes;

  const GeneratedDocumentScreen({super.key, required this.title, required this.pdfBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF: $title'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: PdfPreview(
        build: (format) => pdfBytes,
        pdfFileName: '${title.replaceAll(' ', '_')}.pdf',
        canChangePageFormat: false,
        allowPrinting: true,
        allowSharing: true,
        maxPageWidth: 700,
      ),
    );
  }
}
