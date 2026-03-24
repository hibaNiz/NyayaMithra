import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NvidiaGrievanceService {
  static const String _invokeUrl =
      "https://integrate.api.nvidia.com/v1/chat/completions";
  static const String _model = "qwen/qwen3.5-122b-a10b";

  final Dio _dio = Dio();

  String get _apiKey => dotenv.env['NVDA_API_KEY'] ?? '';

  static const String _imageSystemPrompt =
      """You are an expert Indian Civic Law legal advisor and vision analyst.
The user has submitted a photo. Your job is to ONLY look at the image and determine if it contains a civic/public infrastructure issue.

Civic issues include: potholes, broken roads, illegal dumping, garbage overflow, broken streetlights, open drains, encroachments, water logging, sewage overflow, damaged footpaths, fallen trees blocking roads, etc.

Always respond with a single valid JSON object with EXACTLY these 5 fields:
{
  "issue_type": "Short name of the issue (e.g. Pothole, Illegal Dumping). Use 'None' if no issue.",
  "is_civic_issue": "true or false",
  "reason": "If no civic issue: explain what you actually see in the image and why it is not a reportable civic issue. If it IS a civic issue: briefly describe the exact problem visible.",
  "legal_context": "If civic issue: cite the specific Indian laws, municipal acts, or bylaws that cover this (e.g. Municipal Corporations Act, Motor Vehicles Act, etc.). If not civic issue: leave as empty string.",
  "action_steps": "If civic issue: numbered step-by-step guidance on reporting or resolving it per Indian law. E.g. Step 1: ... Step 2: ... Step 3: ... If not civic issue: leave as empty string."
}

Do not include any text outside the JSON. Respond ONLY with the JSON object.""";

  static const String _textSystemPrompt =
      """You are an expert Indian Civic Law legal advisor.
The user has described a civic/public infrastructure issue they have encountered or observed.

Your role is to:
1. Identify the type of civic issue from their description.
2. Cite specific Indian laws, municipal bylaws, or acts that cover this issue.
3. Give clear step-by-step guidance on how to report or resolve it per Indian law.

Always respond with a single valid JSON object with EXACTLY these 5 fields:
{
  "issue_type": "Short name of the issue (e.g. Pothole, Noise Pollution). Use 'Unclear' if description is vague.",
  "is_civic_issue": "true or false",
  "reason": "Brief explanation of what the issue is and why it is a public concern. If not a civic issue, explain why.",
  "legal_context": "The specific Indian laws/acts/municipal bylaws that apply to this issue.",
  "action_steps": "Numbered step-by-step guidance. E.g. Step 1: ... Step 2: ... Step 3: ..."
}

Do not include any text outside the JSON. Respond ONLY with the JSON object.""";

  /// Analyse an image for civic issues (vision mode)
  Future<Map<String, dynamic>?> analyzeImageForGrievance(
    Uint8List imageBytes, {
    String language = 'en',
  }) async {
    try {
      if (_apiKey.isEmpty) return null;

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
            {
              "type": "text",
              "text":
                  "$_imageSystemPrompt\nCRITICAL RULE: Translate the values for 'issue_type', 'reason', 'legal_context', and 'action_steps' to ${language == 'ml' ? 'Malayalam' : 'English'}. The JSON keys MUST remain exactly as written in English.",
            },
          ],
        },
      ];

      return await _callApi(messages);
    } catch (e) {
      print('Error analyzing image for grievance: $e');
      return null;
    }
  }

  /// Analyse a text description for civic issues (text mode)
  Future<Map<String, dynamic>?> analyzeTextForGrievance(
    String description, {
    String language = 'en',
  }) async {
    try {
      if (_apiKey.isEmpty) return null;

      final messages = [
        {
          "role": "system",
          "content":
              _textSystemPrompt +
              "\nCRITICAL RULE: Translate the values for 'issue_type', 'reason', 'legal_context', and 'action_steps' to ${language == 'ml' ? 'Malayalam' : 'English'}. The JSON keys MUST remain exactly as written in English.",
        },
        {"role": "user", "content": "Issue description: $description"},
      ];

      return await _callApi(messages);
    } catch (e) {
      print('Error analyzing text for grievance: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _callApi(
    List<Map<String, dynamic>> messages,
  ) async {
    final payload = {
      "model": _model,
      "messages": messages,
      "max_tokens": 1024,
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
      final content =
          response.data['choices'][0]['message']['content'] as String;
      return _parseResponse(content);
    }
    return null;
  }

  Map<String, dynamic>? _parseResponse(String raw) {
    try {
      String cleaned = raw.trim();
      // Strip markdown code fences if present
      if (cleaned.startsWith("```")) {
        cleaned = cleaned
            .replaceAll(RegExp(r"```[a-z]*\n?"), "")
            .replaceAll("```", "")
            .trim();
      }
      // Extract first JSON object
      final match = RegExp(r'\{[\s\S]*\}').firstMatch(cleaned);
      if (match == null) return null;
      return jsonDecode(match.group(0)!) as Map<String, dynamic>;
    } catch (e) {
      print('Error parsing response: $e');
      return null;
    }
  }
}
