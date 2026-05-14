import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'app_translations.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale;

  LocaleProvider() : _locale = _detectLocale();

  static Locale _detectLocale() {
    final deviceLocale = ui.PlatformDispatcher.instance.locale;
    final code = deviceLocale.languageCode;
    if (['en', 'es', 'pt'].contains(code)) {
      AppTranslations.currentLocale = code;
      return Locale(code);
    }
    AppTranslations.currentLocale = 'en';
    return const Locale('en');
  }

  Locale get locale => _locale;

  String get currentLanguageCode => _locale.languageCode;

  void setLocale(Locale locale) {
    if (!['en', 'es', 'pt'].contains(locale.languageCode)) return;
    _locale = locale;
    AppTranslations.currentLocale = locale.languageCode;
    notifyListeners();
  }

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];
}

final localeProvider = LocaleProvider();
