# 💬 Gemini AI Chat App

A modern, elegant, and feature-rich Flutter chat application powered by **Google's Gemini AI** for intelligent conversational experiences, with local **SQLite** persistence and secure **`.env`** environment configuration.

---

## 🌟 Highlights & Features

- 🤖 **Google Gemini AI Integration**: Fast, multimodal AI responses using Google Generative AI REST endpoints.
- 🔑 **Secure Environment Variables**: API keys are isolated in a local `.env` file and excluded from Git version control via `.gitignore`.
- 💾 **Offline SQLite Persistence**: Full message history storage using `sqflite` (messages, sender roles, timestamps, chat sessions).
- 🎨 **Modern & Adaptive UI**: Material 3 design system with light/dark theme switching, fluid typography (`Inter`), custom message bubbles, and typing indicators.
- 🧭 **Declarative Navigation**: Built with `go_router` for clean routing between Home, New Chat, History, and Profile screens.
- 📜 **Chat History & Management**: Browse past conversations, view recent message previews, and delete individual chats.
- ⚙️ **Comprehensive Settings & Profile**: In-app About Gemini dialogs, theme toggling, and privacy details.

---

## 🛠️ Tech Stack & Dependencies

| Category | Package / Tool | Purpose |
| :--- | :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev/) (`sdk: flutter`) | Cross-platform mobile UI framework |
| **Language** | [Dart](https://dart.dev/) (`^3.12.2`) | Strongly typed, client-optimized language |
| **AI / REST API** | [Google Generative Language API](https://ai.google.dev/) | Gemini conversational AI engine |
| **Networking** | [`http`](https://pub.dev/packages/http) | Composable HTTP client for calling Gemini REST endpoints |
| **Environment** | [`flutter_dotenv`](https://pub.dev/packages/flutter_dotenv) | Loads environment variables from `.env` |
| **Local Database** | [`sqflite`](https://pub.dev/packages/sqflite) | Local SQLite relational database engine |
| **Path Utilities** | [`path`](https://pub.dev/packages/path) | Database path management across iOS & Android |
| **Routing** | [`go_router`](https://pub.dev/packages/go_router) | Declarative URL-based navigation |
| **Icons** | [`cupertino_icons`](https://pub.dev/packages/cupertino_icons) | iOS & Material design iconography |

---

## 📁 Project Structure

```text
chat_app/
├── assets/
│   └── images/                # Visual assets, logos & Gemini icons
├── lib/
│   ├── core/
│   │   ├── database/          # SQLite database helper (CRUD operations)
│   │   │   └── database_helper.dart
│   │   ├── router/            # GoRouter route declarations
│   │   │   └── app_router.dart
│   │   ├── theme_controller.dart # Light / Dark mode state management
│   │   ├── app_images.dart    # Asset constants
│   │   └── app_strings.dart   # Centralized UI text & strings
│   ├── screens/
│   │   ├── chats/
│   │   │   └── new_chat.dart  # Active chat screen with Gemini AI
│   │   ├── history/
│   │   │   └── history_screen.dart # Past conversations & history list
│   │   ├── home_screen.dart   # Dashboard with recent chats & quick actions
│   │   ├── profile_screen.dart# User profile, theme toggle & API details
│   │   └── splash_screen.dart # Animated launch screen
│   ├── services/
│   │   └── gemini_service.dart# HTTP service communicating with Gemini API
│   └── main.dart              # Entrypoint (initializes dotenv & theme)
├── .env.example               # Template for required environment variables (Git-tracked)
├── .env                       # Local secrets (IGNORED by Git)
├── .gitignore                 # Excludes .env and build artifacts
├── pubspec.yaml               # Dependencies & assets configuration
└── README.md                  # Project documentation
```

---

## 🔑 Gemini API Details & Setup (Step-by-Step)

The application communicates directly with Google's Generative Language API via HTTPS REST calls.

### 1. How to Get a Free Gemini API Key

1. Go to [Google AI Studio](https://aistudio.google.com/).
2. Sign in with your Google account.
3. Click on **"Get API key"** in the top left navigation.
4. Click **"Create API key"** (select an existing Google Cloud project or create a new one automatically).
5. Copy your generated API key.

> 💡 **Note**: Google AI Studio offers a generous **free tier** that is ideal for testing and development.

---

### 2. Configure Environment Variables (`.env`)

To protect your API key from being accidentally committed to GitHub, the app uses `flutter_dotenv`.

1. In the root directory of the project, look for [.env.example](.env.example):
   ```env
   GEMINI_API_KEY=your_gemini_api_key_here
   ```

2. Make a copy of `.env.example` and name it `.env`:
   - **On Windows (PowerShell):**
     ```powershell
     Copy-Item .env.example .env
     ```
   - **On macOS / Linux:**
     ```bash
     cp .env.example .env
     ```

3. Open your new `.env` file and replace the placeholder with your actual Gemini API key:
   ```env
   GEMINI_API_KEY=AIzaSyYourActualKeyHere123456789
   ```

4. **Verify Git ignores `.env`**:
   The [.gitignore](.gitignore) already contains rules to ignore `.env`:
   ```gitignore
   # Environment variables
   .env
   .env.*
   !.env.example
   ```
   You can verify this in terminal by running:
   ```bash
   git status
   ```
   `.env` should **never** appear in untracked or modified files.

---

### 3. Understanding the API Architecture

All Gemini interactions are encapsulated in [`lib/services/gemini_service.dart`](lib/services/gemini_service.dart):

#### Endpoint URL
```http
POST https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent
```

#### Request Headers
| Header | Value | Description |
| :--- | :--- | :--- |
| `Content-Type` | `application/json` | Request payload format |
| `x-goog-api-key` | `dotenv.env['GEMINI_API_KEY']` | Authenticates request with Google |

#### Request Payload Structure
```json
{
  "contents": [
    {
      "parts": [
        {
          "text": "User message prompt goes here"
        }
      ]
    }
  ]
}
```

#### Successful Response Structure (HTTP 200)
```json
{
  "candidates": [
    {
      "content": {
        "parts": [
          {
            "text": "Generated response from Gemini..."
          }
        ],
        "role": "model"
      },
      "finishReason": "STOP"
    }
  ]
}
```

---

### 4. Common API Error Codes & Troubleshooting

| Status Code | Cause | Solution |
| :--- | :--- | :--- |
| **`400 Bad Request`** | Invalid JSON payload or unsupported model name | Verify prompt format and ensure the model endpoint exists. |
| **`401 / 403 Invalid API Key`** | API key is missing, expired, or invalid | Double-check that `.env` has the correct `GEMINI_API_KEY` and restart the app. |
| **`404 Not Found`** | Model endpoint does not exist | Use supported models: `gemini-1.5-flash`, `gemini-2.0-flash`, or `gemini-1.5-pro`. |
| **`429 Resource Exhausted`** | Rate limit or free tier quota exceeded | Wait 1-2 minutes or check quota usage in [Google AI Studio](https://aistudio.google.com/). |
| **`500 / 503 Internal Error`** | Google server-side error | Retry the request after a few moments. |

---

## 🚀 Quick Start Guide

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>=3.12.2`)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / Xcode / VS Code with Flutter extension
- Connected Android/iOS device or Emulator

### Step-by-Step Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Gautam-Vaja/Chat_App.git
   cd Chat_App
   ```

2. **Install project dependencies**:
   ```bash
   flutter pub get
   ```

3. **Set up `.env`**:
   ```bash
   # Copy the template
   cp .env.example .env
   ```
   Add your Gemini API key inside `.env`:
   ```env
   GEMINI_API_KEY=your_actual_api_key_here
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

> ⚠️ **Important**: When you modify `.env` or add new assets to `pubspec.yaml`, perform a **full restart** (`R` or stop and restart `flutter run`) rather than a hot reload, so Flutter can bundle the updated asset files.

---

## 📱 Core Application Screens

1. **Home Screen (`HomeScreen`)**:
   - Displays recent conversations retrieved from SQLite.
   - Quick "Start New Chat" action.
   - Pinned contacts and quick filters.
2. **New Chat Screen (`NewChatScreen`)**:
   - Interactive chat interface with real-time AI responses.
   - Auto-scrolls to the newest message.
   - Typing state indicators and automatic conversation saving.
3. **History Screen (`HistoryScreen`)**:
   - Searchable chronological list of all saved chats.
   - Message count, last active timestamp, and swipe-to-delete support.
4. **Profile & Settings (`ProfileScreen`)**:
   - Switch between Light and Dark themes.
   - View Gemini API details, data handling policies, and app information.

---

## 🛡️ Best Practices & Security Note

- **Never commit `.env` to version control**: The `.gitignore` is pre-configured to exclude `.env`. Always push `.env.example` with dummy values instead.
- **Key Rotation**: If you suspect your API key has been exposed publicly, revoke it immediately at [Google AI Studio](https://aistudio.google.com/) and generate a new one.
- **Production Architecture**: For production applications released on the App Store or Google Play Store, it is recommended to route requests through a secure backend proxy server rather than storing third-party API keys directly inside a client application APK/bundle.

---

## 🤝 Contributing

Contributions, feedback, and bug reports are welcome!
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
