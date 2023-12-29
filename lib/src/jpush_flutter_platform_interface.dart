import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'jpush_flutter_method_channel.dart';

typedef JPushFlutterPluginHandler = Future<void> Function(MethodCall call);

abstract class JPushFlutterPlatform extends PlatformInterface {
  /// Constructs a JPushFlutterPlatform.
  JPushFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static JPushFlutterPlatform _instance = MethodChannelJPushFlutter();

  /// The default instance of [JPushFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelJPushFlutter].
  static JPushFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [JPushFlutterPlatform] when
  /// they register themselves.
  static set instance(JPushFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  void setMethodCallHandler(JPushFlutterPluginHandler handler);

  Future<void> setDebugMode(bool debugMode);

  Future<void> setAuth(bool auth);

  Future<int?> registerToken(String appId, String channel);

  Future<int?> unRegisterToken();

  Future<int?> turnOffPush();

  Future<int?> turnOnPush();

  Future<void> init(String appKey, String channel);

  Future<void> stopPush();

  Future<void> resumePush();

  Future<bool?> isPushStopped();

  Future<int?> setAlias(int sequence, String alias);

  Future<int?> deleteAlias(int sequence);
}
