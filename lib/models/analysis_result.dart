class AnalysisResult {
  final String documentType;
  final String simpleExplanation;
  final List<String> keyInformation;
  final String legalImplications;
  final String completenessCheck;
  final List<String> warnings;
  final List<String> recommendations;
  final String rawResponse;
  final DateTime analyzedAt;
  final String language;
  
  AnalysisResult({
    required this.documentType,
    required this.simpleExplanation,
    required this.keyInformation,
    required this.legalImplications,
    required this.completenessCheck,
    required this.warnings,
    required this.recommendations,
    required this.rawResponse,
    required this.analyzedAt,
    required this.language,
  });
  
  factory AnalysisResult.fromRawResponse(String response, String language) {
    // Parse the response and extract sections
    // This is a simplified parser - the actual response structure depends on Gemini
    return AnalysisResult(
      documentType: _extractSection(response, 'Document Type') ?? 'Legal Document',
      simpleExplanation: _extractSection(response, 'Simple Explanation') ?? response,
      keyInformation: _extractList(response, 'Key Information'),
      legalImplications: _extractSection(response, 'Legal Implications') ?? '',
      completenessCheck: _extractSection(response, 'Completeness Check') ?? '',
      warnings: _extractList(response, 'Important Warnings'),
      recommendations: _extractList(response, 'Recommendations'),
      rawResponse: response,
      analyzedAt: DateTime.now(),
      language: language,
    );
  }
  
  static String? _extractSection(String text, String sectionName) {
    final patterns = [
      RegExp(r'\*\*' + sectionName + r'\*\*[:\s]*(.+?)(?=\*\*|\n\n|$)', dotAll: true),
      RegExp(sectionName + r'[:\s]*(.+?)(?=\n\n|$)', dotAll: true, caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(1)?.trim();
      }
    }
    return null;
  }
  
  static List<String> _extractList(String text, String sectionName) {
    final section = _extractSection(text, sectionName);
    if (section == null) return [];
    
    final lines = section.split(RegExp(r'\n[-•*]|\n\d+\.'));
    return lines
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }
  
  Map<String, dynamic> toJson() {
    return {
      'documentType': documentType,
      'simpleExplanation': simpleExplanation,
      'keyInformation': keyInformation,
      'legalImplications': legalImplications,
      'completenessCheck': completenessCheck,
      'warnings': warnings,
      'recommendations': recommendations,
      'rawResponse': rawResponse,
      'analyzedAt': analyzedAt.toIso8601String(),
      'language': language,
    };
  }
}
