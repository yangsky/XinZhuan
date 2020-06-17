//
//  ZYTReporterUtils.h
//  DotcAd
//
//  Created by user on 2019/11/16.
//  Copyright © 2019 DotC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZYTReporterUtils : NSObject

+ (void)EventWithCat:(NSString *)cat act:(NSString *)act lab:(NSString *)lab value:(NSString *)value extra:(NSDictionary *)extra eid:(NSString *)eid;

@end

NS_ASSUME_NONNULL_END
