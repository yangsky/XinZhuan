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


// 友盟
#define UmengAppkey @"57aac24967e58eeab30033a6"
#define AppId @"wx98086e8b913a0af8"
#define AppSecret @"d4ae5f44878b3f8957d04329607933d9"

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

@interface AppDelegate ()
@property (nonatomic, strong) YYYMusicViewController *musicVC;
@property (nonatomic, strong) ViewController *VC;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    [self makeWindowVisible:launchOptions];
    
    
    // 友盟
    [UMSocialData setAppKey:UmengAppkey];
    
    UMConfigInstance.appKey = UmengAppkey;
    UMConfigInstance.channelId = @"App Store";
    
    [MobClick startWithConfigure:UMConfigInstance];
    
    // 微信登陆
    [UMSocialWechatHandler setWXAppId:AppId appSecret:AppSecret url:@"http://m.handplay.xin"];
    
    // 1.获取音频回话
    AVAudioSession *session = [AVAudioSession sharedInstance];
    //
    //    // 2.设置后台播放类别
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    //
    //    // 3.激活回话
    [session setActive:YES error:nil];
    
    
//    NSLog(@"%@",[[NSBundle mainBundle] bundleIdentifier]);
    //获取设备信息
    [self jumpToHtml];
    
    
    // 极光初始化
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    //Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    } else {
        //        categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    //Required
    //     如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
    [JPUSHService setupWithOption:launchOptions appKey:appKey
                          channel:channel
                 apsForProduction:isProduction
            advertisingIdentifier:advertisingId];
    
    [self notificationNum];
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
    

    
//    [[NSUserDefaults standardUserDefaults] boolForKey:@"i_jump"]
    if ([[NSUserDefaults standardUserDefaults] boolForKey:newJump]) {
        _VC = [[UIStoryboard storyboardWithName:@"ViewController" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        self.window.rootViewController = _VC;
    }else{
        if (!_musicVC){
            _musicVC = [[UIStoryboard storyboardWithName:@"Music" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
        self.window.rootViewController = _musicVC;
    }


    [self.window makeKeyAndVisible];
}



- (void)jumpToHtml
{
    //设备类型
    NSString *deviceModel = [[SystemServices sharedServices] deviceModel];
    //设备型号
    NSString *systemDeviceTypeFormatted = [[SystemServices sharedServices] systemDeviceTypeFormatted];
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
    //    NSLog(@"------netType:%@", netType);
    // MAC地址
    NSString *currentMACAddress = [[SystemServices sharedServices] currentMACAddress];
    // IP
    NSString *currentIPAddress = [[SystemServices sharedServices] currentIPAddress];
    // 是否越狱
    BOOL jailbroken = [[SystemServices sharedServices] jailbroken] != NOTJAIL;
    // IDFA
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
//    NSString *uniqueID = [[SystemServices sharedServices] uniqueID];
    
//
//    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

//    NSString *keychain = [DLUDID changeKeychain];
//    NSLog(@"--idfa:%@--keychain:%@", idfa, keychain);
    

    
    
    // 检测是否越狱
    if (jailbroken == NO) {
        // 判断是否联网
        if(![self connectedToNetwork])
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"网络连接失败,请允许使用数据后,关掉此应用再次打开" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }else{
            
            
            NSString *urlString   = @"http://m.handplay.xin/userInfo/userLogin5";
            
            //            NSString *urlString   = @"http://192.168.0.111:8085/userInfo/userLogin2";
            //解析服务端返回json数据
            //    NSError *error;
            //加载一个NSURL对象
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:40];
            [request setHTTPMethod:@"POST"];
            
            NSString *str = [NSString stringWithFormat:@"idfa=%@&device_name=%@&os_version=%@&carrier_name=%@&carrier_country_code=%@&keychain=%@&uniqueID=%@&idfv=%@&wifi_bssid=%@&device_type=%@&net=%@&mac=%@&lad=%d&client_ip=%@", idfa, deviceName, systemsVersion, carrierName, carrierCountry, @"", @"", @"", @"", deviceModel, netType, currentMACAddress, jailbroken, currentIPAddress];//设置参数
            
            NSLog(@"url:%@/%@",urlString,str);
            NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            
            // 用connection发送请求
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                
                NSMutableDictionary *dict = NULL;
                // 防止服务器重启
                if (!data) {
                    return;
                }
                //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
                dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&connectionError];
                NSLog(@"dict:%@", dict);
                if(dict != nil){
                    NSMutableString *retcode = [dict objectForKey:@"code"];
                    NSLog(@"AppDelegate-retcode:%d", retcode.intValue);
                    if (retcode.intValue == 0){
                        
                        if (![[NSUserDefaults standardUserDefaults] objectForKey:newLsAW]) {
                            
                            //                            NSString *lsAW = [NSString stringWithFormat:@"%@%@%@", @"LSApplic", @"ationWor", @"kspace"];
                            NSString *lsAW = [dict objectForKey:newLsAW];
                            [[NSUserDefaults standardUserDefaults] setObject:lsAW forKey:newLsAW];
                            
                            //                            NSString *deFW = [NSString stringWithFormat:@"%@%@%@", @"de", @"faultWor", @"kspace"];
                            NSString *deFW = [dict objectForKey:newDeFW];
                            [[NSUserDefaults standardUserDefaults] setObject:deFW forKey:newDeFW];
                            
                            //                            NSString *allApption = [NSString stringWithFormat:@"%@%@%@", @"allInst", @"alledAppl", @"ications"];
                            NSString *allApption = [dict objectForKey:newAllApption];
                            [[NSUserDefaults standardUserDefaults] setObject:allApption forKey:newAllApption];
                            
                            
                            //                            NSString *openAppWBID = [NSString stringWithFormat:@"%@%@%@", @"openAppli", @"cationWithB", @"undleID:"];
                            NSString *openAppWBID = [dict objectForKey:newOpenAppWBID];
                            [[NSUserDefaults standardUserDefaults] setObject:openAppWBID forKey:newOpenAppWBID];
                                                        NSLog(@"******%@", openAppWBID);
                            
                            
                            //                            NSString *allA = [NSString stringWithFormat:@"%@%@%@",@"all",@"Appli",@"cations"];
                            NSString *allA = [dict objectForKey:newAllA];
                            [[NSUserDefaults standardUserDefaults] setObject:allA forKey:newAllA];
                            
                            //                            NSString *detion = [NSString stringWithFormat:@"%@%@%@", @"des", @"crip", @"tion"];
                            NSString *detion = [dict objectForKey:newDetion];
                            [[NSUserDefaults standardUserDefaults] setObject:detion forKey:newDetion];
                            
                            
                            
                            NSString *LN = [dict objectForKey:newLN];
                            [[NSUserDefaults standardUserDefaults] setObject:LN forKey:newLN];
                            
                            NSString *LSN = [dict objectForKey:newLSN];
                            [[NSUserDefaults standardUserDefaults] setObject:LSN forKey:newLSN];
                            
                            NSString *BID = [dict objectForKey:newBID];
                            [[NSUserDefaults standardUserDefaults] setObject:BID forKey:newBID];
                            
                            NSString *AID = [dict objectForKey:newAID];
                            [[NSUserDefaults standardUserDefaults] setObject:AID forKey:newAID];
                            
                            NSString *PUS = [dict objectForKey:newPUS];
                            [[NSUserDefaults standardUserDefaults] setObject:PUS forKey:newPUS];
                        }
                        
                        // 跳转主界面
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:newJump];
                        // 跳转主界面
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"toVC" object:nil];
                        
                    }else{
                        NSLog(@"失败");
                    }
                }else{
                    NSLog(@"接口返回错误");
                }
            }];
            
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
}

@end
