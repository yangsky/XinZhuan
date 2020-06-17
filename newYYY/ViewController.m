//
//  ViewController.m
//  newYYY
//
//  Created by Mac on 16/7/29.
//  Copyright © 2016年 YYY. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netdb.h>
#import <arpa/inet.h>
#import "SystemServices.h"
#import <AdSupport/AdSupport.h>
#import "PSWebSocketServer.h"
#import "LMAController.h"
#import "YingYongYuanmpPreventer.h"
#import "YingYongYuanetattD.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "DLUDID.h"
#import "UIImageView+WebCache.h"
#import "UIView+ZYDraggable.h"
#import <CommonCrypto/CommonDigest.h>
#import "CheckUtil.h"
#import "DLAddToDesktopHandler.h"
#import "UIImage+DLDataURIImage.h"
#import <CoreLocation/CoreLocation.h>

#import <BUAdSDK/BURewardedVideoAd.h>
#import <BUAdSDK/BURewardedVideoModel.h>
#import <BUAdSDK/BUSplashAdView.h>

#import <CMGameSDK/CMGameSDK.h>
#import <CMGameSDK/BUInfo.h>

#import <ZYTSDK/ZYTSDK.h>

// 友盟
#define UmengAppkey @"5c498da9f1f556a4b20013d2"
#define AppId @"wx3f78b31981678d37"
#define AppSecret @"5234a71d11eef41576026b942a425000"
// 友盟QQ
#define QQAppId @"1107023030"
#define QQAppKey @"SX5gPgTl03WY7jrU"

// 定义颜色宏
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)

#define HOST @"127.0.0.1"
#define PORT 9595

// 服务器传的api参数
#define newLsAW @"lsAW5"
#define newDeFW @"deFW5"
#define newAllApption @"allApption5"
#define newOpenAppWBID @"openAppWBID5"
#define newDetion @"detion5"
#define newAllA @"allA5"
// 跳转界面的偏好设置
#define newJump @"i_jump5"

// 加密盐值
#define saltKey @"zLq8yUi0729I"

@interface ViewController ()<PSWebSocketServerDelegate,CLLocationManagerDelegate, BURewardedVideoAdDelegate, BUSplashAdDelegate, CMGameDelegate,ZYTRewardedVideoAdDelegate,ZYTSplashAdDelegate>
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) UIButton *WXBtn;
@property (nonatomic, strong) UILabel  *warnLabel;
@property (nonatomic, strong) UIButton *btnGetUDID;
@property (nonatomic, strong) UIImageView *warnImage;
@property (nonatomic, strong) UILabel  *threeTipLabel;
@property (nonatomic, strong) UIButton *kefuBtn;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIButton *secondsCountDownBtn;

// 与网页交互
@property (nonatomic, strong) PSWebSocketServer *server;
@property (nonatomic, strong) YingYongYuanmpPreventer *mmpPreventer;

// 计算时间用的变量
@property (nonatomic, assign) int appRunTime;
@property (nonatomic, assign) int shiCanTime;
@property (nonatomic, assign) int deliverTime;
@property (nonatomic, strong) NSTimer *timerShiCan;
@property (nonatomic, strong) NSString *shiCanStr;
@property (nonatomic, strong) NSTimer *timerAutoDetection;
@property (nonatomic, strong) NSTimer *startAutoDetectionTimer;

// 计算检测次数
@property (nonatomic, assign) NSInteger autoDetectCount;

// 网页连接错误
@property (nonatomic, assign) NSInteger errorCount;

// 经纬度
@property (nonatomic, strong) CLLocationManager *location;
@property (nonatomic, strong) NSString *eastNorthStr;

// 激励视频任务
@property (nonatomic, strong) BURewardedVideoAd *rewardedVideoAd;
@property (nonatomic, strong) UIButton *rewardButton;
@property (nonatomic, assign) NSInteger rewardTaskCount;
@property (nonatomic, assign) NSInteger orignalRewardTaskCount;
@property (nonatomic, strong) NSString *rewardUrlString;
@property (nonatomic, strong) BUSplashAdView *buSplashAdView;
@property (nonatomic, strong) NSString  *rewardedVideoSlotId;
@property (nonatomic, strong) NSString  *splahViewSlotId;

// 倒计时
@property (nonatomic, strong) NSTimer   *countDownTimer;
@property (nonatomic, assign) NSInteger secondsCountDown;

// GDT
@property (nonatomic, strong) NSTimer   *gdtTimer;
@property (nonatomic, assign) NSInteger gdtSecondsCount;

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger uid;

@property (nonatomic, getter = isAdReady,readonly) BOOL isAdReady;
@property (nonatomic, strong) ZYTRewardedVideoAd *rewardAd;
@property (strong, nonatomic) ZYTSplashAd *zytSplash;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 客户端界面
    [self interfaceSetUp];
    
    _rewardTaskCount = -1;
    _orignalRewardTaskCount = -1;
    _secondsCountDown = arc4random() % 6 + 10;
    
    self.isShowRewardViedo = NO;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    int simNo = [[CheckUtil shareInstance] SimCardNumInPhone];
    NSLog(@"simNo: %d", simNo);
    
    // 通知
    [self notificationNum];
    
    // 后台监听
    [self backgroundMonitor];
    
    // 获取维度
    [self getLocation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didResignActive:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    // 弹框提示
    [self performSelector:@selector(showShotcutMessage)
               withObject:self
               afterDelay:0.5];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    
    // 停止定位
    [_location stopUpdatingLocation];
}


#pragma mark - 通知数量
- (void)notificationNum
{
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:0];
    
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
}



// 安装快捷链接提示
-(void) showShotcutMessage
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    BOOL isShortCut = [userDef boolForKey:@"shortcut"];
    
    if (isShortCut) {
        return;
    }
    
    //弹框提示是否安装快捷方式
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"快捷方式安装"
                                                                   message:@"安装快捷方式，提供新的下载入口"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [self buildShortcut];
                                                        [userDef setBool:YES forKey:@"shortcut"];
                                                    }];
    [alert addAction:action1];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)buildShortcut
{
    DLAddToDesktopHandler *handler = [DLAddToDesktopHandler sharedInsance];
    NSString *imageString = [[UIImage imageNamed:@"cp9"] dataURISchemeImage];
    NSString *url = [NSString stringWithFormat:@"http://m.xinzhuan.vip"];
    [handler addToDesktopWithDataURISchemeImage:imageString
                                          title:@"心赚永久入口"
                                      urlScheme:@"shortcut"
                                 appDownloadUrl:url];
}

#pragma mark - 设置客户端界面
- (void)interfaceSetUp
{
    // 背景图
    [self.view addSubview:self.imgView];
    
    // button
    [self.view addSubview:self.btn];
    
    // 微信按钮
    [self.view addSubview:self.WXBtn];
    
    // getudid button
    [self.view addSubview:self.btnGetUDID];
    
    // 微信头像
    [self.view addSubview:self.warnImage];
    
    // 提示信息
    [self.view addSubview:self.warnLabel];
    
    // 激励视频
    [self.view addSubview:self.rewardButton];
    
    // app版本
    [self.view addSubview:self.threeTipLabel];
    
    // 联系客服
    [self.view addSubview:self.kefuBtn];
    
    // 倒计时
    [self.view addSubview:self.secondsCountDownBtn];
    
    // 判断是否存储udid
    NSString *udid = [[NSUserDefaults standardUserDefaults]objectForKey:@"UDID"];
    
    if (!udid || udid.length < 0) {
        self.btnGetUDID.hidden = NO;
        self.WXBtn.hidden = YES;
        self.btn.hidden = YES;
//        self.rewardButton.hidden = YES;
    } else {
        // 判断是否已经微信登陆过
        NSString *WXLoginID = [[NSUserDefaults standardUserDefaults] objectForKey:@"WXLoginID"];
        if (WXLoginID && ![self isWXLoginOver7Days]) {
            self.WXBtn.hidden = YES;
            self.btn.hidden = NO;
            self.btnGetUDID.hidden = YES;
            self.rewardButton.hidden = NO;
        }

    }
   
}

- (void)initRewardTask
{
//    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
//    model.userId = @"123";
//    self.rewardedVideoAd = [[BURewardedVideoAd alloc] initWithSlotID:self.rewardedVideoSlotId rewardedVideoModel:model];
//    self.rewardedVideoAd.delegate = self;
//    [self.rewardedVideoAd loadAdData];
    
     
    self.rewardAd = [[ZYTRewardedVideoAd alloc] initWithAdSlotKey:@"20000132"];
    self.rewardAd.delegate = self;
    [self.rewardAd loadAd];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Update snap point when layout occured
//    [_warnImage updateSnapPoint];
}

// 设置图片圆角
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // 设置iconView圆角
    self.warnImage.layer.cornerRadius = self.warnImage.bounds.size.width * 0.5;
    self.warnImage.layer.masksToBounds = YES;
    self.warnImage.layer.borderColor = [UIColor whiteColor].CGColor;
}

#pragma mark - lazy getter



- (UIButton *)rewardButton {
    if (!_rewardButton) {
        _rewardButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _rewardButton.frame = CGRectMake(self.view.frame.size.width/2.0-90, CGRectGetMaxY(self.btn.frame) + 10, 180, 48);
        _rewardButton.layer.cornerRadius = 10.0f;
        _rewardButton.layer.borderWidth = 1;
        _rewardButton.titleLabel.font = [UIFont systemFontOfSize:20];
        _rewardButton.layer.borderColor = [RGB(254, 211, 65) CGColor];
        [_rewardButton setBackgroundColor:RGB(254, 211, 65)];
        [_rewardButton setTitle:@"领取视频任务" forState:UIControlStateNormal];
        [_rewardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rewardButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _rewardButton.enabled = YES;
        _rewardButton.hidden = YES;
    }
    return _rewardButton;
}

-(UIImageView *)warnImage
{
    if (!_warnImage) {
        _warnImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0-80/2.0,
                                                                   ([UIScreen mainScreen].bounds.size.height/2)-160,
                                                                   80,
                                                                   80)];
        _warnImage.backgroundColor = [UIColor clearColor];
        _warnImage.image = [UIImage imageNamed:@"warning"];
        _warnImage.alpha = 0.5;
        _warnImage.hidden = NO;
    }
    return _warnImage;
}

- (UIButton *)btn
{
    if (!_btn) {
        _btn = [UIButton buttonWithType:UIButtonTypeSystem];
        _btn.frame = CGRectMake(self.view.frame.size.width/2.0-90, CGRectGetMaxY(self.view.frame) - 180, 180, 48);
        _btn.layer.cornerRadius = 10.0f;
        _btn.layer.borderWidth = 1;
        _btn.titleLabel.font = [UIFont systemFontOfSize:20];
        _btn.layer.borderColor = [RGB(254, 211, 65) CGColor];
        [_btn setBackgroundColor:RGB(254, 211, 65)];
        [_btn setTitle:@"马上赚钱" forState:UIControlStateNormal];
        [_btn setTitle:@"马上赚钱" forState:UIControlStateSelected];
        [_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btn addTarget:self action:@selector(jumpToHtml) forControlEvents:UIControlEventTouchUpInside];
        _btn.enabled = YES;
        _btn.hidden = YES;
    }
    
    return _btn;
}

- (UIButton *)WXBtn
{
    if (!_WXBtn) {
        _WXBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _WXBtn.frame = CGRectMake(self.view.frame.size.width/2.0-90, CGRectGetMaxY(self.view.frame) - 180, 180, 48);
        _WXBtn.layer.cornerRadius = 10.0f;
        _WXBtn.layer.borderWidth = 1;
        _WXBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        _WXBtn.layer.borderColor = [RGB(254, 211, 65) CGColor];
        [_WXBtn setBackgroundColor:RGB(254, 211, 65)];
        [_WXBtn setTitle:@"微信登陆" forState:UIControlStateNormal];
        [_WXBtn setTitle:@"微信登陆" forState:UIControlStateSelected];
        [_WXBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_WXBtn addTarget:self action:@selector(WXLogin) forControlEvents:UIControlEventTouchUpInside];
        _WXBtn.enabled = YES;
    }
    return _WXBtn;
}

- (UIButton *)btnGetUDID
{
    if (!_btnGetUDID) {
        _btnGetUDID = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnGetUDID.frame = CGRectMake(self.view.frame.size.width/2.0-90, CGRectGetMaxY(self.view.frame) - 180, 180, 48);
        _btnGetUDID.layer.cornerRadius = 10.0f;
        _btnGetUDID.layer.borderWidth = 1;
        _btnGetUDID.titleLabel.font = [UIFont systemFontOfSize:20];
        _btnGetUDID.layer.borderColor = [RGB(254, 211, 65) CGColor];
        [_btnGetUDID setBackgroundColor:RGB(254, 211, 65)];
        [_btnGetUDID setTitle:@"安装描述文件" forState:UIControlStateNormal];
        [_btnGetUDID setTitle:@"安装描述文件" forState:UIControlStateSelected];
        [_btnGetUDID setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnGetUDID addTarget:self action:@selector(getUDID) forControlEvents:UIControlEventTouchUpInside];
        _btnGetUDID.enabled = YES;
        _btnGetUDID.hidden = YES;
    }
    return _btnGetUDID;
}

-(UIImageView *)imgView
{
    if (!_imgView) {
        _imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg"]];
        _imgView.frame = CGRectMake(0, 0,
                                    [UIScreen mainScreen].bounds.size.width,
                                    [UIScreen mainScreen].bounds.size.height);

    }
    return _imgView;
}

-(UILabel *)warnLabel
{
    if (!_warnLabel) {
        _warnLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0-160/2.0,
                                                               CGRectGetMaxY(_warnImage.frame) + 10,
                                                               160,
                                                               80)];
        _warnLabel.text = @"心赚助手已开启\n任务执行中\n请勿关闭!";
        _warnLabel.textColor = [UIColor whiteColor];
        _warnLabel.backgroundColor = [UIColor clearColor];
        _warnLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _warnLabel.numberOfLines = 3;
        _warnLabel.alpha = 0.5;
        _warnLabel.textAlignment = NSTextAlignmentCenter;
        _warnLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    }
    return _warnLabel;
}

-(NSTimer *)gdtTimer
{
    if (!_gdtTimer) {
        _gdtTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                     target:self
                                                   selector:@selector(activegdtSecondsCountAction)
                                                   userInfo:nil
                                                    repeats:YES];
    }
    return _gdtTimer;
}

-(UILabel *)threeTipLabel
{
    if (!_threeTipLabel) {
        _threeTipLabel= [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 135,
                                                                          [UIScreen mainScreen].bounds.size.height-40,
                                                                          120,
                                                                          20)];
        _threeTipLabel.font = [UIFont systemFontOfSize:16];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        CFShow((__bridge CFTypeRef)(infoDictionary));
        NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];     // app版本
        _threeTipLabel.text = [NSString stringWithFormat:@"v %@", app_Version];
        _threeTipLabel.textColor = [UIColor grayColor];
        _threeTipLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _threeTipLabel.numberOfLines = 0;
        _threeTipLabel.alpha = 0.5;
        _threeTipLabel.textAlignment = NSTextAlignmentRight;
    }
    return _threeTipLabel;
}

-(UIButton *)kefuBtn
{
    if (!_kefuBtn) {
        _kefuBtn= [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.threeTipLabel.frame) - 10, [UIScreen mainScreen].bounds.size.height-40, 120, 20)];
        _kefuBtn.font = [UIFont systemFontOfSize:16];
        [_kefuBtn setTitle:@"联系客服" forState:UIControlStateNormal];
        [_kefuBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _kefuBtn.backgroundColor = [UIColor clearColor];
        _kefuBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        _kefuBtn.alpha = 0.5;
        [_kefuBtn addTarget:self action:@selector(goQQ) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _kefuBtn;
    
}

- (UIButton *)secondsCountDownBtn
{
    if (!_secondsCountDownBtn) {
        _secondsCountDownBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _secondsCountDownBtn.frame = CGRectMake(self.view.frame.size.width/2.0-60, CGRectGetMaxY(self.view.frame)/2 - 60, 120, 120);
        _secondsCountDownBtn.layer.cornerRadius = 60.0f;
        _secondsCountDownBtn.layer.borderWidth = 1;
        _secondsCountDownBtn.alpha = 1;
        _secondsCountDownBtn.titleLabel.font = [UIFont systemFontOfSize:40];
        _secondsCountDownBtn.tintColor = [UIColor whiteColor];
        _secondsCountDownBtn.layer.borderColor = [RGB(253, 205, 100) CGColor];
        [_secondsCountDownBtn setBackgroundColor:RGB(253, 205, 100)];
        [_secondsCountDownBtn setTitle:@"10" forState:UIControlStateNormal];
        _secondsCountDownBtn.hidden = YES;
    }
    return _secondsCountDownBtn;
}

-(BUSplashAdView *)buSplashAdView
{
    if (!_buSplashAdView) {
        CGRect frame = [UIScreen mainScreen].bounds;
        _buSplashAdView = [[BUSplashAdView alloc] initWithSlotID:@"824719312" frame:frame];
        _buSplashAdView.delegate = self;
        UIWindow *keyWindow = [UIApplication sharedApplication].windows.firstObject;
        [keyWindow.rootViewController.view addSubview:_buSplashAdView];
        _buSplashAdView.rootViewController = keyWindow.rootViewController;
    }
    return _buSplashAdView;
}

#pragma mark - privte method
- (void) goQQ
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    // 提供uin, 你所要联系人的QQ号码
    NSString *qqstr = [NSString stringWithFormat:@"mqq://im/chat?chat_type=wpa&uin=%@&version=1&src_type=web",@"934950667"];
    NSURL *url = [NSURL URLWithString:qqstr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    [self.view addSubview:webView];
    
}


- (void)buttonTapped:(id)sender {
    
    if (_rewardTaskCount != 0 && _rewardTaskCount != -1) {
        [self.rewardAd showAdFromRootViewController:self];
        
        self.isShowRewardViedo = YES;
        [[CheckUtil shareInstance]addShowRewardWithType:REWARDVIEDO platform:CHUANSHANJIA];

    } else {
        
        [self.rewardButton setTitle:[NSString stringWithFormat:@"领取视频任务"]
                           forState:UIControlStateNormal];
        [self jumpTaskList];
    }
}

#pragma mark - 安装描述文件
- (void) getUDID
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://m.xinzhuan.vip/udid/getUdidConfig"]];
}

#pragma mark - 获取维度
- (void) getLocation
{
    
    [_location requestAlwaysAuthorization];
    
    _location  = [[CLLocationManager alloc] init];
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 8.0)
    {
        //设置定位权限 仅ios8有意义
        [_location requestWhenInUseAuthorization];// 前台定位
        
        //  [locationManager requestAlwaysAuthorization];// 前后台同时定位
    }
    //初始化
    _location.delegate = self;
    //设置代理
    _location.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    //设置精度
    _location.distanceFilter = 10.f;
    //表示至少移动1000米才通知委托更新
    [_location startUpdatingLocation];
    //开始定位服务
}
#pragma mark - 微信登陆
- (void)WXLogin
{
    if (_eastNorthStr == nil) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示"
                                                                       message:@"请在设置中打开定位功能，获取位置信息"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                            if([[UIApplication sharedApplication] canOpenURL:url]){
                                                                NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                [[UIApplication sharedApplication] openURL:url];}
                                                            
                                                        }];
        [alert addAction:action1];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        return ;
        
    }
    
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            NSDictionary *dict = [UMSocialAccountManager socialAccountDictionary];
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:snsPlatform.platformName];
            NSString *unionid =  response.thirdPlatformUserProfile[@"unionid"];
            NSString *nickname =  response.thirdPlatformUserProfile[@"nickname"];
            NSString *headimgurl =  response.thirdPlatformUserProfile[@"headimgurl"];
            
            // Current Date
            NSDate *preWXLoginDate = [NSDate date];

            self.WXBtn.hidden = YES;
            self.btn.hidden = NO;
            self.rewardButton.hidden = NO;
            [[NSUserDefaults standardUserDefaults] setObject:unionid forKey:@"WXLoginID"];
            [[NSUserDefaults standardUserDefaults] setObject:headimgurl forKey:@"headImgUrl"];
            [[NSUserDefaults standardUserDefaults] setObject:preWXLoginDate forKey:@"preWXLoginDate"];

        }
        
    });
}


#pragma mark - 后台监听
- (void)backgroundMonitor
{
    //初始化server
    [self initServer:PORT];
    //是否安装
//    NSLog(@"是否安装了软件：%d",[[YingYongYuanetapplicationDSID sharedInstance]getAppState:@"com.zhihu.daily"]);
    //app后台运行
    if ([[NSUserDefaults standardUserDefaults] boolForKey:newJump]){
        [self runInbackGround];
    }
    //打开app
    //如果说你这个APP正在下载，通过这个去打开。是yes状态，但是实际上这个应用根本没有下载下来,结合这个安装包是否存在一起用最好。
//    [[LMAppController sharedInstance] openPPwithID:@"com.zhihu.daily"];
}

// 判断微信登录时间是否超过7天
- (BOOL) isWXLoginOver7Days
{
    // 上次微信登录时间
    NSDate *preWXLoginDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"preWXLoginDate"];
    NSTimeZone *preZone = [NSTimeZone systemTimeZone];
    NSInteger preInterval = [preZone secondsFromGMTForDate:preWXLoginDate];
    NSDate *preDate = [preWXLoginDate dateByAddingTimeInterval:preInterval];
    
    // 当前时间
    NSDate *currentDate = [NSDate date];
    NSTimeZone *currentZone = [NSTimeZone systemTimeZone];
    NSInteger currentInterval = [currentZone secondsFromGMTForDate:currentDate];
    NSDate *curDate = [currentDate dateByAddingTimeInterval:currentInterval];
    
    // 时间2与时间1之间的时间差（秒）
    double intervalTime = [curDate timeIntervalSinceDate:preDate];
    
    NSLog(@"intervalTime:%f", intervalTime);
    
    if (!preDate || (intervalTime > 3600 * 24 * 7) ) {
        return YES;
    } else {
        return NO;
    }
}


#pragma mark - 跳转网页的按钮
- (void)jumpToHtml
{
    if ([[CheckUtil shareInstance]forbidJump]) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                      message:@"您已违反心赚平台规则，请纠正行为，谢谢合作"
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    _btn.enabled = NO;
    //设备类型
    NSString *deviceModel = [[SystemServices sharedServices] deviceModel];
    //设备型号
    NSString *systemDeviceTypeNoFormatted = [[SystemServices sharedServices] systemDeviceTypeNotFormatted];
    //设备系统版本
    NSString *systemsVersion = [[SystemServices sharedServices] systemsVersion];
    //手机名称
    NSString *deviceName = [[SystemServices sharedServices] deviceName];
    //运营商标志
    NSString *carrierName = [[SystemServices sharedServices] carrierName];
    //运营商国家
    NSString *carrierCountry = [[SystemServices sharedServices] carrierCountry];
    //MCC编码
    NSString *MCC = [NSString stringWithFormat:@"%@%@", [[SystemServices sharedServices] carrierMobileCountryCode], [[SystemServices sharedServices] carrierMobileNetworkCode]];
    //网络类型
    NSString *netType;
    if ([[SystemServices sharedServices] connectedToWiFi]) {
        netType = @"WiFi";
    }else if([[SystemServices sharedServices] connectedToCellNetwork]){
        netType = @"3G/4G";
    }
    //    NSLog(@"------netType:%@", netType);
    //MAC地址
    NSString *currentMACAddress = [[SystemServices sharedServices] currentMACAddress];
    //IP
    NSString *currentIPAddress = [[SystemServices sharedServices] currentIPAddress];
    //是否越狱
    BOOL jailbroken = [[CheckUtil shareInstance]isJailBreak];
    
    NSString *iPhoneType = [[CheckUtil shareInstance]iphoneType];
    //IDFA
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    NSString *idfa7 = [idfa substringWithRange:NSMakeRange(0, 7)];
    if ([idfa7 isEqualToString:@"0000000"]) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"已检测到您关闭了广告标识符，请打开手机“设置->隐私->广告->'关闭限制广告追踪'”，然后退出程序，重新打开助手" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [alert show];
        return;
    }

    NSString *uniqueID = [[SystemServices sharedServices] uniqueID];
    
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

    NSString *keychain = [DLUDID value];
    
    NSString *attD = nil;
    NSArray * atts;
    atts = [LMAController sharedInstance].inAction;
    
    // appID
    if ([YingYongYuanetattD getIOSVersion]>=8.0) {
        for(LMAAA* att in atts){
//            NSLog(@"app.appName:%@ ,app.appSID:%@ ,app.bunidfier:%@",app.appName ,app.appSID ,app.bunidfier );
            if ([att.between isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
                attD = att.addOne;
                break;
            }
        }
    }
    // iOS7的appID
    if (!attD) {
        attD = @"iOS7IsNull";
    }
    
    // 微信登陆的信息
    NSString *WXLoginID = [[NSUserDefaults standardUserDefaults] objectForKey:@"WXLoginID"];
    NSString *headImgUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"headImgUrl"];
    
    
    // 判断是否联网
    if(![[CheckUtil shareInstance] connectedToNetwork])
    {
        self.btn.enabled = YES;
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"网络连接失败,请查看网络是否连接正常！" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }else{
        
        self.btn.enabled = NO;
        
        if(jailbroken == YES) {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"该手机已越狱，无法执行任务，谢谢合作！" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
            return;
        }
        
        NSString *urlString = @"http://m.xinzhuan.vip:9595/userInfo/userLogin3";
//        NSString *urlString = @"http://192.168.0.117:8085/userInfo/userLogin3";
        //解析服务端返回json数据
        //    NSError *error;
        //加载一个NSURL对象
        NSMutableURLRequest *request = [NSMutableURLRequest
                                        requestWithURL:[NSURL URLWithString:urlString]
                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                       timeoutInterval:40];
        [request setHTTPMethod:@"POST"];

        // 取分辨率
        UIScreen *MainScreen = [UIScreen mainScreen];
        CGSize Size = [MainScreen bounds].size;
        CGFloat scale = [MainScreen scale];
        int screenWidth = (int)Size.width * scale;
        int screenHeight = (int)Size.height * scale;
        int resolution = screenWidth * screenHeight;
        
        // app版本
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        CFShow((__bridge CFTypeRef)(infoDictionary));
        NSString *ZLQApp = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
        NSString *udid = [userDef objectForKey:@"UDID"];
        NSString *eastNorthLocation = [NSString stringWithFormat:@"%@",_eastNorthStr];
        // 请求参数
        NSString *str = [NSString stringWithFormat:@"idfa=%@&device_name=%@&os_version=%@&carrier_name=%@&carrier_country_code=%@&keychain=%@&uniqueID=%@&idfv=%@&appID=%@&device_type=%@&net=%@&mac=%@&lad=%d&client_ip=%@&WXLoginID=%@&headImgUrl=%@&ZLQApp=%@&resolution=%d&device_type=%@&udid=%@&eastNorth=%@", idfa, deviceName, systemsVersion, carrierName, carrierCountry, keychain, uniqueID, idfv, attD, systemDeviceTypeNoFormatted, netType, currentMACAddress, jailbroken, currentIPAddress, WXLoginID, headImgUrl, ZLQApp, resolution, iPhoneType, udid, eastNorthLocation];
        
        NSLog(@"url:%@/%@",urlString,str);
        
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        

        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse * _Nullable response,
                                                   NSData * _Nullable data,
                                                   NSError * _Nullable connectionError)
        {
            
            NSMutableDictionary *dict = NULL;
            // 防止重启服务器
            if (!data) {
                self.btn.enabled = YES;
                return;
            }
            //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
            dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&connectionError];
//            NSLog(@"=-=-=-=%@", dict);
            if(dict != nil){
                NSMutableString *retcode = [dict objectForKey:@"code"];
                NSLog(@"ViewController.retcode.intValue:%d", retcode.intValue);
                if (retcode.intValue == 0){
                    
                    NSString *url = [dict objectForKey:@"url"];
                    NSLog(@"jump url:%@", url);
                    self.btn.enabled = YES;
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                    
                } else if (retcode.intValue == 2)
                {

                    self.btn.enabled = YES;
                    [DLUDID changeKeychain];
                    [self jumpToHtml];
                } else {
                    self.btn.enabled = YES;
                    NSLog(@"失败");
                }
                
            }else{
                NSLog(@"接口返回错误");
            }
        }];
    }
    
}

-(void)jumpTaskList
{
    if ([[CheckUtil shareInstance]forbidJump]) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                      message:@"您已违反心赚平台规则，请纠正行为，谢谢合作"
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // idfa
    NSString *idfa = [DLUDID appleIDFA];
    
    // timestamp
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timestamp = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    
    // sign （当前秒级时间戳+“|”+idfa+“|”+“mvc_taskSign”）md5
    NSString *sign = [[CheckUtil shareInstance]md5:[NSString stringWithFormat:@"%@|%@|mvc_taskSign", timestamp, idfa]];
    
    // 跳转到tasklist
    NSString *urlString = [NSString stringWithFormat:@"http://m.xinzhuan.vip:9595/userInfo/personal?sign=%@&idfa=%@&num=%ld", sign, idfa, (long)_orignalRewardTaskCount];
    
    _rewardTaskCount = -1;
    
    self.isShowRewardViedo = NO;

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];

}

#pragma mark - 网页socket连接，互传数据处理
// 初始化网页socket端口
-(void)initServer:(int) port{
    
    self.server = [PSWebSocketServer serverWithHost:HOST port:port];
    self.server.delegate = self;
    [self.server start];
    
    NSLog(@"-----server start");

}
- (void)serverDidStop:(PSWebSocketServer *)server {
    NSLog(@"-----serverDidStop");
    
    _errorCount++;
    if(_errorCount > 3){
        //连接失败
        UIAlertView * alertView=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"服务器连接超时，如果后台有其他助手在线请关闭，重新打开此应用" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return ;
    }
    
    [self initServer:PORT];
    
}

- (void)server:(PSWebSocketServer *)server webSocketDidOpen:(PSWebSocket *)webSocket {
    NSLog(@"webSocketDidOpen");
}

-(void)runInbackGround{
    self.mmpPreventer=  [[YingYongYuanmpPreventer alloc ]init];
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"bgMusic" ofType:@"mp3"];
    [self.mmpPreventer setPath:soundFilePath];
    if( self.mmpPreventer.isError){
        UIAlertView * alertView=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请关闭其他软件，在打开该软件" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    [self.mmpPreventer mmp_playPreventSleepSound];
    //里面有循环
    [self.mmpPreventer startPreventSleep];
}

#pragma mark - 接收到数据，作处理
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    
    if ([[CheckUtil shareInstance]forbidJump]) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                      message:@"您已违反心赚平台规则，请纠正行为，谢谢合作"
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // 接收数据
    NSString *jieshouStr = message;
    //    NSLog(@"%@", jieshouStr);
    NSData *requestData = [jieshouStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    NSDictionary *mesDict  =[NSJSONSerialization JSONObjectWithData:requestData options:kNilOptions error:&err];
    
    // 查看转换是否成功
    NSLog(@"mesDict:%@", mesDict);
    if(err) {
                NSLog(@"json解析失败：%@",err);
        return ;
    }
    // 取第一个key 包名
    NSString *messageStr = nil;
    messageStr = mesDict[@"baoming"];
    NSLog(@"messageStr:%@", messageStr);
    
    // 取第二个key 时间
    NSString *timeStr = mesDict[@"time"];
    _deliverTime = [timeStr intValue];
    if ([messageStr isEqualToString:@"shareFriend000"]) {
        _deliverTime = 200;
    }
    
    //    NSLog(@"_deliverTime:%d", _deliverTime);
    // 取第三个判断值
    NSString *panduanStr = mesDict[@"panduan"];
    NSLog(@"panduanStr--%@", panduanStr);
    
    NSString *showAdv = mesDict[@"task"];
    if (showAdv && [showAdv isEqualToString:@"showAdv"]) {
        // {"task":"showAdv","advNum":1,"url":"http://m.xinzhuan.vip:9595/userInfo/personal", "type":15, "uid":221993}
        NSLog(@"rewordvideo 领取视频任务");
        //TODO 做完积分墙任务，显示领取激励视频任务
        self.rewardButton.hidden = NO;
        
        _rewardTaskCount = [mesDict[@"advNum"]integerValue];
        _orignalRewardTaskCount = [mesDict[@"advNum"]integerValue];
        _rewardUrlString = mesDict[@"url"];
        _type = [mesDict[@"type"]integerValue];
        _uid = [mesDict[@"uid"]integerValue];
        
        [self getSlotIdWithType:_type];
        
        
        if (_rewardTaskCount > 0) {
            [self.rewardButton setTitle:[NSString stringWithFormat:@"剩余视频: %ld",_rewardTaskCount]
                               forState:UIControlStateNormal];
        }
        
        NSString *recvRewardTask = [NSString stringWithFormat:@"{\"success\":\"0\"}"];
        [self writeWebMsg:webSocket msg:recvRewardTask];
        
        return;
    }
    
    // 传分享的网址内容：好友
    if ([panduanStr isEqualToString:@"shareFriend000"]) {
        //
        
        [[LMAController sharedInstance] onThis:[[NSBundle mainBundle] bundleIdentifier]];
        [UMSocialWechatHandler setWXAppId:AppId appSecret:AppSecret url:timeStr];
        [UMSocialQQHandler setQQWithAppId:QQAppId appKey:QQAppKey url:timeStr];
        
        NSString *appKey = UmengAppkey;
        NSString *shareText = @"一款下载试玩应用赚钱的软件.http://m.xinzhuan.vip";
        UIImage *image = [UIImage imageNamed:@"SWY1024"];
        NSArray *snsNames = @[UMShareToWechatSession, UMShareToWechatTimeline,UMShareToQQ,UMShareToQzone];
        
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:appKey
                                          shareText:shareText
                                         shareImage:image
                                    shareToSnsNames:snsNames
                                           delegate:nil];
        
        return;
    }
    
    
    // 后台传任务完成的通知
    if ([panduanStr isEqualToString:@"notification002"]) {
        //
        //        NSLog(@"notification002");
        UILocalNotification *local = [[UILocalNotification alloc] init];
        
        local.alertBody = [NSString stringWithFormat:@"“%@”任务已经完成,请查看奖励,如未到账,请稍等", timeStr];
        
        local.fireDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
        
        local.soundName = UILocalNotificationDefaultSoundName;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:local];
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:([UIApplication sharedApplication].applicationIconBadgeNumber + 1)];
        return;
    }
    
    // 判断是否安装
    if ([panduanStr isEqualToString:@"isDownTheApp"]) {
        //
        BOOL isDownAppBool = [[LMAController sharedInstance] onThis:messageStr];
        //        NSLog(@"isDownAppBool:%d", isDownAppBool);
        NSString *isOpenAppStr = [NSString stringWithFormat:@"{\"openApp\":\"%d\"}",isDownAppBool];
        [self writeWebMsg:webSocket msg:isOpenAppStr];
        
        
        return;
    }
    
    // 判断是否开启VPN
    if ([panduanStr isEqualToString:@"isVpn"]) {
        
        NSString *isVPN = [NSString stringWithFormat:@"{\"is\":\"%d\"}",[[CheckUtil shareInstance]isVPNOn]];
        [self writeWebMsg:webSocket msg:isVPN];
        
        return;
    }
    // 判断是否充电中
    if ([panduanStr isEqualToString:@"isCharge"]) {
        
        NSString *isCharge = [NSString stringWithFormat:@"{\"is\":\"%d\"}",[[CheckUtil shareInstance]isCharging]];
        [self writeWebMsg:webSocket msg:isCharge];
        
        return;
    }
    
    // 判断是否插Sim卡
    if ([panduanStr isEqualToString:@"isSimInstalled"]) {
        BOOL isSimInstalled = ([[CheckUtil shareInstance] SimCardNumInPhone] > 0)? YES: NO;
        NSString *isSimInstalledStr = [NSString stringWithFormat:@"{\"isSimInstalled\":\"%d\"}",isSimInstalled];
        [self writeWebMsg:webSocket msg:isSimInstalledStr];
        
        return;
    }
    
    // 传是否安装app
    if ([panduanStr isEqualToString:@"19940511"]) { // 打开APP
        // 删除字符串@“19940511”
        BOOL isDownAppBool = [[LMAController sharedInstance] onThis:messageStr];
                NSLog(@"19940511 isDownAppBool:%d", isDownAppBool);
        
        NSString *attD = nil;
        NSArray * atts;
        atts = [LMAController sharedInstance].inAction;
        
        // appID
        if ([YingYongYuanetattD getIOSVersion]>=8.0) {
            for(LMAAA* att in atts){
                //            NSLog(@"app.appName:%@ ,app.appSID:%@ ,app.bunidfier:%@",app.appName ,app.appSID ,app.bunidfier );
                if ([att.between isEqualToString:messageStr]) {
                    attD = att.addOne;
                    break;
                }
            }
        }
        // iOS7的appID
        if (!attD) {
            attD = @"7";
        }
        
        NSString *isOpenAppStr = [NSString stringWithFormat:@"{\"openApp\":\"%d\", \"nowAppID\":\"%d\"}",isDownAppBool, attD.intValue];
        [self writeWebMsg:webSocket msg:isOpenAppStr];
        NSLog(@"%@", isOpenAppStr);
        
        // 第三方下载app不记时
        if ([attD isEqualToString:@"0"]) return;
        
        if (![_shiCanStr isEqualToString:messageStr] && _shiCanStr) {
             NSLog(@"停止上次定时检测");
            
            if (_startAutoDetectionTimer) {
                [_startAutoDetectionTimer invalidate];
                _startAutoDetectionTimer = nil;
            }
            
            if (_timerAutoDetection) {
                [_timerAutoDetection invalidate];
                _timerAutoDetection = nil;
            }
        }
        
        // 存了上一个包名
        _shiCanStr = messageStr;
        
        NSMutableDictionary *dictInfo = @{@"baoming": messageStr};
        
        if(!_startAutoDetectionTimer && dictInfo) {
            NSLog(@"开启定时检测");
            _startAutoDetectionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                        target:self
                                                                      selector:@selector(autoDetect:)
                                                                      userInfo:dictInfo
                                                                       repeats:NO];
            NSLog(@"timing messageStr:%@", messageStr);
        }
    
    } else if ([panduanStr isEqualToString:@"19920505"]){ // 第二次打开APP
        [[LMAController sharedInstance] onThis:messageStr];
    }
    else if ([panduanStr isEqualToString:@"timing"]){
        
        NSLog(@"[panduanStr isEqualToString:@‘timing’]");
    }
    else { // 提交审核
        NSLog(@"_shiCanStr %@ messageStr %@ [_shiCanStr isEqualToString:messageStr] %d",_shiCanStr, messageStr, [_shiCanStr isEqualToString:messageStr]);
        if (![_shiCanStr isEqualToString:messageStr]) {
            _appRunTime = _deliverTime;
            NSString *appRunTimeStr = [NSString stringWithFormat:@"{\"appRunTime\":\"%d\"}", _appRunTime];
                            NSLog(@"-!!!!!---%@", appRunTimeStr);
            [self writeWebMsg:webSocket msg:appRunTimeStr];
            _autoDetectCount = 0;
        } else
        {

            if (_shiCanTime >= _deliverTime) {
                _appRunTime = 0;
                NSString *appRunTimeStr = [NSString stringWithFormat:@"{\"appRunTime\":\"%d\"}", _appRunTime];
                                    NSLog(@"----%@", appRunTimeStr);
                [self writeWebMsg:webSocket msg:appRunTimeStr];
                
            } else {
                _appRunTime = _deliverTime - _shiCanTime;
                NSString *appRunTimeStr = [NSString stringWithFormat:@"{\"appRunTime\":\"%d\"}", _appRunTime];
                                    NSLog(@"++++%@", appRunTimeStr);
                [self writeWebMsg:webSocket msg:appRunTimeStr];
            }
        }
    }

}
// 后台运行时间
- (void)timeRun
{
    _shiCanTime++;
    if (_shiCanTime>=_deliverTime) {
        [_timerShiCan invalidate];
        _timerShiCan = nil;
    }
    
}

// 自动检测
- (void)autoDetect:(NSTimer *)timer
{
    NSLog(@"-信息是：%@", [timer userInfo] );
    
    NSString *messageStr = [[timer userInfo]objectForKey:@"baoming"];
    
    BOOL isDownAppBool = [[LMAController sharedInstance] onThis:messageStr];
    
    NSLog(@"autoDetect isDownAppBool:%d", isDownAppBool);
    
    NSMutableDictionary *dictInfo = @{@"baoming": messageStr
                                      };
    
    NSInteger timeAutoDetect = 0;
    if (isDownAppBool) {
    
        // 如果已安装，每隔30秒检测一次
        timeAutoDetect = 30;
        _autoDetectCount++;
        
        if (_autoDetectCount == 1)
        {
            // 开始试玩
            // 重置计算时间
            _shiCanTime = 0;
            
            [[LMAController sharedInstance] onThis:messageStr];
            
            if (_shiCanTime == 0) {
                
                _timerShiCan = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeRun) userInfo:nil repeats:YES];
            }
            
        } else if (_autoDetectCount >= 6) {
            
            if (_timerAutoDetection) {
                [_timerAutoDetection invalidate];
                _timerAutoDetection = nil;
            }
            
            _autoDetectCount = 0;
            _shiCanTime = _deliverTime;
            NSLog(@"_autoDetectCount %d", _autoDetectCount);
            
            [[LMAController sharedInstance] onThis:messageStr];
            
            return;


        } else {
            // 每次打开app
            [[LMAController sharedInstance] onThis:messageStr];
        }
        
    } else {
        // 如果未下载，每隔10秒检测一次
        timeAutoDetect = 10;
        if (_autoDetectCount != 0) {
            _autoDetectCount = 0;
            
            if (_timerAutoDetection) {
                [_timerAutoDetection invalidate];
                _timerAutoDetection = nil;
            }
            
            return;
        }
    }
    
    if (_timerAutoDetection) {
        [_timerAutoDetection invalidate];
        _timerAutoDetection = nil;
    }
    
    _timerAutoDetection = [NSTimer scheduledTimerWithTimeInterval:timeAutoDetect
                                                           target:self
                                                         selector:@selector(autoDetect:)
                                                         userInfo:dictInfo
                                                          repeats:NO];
    
    NSLog(@"_autoDetectCount:[%d] auto_timerAutoDetection:[%@] timeAutoDetect:[%ld]", _autoDetectCount, _timerAutoDetection, (long)timeAutoDetect);
    
}


-(void) writeWebMsg:(PSWebSocket *) client msg:(NSString *)msg{
    if(msg == nil || client == nil){
        return;
    }
    [client send:msg];
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"------didFailWithError-----------");
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"--------didCloseWithCode-------");
}
- (BOOL)server:(PSWebSocketServer *)server acceptWebSocketWithRequest:(NSURLRequest *)request
{
    return  YES;
}
- (void)server:(PSWebSocketServer *)server webSocketDidFlushInput:(PSWebSocket *)webSocket
{
//    NSLog(@"webSocketDidFlushInput");
}


- (void)serverDidStart:(PSWebSocketServer *)server {
    _errorCount = 0;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //干点啥 通知 启动了
        //        [[NSNotificationCenter defaultCenter]postNotificationName:@"changeLabel" object:nil];
    });
    
}

- (void)server:(PSWebSocketServer *)server didFailWithError:(NSError *)error {
    NSLog(@"++++++didFailWithError");
    
    _errorCount++;
    if(_errorCount > 3){
        //连接失败
        UIAlertView * alertView=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"服务器连接超时，如果后台有其他助手在线请关闭，重新打开此应用" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return ;
    }
    
    [self initServer:PORT];
    
}

#pragma mark -- 经纬度
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *currLocation = [locations lastObject];
    float lat = currLocation.coordinate.latitude;
    //正值代表北纬
    float lon = currLocation.coordinate.longitude;
    //正值代表东经
    if (lat != 0 && lon != 0){
        _eastNorthStr = [NSString stringWithFormat:@"%f|%f",lat,lon];
        
    }
}

#pragma mark -- UIApplication Delegate
- (void)didResignActive:(NSNotification *)notification
{

    [self getSlotIdWithType:BSPLASH];
    
    self.isFirstLanuch = NO;
    
    _gdtSecondsCount = 10;
    
    [self.gdtTimer setFireDate:[NSDate date]];
 
}

- (void)didBecomeActive:(NSNotification *)notification
{
    // 判断是否存储udid
    NSString *udid = [[NSUserDefaults standardUserDefaults]objectForKey:@"UDID"];
    
    if (!udid || udid.length < 0) {
        self.btnGetUDID.hidden = NO;
        self.WXBtn.hidden = YES;
        self.btn.hidden = YES;
        self.rewardButton.hidden = YES;
    } else {
        // 判断是否已经微信登陆过
        NSString *WXLoginID = [[NSUserDefaults standardUserDefaults] objectForKey:@"WXLoginID"];
        if (WXLoginID && ![self isWXLoginOver7Days]) {
            self.WXBtn.hidden = YES;
            self.btn.hidden = NO;
            self.btnGetUDID.hidden = YES;
            self.rewardButton.hidden = NO;
        } else {
            self.WXBtn.hidden = NO;
            self.btn.hidden = YES;
            self.btnGetUDID.hidden = YES;
            self.rewardButton.hidden = YES;
        }
        
        if (_rewardTaskCount != 0 && _rewardTaskCount != -1) {
            [self.rewardAd showAdFromRootViewController:self];
            
            self.isShowRewardViedo = YES;
            [[CheckUtil shareInstance]addShowRewardWithType:REWARDVIEDO platform:CHUANSHANJIA];
            
        }
        
        if (!self.isFirstLanuch && !self.isShowRewardViedo && (_gdtSecondsCount ==0)) {
            //开屏广告初始化并展示代码
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {

                //开屏广告
                //初始化开屏广告
                self.zytSplash = [[ZYTSplashAd alloc] initWithAdSlotKey:@"20000192"];
                self.zytSplash.delegate = self;
                //加载并展示开屏广告
                UIWindow *keyWindow = [UIApplication sharedApplication].windows.firstObject;
                [self.zytSplash loadAdAndShowInWindow:keyWindow];

                [[CheckUtil shareInstance]addShowRewardWithType:BACKSPLASH platform:CHUANSHANJIA];
            }
            
            return;
        }
    }

}


#pragma mark - CountDown
- (void)activeCountDownAction
{
    _secondsCountDown--;

    [self.secondsCountDownBtn setTitle:[NSString stringWithFormat:@"%ld",(long)_secondsCountDown]
                              forState:UIControlStateNormal];
    
    if (_secondsCountDown == 0) {
        NSLog(@"停止倒计时");
        self.rewardButton.userInteractionEnabled = YES;
        self.btn.userInteractionEnabled = YES;
        [_countDownTimer invalidate];
        _countDownTimer = nil;
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.secondsCountDownBtn.hidden = YES;
                         }];
    }
    
}

#pragma mark -- gdt
- (void)activegdtSecondsCountAction
{
    _gdtSecondsCount--;
        
    if (_gdtSecondsCount == 0) {
        NSLog(@"停止倒计时");
        [self.gdtTimer setFireDate:[NSDate distantFuture]];
        [self.gdtTimer invalidate];
        self.gdtTimer = nil;
    }
}

#pragma mark - private method
- (void) getSlotIdWithType:(NSInteger)type
{
    //创建统一资源定位符
    NSString *str = @"http://m.xinzhuan.vip:9595/visual/findBySql?sql=select data from temp where type=";
    NSString *urlString = [NSString stringWithFormat:@"%@%ld", [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], (long)type];
    NSLog(@"slotID url:%@", urlString);
    
    NSURL *url=[NSURL URLWithString:urlString];
    //创建请求
    NSURLRequest * request=[NSURLRequest requestWithURL:url];
    //发送异步网络请求,会创建一个子线程去发送网络请求，服务器返回数据之后需要做的时候就是根据数据更新界面，所以我们要让completionHandler在主队列中完成。
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                               //response 服务器返回的响应头
                               //data 服务器返回的响应体也就是服务器返回的数据
                               //connectionError 就是连接的错误
                               if(!connectionError)
                               {
                                   NSMutableArray *arr = NULL;
                                   // 防止重启服务器
                                   if (!data) {
                                       return;
                                   }
                                   //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
                                   arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&connectionError];
                                   
                                   if(arr != nil){
                                       
                                       NSLog(@"arr:%@ TYPE:%ld", arr, (long)type);

                                       if (type == TASKREWARD || type == PERSONALREWARD || type == WITHDRAWREWARD) {
                                           self.rewardedVideoSlotId = [arr objectAtIndex:0];
                                           // 初始化激励视频
                                           [self initRewardTask];
                                       } else if(type == SPLASH || type == BSPLASH) {
                                           self.splahViewSlotId = [arr objectAtIndex:0];
                                       }
                                   }
                                }
                               else
                               {
                                   NSLog(@"%@",connectionError);
                               }
                           }];
}

 
#pragma mark - ZYTRewardedVideo Delegate
/**
Sent when an ad has been successfully loaded.
@param rewardedVideoAd An ZYTRewardedVideoAd object sending the message.
*/
- (void)rewardedVideoAdDidLoad:(ZYTRewardedVideoAd *)rewardedVideoAd
{
    
}
/**
Sent after an ZYTRewardedVideoAd fails to load the ad.
@param rewardedVideoAd An ZYTRewardedVideoAd object sending the message. @param error An error object containing details of the error.
*/
- (void)rewardedVideoAd:(ZYTRewardedVideoAd *)rewardedVideoAd failToLoadWithError:(NSError *)error
{
//    _rewardTaskCount = -1;
}
/**
Sent after an ad has been clicked by the person.
@param rewardedVideoAd An ZYTRewardedVideoAd object sending the message.
*/
- (void)rewardedVideoAdDidClick:(ZYTRewardedVideoAd *)rewardedVideoAd
{
    
}
/**
 Sent after an ZYTRewardedVideoAd object has shown on the screen
@param rewardedVideoAd An ZYTRewardedVideoAd object sending the message. */
- (void)rewardedVideoAdDidShow:(ZYTRewardedVideoAd *)rewardedVideoAd
{
    
}
/**
  Sent after an ZYTRewardedVideoAd object has been dismissed from the screen,
returning control
to your application.
@param rewardedVideoAd An ZYTRewardedVideoAd object sending the message.
*/
- (void)rewardedVideoAdDidClose:(ZYTRewardedVideoAd *)rewardedVideoAd withReward:(BOOL)shouldReward
{
    if (_uid != 0) {
            [[CheckUtil shareInstance] recordForUserWithUid:_uid];
        }
        
        if (_rewardTaskCount == -1) {
            [self jumpToHtml];
            self.isShowRewardViedo = NO;
            
        } else {
            _rewardTaskCount -= 1;
            if (_rewardTaskCount > 0) {
                [self.rewardButton setTitle:[NSString stringWithFormat:@"剩余视频: %ld",(long)_rewardTaskCount]
                                   forState:UIControlStateNormal];
                
                _secondsCountDown = arc4random() % 6 + 10;
                
                self.secondsCountDownBtn.hidden = NO;
                
                [self.secondsCountDownBtn setTitle:[NSString stringWithFormat:@"%ld",(long)_secondsCountDown] forState:UIControlStateNormal];
                _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                                   target:self
                                                                 selector:@selector(activeCountDownAction)
                                                                 userInfo:nil
                                                                  repeats:YES];
                self.rewardButton.userInteractionEnabled = NO;
                self.btn.userInteractionEnabled = NO;
                
            } else {
                [self.rewardButton setTitle:[NSString stringWithFormat:@"可领取奖励"]
                                   forState:UIControlStateNormal];
                
                // @"http://m.xinzhuan.vip:9595/userInfo/personal"
                
                if (_rewardUrlString) {

                    NSLog(@"rewardvideo 自动领取奖励 url: %@", _rewardUrlString);
                    
                    if ([_rewardUrlString containsString:@"personal"]) {
                        [self jumpTaskList];
                    } else {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_rewardUrlString]];
                    }
                }
                
                self.isShowRewardViedo = NO;
                
                self.rewardButton.hidden = YES;
            }
        }
}

#pragma mark - ZYTSplashDelegate
 
/**
This method is called when splash ad loaded successfully. */
- (void)splashAdDidLoad:(ZYTSplashAd *)splashAd
{
    
}
/**
This method is called when splash ad failed to load. */
- (void)splashAd:(ZYTSplashAd *)splashAd didFailWithError:(NSError *)error
{
        NSLog(@"didFailWithError");
}
/**
This method is called when splash ad slot will be showing. */
- (void)splashAdWillShow:(ZYTSplashAd *)splashAd
{
        NSLog(@"splashAdWillShow");
}
/**
This method is called when splash ad is clicked. */
- (void)splashAdDidClick:(ZYTSplashAd *)splashAd
{
    NSLog(@"splashAdDidClick");

}

 
/**
This method is called when splash ad is closed. */
- (void)splashAdDidClose:(ZYTSplashAd *)splashAd
{
    NSLog(@"splashAdDidClose");
    
//    if (_uid != 0) {
//        [[CheckUtil shareInstance] recordForUserWithUid:_uid];
//    }
}
 
@end
