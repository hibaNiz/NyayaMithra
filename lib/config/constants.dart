class AppConstants {
  // App Info
  static const String appName = 'NyayaMithra';
  static const String appTagline = 'Your Legal & Civic Companion';
  static const String appVersion = '1.0.0';

  // Feature IDs
  static const String featureDocumentExplainer = 'document_explainer';
  static const String featureDocumentMaker = 'document_maker';
  static const String featureCivicAssistance = 'civic_assistance';
  static const String featureGrievancePortal = 'grievance_portal';

  // Languages
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'ml': 'മലയാളം',
  };

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(seconds: 3);

  // API Configuration
  static const String geminiModel = 'gemini-1.5-flash';
  static const int maxImageSize = 4 * 1024 * 1024; // 4MB

  // Shared Preferences Keys
  static const String prefLanguage = 'preferred_language';
  static const String prefFirstLaunch = 'first_launch';
}

class AppStrings {
  // English Strings
  static const Map<String, String> en = {
    'home_title': 'NyayaMithra',
    'home_subtitle': 'Your Legal & Civic Companion',
    'document_explainer': 'Document Explainer',
    'document_explainer_desc':
        'Analyze and understand any legal document with AI',
    'document_maker': 'Document Maker',
    'document_maker_desc': 'Create legal documents with guided templates',
    'civic_assistance': 'Civic Assistance',
    'civic_assistance_desc': 'Get help with civic procedures and rights',
    'grievance_portal': 'Grievance Portal',
    'grievance_portal_desc': 'File and track public grievances',
    'coming_soon': 'Coming Soon',
    'capture_document': 'Capture Document',
    'select_from_gallery': 'Select from Gallery',
    'analyze': 'Analyze Document',
    'analyzing': 'Analyzing...',
    'retake': 'Retake',
    'select_language': 'Select Response Language',
    'camera_permission': 'Camera permission is required',
    'gallery_permission': 'Gallery access is required',
    'analysis_result': 'Analysis Result',
    'share': 'Share',
    'save': 'Save',
    'new_analysis': 'New Analysis',
    'error_occurred': 'An error occurred',
    'try_again': 'Try Again',
    'legal_clarity_title': 'Legal Clarity,\nReimagined.',
    'legal_clarity_desc':
        'Experience the future of legal assistance. Instant analysis, simplified explanations, and smart guidance at your fingertips.',
    'powered_by': 'POWERED BY GEMINI',
  };

  // Malayalam Strings
  static const Map<String, String> ml = {
    'home_title': 'ന്യായമിത്ര',
    'home_subtitle': 'നിങ്ങളുടെ നിയമ & പൗര സഹായി',
    'document_explainer': 'രേഖാ വിശദീകരണം',
    'document_explainer_desc': 'AI ഉപയോഗിച്ച് ഏത് നിയമ രേഖയും വിശകലനം ചെയ്യുക',
    'document_maker': 'രേഖാ നിർമ്മാണം',
    'document_maker_desc':
        'ഗൈഡഡ് ടെംപ്ലേറ്റുകൾ ഉപയോഗിച്ച് നിയമ രേഖകൾ സൃഷ്ടിക്കുക',
    'civic_assistance': 'പൗര സഹായം',
    'civic_assistance_desc': 'പൗര നടപടിക്രമങ്ങളിലും അവകാശങ്ങളിലും സഹായം നേടുക',
    'grievance_portal': 'പരാതി പോർട്ടൽ',
    'grievance_portal_desc':
        'പൊതു പരാതികൾ ഫയൽ ചെയ്യുകയും ട്രാക്ക് ചെയ്യുകയും ചെയ്യുക',
    'coming_soon': 'ഉടൻ വരുന്നു',
    'capture_document': 'രേഖ ക്യാപ്ചർ ചെയ്യുക',
    'select_from_gallery': 'ഗാലറിയിൽ നിന്ന് തിരഞ്ഞെടുക്കുക',
    'analyze': 'രേഖ വിശകലനം ചെയ്യുക',
    'analyzing': 'വിശകലനം ചെയ്യുന്നു...',
    'retake': 'വീണ്ടും എടുക്കുക',
    'select_language': 'പ്രതികരണ ഭാഷ തിരഞ്ഞെടുക്കുക',
    'camera_permission': 'ക്യാമറ അനുമതി ആവശ്യമാണ്',
    'gallery_permission': 'ഗാലറി ആക്സസ് ആവശ്യമാണ്',
    'analysis_result': 'വിശകലന ഫലം',
    'share': 'പങ്കിടുക',
    'save': 'സേവ് ചെയ്യുക',
    'new_analysis': 'പുതിയ വിശകലനം',
    'error_occurred': 'ഒരു പിശക് സംഭവിച്ചു',
    'try_again': 'വീണ്ടും ശ്രമിക്കുക',
    'legal_clarity_title': 'നിയമ വ്യക്തത,\nപുനർസങ്കൽപ്പിച്ചു.',
    'legal_clarity_desc':
        'നിയമ സഹായത്തിന്റെ ഭാവി അനുഭവിക്കുക. തൽക്ഷണ വിശകലനം, ലളിതമായ വിശദീകരണങ്ങൾ, നിങ്ങളുടെ വിരൽത്തുമ്പിൽ സ്മാർട്ട് മാർഗ്ഗനിർദ്ദേശം.',
    'powered_by': 'GEMINI പ്രവർത്തിതം',
  };

  static String get(String key, String languageCode) {
    if (languageCode == 'ml') {
      return ml[key] ?? en[key] ?? key;
    }
    return en[key] ?? key;
  }
}
