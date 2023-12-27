import 'package:flutter_test/flutter_test.dart';
// import 'package:jpush_flutter/src/jpush_flutter.dart';
import 'package:jpush_flutter/src/jpush_flutter_platform_interface.dart';
import 'package:jpush_flutter/src/jpush_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockJPushFlutterPlatform
    with MockPlatformInterfaceMixin
    implements JPushFlutterPlatform {

  @override
  void setMethodCallHandler(JPushFlutterPluginHandler handler) => ();

  @override
  Future<void> setDebugMode(bool debugMode) => Future.value();

  @override
  Future<void> setAuth(bool auth) => Future.value();

  @override
  Future<int?> registerToken(String appId, String channel) => Future.value(0);

  @override
  Future<int?> unRegisterToken() => Future.value(0);

  @override
  Future<int?> turnOffPush() => Future.value(0);

  @override
  Future<int?> turnOnPush() => Future.value(0);

  @override
  Future<void> init(String appKey, String channel) => Future.value();

  @override
  Future<void> stopPush() => Future.value();

  @override
  Future<void> resumePush() => Future.value();

  @override
  Future<bool> isPushStopped() => Future.value(true);

  @override
  Future<void> setAlias(int sequence, String alias) => Future.value();

  @override
  Future<void> deleteAlias(int sequence) => Future.value();
}

void main() {
  final JPushFlutterPlatform initialPlatform = JPushFlutterPlatform.instance;

  test('$MethodChannelJPushFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelJPushFlutter>());
  });

  test('getPlatformVersion', () async {
    MockJPushFlutterPlatform fakePlatform = MockJPushFlutterPlatform();
    JPushFlutterPlatform.instance = fakePlatform;

    // expect(await JPushFlutter.setMethodCallHandler((call) { }), '42');
  });
}
