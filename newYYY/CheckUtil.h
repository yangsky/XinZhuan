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
    ZHIYINGTONG = 2,          /**<智营通    */
};

enum REWARDTYPE {
    REWARDVIEDO  = 0,        /**< 激励视频    */
    LANUCHSPLASH = 1,        /**< 启动时开屏    */
    BACKSPLASH = 2,          /**< 从后台唤起开屏    */
    CMGAME = 3,              /**< 猎豹游戏    */
};

enum SlOTIDTYPE {
    
    SPLASH = 11,            // 11.开屏
    BSPLASH = 12,           // 12.后台开屏
    TASKREWARD = 13,        // 13.激励视频1 url包含 'taskList'
    PERSONALREWARD = 14,    // 14.激励视频2 url包含 'personal'
    WITHDRAWREWARD = 15,    // 15.激励视频3 url包含 'withdraw'
};

@interface CheckUtil : NSObject

+ (CheckUtil *)shareInstance;

- (BOOL)isJailBreak;

- (NSString *)iphoneType;

- (NSString *)getParamByName:(NSString *)name URLString:(NSString *)url;

- (BOOL)isVPNOn;

- (BOOL) isCharging;

- (BOOL) isSIMInstalled;

- (int)SimCardNumInPhone;


- (BOOL) connectedToNetwork;

- (NSString *) md5 : (NSString *) str;

//记录开屏/激励视频展现量
- (void) addShowRewardWithType:(NSInteger)type
                      platform:(NSInteger)platform;

//记录结束观看次数
-(void)recordForUserWithUid:(NSInteger)uid;

// 判断是否安装淘宝、微信、支付宝
-(BOOL)checkInstallApp;

-(BOOL)forbidJump;
@end
