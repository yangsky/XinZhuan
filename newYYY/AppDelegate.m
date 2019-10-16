//
//  AppDelegate.m
//  newYYY
//
//  Created by Mac on 16/7/29.
//  Copyright © 2016年 YYY. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "YYYMusicViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SystemServices.h"
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netdb.h>
#import <arpa/inet.h>
#import <AdSupport/AdSupport.h>
#import "JPUSHService.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "DLUDID.h"
#import "UMMobClick/MobClick.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "CheckUtil.h"
#import <BUAdSDK/BUAdSDKManager.h>
#import "BUAdSDK/BUSplashAdView.h"
#import "GDTSDKConfig.h"

// 友盟
#define UmengAppkey @"5c498da9f1f556a4b20013d2"
#define AppId @"wx3f78b31981678d37"
#define AppSecret @"5234a71d11eef41576026b942a425000"


// 服务器传的api参数
#define newLsAW @"lsAW5"
#define newDeFW @"deFW5"
#define newAllApption @"allApption5"
#define newOpenAppWBID @"openAppWBID5"
#define newDetion @"detion5"
#define newAllA @"allA5"

#define newLN @"LN"
#define newLSN @"LSN"
#define newBID @"BID"
#define newAID @"AID"
#define newPUS @"PUS"
// 跳转界面的偏好设置
#define newJump @"i_jump5"

#define newUDID @"UDID"

@interface AppDelegate () <BUSplashAdDelegate>
@property (nonatomic, strong) YYYMusicViewController *musicVC;
@property (nonatomic, strong) ViewController *VC;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self makeWindowVisible:launchOptions];
    
//    [Fabric with:@[[Crashlytics class]]];
    
    // 友盟
    [UMSocialData setAppKey:UmengAppkey];
    
    UMConfigInstance.appKey = UmengAppkey;
    UMConfigInstance.channelId = @"App Store";
    
    [MobClick startWithConfigure:UMConfigInstance];
    
    // 微信登陆
    [UMSocialWechatHandler setWXAppId:AppId appSecret:AppSecret url:@"http://m.xinzhuan.vip"];
    
    // 1.获取音频回话
    AVAudioSession *session = [AVAudioSession sharedInstance];

    // 2.设置后台播放类别
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    // 3.激活回话
    [session setActive:YES error:nil];
    
    //获取设备信息
//    [self jumpToHtml];
    
    
    // 极光初始化
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    //Required
//    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
//        //可以添加自定义categories
//        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
//                                                          UIUserNotificationTypeSound |
//                                                          UIUserNotificationTypeAlert)
//                                              categories:nil];
//    } else {
//        //        categories 必须为nil
//        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
//                                                          UIRemoteNotificationTypeSound |
//                                                          UIRemoteNotificationTypeAlert)
//                                              categories:nil];
//    }
    
    //Required
    //     如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
//    [JPUSHService setupWithOption:launchOptions
//                           appKey:appKey
//                          channel:channel
//                 apsForProduction:isProduction
//            advertisingIdentifier:advertisingId];
//
//    [self notificationNum];
    
    // BUAd
    [BUAdSDKManager setAppID:@"5024719"];
    [BUAdSDKManager setIsPaidApp:NO];
    
    //开屏广告
    CGRect frame = [UIScreen mainScreen].bounds;
    BUSplashAdView *splashView = [[BUSplashAdView alloc] initWithSlotID:@"824719728" frame:frame];
    splashView.delegate = self;
    UIWindow *keyWindow = [UIApplication sharedApplication].windows.firstObject;
    [splashView loadAdData];
    [keyWindow.rootViewController.view addSubview:splashView];
    splashView.rootViewController = keyWindow.rootViewController;
    
    _VC.isFirstLanuch = YES;
    
    return YES;
}

#pragma mark - 通知数量
- (void)notificationNum
{
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:0];
    
    
}

- (void)makeWindowVisible:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    _VC = [[UIStoryboard storyboardWithName:@"ViewController" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    self.window.rootViewController = _VC;

    [self.window makeKeyAndVisible];
}



- (void)jumpToHtml
{
    //设备类型
    NSString *deviceModel = [[SystemServices sharedServices] deviceModel];
    //设备型号
    NSString *systemDeviceTypeNoFormatted = [[SystemServices sharedServices] systemDeviceTypeNotFormatted];
    //设备系统版本
    NSString *systemsVersion = [[SystemServices sharedServices] systemsVersion];
    //手机名称
    NSString *deviceName = [[SystemServices sharedServices] deviceName];
    //运营商标志
    NSString *carrierName = [[SystemServices sharedServices] carrierName];
    //运营商国家
    NSString *carrierCountry = [[SystemServices sharedServices] carrierCountry];
    //MCC编码
    NSString *MCC = [NSString stringWithFormat:@"%@%@", [[SystemServices sharedServices] carrierMobileCountryCode], [[SystemServices sharedServices] carrierMobileNetworkCode]];
    //网络类型
    NSString *netType;
    if ([[SystemServices sharedServices] connectedToWiFi]) {
        netType = @"WiFi";
    }else if([[SystemServices sharedServices] connectedToCellNetwork]){
        netType = @"3G/4G";
    }
    // MAC地址
    NSString *currentMACAddress = [[SystemServices sharedServices] currentMACAddress];
    // IP
    NSString *currentIPAddress = [[SystemServices sharedServices] currentIPAddress];
    // 是否越狱
    BOOL jailbroken = [[SystemServices sharedServices] jailbroken] != NOTJAIL;
    // IDFA
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    NSString *udid = [[NSUserDefaults standardUserDefaults]objectForKey:newUDID];
    
//    NSString *uniqueID = [[SystemServices sharedServices] uniqueID];
    
//    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

//    NSString *keychain = [DLUDID changeKeychain];
    
//    NSLog(@"--idfa:%@--keychain:%@", idfa, keychain);
    
    // 检测是否越狱
    if (jailbroken == NO) {
        // 判断是否联网
        if(![self connectedToNetwork])
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                          message:@"网络连接失败,请允许使用数据后,关掉此应用再次打开"
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
            [alert show];
        }else{
            //设置键值对
    
            NSString *lsAW = @"LSApplicationWorkspace";
            [[NSUserDefaults standardUserDefaults] setObject:lsAW forKey:newLsAW];
            
            NSString *deFW = @"defaultWorkspace";
            [[NSUserDefaults standardUserDefaults] setObject:deFW forKey:newDeFW];
         
            NSString *allApption = @"allInstalledApplications";
            [[NSUserDefaults standardUserDefaults] setObject:allApption forKey:newAllApption];

            NSString *openAppWBID = @"openApplicationWithBundleID:";
            [[NSUserDefaults standardUserDefaults] setObject:openAppWBID forKey:newOpenAppWBID];
           
            NSString *allA = @"allApplications";
            [[NSUserDefaults standardUserDefaults] setObject:allA forKey:newAllA];
           
            NSString *detion = @"description";
            [[NSUserDefaults standardUserDefaults] setObject:detion forKey:newDetion];

            NSString *LN = @"localizedName";
            [[NSUserDefaults standardUserDefaults] setObject:LN forKey:newLN];

            NSString *LSN = @"localizedShortName";
            [[NSUserDefaults standardUserDefaults] setObject:LSN forKey:newLSN];

            NSString *BID = @"bundleIdentifier";
            [[NSUserDefaults standardUserDefaults] setObject:BID forKey:newBID];

            NSString *AID = @"applicationDSID";
            [[NSUserDefaults standardUserDefaults] setObject:AID forKey:newAID];

            NSString *PUS = @"publicURLSchemes";
            [[NSUserDefaults standardUserDefaults] setObject:PUS forKey:newPUS];
        
            // 跳转主界面
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:newJump];
        }
    } else {
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您的iPhone已越狱，越狱了的手机无法正常使用应用猿" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }


}


// 检测是否联网
-(BOOL) connectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flags\n");
        return NO;
    }
    
    BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
    return (isReachable && !needsConnection) ? YES : NO;
}


- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // IOS 7 Support Required
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    //    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [UMSocialSnsService  applicationDidBecomeActive];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    if ([url.scheme isEqualToString:@"shotcut"]) {
        return YES;
    }
    
    NSString *udidstr = [[CheckUtil shareInstance] getParamByName:@"udid" URLString:url.absoluteString];
    if (udidstr && udidstr.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:udidstr  forKey:newUDID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
   
    return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
}

- (void)splashAdDidClose:(BUSplashAdView *)splashAd {
    [splashAd removeFromSuperview];
}

@end
