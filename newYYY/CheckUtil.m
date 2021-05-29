//
//  CheckUtil.m
//  newYYY
//
//  Created by Yang Shengyuan on 2018/9/20.
//  Copyright © 2018年 YYY. All rights reserved.
//

#import "CheckUtil.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import "objc/runtime.h"
#include <ifaddrs.h>
#import <netdb.h>
#import <arpa/inet.h>
#import <CommonCrypto/CommonDigest.h>

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "YingYongYuanetattD.h"

@implementation CheckUtil

CheckUtil * g_instance_singleton = nil ;

+ (CheckUtil *)shareInstance{
    static CheckUtil * g_instance_singleton = nil ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (g_instance_singleton == nil) {
            g_instance_singleton = [[CheckUtil alloc] init];
        }
    });
    return (CheckUtil *)g_instance_singleton;
}

- (BOOL)isJailBreak {
    
    if([self isJailBreak1] ||
       [self isJailBreak2] ||
       [self isJailBreak3] ||
       [self isJailBreak4])
    {
        return YES;
    }
    return NO;
}

// 判断这些文件是否存在，只要有存在的，就可以认为手机已经越狱了
- (BOOL)isJailBreak1 {
    
    NSArray *jailbreak_tool_paths = @[
                                      @"/Applications/Cydia.app",
                                      @"/Library/MobileSubstrate/MobileSubstrate.dylib",
                                      @"/bin/bash",
                                      @"/usr/sbin/sshd",
                                      @"/etc/apt"
                                      ];

    for (int i=0; i<jailbreak_tool_paths.count; i++) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:jailbreak_tool_paths[i]]) {
            NSLog(@"The device is jail broken!");
            return YES;
        }
    }
    NSLog(@"The device is NOT jail broken!");
    return NO;
}


// 根据是否能打开cydia判断
- (BOOL)isJailBreak2 {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
        NSLog(@"The device is jail broken!");
        return YES;
    }
    NSLog(@"The device is NOT jail broken!");
    return NO;
}

// 根据是否能获取所有应用的名称判断 没有越狱的设备是没有读取所有应用名称的权限的
- (BOOL)isJailBreak3 {
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"User/Applications/"]) {
        NSLog(@"The device is jail broken!");
        NSArray *appList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"User/Applications/" error:nil];
        NSLog(@"appList = %@", appList);
        return YES;
    }
    NSLog(@"The device is NOT jail broken!");
    return NO;
}

//根据读取的环境变量是否有值判断
//DYLD_INSERT_LIBRARIES环境变量在非越狱的设备上应该是空的，而越狱的设备基本上都会有Library/MobileSubstrate/MobileSubstrate.dylib
char* printEnv(void) {
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    NSLog(@"%s", env);
    return env;
}

- (BOOL)isJailBreak4 {
    if (printEnv()) {
        NSLog(@"The device is jail broken!");
        return YES;
    }
    NSLog(@"The device is NOT jail broken!");
    return NO;
}


- (NSString*)iphoneType {
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString*platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    
    if([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    
    if([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    
    if([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    
    if([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    
    if([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    
    if([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    
    if([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    
    if([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    
    if([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    
    if([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    
    if([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    
    if([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    
    if([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    
    if([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    
    if([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    
    if([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    
    if([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    
    if([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    
    if([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    
    if([platform isEqualToString:@"iPhone10,1"]) return @"iPhone 8";
    
    if([platform isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
    
    if([platform isEqualToString:@"iPhone10,2"]) return @"iPhone 8 Plus";
    
    if([platform isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
    
    if([platform isEqualToString:@"iPhone10,3"]) return @"iPhone X";
    
    if([platform isEqualToString:@"iPhone10,6"]) return @"iPhone X";
    
    if ([platform isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
    
    if ([platform isEqualToString:@"iPhone11,4"]) return @"iPhone XS Max";
    
    if ([platform isEqualToString:@"iPhone11,6"]) return @"iPhone XS Max";
    
    if ([platform isEqualToString:@"iPhone11,8"]) return @"iPhone XR";
    
    if ([platform isEqualToString:@"iPhone12,1"]) return @"iPhone 11";
    
    if ([platform isEqualToString:@"iPhone12,3"]) return @"iPhone 11 Pro";

    if ([platform isEqualToString:@"iPhone12,5"]) return @"iPhone 11 Pro Max";

    if ([platform isEqualToString:@"iPhone12,8"]) return @"iPhone SE 2";

    if ([platform isEqualToString:@"iPhone13,1"]) return @"iPhone 12 mini";

    if ([platform isEqualToString:@"iPhone13,2"]) return @"iPhone 12";

    if ([platform isEqualToString:@"iPhone13,3"]) return @"iPhone 12 Pro";

    if ([platform isEqualToString:@"iPhone13,4"]) return @"iPhone 12 Pro Max";

    if([platform isEqualToString:@"iPod1,1"]) return @"iPod Touch 1G";
    
    if([platform isEqualToString:@"iPod2,1"]) return @"iPod Touch 2G";
    
    if([platform isEqualToString:@"iPod3,1"]) return @"iPod Touch 3G";
    
    if([platform isEqualToString:@"iPod4,1"]) return @"iPod Touch 4G";
    
    if([platform isEqualToString:@"iPod5,1"]) return @"iPod Touch 5G";
    
    if([platform isEqualToString:@"iPad1,1"]) return @"iPad 1G";
    
    if([platform isEqualToString:@"iPad2,1"]) return @"iPad 2";
    
    if([platform isEqualToString:@"iPad2,2"]) return @"iPad 2";
    
    if([platform isEqualToString:@"iPad2,3"]) return @"iPad 2";
    
    if([platform isEqualToString:@"iPad2,4"]) return @"iPad 2";
    
    if([platform isEqualToString:@"iPad2,5"]) return @"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad2,6"]) return @"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad2,7"]) return @"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad3,1"]) return @"iPad 3";
    
    if([platform isEqualToString:@"iPad3,2"]) return @"iPad 3";
    
    if([platform isEqualToString:@"iPad3,3"]) return @"iPad 3";
    
    if([platform isEqualToString:@"iPad3,4"]) return @"iPad 4";
    
    if([platform isEqualToString:@"iPad3,5"]) return @"iPad 4";
    
    if([platform isEqualToString:@"iPad3,6"]) return @"iPad 4";
    
    if([platform isEqualToString:@"iPad4,1"]) return @"iPad Air";
    
    if([platform isEqualToString:@"iPad4,2"]) return @"iPad Air";
    
    if([platform isEqualToString:@"iPad4,3"]) return @"iPad Air";
    
    if([platform isEqualToString:@"iPad4,4"]) return @"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,5"]) return @"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,6"]) return @"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,7"]) return @"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad4,8"]) return @"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad4,9"]) return @"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad5,1"]) return @"iPad Mini 4";
    
    if([platform isEqualToString:@"iPad5,2"]) return @"iPad Mini 4";
    
    if([platform isEqualToString:@"iPad5,3"]) return @"iPad Air 2";
    
    if([platform isEqualToString:@"iPad5,4"]) return @"iPad Air 2";
    
    if([platform isEqualToString:@"iPad6,3"]) return @"iPad Pro 9.7";
    
    if([platform isEqualToString:@"iPad6,4"]) return @"iPad Pro 9.7";
    
    if([platform isEqualToString:@"iPad6,7"]) return @"iPad Pro 12.9";
    
    if([platform isEqualToString:@"iPad6,8"]) return @"iPad Pro 12.9";
    
    if([platform isEqualToString:@"iPad6,11"]) return @"iPad 5";
    
    if([platform isEqualToString:@"iPad6,12"]) return @"iPad 5";
    
    if([platform isEqualToString:@"iPad7,1"]) return @"iPad Pro 12.9 inch 2nd gen";
    
    if([platform isEqualToString:@"iPad7,2"]) return @"iPad Pro 12.9 inch 2nd gen";
    
    if([platform isEqualToString:@"iPad7,3"]) return @"iPad Pro 10.5 inch";
    
    if([platform isEqualToString:@"iPad7,4"]) return @"iPad Pro 10.5 inch";
    
    if([platform isEqualToString:@"iPad7,5"]) return @"iPad 6";
    
    if([platform isEqualToString:@"iPad7,6"]) return @"iPad 6";
    
    if([platform isEqualToString:@"iPad7,11"]) return @"iPad 7";
    
    if([platform isEqualToString:@"iPad7,12"]) return @"iPad 7";
    
    if([platform isEqualToString:@"iPad8,1 ~ 8,4"]) return @"iPad Pro 11-inch";
    
    if([platform isEqualToString:@"iPad8,5 ~ 8,8"]) return @"iPad Pro 12.9-inch 3rd gen";
    
    if([platform isEqualToString:@"iPad8,9 ~ 8,10"]) return @"iPad Pro 11-inch 2nd gen";
    
    if([platform isEqualToString:@"iPad8,11 ~ 8,12"]) return @"iPad Pro 12.9-inch 4th gen";
    
    if([platform isEqualToString:@"iPad11,1"]) return @"iPad Mini 5";
    
    if([platform isEqualToString:@"iPad11,2"]) return @"iPad Mini 5";
    
    if([platform isEqualToString:@"iPad11,3"]) return @"iPad Air 3";
    
    if([platform isEqualToString:@"iPad11,4"]) return @"iPad Air 3";
    
    if([platform isEqualToString:@"iPad11,6"]) return @"iPad 8";
    
    if([platform isEqualToString:@"iPad11,7"]) return @"iPad 8";
    
    if([platform isEqualToString:@"iPad13,1"]) return @"iPad Air 4";
    
    if([platform isEqualToString:@"iPad13,2"]) return @"iPad Air 4";
    
    if([platform isEqualToString:@"i386"]) return @"iPhone Simulator";
    
    if([platform isEqualToString:@"x86_64"]) return @"iPhone Simulator";
    
    return platform;
    
}


- (NSString *)getParamByName:(NSString *)name URLString:(NSString *)url
{
    NSError *error;
    NSString *regTags=[[NSString alloc] initWithFormat:@"(^|&|\\?)+%@=+([^&]*)(&|$)", name];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regTags
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    // 执行匹配的过程
    NSArray *matches = [regex matchesInString:url
                                      options:0
                                        range:NSMakeRange(0, [url length])];
    for (NSTextCheckingResult *match in matches) {
        NSString *tagValue = [url substringWithRange:[match rangeAtIndex:2]];  // 分组2所对应的串
        return tagValue;
    }
    return @"";
}


- (BOOL)isVPNOn
{
    BOOL flag = NO;
    NSString *version = [UIDevice currentDevice].systemVersion;
    // need two ways to judge this.
    if (version.doubleValue >= 9.0)
    {
        NSDictionary *dict = CFBridgingRelease(CFNetworkCopySystemProxySettings());
        NSArray *keys = [dict[@"__SCOPED__"] allKeys];
        for (NSString *key in keys) {
            if ([key rangeOfString:@"tap"].location != NSNotFound ||
                [key rangeOfString:@"tun"].location != NSNotFound ||
                [key rangeOfString:@"ipsec"].location != NSNotFound ||
                [key rangeOfString:@"ppp"].location != NSNotFound){
                flag = YES;
                break;
            }
        }
    }
    else
    {
        struct ifaddrs *interfaces = NULL;
        struct ifaddrs *temp_addr = NULL;
        int success = 0;
        
        // retrieve the current interfaces - returns 0 on success
        success = getifaddrs(&interfaces);
        if (success == 0)
        {
            // Loop through linked list of interfaces
            temp_addr = interfaces;
            while (temp_addr != NULL)
            {
                NSString *string = [NSString stringWithFormat:@"%s" , temp_addr->ifa_name];
                if ([string rangeOfString:@"tap"].location != NSNotFound ||
                    [string rangeOfString:@"tun"].location != NSNotFound ||
                    [string rangeOfString:@"ipsec"].location != NSNotFound ||
                    [string rangeOfString:@"ppp"].location != NSNotFound)
                {
                    flag = YES;
                    break;
                }
                temp_addr = temp_addr->ifa_next;
            }
        }
        
        // Free memory
        freeifaddrs(interfaces);
    }
    
    return flag;
}

- (BOOL) isCharging
{

    // Get the device
    UIDevice *Device = [UIDevice currentDevice];
    // Set battery monitoring on
    Device.batteryMonitoringEnabled = YES;

    // Check the battery state
    if ([Device batteryState] == UIDeviceBatteryStateCharging) {
        // Device is charging
        return true;
    } else {
        // Device is not charging
        return false;
    }

}

// 判断设备是否安装sim卡
- (BOOL)isSIMInstalled
{
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    if (!carrier.isoCountryCode) {
        NSLog(@"请安装好手机SIM卡后在拨打电话.");
        return NO;
    }else{
        NSLog(@"存在SIM卡");
        return YES;
    }
}

///方法二：获取手机中sim卡数量（推荐）
- (int)SimCardNumInPhone {
     CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
     if (@available(iOS 12.0, *)) {
          NSDictionary *ctDict = networkInfo.serviceSubscriberCellularProviders;
          if ([ctDict allKeys].count > 1) {
               NSArray *keys = [ctDict allKeys];
               CTCarrier *carrier1 = [ctDict objectForKey:[keys firstObject]];
               CTCarrier *carrier2 = [ctDict objectForKey:[keys lastObject]];
               if (carrier1.mobileCountryCode.length && carrier2.mobileCountryCode.length) {
                    return 2;
               }else if (!carrier1.mobileCountryCode.length && !carrier2.mobileCountryCode.length) {
                    return 0;
               }else {
                    return 1;
               }
          }else if ([ctDict allKeys].count == 1) {
               NSArray *keys = [ctDict allKeys];
               CTCarrier *carrier1 = [ctDict objectForKey:[keys firstObject]];
               if (carrier1.mobileCountryCode.length) {
                    return 1;
               }else {
                    return 0;
               }
          }else {
               return 0;
          }
     }else {
          CTCarrier *carrier = [networkInfo subscriberCellularProvider];
          NSString *carrier_name = carrier.mobileCountryCode;
          if (carrier_name.length) {
               return 1;
          }else {
               return 0;
          }
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

// md5加密
- (NSString *) md5 : (NSString *) str {
    // 判断传入的字符串是否为空
    if (! str) return nil;
    // 转成utf-8字符串
    const char *cStr = str.UTF8String;
    // 设置一个接收数组
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    // 对密码进行加密
    CC_MD5(cStr, (CC_LONG) strlen(cStr), result);
    NSMutableString *md5Str = [NSMutableString string];
    // 转成32字节的16进制
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i ++) {
        [md5Str appendFormat:@"%02x", result[i]];
    }
    return md5Str;
}

#pragma mark -- addShowReward
- (void) addShowRewardWithType:(NSInteger)type
                      platform:(NSInteger)platform
{
    
    //创建统一资源定位符
    NSString *urlString = [NSString stringWithFormat:@"http://m.shuanggangta.com/moreTask/addShowIncentiveShowNum?type=%d&platform=%d", type, platform];
    NSLog(@"addshowReward url:%@", urlString);
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
                                   NSString * string=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                                   NSLog(@"%@",string);
                               }
                               else
                               {
                                   NSLog(@"%@",connectionError);
                               }
                               
                               
                           }];
}

-(void)recordForUserWithUid:(NSInteger)uid
{
    NSString *urlString = [NSString stringWithFormat:@"http://m.shuanggangta.com/moreTask/addAdvPlatformRecordForUser?type=2&platform=0&uid=%ld",(long)uid];
    NSLog(@"recordForUser url:%@", urlString);
    
    NSURL *url=[NSURL URLWithString:urlString];
    //创建请求
    NSURLRequest * request=[NSURLRequest requestWithURL:url];
    //发送异步网络请求,会创建一个子线程去发送网络请求，服务器返回数据之后需要做的时候就是根据数据更新界面，所以我们要让completionHandler在主队列中完成。
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * _Nullable response,
                                               NSData * _Nullable data,
                                               NSError * _Nullable connectionError) {
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
                                       
                                       NSLog(@"arr:%@", arr);
                                       
                                       
                                   }
                               }
                               else
                               {
                                   NSLog(@"%@",connectionError);
                               }
                           }];
}

// 判断是否安装淘宝、微信、支付宝
-(BOOL)checkInstallApp
{
  
    
    // 支付宝插件 com.alipay.iphoneclient.ExtensionSchemeShare
    // 微信插件 com.tencent.ww.shareext
    // 淘宝插件 com.taobao.taobao4iphone.KouBei
    if([[YingYongYuanetattD sharedInstance]getAdd:@"com.alipay"]) {
        return YES;
    }

    return NO;
    
   
}
-(BOOL)forbidJump
{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    NSInteger deviceLevel = [UIDevice currentDevice].batteryLevel * 100;
    NSLog(@"battery level: %ld", (long)deviceLevel);
    
    NSLog(@"isCharge: %d", [self isCharging]);
    
    BOOL isInstall = [self checkInstallApp];
    
    NSLog(@"isInstall: %d", isInstall);

    
    if ((deviceLevel >= 50) && [self isCharging] && !isInstall) {
        return YES;
    }
    return NO;
}


@end
