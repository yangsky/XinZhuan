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

@interface ViewController ()<PSWebSocketServerDelegate>
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) UIButton *WXBtn;
@property (nonatomic, strong) UILabel *warnLabel;
@property (nonatomic, strong) UIButton *btnGetUDID;

@property (nonatomic, strong) UIImageView *warnImage;

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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 通知
    [self notificationNum];
    // 客户端界面
    [self interfaceSetUp];
    // 后台监听
    [self backgroundMonitor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    // 弹框提示
    [self performSelector:@selector(showShotcutMessage) withObject:self afterDelay:0.5];

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
    UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg"]];
    imgView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.view addSubview:imgView];
    
    // button
    _btn = [UIButton buttonWithType:UIButtonTypeSystem];
    _btn.frame = CGRectMake(self.view.frame.size.width/2.0-90, CGRectGetMaxY(self.view.frame) - 180, 180, 54);
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
    [self.view addSubview:_btn];
    
    // 微信按钮
    _WXBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _WXBtn.frame = CGRectMake(self.view.frame.size.width/2.0-90, CGRectGetMaxY(self.view.frame) - 180, 180, 54);
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
    [self.view addSubview:_WXBtn];
    
    // button
    _btnGetUDID = [UIButton buttonWithType:UIButtonTypeSystem];
    _btnGetUDID.frame = CGRectMake(self.view.frame.size.width/2.0-90, CGRectGetMaxY(self.view.frame) - 180, 180, 54);
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
    [self.view addSubview:_btnGetUDID];
    
    // 微信头像
    _warnImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0-80/2.0,
                                                               ([UIScreen mainScreen].bounds.size.height/2)-160,
                                                               80,
                                                               80)];
    _warnImage.backgroundColor = [UIColor clearColor];
    _warnImage.image = [UIImage imageNamed:@"warning"];
    _warnImage.alpha = 0.5;
    _warnImage.hidden = NO;
    [self.view addSubview:_warnImage];
    
    // 提示信息
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
    [self.view addSubview:_warnLabel];
    
    
    // 判断是否存储udid
    NSString *udid = [[NSUserDefaults standardUserDefaults]objectForKey:@"UDID"];
    
    if (!udid || udid.length < 0) {
        _btnGetUDID.hidden = NO;
        _WXBtn.hidden = YES;
        _btn.hidden = YES;
    } else {
        // 判断是否已经微信登陆过
        NSString *WXLoginID = [[NSUserDefaults standardUserDefaults] objectForKey:@"WXLoginID"];
        if (WXLoginID && ![self isWXLoginOver7Days]) {
            _WXBtn.hidden = YES;
            _btn.hidden = NO;
            _btnGetUDID.hidden = YES;
        }

    }
 
    
    // app版本
    UILabel *threeTipLabel= [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 135,
                                                                      [UIScreen mainScreen].bounds.size.height-40,
                                                                      120,
                                                                      20)];
    threeTipLabel.font = [UIFont systemFontOfSize:16];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    CFShow((__bridge CFTypeRef)(infoDictionary));
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];     // app版本
    threeTipLabel.text = [NSString stringWithFormat:@"v %@", app_Version];
    threeTipLabel.textColor = [UIColor grayColor];
    threeTipLabel.lineBreakMode = NSLineBreakByCharWrapping;
    threeTipLabel.numberOfLines = 0;
    threeTipLabel.alpha = 0.5;
    threeTipLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:threeTipLabel];
    
    // 联系客服
    UIButton *kefuBtn= [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(threeTipLabel.frame) - 10, [UIScreen mainScreen].bounds.size.height-40, 120, 20)];
    kefuBtn.font = [UIFont systemFontOfSize:16];
    [kefuBtn setTitle:@"联系客服" forState:UIControlStateNormal];
    [kefuBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    kefuBtn.backgroundColor = [UIColor clearColor];
    kefuBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    kefuBtn.alpha = 0.5;
    [kefuBtn addTarget:self action:@selector(goQQ) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:kefuBtn];
    
   
}

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

#pragma mark - 安装描述文件
- (void) getUDID
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://m.xinzhuan.vip/udid/getUdidConfig"]];
}

#pragma mark - 微信登陆
- (void)WXLogin
{
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

            _WXBtn.hidden = YES;
            _btn.hidden = NO;
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
//    BOOL jailbroken = [[SystemServices sharedServices] jailbroken] != NOTJAIL;
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
    if(![self connectedToNetwork])
    {
        _btn.enabled = YES;
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"网络连接失败,请查看网络是否连接正常！" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }else{
        
        _btn.enabled = NO;
        
        if(jailbroken == YES) {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"该手机已越狱，无法执行任务，谢谢合作！" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
            return;
        }
        
        NSString *urlString = @"http://m.xinzhuan.vip:9595/userInfo/userLogin3";
//                NSString *urlString = @"http://192.168.0.117:8085/userInfo/userLogin3";
        //解析服务端返回json数据
        //    NSError *error;
        //加载一个NSURL对象
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:40];
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
        // 请求参数
        NSString *str = [NSString stringWithFormat:@"idfa=%@&device_name=%@&os_version=%@&carrier_name=%@&carrier_country_code=%@&keychain=%@&uniqueID=%@&idfv=%@&appID=%@&device_type=%@&net=%@&mac=%@&lad=%d&client_ip=%@&WXLoginID=%@&headImgUrl=%@&ZLQApp=%@&resolution=%d&device_type=%@&udid=%@", idfa, deviceName, systemsVersion, carrierName, carrierCountry, keychain, uniqueID, idfv, attD, systemDeviceTypeNoFormatted, netType, currentMACAddress, jailbroken, currentIPAddress, WXLoginID, headImgUrl, ZLQApp, resolution, iPhoneType, udid];
        
        NSLog(@"url:%@/%@",urlString,str);
        
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        

        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            
            NSMutableDictionary *dict = NULL;
            // 防止重启服务器
            if (!data) {
                _btn.enabled = YES;
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
                    _btn.enabled = YES;
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                    
                } else if (retcode.intValue == 2)
                {

                    _btn.enabled = YES;
                    [DLUDID changeKeychain];
                    [self jumpToHtml];
                } else {
                    _btn.enabled = YES;
                    NSLog(@"失败");
                }
                
            }else{
                NSLog(@"接口返回错误");
            }
        }];
    }
    
}


// 检测是否联网
-(BOOL) connectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flags\n");
        return NO;
    }
    
    BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
    return (isReachable && !needsConnection) ? YES : NO;
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
//    NSLog(@"webSocketDidOpen");
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
    
    // 接收数据
    NSString *jieshouStr = nil;
    jieshouStr = message;
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
//        NSString *str = @"已掉线，点击此处可重新激活";// [NSString stringWithFormat: ];
        //连接失败
        UIAlertView * alertView=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"服务器连接超时，如果后台有其他助手在线请关闭，重新打开此应用" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return ;
    }
    
    [self initServer:PORT];
    
}

#pragma mark - UIApplication Delegate
- (void)didResignActive:(NSNotification *)notification
{
    
}

- (void)didBecomeActive:(NSNotification *)notification
{
    // 判断是否存储udid
    NSString *udid = [[NSUserDefaults standardUserDefaults]objectForKey:@"UDID"];
    
    if (!udid || udid.length < 0) {
        _btnGetUDID.hidden = NO;
        _WXBtn.hidden = YES;
        _btn.hidden = YES;
    } else {
        // 判断是否已经微信登陆过
        NSString *WXLoginID = [[NSUserDefaults standardUserDefaults] objectForKey:@"WXLoginID"];
        if (WXLoginID && ![self isWXLoginOver7Days]) {
            _WXBtn.hidden = YES;
            _btn.hidden = NO;
            _btnGetUDID.hidden = YES;
        } else {
            _WXBtn.hidden = NO;
            _btn.hidden = YES;
            _btnGetUDID.hidden = YES;
        }
        
    }
}
@end
