import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taxi_app/controllers/theme_provider.dart';
import 'package:taxi_app/controllers/user_provider.dart';
import 'package:taxi_app/services/auth_gate.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Supabase.initialize(
    url: 'https://baqsrpwzkcnuurcngeve.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJhcXNycHd6a2NudXVyY25nZXZlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM4MTcyMjAsImV4cCI6MjA2OTM5MzIyMH0.Uiy2WTJ_F4yK3uLK87bgr2XthYiDoMQALTwgS3NK374',
  );
  await dotenv.load();
  // final userProvider = UserProvider();
  // await userProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
    return MaterialApp(
      title: 'KIPGO',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      // theme: ThemeData(primarySwatch: Colors.indigo, fontFamily: 'Roboto'),
      // home: const LoginScreen(),
      home: AuthGate(),
    );
  }
}
