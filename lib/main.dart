import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/firebase_auth_provider.dart';
import 'providers/app_provider.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 初期化
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const FlashCompositionApp());
}

class FlashCompositionApp extends StatefulWidget {
  const FlashCompositionApp({super.key});

  @override
  State<FlashCompositionApp> createState() => _FlashCompositionAppState();
}

class _FlashCompositionAppState extends State<FlashCompositionApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FirebaseAuthProvider()),
        ChangeNotifierProvider(create: (context) => AppProvider()),
      ],
      child: Consumer<FirebaseAuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            title: '瞬間英作文',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue[600]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[600]!),
                ),
              ),
            ),
            routerConfig: AppRouter.createRouter(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
