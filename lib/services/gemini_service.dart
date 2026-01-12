import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/analysis_result.dart';

class GeminiService {
  static GeminiService? _instance;
  late final GenerativeModel _model;

  GeminiService._() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in environment');
    }

    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.4,
        topK: 32,
        topP: 0.9,
        maxOutputTokens: 4096,
      ),
    );
  }

  static GeminiService get instance {
    _instance ??= GeminiService._();
    return _instance!;
  }

  String _getSystemPrompt(String language) {
    final languageName = language == 'ml' ? 'Malayalam' : 'English';

    return '''
You are NyayaMithra, an expert Indian legal document analyst. Analyze the document image provided and give a DETAILED analysis.

CRITICAL: You MUST carefully examine the image and extract actual information from it. Do NOT give generic responses.

Provide your analysis in this EXACT format with these section headers:

**Document Type**
[Identify the specific type of legal document from the image]

**What I See**
[Describe what you actually see in the document - text, stamps, signatures, format, etc.]

**Simple Explanation**
[Explain what this document is about in simple terms]

**Key Information**
[Extract ACTUAL information from the document:]
• Name(s): [from document]
• Date(s): [from document]
• Amount(s): [from document]
• Address(es): [from document]
• Any other important details you can read

**Legal Implications**
[What are the legal consequences and obligations created by this document?]

**Completeness Check**
• Document appears [complete/incomplete]
• Signatures: [present/missing]
• Stamps: [present/missing/describe what you see]
• Missing information: [list any blank fields]

**Important Warnings**
[Any concerns or red flags visible in the document]

**Recommendations**
[What should the person do next with this document?]

RULES:
1. Respond in $languageName language
2. Use simple, everyday words
3. Extract REAL information from the image - don't make up generic content
4. If text is unclear, mention which parts are hard to read
5. If it's not a legal document, explain what you see
6. Be specific and detailed based on what's ACTUALLY in the image
''';
  }

  Future<AnalysisResult> analyzeDocument(
    Uint8List imageBytes,
    String language,
  ) async {
    try {
      final prompt = _getSystemPrompt(language);

      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ];

      final response = await _model.generateContent(content);
      final responseText = response.text ?? 'Unable to analyze the document.';

      return AnalysisResult.fromRawResponse(responseText, language);
    } catch (e) {
      throw Exception('Failed to analyze document: $e');
    }
  }

  Future<String> analyzeDocumentRaw(
    Uint8List imageBytes,
    String language,
  ) async {
    try {
      final prompt = _getSystemPrompt(language);

      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ];

      final response = await _model.generateContent(content);
      return response.text ?? 'Unable to analyze the document.';
    } catch (e) {
      throw Exception('Failed to analyze document: $e');
    }
  }

  Future<String> getCivicAssistanceResponse(
    String userMessage,
    String language,
  ) async {
    try {
      final prompt = _getCivicAssistancePrompt(language);

      final content = [Content.text('$prompt\n\nUser Query: $userMessage')];

      final response = await _model.generateContent(content);
      return response.text ?? 'I apologize, I couldn\'t generate a response.';
    } catch (e) {
      throw Exception('Failed to get civic assistance response: $e');
    }
  }

  String _getCivicAssistancePrompt(String language) {
    final languageName = language == 'ml' ? 'Malayalam' : 'English';

    return '''
You are NyayaMithra Civic Assistant, an expert AI helper for Indian legal rights, civic procedures, and government schemes.

YOUR EXPERTISE COVERS:
• Indian Constitution - Fundamental Rights, Duties, and Directive Principles
• Indian Legal System - Civil, Criminal, and Administrative Law
• Government Schemes - Central and State welfare programs
• Civic Services - Ration card, Aadhaar, PAN, Voter ID, Passport
• Consumer Rights - Product returns, complaints, refunds
• RTI (Right to Information) - How to file, what to request
• Property & Land Rights - Ownership, registration, disputes
• Employment Laws - Labor rights, minimum wage, workplace issues
• Women & Child Rights - Special protections and schemes
• Senior Citizen & Disability Benefits
• Legal Procedures - Filing FIR, court procedures, bail
• Public Services - Electricity, water, municipal services

GUIDELINES FOR YOUR RESPONSES:
1. Be accurate and cite relevant laws/acts when applicable (e.g., Consumer Protection Act 2019)
2. Explain legal concepts in SIMPLE terms anyone can understand
3. Provide step-by-step guidance for procedures
4. Mention required documents when relevant
5. Inform about time limits and fees if applicable
6. Suggest when professional legal help is necessary
7. Be empathetic and supportive
8. Respond in $languageName language
9. If you're unsure, admit it and suggest consulting a lawyer
10. Keep responses concise but comprehensive

IMPORTANT:
- Never give specific case advice that requires a lawyer
- Focus on general information and procedural guidance
- Always mention that complex matters need professional consultation
- Prioritize user safety and legal compliance

Now answer the user's query professionally and helpfully.
''';
  }
}
