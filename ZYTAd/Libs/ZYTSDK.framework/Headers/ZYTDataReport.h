//
//  ZYTDataReport.h
//  GoGoBuy
//
//  Created by QianGuoqiang on 16/10/14.
//  Copyright © 2016年 GoGoBuy. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZYTReportConfiguration.h"

@interface ZYTDataReport : NSObject

/* 初始化SDK */
+ (void)startWithConfiguration:(ZYTReportConfiguration *)configuration;

+ (void)isGDPRApplicable:(BOOL)GDPRApplicable;

/* 更多配置 */


/**
 设置上报间隔 默认为180s

 @param interval 上报时间间隔
 */
+ (void)setReportInterval:(NSTimeInterval)interval; // default is 180s

/**
 设置设备地理位置

 @param lati lati
 @param longi longi
 */
+ (void)setLati:(NSString *)lati longi:(NSString *)longi;


+ (void)setDebug:(BOOL)debug;

+ (BOOL)debugEnable;

+ (void)setAdsAppId:(NSString *)appId;


// 文档接口
+ (void)sendDailyActive;
+ (void)sendRealActive;

/* 用户事件 */
+ (void)trackEventWithCategory:(NSString *)cat
                        action:(NSString *)act
                         label:(NSString *)lab
                         value:(NSString *)val;

+ (void)eventWithCat:(NSString *)cat
                 act:(NSString *)act
                 lab:(NSString *)lab
               extra:(NSDictionary *)extra
                 eid:(NSString *)eid;

+ (void)eventWithCat:(NSString *)cat
                 act:(NSString *)act
                 lab:(NSString *)lab
                 val:(NSString *)val
               extra:(NSDictionary *)extra
                 eid:(NSString *)eid;


/* 页面事件 */
+ (void)pageBeginWithName:(NSString *)pageName ext:(NSDictionary *)ext;
+ (void)pageEndWithName:(NSString *)pageName;

/* 设置用户属性 */
+ (void)setPropertyWithName:(NSString *)name value:(NSString *)value;
+ (void)setPropertysWithDictionary:(NSDictionary<NSString *, NSString *> *)dictionary;

/**
 *  发送特定内容到指定服务器
 *
 *  @param content    要发送的内容
 *  @param url        服务器URL
 *  @param completion 发送成功时的回调
 */
+ (void)sendContent:(id)content toURL:(NSURL *)url completion:(void (^)(void))completion;


+ (void)afEnentWithAction:(NSString *)act
               installDic:(NSDictionary *)dic;

+ (NSString *)deviceID;     // 设备唯一标示
+ (NSString *)bid;          // 用户A/B Test标识
+ (NSString *)idfa;
+ (NSString *)deviceModel; // 机型

@end
