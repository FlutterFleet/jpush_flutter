import 'package:flutter_test/flutter_test.dart';
import 'package:jpush_flutter/src/jpush_flutter.dart';
import 'package:jpush_flutter/src/jpush_flutter_platform_interface.dart';
import 'package:jpush_flutter/src/jpush_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockJPushFlutterPlatform
    with MockPlatformInterfaceMixin
    implements JPushFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final JPushFlutterPlatform initialPlatform = JPushFlutterPlatform.instance;

  test('$MethodChannelJPushFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelJPushFlutter>());
  });

  test('getPlatformVersion', () async {
    JPushFlutter jpushFlutterPlugin = JPushFlutter();
    MockJPushFlutterPlatform fakePlatform = MockJPushFlutterPlatform();
    JPushFlutterPlatform.instance = fakePlatform;

    expect(await jpushFlutterPlugin.getPlatformVersion(), '42');
  });
}
