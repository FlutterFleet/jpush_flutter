import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'jpush_flutter_platform_interface.dart';

/// An implementation of [JPushFlutterPlatform] that uses method channels.
class MethodChannelJPushFlutter extends JPushFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel =
      const MethodChannel('plugins.kjxbyz.com/jpush_flutter_plugin');

  @override
  void setMethodCallHandler(JPushFlutterPluginHandler handler) {
    return methodChannel.setMethodCallHandler((MethodCall call) async {
      handler(call);
    });
  }

  @override
  Future<void> setDebugMode(bool debugMode) {
    return methodChannel
        .invokeMethod<void>('setDebugMode', {'debugMode': debugMode});
  }

  @override
  Future<void> setAuth(bool auth) {
    return methodChannel.invokeMethod<void>('setAuth', {
      'auth': auth,
    });
  }

  @override
  Future<int?> registerToken(String appId, String channel) {
    return methodChannel.invokeMethod<int>('registerToken', {
      'appId': appId,
      'channel': channel,
    });
  }

  @override
  Future<int?> unRegisterToken() {
    return methodChannel.invokeMethod<int>('unRegisterToken');
  }

  @override
  Future<int?> turnOffPush() {
    return methodChannel.invokeMethod<int>('turnOffPush');
  }

  @override
  Future<int?> turnOnPush() {
    return methodChannel.invokeMethod<int>('turnOnPush');
  }

  @override
  Future<void> init(String appKey, String channel) {
    return methodChannel.invokeMethod<void>('init', {
      'appKey': appKey,
      'channel': channel,
    });
  }

  @override
  Future<void> stopPush() {
    return methodChannel.invokeMethod<void>('stopPush');
  }

  @override
  Future<void> resumePush() {
    return methodChannel.invokeMethod<void>('resumePush');
  }

  @override
  Future<bool?> isPushStopped() {
    return methodChannel.invokeMethod<bool>('isPushStopped');
  }

  @override
  Future<void> setAlias(int sequence, String alias) {
    return methodChannel.invokeMethod<void>('setAlias', {
      'sequence': sequence,
      'alias': alias,
    });
  }

  @override
  Future<void> deleteAlias(int sequence) {
    return methodChannel.invokeMethod<void>('deleteAlias', {
      'sequence': sequence,
    });
  }
}
