import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/controllers/locale_provider.dart';
import 'package:taxi_app/l10n/app_localizations.dart';
import 'package:taxi_app/l10n/l10n.dart';

class LanguagePickerWidget extends StatelessWidget {
  const LanguagePickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    final locale = provider.locale;
    return DropdownButtonHideUnderline(
      child: DropdownButton(
        value: locale,
        padding: EdgeInsets.all(0),
        enableFeedback: true,
        elevation: 1,
        icon: Container(width: 12),
        items: L10n.all.map((locale) {
          final flag = L10n.getFlag(locale.languageCode);
          final languageText = locale.languageCode == 'ru'
              ? AppLocalizations.of(context)!.englishRussian
              : locale.languageCode == 'tr'
              ? AppLocalizations.of(context)!.englishTurkish
              : AppLocalizations.of(context)!.englishEnglish;

          return DropdownMenuItem(
            // alignment: AlignmentDirectional.centerEnd,
            value: locale,
            onTap: () {
              final provider = Provider.of<LocaleProvider>(
                context,
                listen: false,
              );
              provider.setLocale(locale);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(flag, style: TextStyle(fontSize: 22)),
                SizedBox(width: 5),
                Text(languageText),
              ],
            ),
          );
        }).toList(),
        onChanged: (_) {},
      ),
    );
  }
}
