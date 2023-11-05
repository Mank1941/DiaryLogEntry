import 'package:assignment2_2/model/logmodel.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'view/log_view.dart';

Future<void> main() async {
  // Ensure Flutter is initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for Flutter.
  await Hive.initFlutter();

  // Register the adapter for `CarModel`.
  Hive.registerAdapter(LogModelAdapter());

  // Open the 'cars_box' box for storing car data.
  await Hive.openBox('logs_box');

  // Start the Flutter app with `MainApp` as the root widget.
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.orange[100],
      ),
      home: const DiaryLogScreen(),
    );
  }
}
