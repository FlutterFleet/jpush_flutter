import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  JPushFlutter.setDebugMode(debugMode: true);
  JPushFlutter.init('cd04621e5858bdfffb42bad6', 'developer-default');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? args;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Permission.notification.request();
      if (Platform.isIOS) {
        await Permission.appTrackingTransparency.request();
      }
      JPushFlutter.setMethodCallHandler((call) async {
        if (call.method == 'notificationClick') {
          if (kDebugMode) {
            print('setMethodCallHandler: ${call.arguments}');
            setState(() => args = call.arguments);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('JPushPlugin Example'),
        ),
        body: Center(
          child: Column(
            children: [
              const Text('JPush Flutter Plugin'),
              Text(args ?? ''),
            ],
          ),
        ),
      ),
    );
  }
}
