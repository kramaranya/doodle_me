import 'package:flutter/material.dart';

class L10n {
  static final all = [
    const Locale('en'),
    const Locale('fr'),
    const Locale('uk')
  ];

  static String getLanguageName(String localeCode) {
    switch (localeCode) {
      case 'en':
        return 'English';
      case 'uk':
        return 'Українська';
      case 'fr':
        return 'Français';
      default:
        return 'Unknown';
    }
  }
}
