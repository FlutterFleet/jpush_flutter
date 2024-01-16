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

  // 初始化推送服务
  static Future<void> registerToken(String appId, String channel) {
    return JPushFlutterPlatform.instance.registerToken(appId, channel);
  }

  // 调用此接口后，会停用所有 Push SDK 提供的功能
  static Future<void> unRegisterToken() {
    return JPushFlutterPlatform.instance.unRegisterToken();
  }

  // 停止推送服务
  static Future<void> turnOffPush() {
    return JPushFlutterPlatform.instance.turnOffPush();
  }

  // 恢复推送服务
  static Future<void> turnOnPush() {
    return JPushFlutterPlatform.instance.turnOnPush();
  }

  // 初始化推送服务
  static Future<void> init(String appKey, String channel) {
    return JPushFlutterPlatform.instance.init(appKey, channel);
  }

  // 获取 Registration ID
  static Future<String?> getRegistrationID() {
    return JPushFlutterPlatform.instance.getRegistrationID();
  }

  // 停止推送服务
  static Future<void> stopPush() {
    return JPushFlutterPlatform.instance.stopPush();
  }

  // 恢复推送服务
  static Future<void> resumePush() {
    return JPushFlutterPlatform.instance.resumePush();
  }

  // 检查推送是否被停止
  static Future<bool?> isPushStopped() {
    return JPushFlutterPlatform.instance.isPushStopped();
  }

  // 设置别名
  static Future<int?> setAlias(int sequence, String alias) {
    return JPushFlutterPlatform.instance.setAlias(sequence, alias);
  }

  // 删除别名
  static Future<int?> deleteAlias(int sequence) {
    return JPushFlutterPlatform.instance.deleteAlias(sequence);
  }
}
