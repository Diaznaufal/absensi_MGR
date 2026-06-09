# 🏢 HRM Attendance App

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A modern and comprehensive Human Resource Management (HRM) attendance application built with Flutter. This app provides advanced face detection, location-based attendance, and real-time attendance tracking with a beautiful, professional UI.

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** >= 3.0.0
- **Dart SDK** >= 3.0.0
- **Android Studio** / **VS Code** with Flutter plugins
- **iOS development** (for iOS deployment)
- **Device/Emulator** with camera support

### Installation

1. **Clone the repository**

   ```bash
   extract zip
   cd flutter_absensi_app
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (if using Firebase)

   ```bash
   # Add your google-services.json (Android)
   # Add your GoogleService-Info.plist (iOS)
   ```

4. **Set up ML Models**

   ```bash
   # Ensure ML Kit models are properly configured
   # Face detection models will be downloaded automatically
   ```

5. **Configure permissions**

   **Android** (`android/app/src/main/AndroidManifest.xml`):

   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
   <uses-permission android:name="android.permission.INTERNET" />
   ```

   **iOS** (`ios/Runner/Info.plist`):

   ```xml
   <key>NSCameraUsageDescription</key>
   <string>This app needs camera access for face recognition attendance</string>
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>This app needs location access for location-based attendance</string>
   ```

6. **Run the application**

   ```bash
   # Debug mode
   flutter run

   # Release mode
   flutter run --release
   ```

### Build for Production

**Android APK:**

```bash
flutter build apk --release
```

**Android App Bundle:**

```bash
flutter build appbundle --release
```

**iOS:**

```bash
flutter build ios --release
```

## 📱 Screenshots

|           Splash Screen           |              Login              |        Home Dashboard         |
| :-------------------------------: | :-----------------------------: | :---------------------------: |
| ![Splash](screenshots/splash.png) | ![Login](screenshots/login.png) | ![Home](screenshots/home.png) |

|                  Face Detection                   |                Attendance                 |               Profile               |
| :-----------------------------------------------: | :---------------------------------------: | :---------------------------------: |
| ![Face Detection](screenshots/face_detection.png) | ![Attendance](screenshots/attendance.png) | ![Profile](screenshots/profile.png) |

## ✨ Features

### 🔐 Authentication & Security

- **Modern Login Interface** - Clean, gradient-based login with professional design
- **Secure Authentication** - Token-based authentication with auto-refresh
- **Biometric Face Detection** - ML Kit powered face recognition with liveness detection
- **Head Turn Verification** - Anti-spoofing security requiring head movement

### 📍 Attendance Management

- **Multiple Attendance Methods**:
  - 🤖 **Face Recognition** - Advanced AI-powered facial recognition
  - 📱 **QR Code Scanning** - Quick attendance via QR codes
  - 📍 **Location-based** - GPS verification for remote attendance
- **Real-time Tracking** - Live attendance monitoring
- **Check-in/Check-out** - Complete attendance cycle management
- **Attendance History** - Comprehensive attendance records

### 🏠 Modern Dashboard

- **Professional UI** - Clean, modern interface with gradient themes
- **Quick Actions** - Fast access to common functions
- **Real-time Updates** - Live data synchronization
- **Beautiful Animations** - Smooth, professional transitions

### 📋 Leave Management

- **Leave Requests** - Submit leave applications with attachments
- **Photo Attachments** - Support for image uploads
- **Status Tracking** - Real-time leave request status
- **Leave History** - Complete leave records

### 👤 Profile Management

- **User Profile** - Complete user information management
- **Settings** - Customizable app preferences
- **Notifications** - Push notification support

## 🛠️ Technology Stack

### Frontend

- **Flutter** 3.x - Cross-platform mobile framework
- **Dart** 3.x - Programming language
- **BLoC Pattern** - State management architecture
- **Google Fonts** - Typography system

### UI/UX

- **Material Design 3** - Modern material design principles
- **Gradient Themes** - Professional color schemes
- **Glassmorphism** - Modern UI effects
- **Responsive Design** - Adaptive layouts for all screen sizes

### Camera & ML

- **Camera Plugin** - Real-time camera integration
- **Google ML Kit** - Face detection and recognition
- **Face Detection API** - Advanced facial analysis
- **Image Processing** - Real-time image manipulation

### Location & Maps

- **Geolocator** - GPS and location services
- **Location Permissions** - Secure location access
- **Geofencing** - Location-based attendance validation

### Storage & Data

- **Local Storage** - Secure local data persistence
- **Image Picker** - Photo capture and selection
- **File Management** - Document and image handling

### Network & API

- **HTTP Client** - RESTful API communication
- **JSON Serialization** - Data parsing and formatting
- **Error Handling** - Comprehensive error management

## 🏗️ Architecture

The app follows **Clean Architecture** principles with **BLoC Pattern** for state management:

```
lib/
├── core/                    # Core functionality
│   ├── assets/             # Asset management
│   ├── components/         # Reusable UI components
│   ├── constants/          # App constants
│   ├── extensions/         # Dart extensions
│   ├── helper/            # Helper functions
│   └── ml/                # Machine learning utilities
├── data/                   # Data layer
│   ├── datasources/       # Data sources (API, local)
│   └── models/            # Data models
└── presentation/           # Presentation layer
    ├── auth/              # Authentication screens
    ├── home/              # Home & dashboard screens
    └── profile/           # Profile management screens
```

## 📱 App Flow

### Authentication Flow

1. **Splash Screen** → Auto-check authentication status
2. **Login Screen** → Email/password authentication
3. **Dashboard** → Main application interface

### Attendance Flow

1. **Choose Method** → Face Recognition / QR Code / Location
2. **Face Detection** →
   - Position face in center
   - Turn head to the right (liveness detection)
   - Capture when ready
3. **Verification** → Process attendance with timestamp
4. **Confirmation** → Success/failure feedback

### Leave Request Flow

1. **Permission Page** → Fill leave request form
2. **Date Selection** → Choose leave dates
3. **Reason Input** → Provide leave reason
4. **Attachment** → Optional photo upload
5. **Submit** → Send request for approval

## 🎨 UI/UX Design Principles

### Design System

- **Professional Blue Gradient** - Primary color scheme
- **Glassmorphism Effects** - Modern semi-transparent elements
- **Consistent Spacing** - 8dp grid system
- **Typography** - Poppins font family throughout
- **Accessibility** - WCAG 2.1 AA compliance

### Components

- **Custom Buttons** - Gradient buttons with shadows
- **Form Fields** - Modern input fields with validation
- **Cards** - Elevated cards with rounded corners
- **Navigation** - Floating bottom navigation with glassmorphism
- **Overlays** - Professional camera overlays and guides

## 🔧 Configuration

### Environment Setup

Create `.env` file in project root:

```env
API_BASE_URL=https://your-api-domain.com/api
API_KEY=your_api_key_here
FIREBASE_PROJECT_ID=your_firebase_project
```

### App Configuration

Update `lib/core/constants/variables.dart`:

```dart
class AppConfig {
  static const String appName = 'HRM Attendance';
  static const String apiBaseUrl = 'YOUR_API_URL';
  static const double attendanceRadius = 100.0; // meters
  static const int faceDetectionTimeout = 30; // seconds
}
```

## 📋 Testing

### Run Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/widget_test.dart
```

### Test Coverage

```bash
# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 🚀 Deployment

### Android Deployment

1. **Generate Keystore**

   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Configure Signing** - Update `android/key.properties`

3. **Build Release**
   ```bash
   flutter build appbundle --release
   ```

### iOS Deployment

1. **Configure Xcode** - Set up signing certificates
2. **Build Archive** - Create iOS archive
3. **Upload to App Store** - Use Xcode or Application Loader

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter analyze` to check code quality
- Format code with `dart format`

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Developer**: [Bahri](https://github.com/bahrie127)
- **Course**: Flutter Intensive Code (FIC) 16 Jilid 2

## 📞 Support

For support and questions:

- 📧 Email: your-email@domain.com
- 💬 Telegram: @yourusername
- 🐛 Issues: [GitHub Issues](https://github.com/bahrie127/flutter_absensi_app/issues)

## 🔄 Changelog

### Version 2.0.0 (Latest)

- ✨ Modern UI redesign with gradient themes
- 🤖 Advanced face detection with liveness verification
- 📱 Glassmorphism bottom navigation
- 🎨 Professional camera overlay with head turn detection
- 📋 Enhanced leave management system
- 🔧 Improved state management with BLoC pattern

### Version 1.0.0

- 🎯 Initial release
- 👤 Basic authentication
- 📍 Location-based attendance
- 📱 QR code scanning
- 👤 User profile management

---

**Built with ❤️ using Flutter**
