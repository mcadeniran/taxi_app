import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxi_app/l10n/l10n.dart';
import 'package:timeago/timeago.dart' as timeago;

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider() {
    _registerTimeagoLocales();
    _loadLocale(); // load saved locale when provider is created
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('localeCode');

    if (languageCode != null) {
      _locale = Locale(languageCode);
      timeago.setDefaultLocale(languageCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!L10n.all.contains(locale)) return;

    _locale = locale;
    timeago.setDefaultLocale(_locale.languageCode);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('localeCode', locale.languageCode);
  }

  Future<void> clearLocale() async {
    _locale = const Locale('en');
    timeago.setDefaultLocale('en');
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('localeCode');
  }

  void _registerTimeagoLocales() {
    timeago.setLocaleMessages('en', timeago.EnMessages());
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    timeago.setLocaleMessages('ru', timeago.RuMessages());
  }
}
