# Setup Instructions

## 1. Install Dependencies

```bash
flutter pub get
```

## 2. Generate Code

Run build_runner to generate JSON serialization and Retrofit code:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 3. Configure API Key

Edit `lib/data/api/api_client.dart` and replace `YOUR_API_KEY_HERE` with your TMDB API key.

## 4. Configure Sentry (Optional)

Edit `lib/core/config/sentry_config.dart` and replace `YOUR_SENTRY_DSN_HERE` with your Sentry DSN, or leave it empty to disable Sentry.

## 5. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── core/
│   ├── config/          # App configuration (Sentry, etc.)
│   ├── router/           # Go router configuration
│   └── theme/            # Light/Dark theme configuration
├── data/
│   ├── api/              # Retrofit API service
│   ├── cache/             # Hive caching
│   ├── models/            # Data models (JSON serializable)
│   └── repository/        # Data repository
└── presentation/
    ├── cubit/             # BLoC Cubits (state management)
    ├── screens/           # App screens
    └── widgets/           # Reusable widgets
```

## Features Implemented

- ✅ Light and Dark Theming
- ✅ Pagination
- ✅ Caching with Hive
- ✅ Error Logging with Sentry
- ✅ Clean Architecture (Presentation + Data layers)
- ✅ Dio + Retrofit for API calls
- ✅ JSON Serialization
- ✅ Go Router for navigation
- ✅ Equatable and Dartz
- ✅ Hive for local caching
- ✅ Cached Network Image
- ✅ BLoC (Cubit) State Management

