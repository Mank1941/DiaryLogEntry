import 'firebase_options.dart';
import 'view/log_add_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'view/log_view.dart';
import 'auth_gate.dart';

Future<void> main() async {
  // Ensure Flutter is initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for Flutter.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.orange[100],
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/logScreen': (context) => DiaryLogScreen(
            //logController: logController,
            ),
        '/addEntry': (context) => DiaryEntryScreen(
            //logController: logController,
            ),
        //'/editEntry': (context) => LogEditScreen(),
      },
      home: const AuthGate(),
    );
  }
}
