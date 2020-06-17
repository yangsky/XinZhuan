//
//  ZYTReportConfiguration.h
//  DCGReporter
//
//  Created by user on 2018/9/3.
//  Copyright © 2018年 DotC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYTReportConfiguration : NSObject

@property (nonatomic, copy) NSString *appid;              // AppId
@property (nonatomic, copy) NSString *encodeKey;          // 加密盐
@property (nonatomic, copy) NSString *decodeKey;          // 解密盐

@property (nonatomic, copy) NSString *serverUrl;          // 数据上报服务器的URL
@property (nonatomic, copy) NSString *appsFlyerKey;       // 设置 AppsFlyerKey ，如果需要则由接入方运营负责人统一申请
@property (nonatomic, copy) NSString *itunesId;           // AppsFlyerKey初始化需要上传
@property (nonatomic, copy) NSString *trafficId;          // 设置 应用的tid，由接入方运营负责人统一申请
@property (nonatomic, copy) NSString *installChannel;     // 设置 本次安装的包渠道
@property (nonatomic, copy) NSString *buglyAppId;         // 设置 BuglyAppId ，由接入方运营负责人统一申请

+ (ZYTReportConfiguration *)setConfigurationWithAppid:(NSString *)appid
                                            encodeKey:(NSString *)en
                                            decodeKey:(NSString *)de
                                            serverUrl:(NSString *)url
                                            trafficId:(NSString *)tr
                                       installChannel:(NSString *)is
                                         appsFlyerKey:(NSString *)fy
                                             itunesId:(NSString *)it
                                           buglyAppId:(NSString *)bg;

@end

