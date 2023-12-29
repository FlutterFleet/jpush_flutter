import 'dart:developer';
import 'dart:io';

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
    if (Platform.isIOS) {
      log('[JPushFlutter]: The registerToken method is not supported on ios.');
      return Future.value();
    }
    return methodChannel.invokeMethod<int>('registerToken', {
      'appId': appId,
      'channel': channel,
    });
  }

  @override
  Future<int?> unRegisterToken() {
    if (Platform.isIOS) {
      log('[JPushFlutter]: The unRegisterToken method is not supported on ios.');
      return Future.value();
    }
    return methodChannel.invokeMethod<int>('unRegisterToken');
  }

  @override
  Future<int?> turnOffPush() {
    if (Platform.isIOS) {
      log('[JPushFlutter]: The turnOffPush method is not supported on ios.');
      return Future.value();
    }
    return methodChannel.invokeMethod<int>('turnOffPush');
  }

  @override
  Future<int?> turnOnPush() {
    if (Platform.isIOS) {
      log('[JPushFlutter]: The turnOnPush method is not supported on ios.');
      return Future.value();
    }
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
    if (Platform.isIOS) {
      log('[JPushFlutter]: The isPushStopped method is not supported on ios.');
      return Future.value();
    }
    return methodChannel.invokeMethod<bool>('isPushStopped');
  }

  @override
  Future<int?> setAlias(int sequence, String alias) {
    return methodChannel.invokeMethod<int>('setAlias', {
      'sequence': sequence,
      'alias': alias,
    });
  }

  @override
  Future<int?> deleteAlias(int sequence) {
    return methodChannel.invokeMethod<int>('deleteAlias', {
      'sequence': sequence,
    });
  }
}
