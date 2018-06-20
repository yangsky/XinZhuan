//
//  GetapplicationDSID.m
//  微加钥匙
//
//  Created by 云冯 on 16/2/22.
//  Copyright © 2016年 冯云. All rights reserved.
//
#import "YingYongYuanetattD.h"
#import "LMAController.h"

// 服务器传的api参数
#define newLsAW @"lsAW5"
#define newDeFW @"deFW5"
#define newAllApption @"allApption5"
#define newOpenAppWBID @"openAppWBID5"
#define newDetion @"detion5"
#define newAllA @"allA5"
// 跳转界面的偏好设置
#define newJump @"i_jump5"


@implementation YingYongYuanetattD
-(int) getAdd:(NSString *) package
{
    
    NSArray * atts;
    if ([YingYongYuanetattD getIOSVersion]>=8.0) {
        atts = [LMAController sharedInstance].inAction;
        if(package.length!=0){
            for(LMAAA* att in atts){
                if ([att.between isEqualToString:package]) {
                    return 1;
                }
            }
        }
    }else
    {

        NSString *str1 = [[NSUserDefaults standardUserDefaults] objectForKey:newLsAW];
        const char *str2 = [str1 UTF8String];
        
        Class LSspace_class = objc_getClass(str2);

        
        // 纯runtime
        const char *defWS = [[[NSUserDefaults standardUserDefaults] objectForKey:newDeFW] UTF8String];
        NSObject* WKSP = objc_msgSend(LSspace_class, sel_registerName(defWS));

        const char *alAption = [[[NSUserDefaults standardUserDefaults] objectForKey:newAllA] UTF8String];
        NSArray * resArray = objc_msgSend(WKSP, sel_registerName(alAption));
        
        
        for (LSspace_class in resArray) {
            const char *dededes = [[[NSUserDefaults standardUserDefaults] objectForKey:newDetion] UTF8String];
            NSString *appName = objc_msgSend(LSspace_class, sel_registerName(dededes));

            if ([appName rangeOfString:package].location!=NSNotFound)
            {
                return 1;
            }
        }
    }
    return 0;
}
+ (float)getIOSVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}
+(YingYongYuanetattD *)sharedInstance{
    static dispatch_once_t onceToken;
    static YingYongYuanetattD * attd;
    dispatch_once(&onceToken, ^{
        attd=[[YingYongYuanetattD alloc]init];
    });
    return attd;
}


-(NSString *) deJson:(NSString *) string{
    NSString * base64 = @"";
    for (int i = 0; i<[string length]; i++) {
        //截取字符串中的每一个字符
        NSString *s = [string substringWithRange:NSMakeRange(i, 1)];
        if((i>=1 && i<=4) || (i>=6 && i<=9)||  (i>=11 && i<=14) ||  (i>=16 && i<=19) ||  (i>=21 && i<=24) ||  (i>=26 && i<=29)  ||  (i>=31 && i<=34)  ||  (i>=36 && i<=39)){
            continue;
        }
        base64 =  [base64 stringByAppendingString:s];
    }
    //YingYongYuanjStringUtil.h
    base64 = [self replace:base64 reg:@"-" target:@"+"];
    base64 = [self replace:base64 reg:@"_" target:@"/"];
    base64 = [self replace:base64 reg:@"," target:@"="];
    
    
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64 options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    
    return decodedString;
    
}

-(NSString *) replace:(NSString *) str reg:(NSString *) reg target:(NSString *) targetStr{
    NSString *strUrl = [str stringByReplacingOccurrencesOfString:reg withString:targetStr];
    return  strUrl;
    
}
@end
