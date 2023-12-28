#import "JPushFlutterPlugin.h"

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
  if ([@"show" isEqualToString:call.method]) {
    id arguments = call.arguments;
    if (arguments == nil) {
      NSLog(@"hCaptcha配置为空");
      return;
    }

    if (![arguments isKindOfClass: NSMutableDictionary.class]) {
      NSLog(@"hCaptcha配置必须为字典类型");
      return;
    }

    NSMutableDictionary *config = (NSMutableDictionary *) arguments;
    id siteKey = [config objectForKey:@"siteKey"];
    id language = [config objectForKey:@"language"];
    if (siteKey == nil || [@"" isEqualToString:siteKey]) {
      NSLog(@"hCaptcha验证码配置中siteKey字段为空");
      return;
    }

    if (language == nil || [@"" isEqualToString:language]) {
      NSLog(@"hCaptcha验证码配置中language字段为空");
      language = @"en";
    }

    
    result(nil);
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
 
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
  
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
  
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification {
  
}

- (void)jpushNotificationAuthorization:(JPAuthorizationStatus)status withInfo:(nullable NSDictionary *)info { 
  
}


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
  return YES;
}

- (UIViewController *)topViewController {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  // TODO(stuartmorgan) Provide a non-deprecated codepath. See
  // https://github.com/flutter/flutter/issues/104117
  return [self topViewControllerFromViewController:[UIApplication sharedApplication]
                                                       .keyWindow.rootViewController];
#pragma clang diagnostic pop
}

/**
 * This method recursively iterate through the view hierarchy
 * to return the top most view controller.
 *
 * It supports the following scenarios:
 *
 * - The view controller is presenting another view.
 * - The view controller is a UINavigationController.
 * - The view controller is a UITabBarController.
 *
 * @return The top most view controller.
 */
- (UIViewController *)topViewControllerFromViewController:(UIViewController *)viewController {
  if ([viewController isKindOfClass:[UINavigationController class]]) {
    UINavigationController *navigationController = (UINavigationController *)viewController;
    return [self
        topViewControllerFromViewController:[navigationController.viewControllers lastObject]];
  }
  if ([viewController isKindOfClass:[UITabBarController class]]) {
    UITabBarController *tabController = (UITabBarController *)viewController;
    return [self topViewControllerFromViewController:tabController.selectedViewController];
  }
  if (viewController.presentedViewController) {
    return [self topViewControllerFromViewController:viewController.presentedViewController];
  }
  return viewController;
}

@end
