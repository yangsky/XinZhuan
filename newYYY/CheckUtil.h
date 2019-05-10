//
//  CheckUtil.h
//  newYYY
//
//  Created by Yang Shengyuan on 2018/9/20.
//  Copyright © 2018年 YYY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CheckUtil : NSObject

+ (CheckUtil *)shareInstance;

- (BOOL)isJailBreak;

- (NSString *)iphoneType;

- (NSString *)getParamByName:(NSString *)name URLString:(NSString *)url;

-(BOOL) connectedToNetwork;

@end
