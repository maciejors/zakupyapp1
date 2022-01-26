import 'package:flutter/material.dart';
import 'package:zakupyapk/screens/home.dart';
import 'package:zakupyapk/screens/settings.dart';
import 'package:zakupyapk/utils/storage_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SM.setupStorage();
  runApp(MaterialApp(
    routes: {
      '/': (context) => Home(),
      '/settings': (context) => Settings(),
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
