import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:taxi_app/controllers/drive_history_provider.dart';
import 'package:taxi_app/controllers/locale_provider.dart';
import 'package:taxi_app/controllers/ride_history_provider.dart';
import 'package:taxi_app/controllers/theme_provider.dart';
import 'package:taxi_app/controllers/profile_provider.dart';
import 'package:taxi_app/firebase_options.dart';
import 'package:taxi_app/infoHandler/app_info.dart';
import 'package:taxi_app/l10n/app_localizations.dart';
import 'package:taxi_app/l10n/l10n.dart';
import 'package:taxi_app/services/auth_gate.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider()..initAuthListener(),
        ),
        ChangeNotifierProvider(create: (_) => RideHistoryProvider()),
        ChangeNotifierProvider(create: (_) => DriveHistoryProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AppInfo()),
      ],
      child: const TaxiApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class TaxiApp extends StatefulWidget {
  const TaxiApp({super.key});

  @override
  State<TaxiApp> createState() => _TaxiAppState();
}

class _TaxiAppState extends State<TaxiApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    return MaterialApp(
      title: 'KIPGO',
      supportedLocales: L10n.all,
      locale: localeProvider.locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      home: AuthGate(),
      // home: LoginScreen(),
    );
  }
}
