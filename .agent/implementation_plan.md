# NyayaMithra - Implementation Plan

## Project Overview
**NyayaMithra** is an AI-powered legal and civic assistance platform built with Flutter, targeting Android devices.

## Core Features
1. **Document Explainer** - Analyze legal documents using AI
2. **Document Maker** - Create legal documents with templates
3. **Civic Assistance** - Get help with civic matters
4. **Public Grievance Portal** - File and track public grievances

---

## Phase 1: Document Explainer (Current Focus)

### 1.1 Project Setup
- [ ] Initialize Flutter project with proper structure
- [ ] Configure Android-specific settings
- [ ] Add required dependencies:
  - `camera` - Camera access
  - `image_picker` - Gallery selection
  - `google_generative_ai` - Gemini API integration
  - `permission_handler` - Handle camera/storage permissions
  - `flutter_spinkit` - Loading animations
  - `animate_do` - UI animations

### 1.2 Home Screen
- [ ] Create stunning home screen with app branding
- [ ] Design 4 feature navigation cards:
  - Document Explainer (active)
  - Document Maker (coming soon)
  - Civic Assistance (coming soon)
  - Public Grievance Portal (coming soon)
- [ ] Implement glassmorphism design
- [ ] Add micro-animations for interactions
- [ ] Language selector (English/Malayalam)

### 1.3 Document Explainer Screen
- [ ] Camera preview with capture functionality
- [ ] Gallery selection option
- [ ] Image preview after capture/selection
- [ ] Retake/Reselect options
- [ ] "Analyze Document" button
- [ ] Language preference selection for response

### 1.4 Analysis Screen
- [ ] Loading state with animation
- [ ] Gemini API integration with system prompt
- [ ] Display analysis results:
  - Document type identification
  - Simple explanation in chosen language
  - Legal implications
  - Key points
  - Correctness check
  - Recommendations
- [ ] Share/Save analysis option

### 1.5 Gemini API Integration
- [ ] Configure API key securely
- [ ] Create system prompt for legal document analysis
- [ ] Handle image-to-text analysis
- [ ] Multi-language response support (EN/ML)
- [ ] Error handling and retry logic

---

## UI/UX Design Specifications

### Color Palette
- Primary: Deep Blue (#1E3A5F) - Trust & Professionalism
- Secondary: Gold (#D4AF37) - Justice & Wisdom
- Accent: Teal (#20B2AA) - Clarity & Guidance
- Background: Dark Navy (#0A1628) - Modern Dark Theme
- Surface: Semi-transparent whites for glassmorphism

### Typography
- Headlines: Poppins Bold
- Body: Inter Regular
- Malayalam: Noto Sans Malayalam

### Design Elements
- Glassmorphism cards with blur effects
- Gradient buttons with shimmer effects
- Smooth page transitions
- Floating action elements
- Custom icons for legal themes

---

## File Structure
```
lib/
├── main.dart
├── config/
│   ├── theme.dart
│   ├── constants.dart
│   └── api_config.dart
├── models/
│   └── analysis_result.dart
├── screens/
│   ├── home_screen.dart
│   ├── document_explainer/
│   │   ├── camera_screen.dart
│   │   └── analysis_screen.dart
│   └── splash_screen.dart
├── services/
│   ├── gemini_service.dart
│   └── camera_service.dart
├── widgets/
│   ├── feature_card.dart
│   ├── glass_container.dart
│   ├── custom_button.dart
│   └── language_selector.dart
└── utils/
    └── helpers.dart
```

---

## Implementation Order
1. ✅ Create implementation plan
2. Initialize Flutter project
3. Add dependencies to pubspec.yaml
4. Create theme and constants
5. Build reusable widgets
6. Implement home screen
7. Build camera/gallery screen
8. Implement Gemini service
9. Create analysis screen
10. Polish and test

---

## API System Prompt (Gemini)
```
You are NyayaMithra, an expert Indian legal document analyst. Analyze the uploaded document image and provide:

1. **Document Type**: Identify what type of legal document this is
2. **Simple Explanation**: Explain in simple terms what this document is about
3. **Key Information**: Extract important details like names, dates, amounts
4. **Legal Implications**: What are the legal consequences of this document
5. **Completeness Check**: Is the document filled correctly? Any missing fields?
6. **Important Warnings**: Any red flags or things to be careful about
7. **Recommendations**: What should the user do next

Respond in {LANGUAGE}. Use simple language that a common person can understand.
If the image is not a legal document, politely explain what you see and suggest how you can help.
```

---

## Notes
- Target SDK: Android 21+ (Lollipop and above)
- Gemini Model: gemini-1.5-flash (for faster responses with vision)
- Secure API key storage using environment variables
