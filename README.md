# 🎬 Movie App

A Flutter application that displays top-rated movies from The Movie Database (TMDb) API. The app features a clean, modern UI with pagination, caching, offline support, and error handling.

## ✨ Features

- 🎥 **Top-Rated Movies**: Browse top-rated movies from TMDb
- 📄 **Infinite Scroll Pagination**: Load more movies as you scroll
- 💾 **Offline Caching**: View cached movies when offline
- 🌓 **Dark/Light Theme**: Toggle between dark and light modes
- 📱 **Movie Details**: View detailed information about each movie
- 🖼️ **Image Caching**: Efficient image loading and caching
- 🔍 **Error Handling**: Comprehensive error handling with Sentry integration
- 🚀 **Clean Architecture**: Follows best practices with separation of concerns

## 🏗️ Architecture

The app follows Clean Architecture principles with clear separation of layers:

```
lib/
├── core/              # Core functionality (DI, routing, theme, error handling)
├── data/              # Data layer (API, cache, models, repository)
└── presentation/      # UI layer (screens, cubits, widgets)
```

### Key Technologies

- **State Management**: Flutter BLoC (Cubit pattern)
- **Dependency Injection**: GetIt
- **Networking**: Dio with Retrofit
- **Caching**: Hive
- **Routing**: GoRouter
- **Error Tracking**: Sentry
- **Image Loading**: Cached Network Image

## 📋 Prerequisites

- Flutter SDK (>=3.9.2)
- Dart SDK (>=3.9.2)
- Android Studio / Xcode / VS Code
- TMDb API Key (get one at [themoviedb.org](https://www.themoviedb.org/settings/api))

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/MoustafaSaid/movie_app.git
cd movie_app
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure API Key

The app uses TMDb API for fetching movie data. Update the API key in:

- `lib/core/di/injection_container.dart` - Update `_apiKey` constant

```dart
const String _apiKey = 'YOUR_TMDB_API_KEY_HERE';
```

### 4. Generate code (if needed)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Run the app

```bash
flutter run
```

## 📦 Dependencies

### Main Dependencies

- `flutter_bloc` - State management
- `dio` - HTTP client
- `retrofit` - Type-safe HTTP client for Dart
- `hive_ce` - Fast, lightweight key-value database
- `go_router` - Declarative routing
- `get_it` - Dependency injection
- `cached_network_image` - Image caching
- `dartz` - Functional programming (Either)
- `sentry_flutter` - Error tracking

See `pubspec.yaml` for the complete list.

## 📱 Screenshots

### Main Features

- **Movies List**: Paginated list of top-rated movies
- **Movie Details**: Detailed view with poster, rating, and description
- **Theme Toggle**: Switch between dark and light modes
- **Pull to Refresh**: Refresh the movie list

## 🔧 Configuration

### Sentry Configuration

To enable error tracking with Sentry, update the DSN in:

- `lib/core/config/sentry_config.dart`

### Cache Configuration

Cache settings can be adjusted in:

- `lib/data/cache/movie_cache.dart` - Cache duration (default: 1 hour)

## 🏃 Running Tests

```bash
flutter test
```

## 📝 Code Generation

If you modify models or API services, regenerate code:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Or use the provided script:

```bash
./build_runner.sh
```

## 📂 Project Structure

```
lib/
├── core/
│   ├── config/          # App configuration (Sentry, etc.)
│   ├── di/              # Dependency injection setup
│   ├── error/            # Error handling
│   ├── router/          # Navigation configuration
│   └── theme/            # App theme configuration
├── data/
│   ├── api/             # API service definitions
│   ├── cache/            # Caching implementation (Hive)
│   ├── models/           # Data models
│   └── repository/       # Repository pattern implementation
└── presentation/
    ├── cubit/           # State management (BLoC Cubits)
    ├── screens/          # UI screens
    └── widgets/          # Reusable widgets
```

## 🐛 Troubleshooting

### Build Issues

If you encounter build issues, try:

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Cache Issues

To clear the app cache:

- Delete the app data or reinstall the app
- The cache is stored locally using Hive

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is open source and available under the MIT License.

## 👤 Author

**Moustafa Said**

- GitHub: [@MoustafaSaid](https://github.com/MoustafaSaid)

## 🙏 Acknowledgments

- [The Movie Database (TMDb)](https://www.themoviedb.org/) for the movie API
- Flutter community for excellent packages
- All contributors and maintainers of the open-source packages used

---

Made with ❤️ using Flutter
