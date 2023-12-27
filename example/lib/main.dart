import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  JPushFlutter.setMethodCallHandler((call) async {
    if (call.method == 'notificationClick') {
      if (kDebugMode) {
        print('setMethodCallHandler: ${call.arguments}');
      }
    }
  });
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Permission.notification.request();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('JPushPlugin Example'),
        ),
        body: const Center(
          child: Text('JPush Flutter Plugin'),
        ),
      ),
    );
  }

}
