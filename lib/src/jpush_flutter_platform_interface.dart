import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'jpush_flutter_method_channel.dart';

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

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
