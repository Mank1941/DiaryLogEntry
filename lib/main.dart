import 'package:assignment2_2/controller/log_controller.dart';
import 'package:assignment2_2/model/logmodel.dart';
import 'package:assignment2_2/view/log_add_view.dart';
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

  final logBox = await Hive.openBox('logBox');
  final LogController logController = LogController(logBox);

  // Start the Flutter app with `MainApp` as the root widget.
  runApp(MainApp(
    logController: logController,
  ));
}

class MainApp extends StatelessWidget {
  final LogController logController;
  const MainApp({super.key, required this.logController});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.orange[100],
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => DiaryLogScreen(
              logController: logController,
            ),
        '/addEntry': (context) => DiaryEntryScreen(
              logController: logController,
            ),
      },
    );
  }
}
