import 'jpush_flutter_platform_interface.dart';

class JPushFlutter {
  Future<String?> getPlatformVersion() {
    return JPushFlutterPlatform.instance.getPlatformVersion();
  }
}
