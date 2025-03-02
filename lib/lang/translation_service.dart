import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class TranslationService extends Translations {
  static final locale = Get.deviceLocale ?? const Locale('en', 'US');
  static const fallbackLocale = Locale('en', 'US');

  static final List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('ar', 'SA'),
  ];

  static Map<String, Map<String, String>> translations = {};

  @override
  Map<String, Map<String, String>> get keys => translations;

  /// Loads JSON translations asynchronously before the app starts
  static Future<void> loadTranslations() async {
    translations = {
      'en_US': await _loadJson('assets/lang/en.json'),
      'ar_SA': await _loadJson('assets/lang/ar.json'),
    };
  }

  /// Reads a JSON file and converts it to a Map<String, String>
  static Future<Map<String, String>> _loadJson(String path) async {
    String jsonString = await rootBundle.loadString(path);
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    return jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }

  /// Changes the language dynamically
  static void changeLocale(String languageCode) {
    final locale = supportedLocales.firstWhere(
            (element) => element.languageCode == languageCode,
        orElse: () => fallbackLocale);
    Get.updateLocale(locale);
  }
}
