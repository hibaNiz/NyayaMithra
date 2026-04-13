# ⚖️ NyayaMithra (न्यायमित्र)

**Empowering Citizens through AI-Powered Legal & Civic Assistance**

NyayaMithra is a comprehensive mobile platform designed to bridge the gap between common citizens and the often complex world of legal and civic systems. Leveraging state-of-the-art AI, the application provides intuitive tools for document generation, legal analysis, and civic grievance redressal.

---

## ✨ Core Features

### 📄 Document Explainer (AI-Powered)
- **Instant Analysis:** Upload or scan complex legal documents (PDFs/Images).
- **Simplification:** AI breaks down legalese into plain, understandable language.
- **Key Information Extraction:** Automatically identifies critical dates, obligations, and parties involved.

### ✍️ Legal Document Maker
- **Smart Templates:** Generate legally sound documents (Affidavits, Rental Agreements, Notices) in minutes.
- **Digital Signatures:** Integrated signature pad for immediate verification.
- **Export to PDF:** Professional-grade PDF generation ready for printing or storage.

### 🏛️ Civic Assistance & Grievance Portal
- **Right to Know:** Easy access to information regarding civic rights and government schemes.
- **Automated Complaints:** AI-assisted complaint drafting for various departments.
- **Location Awareness:** Automatic detection of jurisdiction for precise grievance reporting.

### 🤖 Intelligent Assistant
- **Bilingual Support:** Designed with the Indian context in mind, supporting local languages.
- **Guided Workflows:** Step-by-step assistance for common legal and civic procedures.

---

## 🚀 Technology Stack

### **Frontend & UI**
- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **Aesthetics:** 
  - **Glassmorphism:** Using `glass_kit` for a premium look.
  - **Animations:** Powered by `flutter_animate` and `Lottie`.
  - **Visual Feedback:** `shimmer` effects for loading states and `google_fonts` for crisp typography.

### **Artificial Intelligence**
- **Large Language Models:**
  - **Google Gemini:** Primary engine for real-time document analysis and chat support.
  - **Qwen 3.5 (Fine-tuned):** Custom LoRA fine-tuning for specialized Indian legal and civic context.
- **Backend Training:** Python-based pipeline using `HuggingFace Transformers`, `PEFT`, and `BitsAndBytes` for memory-efficient training.

### **Core Utilities**
- **Camera & Imaging:** `camera`, `image_picker`.
- **Location Services:** `geolocator`, `geocoding`.
- **Media Processing:** `pdf`, `printing`, `signature`.

---

## 🛠️ Setup & Installation

### **Prerequisites**
- Flutter SDK (Latest Stable)
- Android Studio / VS Code
- Python 3.9+ (For training scripts)

### **Installation Steps**
1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/NyayaMithra.git
   cd NyayaMithra
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables:**
   Create a `.env` file in the root directory and add your API keys:
   ```env
   GEMINI_API_KEY=your_gemini_api_key_here
   ```

4. **Run the application:**
   ```bash
   flutter run
   ```

---

## 🧠 AI Fine-tuning (Developer Preview)

The project includes a specialized training script `train_qwen_lora.py` to adapt the **Qwen 3.5-7B** model for the Indian legal ecosystem.

- **Method:** LoRA (Low-Rank Adaptation).
- **Rank (r):** 16.
- **Target Modules:** q_proj, k_proj, v_proj, etc.
- **Optimization:** Paged AdamW 8-bit for low-VRAM training.

---

## 📜 Roadmap
- [ ] Multilingual Voice Assistant integration.
- [ ] Integration with Government API portals for live tracking.
- [ ] Blockchain-based document store for tamper-proof records.

---

## 👥 Contributors
- **Hiba Nizar** - *Lead Developer & Architect*

---

Designed with ❤️ to make justice accessible to all.
