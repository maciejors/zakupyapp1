import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:zakupyapp/storage/storage_manager.dart';
import 'package:zakupyapp/utils/app_info.dart';
import 'package:zakupyapp/screens/home.dart';
import 'package:zakupyapp/screens/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SM.setupStorage();
  await AppInfo.initialise();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate();

  runApp(MaterialApp(
    routes: {
      '/': (context) => HomeScreen(),
      '/settings': (context) => SettingsScreen(),
    },
    theme: ThemeData(
      primarySwatch: Colors.orange,
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          fontSize: SM.getMainFontSize(),
        ),
      ),
    ),
  ));
}
