//
//  YYYMusicTool.h
//  newYYY
//
//  Created by Mac on 16/7/30.
//  Copyright © 2016年 YYY. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YYYMusic;

@interface YYYMusicTool : NSObject


+ (NSArray *)musics;

+ (YYYMusic *)playingMusic;

+ (void)setPlayingMusic:(YYYMusic *)playingMusic;

+ (YYYMusic *)nextMusic;

+ (YYYMusic *)previousMusic;
@end
