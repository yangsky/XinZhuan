//
//  AppDelegate.h
//  newYYY
//
//  Created by Mac on 16/7/29.
//  Copyright © 2016年 YYY. All rights reserved.
//

#import <UIKit/UIKit.h>

//#define BUAdID @"5097378"
//#define bUAdSplashID @"887368651"
//#define bUAdRewardVideoID @"945390857"

//#define BUAdID @"5024719"
//#define bUAdSplashID @"887383161"
//#define bUAdRewardVideoID @"945494922"

#define BUAdID @"5108853"
#define bUAdSplashID @"887386138"
#define bUAdRewardVideoID @"945514854"

#define BUD_Log(frmt, ...)   \
do {                                                      \
NSLog(@"【BUAdDemo】%@", [NSString stringWithFormat:frmt,##__VA_ARGS__]);  \
} while(0)

// 极光
static NSString *appKey = @"73aa1fa64c266d785f90be9b";

static NSString *channel = @"Publish channel";

static BOOL isProduction = YES;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

