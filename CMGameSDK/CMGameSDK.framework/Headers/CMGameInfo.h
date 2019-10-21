//
//  Created by Steven Liang on 2019/3/7.
//  Copyright © 2019年 CMGame. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMGameInfo : NSObject

@property(copy, nonatomic) NSString *gameName;
@property(copy, nonatomic) NSString *gameId;
@property(copy, nonatomic) NSString *gameUrl;
@property(copy, nonatomic) NSString *iconUrl;
@property(copy, nonatomic) NSString *iconUrlSquare;
@property(nonatomic) NSInteger playerNum;

-(instancetype)initWithDictionary:(NSDictionary *)dict;

@end