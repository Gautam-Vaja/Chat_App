# 💬 Gemini AI Chat App

A modern, elegant, and feature-rich Flutter chat application integrated with **Google's Gemini AI** for intelligent real-time conversational experiences, backed by **SQLite** for robust offline message persistence.

---

## ✨ Features

- 🤖 **Gemini AI Integration**: Interactive AI chatting powered by Google Generative AI (`gemini-3.6-flash`) with dynamic message generation.
- 💾 **Local Offline Storage**: Full local message persistence using **SQLite** (`sqflite`). Chat history, sender roles, and timestamps are saved and loaded seamlessly.
- 🎨 **Modern & Premium UI**: Clean, polished Material 3 design system with custom color palettes (`#3525CD` primary), responsive chat bubbles, and smooth animations.
- 🧭 **Declarative Routing**: Seamless screen transitions and deep navigation configured with `go_router`.
- 📌 **Pinned & Recent Conversations**: Organize chats with dedicated sections for pinned contacts and recent messages.
- 👤 **Profile & Settings Screen**: Clean user profile overview with avatar, status, preferences, and account management options.
- 📱 **Cross-Platform Ready**: Optimized for Android and iOS devices.

---

## 🛠️ Tech Stack & Packages

| Category | Technology / Package | Description |
| :--- | :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev/) | Cross-platform UI toolkit |
| **Language** | [Dart](https://dart.dev/) | Client-optimized language for fast apps on any platform |
| **Navigation** | [`go_router`](https://pub.dev/packages/go_router) | Declarative routing package for Flutter |
| **API & Networking** | [`http`](https://pub.dev/packages/http) | Composable HTTP request library for Gemini API |
| **Database** | [`sqflite`](https://pub.dev/packages/sqflite) | SQLite database plugin for Flutter |
| **Path Handling** | [`path`](https://pub.dev/packages/path) | Path manipulation utilities |
| **Icons** | [`cupertino_icons`](https://pub.dev/packages/cupertino_icons) & Material Icons | iOS and Material styled iconography |

---

## 📁 Project Structure

```text
chat_app/
├── android/                   # Android native configuration
├── assets/
│   └── images/                # App logos, avatars, and visual assets
├── ios/                       # iOS native configuration
├── lib/
│   ├── core/
│   │   ├── database/          # Database helper for SQLite (CRUD operations)
│   │   │   └── database_helper.dart
│   │   ├── router/            # GoRouter configuration & routes
│   │   │   └── app_router.dart
│   │   ├── app_images.dart    # Asset constants
│   │   └── app_strings.dart   # String constants
│   ├── screens/
│   │   ├── home_screen.dart   # Main chat screen with Gemini AI
│   │   ├── profile_screen.dart# User profile & preferences
│   │   └── user_screen/       # Conversation screen
│   │       └── user_screen.dart
│   ├── services/
│   │   └── gemini_service.dart# Google Gemini AI API integration
│   └── main.dart              # Application entry point & theme configuration
├── pubspec.yaml               # Package dependencies & asset declarations
└── README.md                  # Project documentation
```

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed on your machine:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version `^3.12.2` or higher)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / Xcode / VS Code with Flutter extension
- An active Android/iOS emulator or connected physical device

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Gautam-Vaja/Chat_App.git
   cd Chat_App
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Gemini API Key**:
   Open `lib/services/gemini_service.dart` and ensure your Gemini API key is configured:
   ```dart
   final String apiKey = 'YOUR_GEMINI_API_KEY';
   ```
   > 💡 *Tip: For production environments, it is strongly recommended to store API keys securely using environment variables (`--dart-define`) or a secure storage solution.*

4. **Run the application**:
   ```bash
   flutter run
   ```

---

## 📱 Application Flow & Screens

1. **Home / Chat Screen (`HomeScreen`)**:
   - Direct entry point into the chat experience.
   - Real-time conversation interface with Gemini AI.
   - Dynamic message rendering with distinct user vs. AI message bubbles.
   - Typing indicator and auto-scroll to the latest response.
   - Quick action controls (calls, video, and menu to clear chat history).
   - Automatic local storage of sent and received messages in SQLite.
2. **Profile / Settings Screen (`ProfileScreen`)**:
   - Profile overview, account settings, preferences, and notifications.
3. **Database Management**:
   - `DatabaseHelper` manages table initialization (`messages`), message retrieval by `chat_id`, insertion, and clearing conversation histories.

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page or submit a pull request.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE) (or your chosen license).
