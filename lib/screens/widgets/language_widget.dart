import 'package:flutter/material.dart';
import 'package:taxi_app/l10n/l10n.dart';

class LanguageWidget extends StatelessWidget {
  const LanguageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final flag = L10n.getFlag(locale.languageCode);
    return const Placeholder();
  }
}
