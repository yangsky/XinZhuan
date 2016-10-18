//
//  YYYMusicTool.m
//  newYYY
//
//  Created by Mac on 16/7/30.
//  Copyright © 2016年 YYY. All rights reserved.
//

#import "YYYMusicTool.h"
#import "YYYMusic.h"
#import "MJExtension.h"

@implementation YYYMusicTool

static NSArray *_musics;
static YYYMusic *_playingMusic;

+ (void)initialize
{
   
    if (_musics == nil) {
        _musics = [YYYMusic objectArrayWithFilename:@"Musics.plist"];
    }
    
    if (_playingMusic == nil) {
        _playingMusic = _musics[0];
    }
}

+ (NSArray *)musics
{
    return _musics;
}


+ (YYYMusic *)playingMusic
{
    return _playingMusic;
}

+ (void)setPlayingMusic:(YYYMusic *)playingMusic
{
    _playingMusic = playingMusic;
}


+ (YYYMusic *)nextMusic
{
    // 1.拿到当前播放歌词下标值
    NSInteger currentIndex = [_musics indexOfObject:_playingMusic];
    
    // 2.取出下一首
    NSInteger nextIndex = ++currentIndex;
    if (nextIndex >= _musics.count) {
        nextIndex = 0;
    }
    YYYMusic *nextMusic = _musics[nextIndex];
    
    return nextMusic;
}

+ (YYYMusic *)previousMusic
{
    // 1.拿到当前播放歌词下标值
    NSInteger currentIndex = [_musics indexOfObject:_playingMusic];
    
    // 2.取出下一首
    NSInteger previousIndex = --currentIndex;
    if (previousIndex < 0) {
        previousIndex = _musics.count - 1;
    }
    YYYMusic *previousMusic = _musics[previousIndex];
    
    return previousMusic;
}

@end
