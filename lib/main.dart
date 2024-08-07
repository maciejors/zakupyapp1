import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'package:zakupyapp/screens/manage_lists.dart';
import 'package:zakupyapp/services/storage_manager.dart';
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

  runApp(
    MaterialApp(
      routes: {
        '/': (context) => HomeScreen(),
        '/settings': (context) => SettingsScreen(),
        '/manage-lists': (context) => ManageListsScreen()
      },
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: false,
      ),
    ),
  );
}
