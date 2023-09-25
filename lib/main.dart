import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
  runApp(
    ChangeNotifierProvider(create: (context) => ThemeProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: Provider.of<ThemeProvider>(context).getTheme,
        title: 'Flutter Demo',
        home: const AuthPage(),
      ),
    );
  }
}