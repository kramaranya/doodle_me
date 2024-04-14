import 'package:flutter/material.dart';

class L10n {
  static final all = [
    const Locale('en'),
    const Locale('zh'), // Chinese
    const Locale('nl'), // Dutch
    const Locale('fr'), // French
    const Locale('de'), // German
    const Locale('it'), // Italian
    const Locale('pl'), // Polish
    const Locale('es'), // Spanish
    const Locale('sl'), // Slovenian
    const Locale('uk') // Ukrainian
  ];

  static String getLanguageName(String localeCode) {
    switch (localeCode) {
      case 'en':
        return 'English';
      case 'zh':
        return 'Chinese';
      case 'nl':
        return 'Dutch';
      case 'fr':
        return 'French';
      case 'de':
        return 'German';
      case 'it':
        return 'Italian';
      case 'pl':
        return 'Polish';
      case 'es':
        return 'Spanish';
      case 'sl':
        return 'Slovenian';
      case 'uk':
        return 'Ukrainian';
      default:
        return 'Unknown';
    }
  }
}
