import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeBoxName = 'theme';
  static const String _isDarkModeKey = 'isDarkMode';

  ThemeCubit() : super(ThemeState(isDarkMode: false)) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final box = await Hive.openBox(_themeBoxName);
      final isDarkMode = box.get(_isDarkModeKey, defaultValue: false) as bool;
      emit(ThemeState(isDarkMode: isDarkMode));
    } catch (e) {
      emit(ThemeState(isDarkMode: false));
    }
  }

  Future<void> toggleTheme() async {
    final newIsDarkMode = !state.isDarkMode;
    try {
      final box = await Hive.openBox(_themeBoxName);
      await box.put(_isDarkModeKey, newIsDarkMode);
      emit(ThemeState(isDarkMode: newIsDarkMode));
    } catch (e) {
      emit(ThemeState(isDarkMode: newIsDarkMode));
    }
  }
}
