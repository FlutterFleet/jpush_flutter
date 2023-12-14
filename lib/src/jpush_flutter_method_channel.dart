import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'jpush_flutter_platform_interface.dart';

/// An implementation of [JPushFlutterPlatform] that uses method channels.
class MethodChannelJPushFlutter extends JPushFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('plugins.kjxbyz.com/jpush_flutter_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
