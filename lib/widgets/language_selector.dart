import 'package:flutter/material.dart';
import '../i18n/locale_provider.dart';
import '../i18n/app_translations.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLang = localeProvider.currentLanguageCode;

    return PopupMenuButton<String>(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: Image.asset(
              'assets/images/flags/$currentLang.png',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 4),
          Text(AppTranslations.of('select_language')),
        ],
      ),
      onSelected: (code) {
        localeProvider.setLocale(Locale(code));
      },
      itemBuilder: (_) {
        final languages = [
          {'code': 'en', 'label': AppTranslations.of('english')},
          {'code': 'es', 'label': AppTranslations.of('spanish')},
          {'code': 'pt', 'label': AppTranslations.of('portuguese')},
        ];

        return languages.map((lang) {
          final code = lang['code'] as String;
          return PopupMenuItem<String>(
            value: code,
            child: Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/flags/$code.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 8),
                Text(lang['label'] as String),
                const Spacer(),
                if (code == currentLang)
                  const Icon(Icons.check, size: 16, color: Colors.green),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
