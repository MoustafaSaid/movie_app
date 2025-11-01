import 'package:hive_ce/hive.dart';
import '../models/movie_model.dart';

class MovieCache {
  static const String moviesBoxName = 'movies';
  static const String cachedMoviesKey = 'cached_movies';
  static const String cachedPageKey = 'cached_page';
  static const String cacheTimestampKey = 'cache_timestamp';

  static Future<void> init() async {
    // Register Hive adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MovieModelAdapter());
    }
  }

  static Future<Box> get _box async => await Hive.openBox(moviesBoxName);

  static Future<void> saveMovies(List<MovieModel> movies, int page) async {
    final box = await _box;
    await box.put(cachedMoviesKey, movies);
    await box.put(cachedPageKey, page);
    await box.put(cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<List<MovieModel>?> getCachedMovies() async {
    final box = await _box;
    final movies = box.get(cachedMoviesKey);
    if (movies == null) return null;
    // Cast the dynamic result to List<MovieModel>
    if (movies is List) {
      return List<MovieModel>.from(movies);
    }
    return null;
  }

  static Future<int?> getCachedPage() async {
    final box = await _box;
    return box.get(cachedPageKey) as int?;
  }

  static Future<bool> isCacheValid({
    Duration maxAge = const Duration(hours: 1),
  }) async {
    final box = await _box;
    final timestamp = box.get(cacheTimestampKey) as int?;
    if (timestamp == null) return false;
    final cacheAge = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
    return cacheAge < maxAge;
  }

  static Future<void> clearCache() async {
    final box = await _box;
    await box.clear();
  }
}
