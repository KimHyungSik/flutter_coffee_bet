import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class VibrationManager {
  static const String VIBRATION_ENABLED_KEY = 'vibration_enabled';
  static bool _isVibrationEnabled = true; // Default to enabled

  // Initialize the vibration manager
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isVibrationEnabled = prefs.getBool(VIBRATION_ENABLED_KEY) ?? true;
  }

  // Get current vibration state
  static bool isVibrationEnabled() {
    return _isVibrationEnabled;
  }

  // Toggle vibration and save the preference
  static Future<bool> toggleVibration() async {
    _isVibrationEnabled = !_isVibrationEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(VIBRATION_ENABLED_KEY, _isVibrationEnabled);
    return _isVibrationEnabled;
  }

  // Set vibration state and save the preference
  static Future<void> setVibrationEnabled(bool enabled) async {
    _isVibrationEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(VIBRATION_ENABLED_KEY, enabled);
  }

  // Vibrate for countdown (stronger pulse)
  static Future<void> vibrateCountdown() async {
    if (await Vibration.hasCustomVibrationsSupport()) {
      Vibration.vibrate(duration: 300, amplitude: 128);
    } else {
      Vibration.vibrate();
      await Future.delayed(Duration(milliseconds: 300));
      Vibration.vibrate();
    }
  }

  // Vibrate for game over (much more intense pattern)
  static Future<void> vibrateGameOver() async {
    if (await Vibration.hasCustomVibrationsSupport()) {
      Vibration.vibrate(pattern: [500, 200, 500, 200], intensities: [1, 255]);
    } else {
      Vibration.vibrate();
      await Future.delayed(Duration(milliseconds: 500));
      Vibration.vibrate();
    }
  }
}
