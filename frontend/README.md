# 📱 Seapedia Mobile App — Flutter Experience

This is the mobile application frontend for the **Seapedia Marketplace**, built using **Flutter SDK** and **Dart**. The app is optimized for multi-platform environments (Android, iOS, and Web) and implements modern state management and networking standards.

---

## 🚀 Getting Started

### 1. Prerequisites
Ensure you have the **Flutter SDK (v3.x)** configured in your global path environment. Ensure you also have the appropriate emulators (Android/iOS) or web server targets installed.

### 2. Local Setup
Navigate to this folder and fetch the Dart dependencies:
```bash
cd frontend
flutter pub get
```

---

## 📐 Architectural Design Pattern

The codebase adheres strictly to the **MVVM (Model-View-ViewModel)** architectural pattern coupled with clean layer isolation. This keeps concerns isolated, testable, and highly responsive.

```text
frontend/lib/
├── core/
│   ├── network/          # Global Dio Network Clients & Interceptors
│   ├── router/           # GoRouter Routing Manifests
│   ├── storage/          # Secure Storage Providers
│   └── widgets/          # Shared Cross-Feature UI components
└── features/             # Subsystem Feature Folders (e.g., auth, buyer, seller)
    └── <feature_name>/
        ├── data/         # Models & Repositories
        └── presentation/ # Controllers (ViewModels) & Screen Widgets (Views)
```

### Component Roles & Responsibilities

1.  **Model (`/data/` models)**
    *   Plain Dart classes defining raw properties and JSON translation logic (e.g., `auth_models.dart`).
    *   Decoupled entirely from UI or framework dependencies.

2.  **View (`/presentation/` screens & widgets)**
    *   Standard Flutter declarative layout code (e.g., `login_screen.dart`).
    *   Subscribes to Riverpod states to dynamically update UI.
    *   Forwards user gestures/inputs directly to the Controller.

3.  **ViewModel/Controller (`/presentation/` controllers)**
    *   State Notifiers/Controllers managed by **Riverpod 3.x** (e.g., `auth_controller.dart`).
    *   Responsible for storing the immediate UI state (loading, error, authenticated, etc.).
    *   Coordinates with the data repositories to fetch updates, updating states reactively.

4.  **Repository (`/data/` repositories)**
    *   Data providers encapsulating API fetch operations (e.g., `auth_repository.dart`).
    *   Communicates with the backend using the global `Dio` client provider (`dioProvider`).

---

## 🌐 Network Layer & Auth Interceptors

API networking is powered by **Dio (v5.x)**, which is configured centrally inside [dio_provider.dart](file:///d:/KULIAH/kursus/Compfest%20Academy/seleksi/seapedia/frontend/lib/core/network/dio_provider.dart):

*   **Smart API Routing**: The app automatically resolves the backend base URL depending on the runtime platform:
    *   **Android Emulator**: `http://10.0.2.2:3000` (bridges to host localhost).
    *   **iOS Emulator / Web**: `http://localhost:3000`.
*   **Authorization Interceptor**: A custom request interceptor automatically pulls the JWT token from **Flutter Secure Storage** and adds the HTTP header `Authorization: Bearer <accessToken>` to every outgoing request.
*   **Session Guard**: If any API response yields an HTTP `401 Unauthorized` status (due to token expiry or invalidation), the interceptor automatically triggers a global `logout()` operation through the `authControllerProvider` to secure the app state.

---

## 💻 Running & Building

### 🔍 Find Available Devices
Verify that your target emulator, simulator, or browser is active:
```bash
flutter devices
```

### 🏃 Running in Development Mode
Run the app dynamically with hot reload enabled:
```bash
# Run on the default active device
flutter run

# Run on a specific device ID
flutter run -d <device-id>

# Run on Web Server
flutter run -d chrome
```

### 📦 Building Production Assets
Compile production bundles for distribution:

```bash
# Build Android APK (outputs to build/app/outputs/flutter-apk/)
flutter build apk --release

# Build Android App Bundle (for Google Play Console submission)
flutter build appbundle --release

# Build iOS Bundle (outputs IPA payload)
flutter build ipa --release

# Build Web distribution files
flutter build web --release
```
