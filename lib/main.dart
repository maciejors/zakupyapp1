import 'package:flutter/material.dart';
import 'package:zakupyapk/screens/home.dart';
import 'package:zakupyapk/screens/settings.dart';
import 'package:zakupyapk/utils/app_info.dart';
import 'package:zakupyapk/storage/storage_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SM.setupStorage();
  await AppInfo.initialise();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
    routes: {
      '/': (context) => HomeScreen(),
      '/settings': (context) => SettingsScreen(),
    },
    theme: ThemeData(
      primarySwatch: Colors.orange,
      textTheme: TextTheme(
        bodyText2: TextStyle(
          fontSize: SM.getMainFontSize(),
        ),
      ),
    ),
  ));
}
