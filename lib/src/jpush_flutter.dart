import 'jpush_flutter_platform_interface.dart';

class JPushFlutter {

  // 设置回调监听
  static void setMethodCallHandler(JPushFlutterPluginHandler handler) {
    return JPushFlutterPlatform.instance.setMethodCallHandler(handler);
  }

  // 开启debug模式
  static Future<void> setDebugMode({bool debugMode = false}) {
    return JPushFlutterPlatform.instance.setDebugMode(debugMode);
  }

  // 隐私确认接口与 SDK 推送业务功能启用
  static Future<void> setAuth({bool auth = false}) {
    return JPushFlutterPlatform.instance.setAuth(auth);
  }

  // 初始化
  static Future<void> init(String appKey, String channel) {
    return JPushFlutterPlatform.instance.init(appKey, channel);
  }

  // 设置别名
  static Future<void> setAlias(int sequence, String alias) {
    return JPushFlutterPlatform.instance.setAlias(sequence, alias);
  }

  // 删除别名
  static Future<void> deleteAlias(int sequence) {
    return JPushFlutterPlatform.instance.deleteAlias(sequence);
  }
}
