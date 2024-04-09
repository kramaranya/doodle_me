import 'package:flutter/material.dart';

class L10n {
  static final all = [
    const Locale('en'),
    const Locale('uk'),
    const Locale('fr'),
    const Locale('es'),
    const Locale('de'),
    const Locale('it'),
    const Locale('pl'),
    const Locale('nl'),
    const Locale('sl'),
    const Locale('zh')
  ];

  static String getLanguageName(String localeCode) {
    switch (localeCode) {
      case 'en':
        return 'English';
      case 'uk':
        return 'Ukrainian';
      case 'fr':
        return 'French';
      case 'es':
        return 'Spanish';
      case 'de':
        return 'German';
      case 'it':
        return 'Italian';
      case 'pl':
        return 'Polish';
      case 'nl':
        return 'Dutch';
      case 'sl':
        return 'Slovenian';
      case 'zh':
        return 'Chinese';
      default:
        return 'Unknown';
    }
  }
}
