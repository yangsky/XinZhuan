//
//  Created by Steven Liang on 2019/3/14.
//  Copyright © 2019年 CMGame. All rights reserved.
//

#ifndef CMGameSDK_h
#define CMGameSDK_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "CMGameInfo.h"
#import "BUInfo.h"
#import "CMGameAppInfo.h"

@protocol CMGameDelegate <NSObject>
@optional
- (void)loadImage:(UIImageView *)imgView url:(NSString *)url placeHolder:(UIImage *)placeHolder;

- (void)didCMGameListReady:(NSUInteger)gameCount;

- (void)didCMGameClicked:(NSString *)gameId;

- (void)didCMGameExit:(NSString *)gameId;

- (void)didCMGameLoadFinish:(NSString *)gameId :(bool)isSuccess;
@end

@interface CMGameSDK : NSObject

typedef NS_ENUM(NSInteger, CMGameSDKStatusCode) {
    CMGameSDKStatusCodeSuccess = 0,//成功
    CMGameSDKStatusCodeGameNotFound = -1,//找不到游戏
    CMGameSDKStatusCodeAuthDeny = -2,//授权失败
};

/**
 设置游戏信息
 @appInfo 游戏信息，由猎豹分配
 */
+ (void)setAppInfo:(CMGameAppInfo *)info;

/**
 设置广告联盟ID
 */
+ (void)setBUInfo:(BUInfo *)info;

/**
 初始化SDK
 */
+ (void)init:(bool)isDebug;

/**
 申请用户鉴权信息（同步阻塞操作）
 */
+ (void)initCmGameAccount;

/**
 设置游戏代理
 @delegate
 */
+ (void)setDelegate:(id <CMGameDelegate>)delegate;

/**
 打开游戏界面
 @gameId 游戏标识符
 */
+ (CMGameSDKStatusCode)playGame:(NSString *)gameId;

+ (CMGameSDKStatusCode)playGame:(NSString *)gameId row:(short)row column:(short)column;

/**
 退出游戏界面，用于接入方自行实现 loading 界面时，在退出 loading 界面后通知游戏停止加载。
 @gameId 游戏标识符
 @return 是否成功退出（在游戏实例存在，并且 gameId 匹配时返回 YES）
 */
+ (bool)quitGame:(NSString *)gameId;

/**
 获取 SDK 当前的游戏列表
 */
+ (NSArray *)getGameList;

/**
 从 SDK 当前的游戏列表取得某游戏
 */
+ (CMGameInfo *)getGameInfo:(NSString *)gameId;

/**
 获取游戏滚动列表界面
 @frame 游戏列表屏幕矩形信息
 */
+ (UIScrollView *)getGameScrollView:(CGRect)frame;

/**
 获取游戏滚动列表（带分类）界面
 @frame 游戏列表屏幕矩形信息
 */
+ (UIScrollView *)getGameClassifyView:(CGRect)frame;

/**
 获取外部提供的 vc 来展示游戏的 WebView
 */
+ (void)putPresentViewController:(UIViewController *)vc;

/**
 获取当前 SDK 的版本号
 */
+ (NSString *)getVersion;

@end

#endif