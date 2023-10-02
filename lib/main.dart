import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:orchestra_app/auth/auth.dart';
import 'package:orchestra_app/auth/login_or_register.dart';
import 'package:orchestra_app/firebase_options.dart';
import 'package:orchestra_app/theme/dark_theme.dart';
import 'package:orchestra_app/theme/light_theme.dart';
import 'package:orchestra_app/theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Make system nav bar have the same color as the bottom nav bar
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
  const SystemUiOverlayStyle(
  systemNavigationBarColor: Colors.transparent,
  ),
  );

  final initialBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(initialBrightness),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).getTheme,
      title: 'Flutter Demo',
      home: const AuthPage(),
      supportedLocales: const [
        Locale('nl', 'BE'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],


    );
  }
}