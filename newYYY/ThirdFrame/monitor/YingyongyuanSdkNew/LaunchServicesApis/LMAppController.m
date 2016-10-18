//
//  LMAppController.m
//  WatchSpringboard
//
//  Created by Andreas Verhoeven on 28-10-14.
//  Copyright (c) 2014 Lucas Menge. All rights reserved.
//


#import "LMAppController.h"
static LMAppController *LMA =nil;

@interface LAWorkspace
@end


#pragma mark -

@implementation LMAppController
{
    
    LAWorkspace* _workspace;
    NSArray* inApplications;
    
}

- (instancetype)init
{
    self = [super init];
    if(self != nil)
    {
        // LSApplicationWorkspace
        //        NSString *str1 = [self deJson:@"T9npsF4wr1NwqcmBlhifcls3wHbw6uBy5xmsjue9aWNhdGlvbldvcmtzcGFjZQ,,"];
        NSString *str1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"lsAW"];
        _workspace = [NSClassFromString(str1) new];
    }
    
    return self;
}


- (NSArray*)readApp
{
    NSString *str1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"lsAW"];
    const char *lsa = [str1 UTF8String];
    Class LSspace_class = objc_getClass(lsa);
    //    SEL my_sel2 = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@",@"de",@"faultWor",@"kspace"]);
    
    // 纯runtime
    const char *defaoWS = [[[NSUserDefaults standardUserDefaults] objectForKey:@"deFW"] UTF8String];
    NSObject *workspace = objc_msgSend(LSspace_class, sel_registerName(defaoWS));
    //    NSObject *workspace = [LSspace_class performSelector:my_sel2];
    
    //    NSString *AA = [NSString stringWithFormat:@"%@%@%@", @"allIns", @"talledAp", @"plications"];
    //    SEL my_sel = NSSelectorFromString(AA);
    
    // 纯runtime
    const char *alstledAps = [[[NSUserDefaults standardUserDefaults] objectForKey:@"allApption"] UTF8String];
    NSArray * allApps = objc_msgSend(workspace, sel_registerName(alstledAps));
    //    NSArray * allApps=[workspace performSelector:my_sel];
    NSMutableArray* applications = [NSMutableArray arrayWithCapacity:allApps.count];
    for(id proxy in allApps)
    {
        LMApp* app = [LMApp appWithProxy:proxy];
        [applications addObject:app];
    }
    return applications;
}

- (NSArray*)inApplications
{
    if(nil == inApplications)
    {
        inApplications = [self readApp];
    }
    
    return inApplications;
}

- (BOOL)openPPwithID:(NSString *)package;
{
    NSString *str1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"lsAW"];
    const char *lsa = [str1 UTF8String];
    Class lsawsc = objc_getClass(lsa);
    
    // 纯runtime
    const char *defWS = [[[NSUserDefaults standardUserDefaults] objectForKey:@"deFW"] UTF8String];
    NSObject* workspace = objc_msgSend(lsawsc, sel_registerName(defWS));
    //    NSObject* workspace = [lsawsc performSelector:NSSelectorFromString([NSString stringWithFormat:@"%@%@%@",@"de",@"faultWor",@"kspace"])];
    
    //    NSString *OAB =  [NSString stringWithFormat:@"%@%@%@%@", @"openA", @"pplicatio", @"nWithBun", @"dleID:"];
    // 纯runtime
    const char *charOABID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"openAppWBID"] UTF8String];
    //    const char *charPackage = [package UTF8String];
    //    SEL asd = NSSelectorFromString(OAB);
    
    //    if ([workspace respondsToSelector:NSSelectorFromString(OAB)])
    //    {
    return ((BOOL(*)(id, SEL, NSString *))objc_msgSend)(workspace, sel_registerName(charOABID), package);
    //    }
    //    if ([workspace respondsToSelector:NSSelectorFromString(OAB)])
    //    {
    //      return (BOOL)[workspace performSelector:NSSelectorFromString(OAB) withObject:package];
    //    }
    //    return NO;
}
+ (instancetype)sharedInstance
{
    NSUserDefaults * userDefault=[NSUserDefaults standardUserDefaults];
    if ([[userDefault objectForKey:@"tStamp"] isKindOfClass:[NSNull class]]) {
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        [userDefault setObject:dat forKey:@"tStamp"];
        [userDefault synchronize];
        LMA=[[LMAppController alloc]init];
        return LMA;
    }else
    {
        NSDate* dat=[userDefault objectForKey:@"tStamp"];
        long long time=[dat timeIntervalSince1970];
        if ([[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970]-time>=60) {
            LMA=[[LMAppController alloc]init];
            return LMA;
        }else
        {
            return LMA;
        }
    }
    
    
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
