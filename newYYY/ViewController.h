//
//  ViewController.h
//  newYYY
//
//  Created by Mac on 16/7/29.
//  Copyright © 2016年 YYY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDTSplashAd.h"

static NSString *kGDTMobSDKAppId = @"1105344611";

@interface ViewController : UIViewController <GDTSplashAdDelegate>

@property (strong, nonatomic) GDTSplashAd *splash;

@property (assign, nonatomic) BOOL isFirstLanuch;

@end

