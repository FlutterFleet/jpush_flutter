#import "JPushFlutterPlugin.h"
// 引入 JPush 功能所需头文件
#import <JGInforCollectionAuth.h>
#import <JPUSHService.h>

NSString * const FlutterMethodCallBadRequest = @"FlutterMethodCallBadRequest";

@interface JPushFlutterPlugin () <JPUSHRegisterDelegate>

@property(strong, readonly) FlutterMethodChannel *channel;
@property(strong) NSDictionary *launchOptions;

@end

@implementation JPushFlutterPlugin
- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
    self = [super init];
    if (self) {
      _channel = channel;
    }
    return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"plugins.kjxbyz.com/jpush_flutter_plugin"
            binaryMessenger:[registrar messenger]];
  JPushFlutterPlugin* instance = [[JPushFlutterPlugin alloc] initWithChannel: channel];
  [registrar addApplicationDelegate:instance];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  id arguments = call.arguments;

  if ([@"setDebugMode" isEqualToString:call.method]) {
    if (arguments == nil) {
      NSLog(@"Configuration must not be nil");
      result([FlutterError errorWithCode:FlutterMethodCallBadRequest message:@"Configuration must not be nil" details:nil]);
      return;
    }

    if (![arguments isKindOfClass: NSMutableDictionary.class]) {
      NSLog(@"Configuration must be of dictionary type");
      result([FlutterError errorWithCode:FlutterMethodCallBadRequest message:@"Configuration must be of dictionary type" details:nil]);
      return;
    }

    NSMutableDictionary *config = (NSMutableDictionary *) arguments;
    BOOL debugMode = [[config objectForKey:@"debugMode"] boolValue];

    [self setDebugMode:debugMode withCompletionHandler:result];
  } else if ([@"setAuth" isEqualToString:call.method]) {
    if (arguments == nil) {
      NSLog(@"Configuration must not be nil");
      result([FlutterError errorWithCode:FlutterMethodCallBadRequest message:@"Configuration must not be nil" details:nil]);
      return;
    }

    if (![arguments isKindOfClass: NSMutableDictionary.class]) {
      NSLog(@"Configuration must be of dictionary type");
      result([FlutterError errorWithCode:FlutterMethodCallBadRequest message:@"Configuration must be of dictionary type" details:nil]);
      return;
    }

    NSMutableDictionary *config = (NSMutableDictionary *) arguments;
    BOOL auth = [[config objectForKey:@"auth"] boolValue];

    [self setAuth:auth withCompletionHandler:result];
  } else if ([@"init" isEqualToString:call.method]) {
    if (arguments == nil) {
      NSLog(@"Configuration must not be nil");
      result([FlutterError errorWithCode:FlutterMethodCallBadRequest message:@"Configuration must not be nil" details:nil]);
      return;
    }

    if (![arguments isKindOfClass: NSMutableDictionary.class]) {
      NSLog(@"Configuration must be of dictionary type");
      result([FlutterError errorWithCode:FlutterMethodCallBadRequest message:@"Configuration must be of dictionary type" details:nil]);
      return;
    }

    NSMutableDictionary *config = (NSMutableDictionary *) arguments;
    id appKey = [config objectForKey:@"appKey"];
    id channel = [config objectForKey:@"channel"];
    if (appKey == nil || [@"" isEqualToString:appKey]) {
      NSLog(@"appKey must not be nil");
      result([FlutterError errorWithCode:FlutterMethodCallBadRequest message:@"appKey must not be nil" details:nil]);
      return;
    }

    if (channel == nil || [@"" isEqualToString:channel]) {
      NSLog(@"channel must not be nil");
      result([FlutterError errorWithCode:FlutterMethodCallBadRequest message:@"channel must not be nil" details:nil]);
      return;
    }

    [self init:appKey withChannel:channel withCompletionHandler:result];
  } else if ([@"getRegistrationID" isEqualToString:call.method]) {
    [self getRegistrationID:result];
  } else if ([@"stopPush" isEqualToString:call.method]) {
    [self setPushEnable:NO withCompletionHandler:result];
  } else if ([@"resumePush" isEqualToString:call.method]) {
    [self setPushEnable:YES withCompletionHandler:result];
  } else if ([@"setAlias" isEqualToString:call.method]) {
    if (arguments == nil) {
      NSLog(@"Configuration must not be nil");
      result([FlutterError errorWithCode:FlutterMethodCallBadRequest message:@"Configuration must not be nil" details:nil]);
      return;
    }

    if (![arguments isKindOfClass: NSMutableDictionary.class]) {
      NSLog(@"Configuration must be of dictionary type");
      result([FlutterError errorWithCode:FlutterMethodCallBadRequest message:@"Configuration must be of dictionary type" details:nil]);
      return;
    }

    NSMutableDictionary *config = (NSMutableDictionary *) arguments;
    NSInteger sequence = [[config objectForKey:@"sequence"] integerValue];
    id alias = [config objectForKey:@"alias"];

    [self setAliass:sequence withAlias:alias withCompletionHandler:result];
  } else if ([@"deleteAlias" isEqualToString:call.method]) {
    if (arguments == nil) {
      NSLog(@"Configuration must not be nil");
      result([FlutterError errorWithCode:FlutterMethodCallBadRequest message:@"Configuration must not be nil" details:nil]);
      return;
    }

    if (![arguments isKindOfClass: NSMutableDictionary.class]) {
      NSLog(@"Configuration must be of dictionary type");
      result([FlutterError errorWithCode:FlutterMethodCallBadRequest message:@"Configuration must be of dictionary type" details:nil]);
      return;
    }

    NSMutableDictionary *config = (NSMutableDictionary *) arguments;
    NSInteger sequence = [[config objectForKey:@"sequence"] integerValue];

    [self deleteAliass:sequence withCompletionHandler:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

// 开启debug模式
- (void)setDebugMode:(BOOL) debugMode withCompletionHandler:(FlutterResult)result {
  if (debugMode) {
    [JPUSHService setDebugMode];
  } else {
    [JPUSHService setLogOFF];
  }
  result(nil);
}

// 隐私监管
- (void)setAuth:(BOOL) auth withCompletionHandler:(FlutterResult)result {
  [JGInforCollectionAuth JCollectionAuth:^(JGInforCollectionAuthItems * _Nonnull authInfo) {
    authInfo.isAuth = auth;
    result(nil);
  }];
}

// 初始化
- (void)init:(NSString *) appKey withChannel:(NSString *) channel withCompletionHandler:(FlutterResult)result {
  __block NSString* advertisingId;

  if (@available(iOS 14, *)) {
    ATTrackingManagerAuthorizationStatus states = [ATTrackingManager trackingAuthorizationStatus];
    if (states == ATTrackingManagerAuthorizationStatusNotDetermined) {
      [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
          // 获取到权限后，依然使用老方法获取idfa
          if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
            advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
          }
        });
      }];
    } else if (states == ATTrackingManagerAuthorizationStatusAuthorized) {
      advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
  } else {
    advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
  }

  [JPUSHService setupWithOption:self.launchOptions appKey:appKey channel:channel apsForProduction:YES advertisingIdentifier: advertisingId];

  [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
    NSLog(@"resCode : %d, registrationID: %@", resCode, registrationID);
  }];

  result(nil);
}

// 获取 Registration ID
- (void)getRegistrationID: (FlutterResult)result {
  [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
    NSLog(@"resCode : %d, registrationID: %@",resCode,registrationID);
    result(registrationID);
  }];
}

// 控制极光的消息状态。 关闭 PUSH 之后，将接收不到极光通知推送、自定义消息推送、liveActivity 消息推送，默认是开启。
- (void)setPushEnable:(BOOL)isEnable withCompletionHandler:(FlutterResult)result {
  [JPUSHService setPushEnable:isEnable completion:^(NSInteger iResCode) {
    result([NSNumber numberWithInteger:iResCode]);
  }];
}

// 设置别名
- (void)setAliass:(NSInteger) sequence withAlias: (NSString *) alias withCompletionHandler:(FlutterResult)result {
  [JPUSHService setAlias:alias completion:^(NSInteger iResCode, NSString * _Nullable iAlias, NSInteger seq) {
    result([NSNumber numberWithInteger:iResCode]);
  } seq:sequence];
}

// 删除别名
- (void)deleteAliass:(NSInteger) sequence withCompletionHandler:(FlutterResult)result {
  [JPUSHService deleteAlias:^(NSInteger iResCode, NSString * _Nullable iAlias, NSInteger seq) {
    result([NSNumber numberWithInteger:iResCode]);
  } seq:sequence];
}

// iOS 10 Support
// iOS 设备收到通知推送（APNs ），用户点击推送通知打开应用时，应用程序根据运行状态进行不同处理
// 1. App 在前台运行
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
  // Required
  NSDictionary * userInfo = notification.request.content.userInfo;
  if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
    [JPUSHService handleRemoteNotification:userInfo];
  }
  
  UNNotificationRequest* request = notification.request; // 收到推送的请求
  UNNotificationContent* content = request.content; // 收到推送的消息内容
  NSString* title = content.title;
  NSString* subtitle = content.subtitle;
  NSString* body = content.body;
  NSNumber* badge = content.badge;
  
  NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
  [data setValue:title forKey:@"title"];
  [data setValue:subtitle forKey:@"subtitle"];
  [data setValue:body forKey:@"body"];
  [data setValue:badge forKey:@"badge"];
  [data setObject:userInfo forKey:@"extras"];
  
  NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self.channel != nil) {
      [self.channel invokeMethod:@"notificationClick" arguments:jsonString];
    }
  });
  
  completionHandler(UNNotificationPresentationOptionAlert| UNNotificationPresentationOptionSound | UNNotificationPresentationOptionBadge); // 需要执行这个方法，选择是否提醒用户，有 Badge、Sound、Alert 三种类型可以选择设置
}

// iOS 10 Support
// 2. App 在后台时（需要点击通知才能触发回调）
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
  // Required
  NSDictionary * userInfo = response.notification.request.content.userInfo;
  if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
    [JPUSHService handleRemoteNotification:userInfo];
  }
  
  UNNotificationRequest* request = response.notification.request; // 收到推送的请求
  UNNotificationContent* content = request.content; // 收到推送的消息内容
  NSString* title = content.title;
  NSString* subtitle = content.subtitle;
  NSString* body = content.body;
  NSNumber* badge = content.badge;
  
  NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
  [data setValue:title forKey:@"title"];
  [data setValue:subtitle forKey:@"subtitle"];
  [data setValue:body forKey:@"body"];
  [data setValue:badge forKey:@"badge"];
  [data setObject:userInfo forKey:@"extras"];
  
  NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self.channel != nil) {
      [self.channel invokeMethod:@"notificationClick" arguments:jsonString];
    }
  });
  
  completionHandler();    // 系统要求执行这个方法
}

#ifdef __IPHONE_12_0
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification {
  NSString *title = nil;
  if (notification) {
    title = @"从通知界面直接进入应用";
  }else{
    title = @"从系统设置界面进入应用";
  }
  NSLog(@"%@", title);
}
#endif

- (void)jpushNotificationAuthorization:(JPAuthorizationStatus)status withInfo:(nullable NSDictionary *)info {
  NSLog(@"receive notification authorization status:%lu, info:%@", status, info);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  NSLog(@"deviceToken: %@", deviceToken);
  //sdk注册DeviceToken
  [JPUSHService registerDeviceToken:deviceToken];
}

// 3. App 未启动状态（需要点击通知才能触发回调）
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.launchOptions = launchOptions;
  //Required
  //notice: 3.0.0 及以后版本注册可以这样写，也可以继续用之前的注册方式
  JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
  entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
  if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
    // 可以添加自定义 categories
    // NSSet<UNNotificationCategory *> *categories for iOS10 or later
    // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
  }
  [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
  
  if (launchOptions != nil) {
    NSDictionary *remoteNotification = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    NSDictionary *aps = [remoteNotification objectForKey:@"aps"];
    NSNumber *badge = [remoteNotification valueForKey:@"badge"];
    NSDictionary *alert = [aps objectForKey:@"alert"];
    NSString *title = [alert valueForKey:@"title"];
    NSString *body = [alert valueForKey:@"body"];
    
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setValue:title forKey:@"title"];
    [data setValue:body forKey:@"body"];
    [data setValue:badge forKey:@"badge"];
    [data setObject:remoteNotification forKey:@"extras"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      if (self.channel != nil) {
        [self.channel invokeMethod:@"notificationClick" arguments:jsonString];
      }
    });
  }
  
  return YES;
}

@end
