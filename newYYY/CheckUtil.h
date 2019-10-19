//
//  CheckUtil.h
//  newYYY
//
//  Created by Yang Shengyuan on 2018/9/20.
//  Copyright © 2018年 YYY. All rights reserved.
//

#import <Foundation/Foundation.h>

enum PLATFORM {
    CHUANSHANJIA  = 0,        /**< 穿山甲    */
    GUANGDIANTONG = 1,        /**< 广点通    */
};

enum REWARDTYPE {
    REWARDVIEDO  = 0,        /**< 激励视频    */
    LANUCHSPLASH = 1,        /**< 启动时开屏    */
    BACKSPLASH = 2,          /**< 从后台唤起开屏    */
};

@interface CheckUtil : NSObject

+ (CheckUtil *)shareInstance;

- (BOOL)isJailBreak;

- (NSString *)iphoneType;

- (NSString *)getParamByName:(NSString *)name URLString:(NSString *)url;

- (BOOL)isVPNOn;

- (BOOL) isCharging;

- (BOOL) isSIMInstalled;

- (BOOL) connectedToNetwork;

- (NSString *) md5 : (NSString *) str;

//记录开屏/激励视频展现量
- (void) addShowRewardWithType:(NSInteger)type
                      platform:(NSInteger)platform;


@end
