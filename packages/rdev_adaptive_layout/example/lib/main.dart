import 'package:example/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS) {
      return const CupertinoApp(home: AppWidget());
    }
    return const MaterialApp(home: AppWidget());
  }
}
