import 'package:flutter/material.dart';

class L10n {
  static final all = [
    const Locale('en'),
    const Locale('ru'),
    const Locale('tr'),
  ];

  static String getFlag(String code) {
    switch (code) {
      case 'en':
        return '🏴󠁧󠁢󠁥󠁮󠁧󠁿';
      case 'ru':
        return '🇷🇺';
      case 'tr':
        return '🇹🇷';
      default:
        return '🏴󠁧󠁢󠁥󠁮󠁧󠁿';
    }
  }
}
