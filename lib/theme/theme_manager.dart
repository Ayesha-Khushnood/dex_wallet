import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dark_theme.dart';
import 'light_theme.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  
  AppThemeMode _currentThemeMode = AppThemeMode.dark;
  bool _isDarkMode = true;
  
  AppThemeMode get currentThemeMode => _currentThemeMode;
  bool get isDarkMode => _isDarkMode;
  
  ThemeData get currentTheme => _isDarkMode ? DarkTheme.themeData : LightTheme.themeData;
  
  ThemeManager() {
    // Initialize with default dark theme synchronously
    _currentThemeMode = AppThemeMode.dark;
    _isDarkMode = true;
    // Load preferences asynchronously in background
    _loadThemeFromPreferences();
  }
  
  /// Load theme preference from SharedPreferences
  Future<void> _loadThemeFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? AppThemeMode.dark.index;
      _currentThemeMode = AppThemeMode.values[themeIndex];
      _updateThemeMode();
      
      // Performance optimization: Removed debug print
    } catch (e) {
      // If there's an error loading preferences, use default dark theme
      _currentThemeMode = AppThemeMode.dark;
      _isDarkMode = true;
      // Performance optimization: Removed debug print
    }
    notifyListeners();
  }
  
  /// Save theme preference to SharedPreferences
  Future<void> _saveThemeToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, _currentThemeMode.index);
    } catch (e) {
      // Handle error silently or log it
      debugPrint('Error saving theme preference: $e');
    }
  }
  
  /// Update the current theme mode
  void _updateThemeMode() {
    switch (_currentThemeMode) {
      case AppThemeMode.light:
        _isDarkMode = false;
        break;
      case AppThemeMode.dark:
        _isDarkMode = true;
        break;
      case AppThemeMode.system:
        // Get system brightness
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        _isDarkMode = brightness == Brightness.dark;
        break;
    }
  }
  
  /// Set theme mode to light
  Future<void> setLightTheme() async {
    _currentThemeMode = AppThemeMode.light;
    _isDarkMode = false;
    await _saveThemeToPreferences();
    notifyListeners();
  }
  
  /// Set theme mode to dark
  Future<void> setDarkTheme() async {
    _currentThemeMode = AppThemeMode.dark;
    _isDarkMode = true;
    await _saveThemeToPreferences();
    notifyListeners();
  }
  
  /// Set theme mode to system
  Future<void> setSystemTheme() async {
    _currentThemeMode = AppThemeMode.system;
    _updateThemeMode();
    await _saveThemeToPreferences();
    notifyListeners();
  }
  
  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    if (_currentThemeMode == AppThemeMode.system) {
      // If currently on system theme, toggle to opposite of current system theme
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      if (brightness == Brightness.dark) {
        await setLightTheme();
      } else {
        await setDarkTheme();
      }
    } else {
      // Toggle between light and dark
      if (_isDarkMode) {
        await setLightTheme();
      } else {
        await setDarkTheme();
      }
    }
  }
  
  /// Get theme mode as string for display
  String get themeModeString {
    switch (_currentThemeMode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }
  
  /// Get theme mode description
  String get themeModeDescription {
    switch (_currentThemeMode) {
      case AppThemeMode.light:
        return 'Always use light theme';
      case AppThemeMode.dark:
        return 'Always use dark theme';
      case AppThemeMode.system:
        return 'Follow system theme';
    }
  }
  
  /// Check if current theme is system theme
  bool get isSystemTheme => _currentThemeMode == AppThemeMode.system;
  
  /// Get the effective brightness (considering system theme)
  Brightness get effectiveBrightness {
    if (_currentThemeMode == AppThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness;
    }
    return _isDarkMode ? Brightness.dark : Brightness.light;
  }
  
  /// Listen to system brightness changes (for system theme mode)
  void listenToSystemBrightness() {
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      if (_currentThemeMode == AppThemeMode.system) {
        _updateThemeMode();
        notifyListeners();
      }
    };
  }
  
  /// Initialize the theme manager
  Future<void> initialize() async {
    // Performance optimization: Simplified initialization
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? AppThemeMode.dark.index;
      _currentThemeMode = AppThemeMode.values[themeIndex];
      _updateThemeMode();
    } catch (e) {
      // If there's an error loading preferences, use default dark theme
      _currentThemeMode = AppThemeMode.dark;
      _isDarkMode = true;
    }
    
    // Performance optimization: Only notify listeners once at the end
    notifyListeners();
    listenToSystemBrightness();
  }
  
  /// Force light theme for testing
  void forceLightTheme() {
    _currentThemeMode = AppThemeMode.light;
    _isDarkMode = false;
    print('ThemeManager - Forced light theme');
    notifyListeners();
  }
  
  /// Reset to default theme (dark)
  Future<void> resetToDefault() async {
    await setDarkTheme();
  }
  
  /// Get theme mode options for settings
  List<Map<String, dynamic>> get themeOptions => [
    {
      'mode': AppThemeMode.light,
      'title': 'Light',
      'description': 'Always use light theme',
      'icon': Icons.light_mode,
    },
    {
      'mode': AppThemeMode.dark,
      'title': 'Dark',
      'description': 'Always use dark theme',
      'icon': Icons.dark_mode,
    },
    {
      'mode': AppThemeMode.system,
      'title': 'System',
      'description': 'Follow system theme',
      'icon': Icons.brightness_auto,
    },
  ];
}
