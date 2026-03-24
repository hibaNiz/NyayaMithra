import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/analysis_result.dart';

class GeminiService {
  static GeminiService? _instance;
  final Dio _dio = Dio();

  static const String _invokeUrl =
      "https://integrate.api.nvidia.com/v1/chat/completions";
  static const String _model = "qwen/qwen3.5-122b-a10b";

  GeminiService._();

  static GeminiService get instance {
    _instance ??= GeminiService._();
    return _instance!;
  }

  String get _apiKey =>
      dotenv.env['NVDA_API_KEY'] ??
      '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';

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
      final responseText = await analyzeDocumentRaw(imageBytes, language);
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
      if (_apiKey.isEmpty)
        throw Exception('NVDA_API_KEY not found in environment');

      final base64Image = base64Encode(imageBytes);
      final imageDataUrl = "data:image/jpeg;base64,$base64Image";

      final messages = [
        {
          "role": "user",
          "content": [
            {
              "type": "image_url",
              "image_url": {"url": imageDataUrl},
            },
            {"type": "text", "text": _getSystemPrompt(language)},
          ],
        },
      ];

      return await _callApi(messages, maxTokens: 4096);
    } catch (e) {
      throw Exception('Failed to analyze document: $e');
    }
  }

  Future<String> getCivicAssistanceResponse(
    String userMessage,
    String language,
  ) async {
    try {
      if (_apiKey.isEmpty)
        throw Exception('NVDA_API_KEY not found in environment');

      final messages = [
        {"role": "system", "content": _getCivicAssistancePrompt(language)},
        {"role": "user", "content": userMessage},
      ];

      return await _callApi(messages, maxTokens: 2048);
    } catch (e) {
      throw Exception('Failed to get civic assistance response: $e');
    }
  }

  Future<String> _callApi(
    List<Map<String, dynamic>> messages, {
    int maxTokens = 1024,
  }) async {
    final payload = {
      "model": _model,
      "messages": messages,
      "max_tokens": maxTokens,
      "temperature": 0.40,
      "top_p": 0.95,
      "stream": false,
      "chat_template_kwargs": {"enable_thinking": false},
    };

    final response = await _dio.post(
      _invokeUrl,
      options: Options(
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Accept": "application/json",
        },
        sendTimeout: const Duration(seconds: 90),
        receiveTimeout: const Duration(seconds: 90),
      ),
      data: payload,
    );

    if (response.statusCode == 200) {
      return response.data['choices'][0]['message']['content'] as String;
    }

    return 'Unable to generate response from NVIDIA integration.';
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
