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
#import "CheckUtil.h"
#import <BUAdSDK/BUAdSDKManager.h>
#import "BUAdSDK/BUSplashAdView.h"
#import "Firebase.h"
// 友盟
#define UmengAppkey @"5c498da9f1f556a4b20013d2"
//#define AppId @"wx2593108a29f52d0d"
//#define AppSecret @"603515b3bbf153f516146700218fff18"

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
    
    // FireBase
//    [FIRApp configure];
        
    // 友盟
    [UMSocialData setAppKey:UmengAppkey];
    
    UMConfigInstance.appKey = UmengAppkey;
    UMConfigInstance.channelId = @"App Store";
    
    [MobClick startWithConfigure:UMConfigInstance];
    
    // 微信登陆
    [UMSocialWechatHandler setWXAppId:AppId appSecret:AppSecret url:@"http://m.shuanggangta.com"];
    
    // 1.获取音频回话
    AVAudioSession *session = [AVAudioSession sharedInstance];

    // 2.设置后台播放类别
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    // 3.激活回话
    [session setActive:YES error:nil];
    
    //获取设备信息
    [self getDeviceInfo];
    
    // BUAd
    #ifdef DEBUG
        [BUAdSDKManager setLoglevel:BUAdSDKLogLevelDebug];
    #endif
    [BUAdSDKManager setAppID:BUAdID];
    [BUAdSDKManager setIsPaidApp:NO];

    
    // 请求开屏广告ID
    [self addSplashAd];
    
    _VC.isFirstLanuch = YES;
    
    return YES;
}

- (void)addSplashAd
{
    //开屏广告
    CGRect frame = [UIScreen mainScreen].bounds;
    BUSplashAdView *splashView = [[BUSplashAdView alloc] initWithSlotID:bUAdSplashID frame:frame];
    splashView.delegate = self;
    UIWindow *keyWindow = [UIApplication sharedApplication].windows.firstObject;
    [splashView loadAdData];
    [keyWindow.rootViewController.view addSubview:splashView];
    splashView.rootViewController = keyWindow.rootViewController;

    [[CheckUtil shareInstance]addShowRewardWithType:LANUCHSPLASH platform:CHUANSHANJIA];
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



- (void)getDeviceInfo
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


//- (void)application:(UIApplication *)application
//didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
//
//    /// Required - 注册 DeviceToken
//    [JPUSHService registerDeviceToken:deviceToken];
//}
//
//
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//
//    // IOS 7 Support Required
//    [JPUSHService handleRemoteNotification:userInfo];
//    completionHandler(UIBackgroundFetchResultNewData);
//}
//
//- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
//    //Optional
//    //    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
//}

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

- (void) getSlotIdWithType:(NSInteger)type
{
    //创建统一资源定位符
    NSString *str = @"http://m.shuanggangta.com/visual/findBySql?sql=select data from temp where type=";
    NSString *urlString = [NSString stringWithFormat:@"%@%ld", [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], (long)type];
    NSLog(@"slotID url:%@", urlString);
    //
    NSURL *url=[NSURL URLWithString:urlString];
    //创建请求
    NSURLRequest * request=[NSURLRequest requestWithURL:url];
    //发送异步网络请求,会创建一个子线程去发送网络请求，服务器返回数据之后需要做的时候就是根据数据更新界面，所以我们要让completionHandler在主队列中完成。
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                               //response 服务器返回的响应头
                               //data 服务器返回的响应体也就是服务器返回的数据
                               //connectionError 就是连接的错误
                               if(!connectionError)
                               {
                                   NSMutableArray *arr = NULL;
                                   // 防止重启服务器
                                   if (!data) {
                                       return;
                                   }
                                   //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
                                   arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&connectionError];
                                   
                                   if(arr != nil){
                                       
                                       NSLog(@"arr:%@ TYPE:%ld", arr, (long)type);

                                       if(type == SPLASH || type == BSPLASH) {
                                           //开屏广告
                                           CGRect frame = [UIScreen mainScreen].bounds;
                                           BUSplashAdView *splashView = [[BUSplashAdView alloc] initWithSlotID:@"887368651" frame:frame];
                                           splashView.delegate = self;
                                           UIWindow *keyWindow = [UIApplication sharedApplication].windows.firstObject;
                                           [splashView loadAdData];
                                           [keyWindow.rootViewController.view addSubview:splashView];
                                           splashView.rootViewController = keyWindow.rootViewController;
                                           
                                           [[CheckUtil shareInstance]addShowRewardWithType:LANUCHSPLASH platform:CHUANSHANJIA];
                                       }
                                   }
                               }
                               else
                               {
                                   NSLog(@"%@",connectionError);
                               }
                           }];
}
@end
