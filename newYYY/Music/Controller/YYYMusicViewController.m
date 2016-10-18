//
//  YYYMusicViewController.m
//  newYYY
//
//  Created by Mac on 16/7/30.
//  Copyright © 2016年 YYY. All rights reserved.
//

#import "YYYMusicViewController.h"
#import "Masonry.h"
#import "YYYMusicTool.h"
#import "YYYMusic.h"
#import "XMGAudioTool.h"
#import "CALayer+PauseAimate.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ViewController.h"

@interface YYYMusicViewController ()<UIScrollViewDelegate, AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *singerImage;

@property (weak, nonatomic) IBOutlet UILabel *songName;
@property (weak, nonatomic) IBOutlet UILabel *singerName;

/** 当前的播放器 */
@property (nonatomic, strong) AVAudioPlayer *currentPlayer;
/** 进度的Timer */
@property (nonatomic, strong) NSTimer *progressTimer;

// 滑块
@property (weak, nonatomic) IBOutlet UISlider *progressSlide;

// 播放停止按钮
@property (weak, nonatomic) IBOutlet UIButton *playOrPauseBtn;

@property (nonatomic, strong) ViewController *VC;

#pragma mark - 滑块的拖动
- (IBAction)startSlider;
- (IBAction)sliderValueChange;
- (IBAction)endSlider;

- (IBAction)sliderClick:(UITapGestureRecognizer *)sender;

@end

@implementation YYYMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1.毛玻璃背景
    [self setupBlurView];

    
    // 2.设置滑块的图片
    [self.progressSlide setThumbImage:[UIImage imageNamed:@"player_slider_playback_thumb"] forState:UIControlStateNormal];
    
    // 3.展示界面的信息
    [self startPlayingMusic];
    [self.currentPlayer pause];
    self.playOrPauseBtn.selected = NO;
    [self.singerImage.layer pauseAnimate];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToVC) name:@"toVC" object:nil];

}

- (void)goToVC
{
    // 跳转主界面
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        _VC = [[UIStoryboard storyboardWithName:@"ViewController" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        
        [self presentViewController:_VC animated:NO completion:nil];
    });
    
    
}

- (void)dealloc
{
    NSLog(@"-----music---dealloc----");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 顶部状态栏
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
#pragma mark - 三个控制按钮
- (IBAction)playOrPause {
    self.playOrPauseBtn.selected = !self.playOrPauseBtn.selected;
    
    if (self.currentPlayer.playing) {
        [self.currentPlayer pause];
        
        [self removeProgressTimer];
        
        
        // 暂停iconView的动画
        [self.singerImage.layer pauseAnimate];
    } else {
        [self.currentPlayer play];
        
        [self addProgressTimer];
        
        
        // 恢复iconView的动画
        [self.singerImage.layer resumeAnimate];
    }
}

- (IBAction)previous {
    
    // 1.取出上一首歌曲
    YYYMusic *previousMusic = [YYYMusicTool previousMusic];
    
    // 2.播放上一首歌曲
    [self playingMusicWithMusic:previousMusic];
}

- (IBAction)next {
    
    // 1.取出下一首歌曲
    YYYMusic *nextMusic = [YYYMusicTool nextMusic];
    
    // 2.播放下一首歌曲
    [self playingMusicWithMusic:nextMusic];
}

- (void)playingMusicWithMusic:(YYYMusic *)music
{
    // 1.停止当前歌曲
    YYYMusic *playingMusic = [YYYMusicTool playingMusic];
    [XMGAudioTool stopMusicWithMusicName:playingMusic.filename];
    
    // 3.播放歌曲
    [XMGAudioTool playMusicWithMusicName:music.filename];
    
    // 4.将工具类中的当前歌曲切换成播放的歌曲
    [YYYMusicTool setPlayingMusic:music];
    
    // 5.改变界面信息
    [self startPlayingMusic];
}
// 背景毛玻璃
- (void)setupBlurView
{
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    [toolBar setBarStyle:UIBarStyleBlack];
    [self.backgroundImage addSubview:toolBar];
    toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    [toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backgroundImage.mas_top);
        make.bottom.equalTo(self.backgroundImage.mas_bottom);
        make.left.equalTo(self.backgroundImage.mas_left);
        make.right.equalTo(self.backgroundImage.mas_right);
        
    }];
}

// 设置图片圆角
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // 设置iconView圆角
    self.singerImage.layer.cornerRadius = self.singerImage.bounds.size.width * 0.5;
    self.singerImage.layer.masksToBounds = YES;
    self.singerImage.layer.borderWidth = 8.0;
    self.singerImage.layer.borderColor = [UIColor colorWithRed:36/256.0 green:36/256.0 blue:36/256.0 alpha:1.0].CGColor;
}


#pragma mark - 播放歌曲
- (void)startPlayingMusic
{
    // 1.取出当前播放歌曲
    YYYMusic *playingMusic = [YYYMusicTool playingMusic];
    
    // 2.设置界面信息
    self.backgroundImage.image = [UIImage imageNamed:playingMusic.icon];
    ;
    self.singerImage.image = [UIImage imageNamed:playingMusic.icon];
    self.songName.text = playingMusic.name;
    self.singerName.text = playingMusic.singer;
    
    // 3.开始播放歌曲
    AVAudioPlayer *currentPlayer = [XMGAudioTool playMusicWithMusicName:playingMusic.filename];
    currentPlayer.delegate = self;
    self.currentPlayer = currentPlayer;
    self.playOrPauseBtn.selected = self.currentPlayer.isPlaying;
//    self.currentTimeLabel.text = [NSString stringWithTime:currentPlayer.currentTime];

//    self.playOrPauseBtn.selected = self.currentPlayer.isPlaying;
    
    // 播放动画
    [self startIconViewAnimate];
    
    // 6.添加定时器用户更新进度界面
    [self removeProgressTimer];
    [self addProgressTimer];

    [self setupLockScreenInfo];

}

- (void)startIconViewAnimate
{
    // 1.创建基本动画
    CABasicAnimation *rotateAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    // 2.设置基本动画属性
    rotateAnim.fromValue = @(0);
    rotateAnim.toValue = @(M_PI * 2);
    rotateAnim.repeatCount = NSIntegerMax;
    rotateAnim.duration = 40;
    
    // 3.添加动画到图层上
    [self.singerImage.layer addAnimation:rotateAnim forKey:nil];
}

#pragma mark - 对定时器的操作
- (void)addProgressTimer
{
    [self updateProgressInfo];
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressInfo) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
}

- (void)removeProgressTimer
{
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}

#pragma mark - 更新进度的界面
- (void)updateProgressInfo
{
    // 1.设置当前的播放时间
//    self.currentTimeLabel.text = [NSString stringWithTime:self.currentPlayer.currentTime];
    
    // 2.更新滑块的位置
    self.progressSlide.value = self.currentPlayer.currentTime / self.currentPlayer.duration;
}

#pragma mark - Slider的事件处理
- (IBAction)startSlider {
    [self removeProgressTimer];
}

- (IBAction)sliderValueChange {
}

- (IBAction)endSlider {
    // 1.设置歌曲的播放时间
    self.currentPlayer.currentTime = self.progressSlide.value * self.currentPlayer.duration;
    // 2.添加定时器
    [self addProgressTimer];
}

- (IBAction)sliderClick:(UITapGestureRecognizer *)sender {
    // 1.获取点击的位置
    CGPoint point = [sender locationInView:sender.view];
    // 2.获取点击的在slider长度中占据的比例
    CGFloat ratio = point.x / self.progressSlide.bounds.size.width;
    // 3.改变歌曲播放的时间
    self.currentPlayer.currentTime = ratio * self.currentPlayer.duration;
    // 4.更新进度信息
    [self updateProgressInfo];
}

#pragma mark - 设置锁屏界面的信息
- (void)setupLockScreenInfo
{
    // 0.获取当前正在播放的歌曲
    YYYMusic *playingMusic = [YYYMusicTool playingMusic];
    
    // 1.获取锁屏界面中心
    MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
    
    // 2.设置展示的信息
    NSMutableDictionary *playingInfo = [NSMutableDictionary dictionary];
    [playingInfo setObject:playingMusic.name forKey:MPMediaItemPropertyAlbumTitle];
    [playingInfo setObject:playingMusic.singer forKey:MPMediaItemPropertyArtist];
    MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:playingMusic.icon]];
    [playingInfo setObject:artWork forKey:MPMediaItemPropertyArtwork];
    [playingInfo setObject:@(self.currentPlayer.duration) forKey:MPMediaItemPropertyPlaybackDuration];
    
    playingInfoCenter.nowPlayingInfo = playingInfo;
    
    // 3.让应用程序可以接受远程事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}
// 监听远程事件
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
        case UIEventSubtypeRemoteControlPause:
            [self playOrPause];
            break;
            
        case UIEventSubtypeRemoteControlNextTrack:
            [self next];
            break;
            
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self previous];
            break;
            
        default:
            break;
    }
}


@end
