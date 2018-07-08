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


// 友盟
#define UmengAppkey @"5b3b94eeb27b0a0ca0000069"
#define AppId @"wxa12f5d8b3b013fe4"
#define AppSecret @"6aa5ec829a267cf7873400016a8ceae8"
// 友盟QQ
#define QQAppId @"1107023030"
#define QQAppKey @"SX5gPgTl03WY7jrU"

// 定义颜色宏
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)

#define HOST @"127.0.0.1"
#define PORT 8086

// 应用版本号
#define YYYApp @"Yellow1.3"

// 服务器传的api参数
#define newLsAW @"lsAW5"
#define newDeFW @"deFW5"
#define newAllApption @"allApption5"
#define newOpenAppWBID @"openAppWBID5"
#define newDetion @"detion5"
#define newAllA @"allA5"
// 跳转界面的偏好设置
#define newJump @"i_jump5"

@interface ViewController ()<PSWebSocketServerDelegate>
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) UIButton *WXBtn;

@property (nonatomic, strong) UIImageView *WXImage;
@property (nonatomic, strong) UIImageView *zaiXianImage;

// 与网页交互
@property (nonatomic, strong) PSWebSocketServer *server;
@property (nonatomic, strong) YingYongYuanmpPreventer *mmpPreventer;
// 计算时间用的变量
@property (nonatomic, assign) int appRunTime;
@property (nonatomic, assign) int shiCanTime;
@property (nonatomic, assign) int deliverTime;
@property (nonatomic, strong) NSTimer *timerShiCan;
@property (nonatomic, strong) NSString *shiCanStr;
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

#pragma mark - 设置客户端界面
- (void)interfaceSetUp
{
    UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg"]];
    imgView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.view addSubview:imgView];
    
    _zaiXianImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0-160/2.0, ([UIScreen mainScreen].bounds.size.height/2) - 240, 160, 160)];
    _zaiXianImage.image = [UIImage imageNamed:@"cp9"];
    _zaiXianImage.layer.cornerRadius = 80.0f;
    _zaiXianImage.layer.masksToBounds = YES;
    [self.view addSubview:_zaiXianImage];

    
    // button
    _btn = [UIButton buttonWithType:UIButtonTypeSystem];
    _btn.frame = CGRectMake(self.view.frame.size.width/2.0-90, CGRectGetMaxY(self.view.frame) - 120, 180, 48);
    _btn.layer.cornerRadius = 10.0f;
    _btn.layer.borderWidth = 1;
    _btn.titleLabel.font = [UIFont systemFontOfSize:17];
    _btn.layer.borderColor = [RGB(251, 131, 99) CGColor];
    [_btn setBackgroundColor:RGB(251, 131, 99)];
    [_btn setTitle:@"进入指来钱" forState:UIControlStateNormal];
    [_btn setTitle:@"进入指来钱" forState:UIControlStateSelected];
    [_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btn addTarget:self action:@selector(jumpToHtml) forControlEvents:UIControlEventTouchUpInside];
    _btn.enabled = YES;
    
    _btn.hidden = YES;
    [self.view addSubview:_btn];
    
    // 微信按钮
    _WXBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _WXBtn.frame = CGRectMake(self.view.frame.size.width/2.0-90, CGRectGetMaxY(self.view.frame) - 120, 180, 48);
    _WXBtn.layer.cornerRadius = 10.0f;
    _WXBtn.layer.borderWidth = 1;
    _WXBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    _WXBtn.layer.borderColor = [RGB(251, 131, 99) CGColor];
    [_WXBtn setBackgroundColor:RGB(251, 131, 99)];
    [_WXBtn setTitle:@"微信登陆" forState:UIControlStateNormal];
    [_WXBtn setTitle:@"微信登陆" forState:UIControlStateSelected];
    [_WXBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_WXBtn addTarget:self action:@selector(WXLogin) forControlEvents:UIControlEventTouchUpInside];
    _WXBtn.enabled = YES;
    [self.view addSubview:_WXBtn];
    
    // 微信头像
    _WXImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0-160/2.0, ([UIScreen mainScreen].bounds.size.height/2)-240, 160, 160)];
    _WXImage.backgroundColor = [UIColor whiteColor];
    
    _WXImage.hidden = YES;
    [self.view addSubview:_WXImage];
    
    _WXImage.userInteractionEnabled = YES;
    
    // Make avatarView draggable
    //[_WXImage makeDraggable];
    
    // 判断是否已经微信登陆过
    NSString *WXLoginID = [[NSUserDefaults standardUserDefaults] objectForKey:@"WXLoginID"];
    if (WXLoginID) {
        _WXBtn.hidden = YES;
        _btn.hidden = NO;
    }
    // 判断是否已经微信登陆过
    NSString *headImgUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"headImgUrl"];
    if (headImgUrl) {
        [_WXImage sd_setImageWithURL:[NSURL URLWithString:headImgUrl]];
        _zaiXianImage.hidden = YES;
        _WXImage.hidden = NO;
    }
    
    // twoTipLabel
//    UILabel *twoTipLabel= [[UILabel alloc] initWithFrame:CGRectMake(30, [UIScreen mainScreen].bounds.size.height-110, [UIScreen mainScreen].bounds.size.width - 60, 20)];
//    twoTipLabel.font = [UIFont systemFontOfSize:14];
//    twoTipLabel.text = @"小提示:任务时，请勿退出";
//    twoTipLabel.textColor = [UIColor grayColor];
//    twoTipLabel.lineBreakMode = NSLineBreakByCharWrapping;
//    twoTipLabel.numberOfLines = 0;
//    twoTipLabel.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:twoTipLabel];
    
    // threeTipLabel
//    UILabel *threeTipLabel= [[UILabel alloc] initWithFrame:CGRectMake(30, [UIScreen mainScreen].bounds.size.height-90, [UIScreen mainScreen].bounds.size.width - 60, 20)];
//    threeTipLabel.font = [UIFont systemFontOfSize:14];
//    threeTipLabel.text = @"“猿猿Music”以免无法获得奖励。";
//    threeTipLabel.textColor = [UIColor grayColor];
//    threeTipLabel.lineBreakMode = NSLineBreakByCharWrapping;
//    threeTipLabel.numberOfLines = 0;
//    threeTipLabel.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:threeTipLabel];
    
    // 底部label
//    UILabel *downTipLabel= [[UILabel alloc] initWithFrame:CGRectMake(40, [UIScreen mainScreen].bounds.size.height-30, [UIScreen mainScreen].bounds.size.width - 80, 14)];
//    downTipLabel.font = [UIFont systemFontOfSize:14];
//    downTipLabel.text = @"版权所有 © 2017 应用猿";
//    downTipLabel.textColor = [UIColor grayColor];
//    downTipLabel.lineBreakMode = NSLineBreakByCharWrapping;
//    downTipLabel.numberOfLines = 0;
//    downTipLabel.textAlignment = NSTextAlignmentCenter;
//    downTipLabel.alpha = 0.5;
//    [self.view addSubview:downTipLabel];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Update snap point when layout occured
    [_WXImage updateSnapPoint];
}

// 设置图片圆角
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // 设置iconView圆角
    self.WXImage.layer.cornerRadius = self.WXImage.bounds.size.width * 0.5;
    self.WXImage.layer.masksToBounds = YES;
//    self.WXImage.layer.borderWidth = 1.0;
//    self.WXImage.layer.borderColor = [UIColor whiteColor].CGColor;
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

            _WXBtn.hidden = YES;
            _btn.hidden = NO;
            [[NSUserDefaults standardUserDefaults] setObject:unionid forKey:@"WXLoginID"];
            [[NSUserDefaults standardUserDefaults] setObject:headimgurl forKey:@"headImgUrl"];
            
            [self.WXImage sd_setImageWithURL:[NSURL URLWithString:headimgurl]];
            _zaiXianImage.hidden = YES;
            _WXImage.hidden = NO;

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


#pragma mark - 跳转网页的按钮
- (void)jumpToHtml
{
    
    _btn.enabled = NO;
    //设备类型
    NSString *deviceModel = [[SystemServices sharedServices] deviceModel];
    //设备型号
    NSString *systemDeviceTypeFormatted = [[SystemServices sharedServices] systemDeviceTypeFormatted];
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
    BOOL jailbroken = [[SystemServices sharedServices] jailbroken] != NOTJAIL;
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

//    NSLog(@"key:%@   idfa:%@", keychain, idfa);
    
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
        
        NSString *urlString = @"http://m.handplay.xin/userInfo/userLogin3";
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
        
        // 请求参数
        NSString *str = [NSString stringWithFormat:@"idfa=%@&device_name=%@&os_version=%@&carrier_name=%@&carrier_country_code=%@&keychain=%@&uniqueID=%@&idfv=%@&appID=%@&device_type=%@&net=%@&mac=%@&lad=%d&client_ip=%@&WXLoginID=%@&headImgUrl=%@&YYYApp=%@&resolution=%d", idfa, deviceName, systemsVersion, carrierName, carrierCountry, keychain, uniqueID, idfv, attD, deviceModel, netType, currentMACAddress, jailbroken, currentIPAddress, WXLoginID, headImgUrl, YYYApp, resolution];
        
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
        //        NSLog(@"json解析失败：%@",err);
        return ;
    }
    // 取第一个key 包名
    NSString *messageStr = nil;
    messageStr = mesDict[@"baoming"];
    //    NSLog(@"messageStr:%@", messageStr);
    // 取第二个key 时间
    NSString *timeStr = mesDict[@"time"];
    _deliverTime = [timeStr intValue];
    if ([messageStr isEqualToString:@"shareFriend000"]) {
        _deliverTime = 200;
    }
    //    NSLog(@"_deliverTime:%d", _deliverTime);
    // 取第三个判断值
    NSString *panduanStr = mesDict[@"panduan"];
    //    NSLog(@"panduanStr--%@", panduanStr);
    

    
    // 传分享的网址内容：好友
    if ([panduanStr isEqualToString:@"shareFriend000"]) {
        //
        
        [[LMAController sharedInstance] onThis:[[NSBundle mainBundle] bundleIdentifier]];
        [UMSocialWechatHandler setWXAppId:AppId appSecret:AppSecret url:timeStr];
        [UMSocialQQHandler setQQWithAppId:QQAppId appKey:QQAppKey url:timeStr];
        
        NSString *appKey = UmengAppkey;
        NSString *shareText = @"一款下载试玩应用赚钱的软件.http://m.handplay.xin";
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
        BOOL isDownAppBool = [[YingYongYuanetattD sharedInstance] getAdd:messageStr];
        //        NSLog(@"isDownAppBool:%d", isDownAppBool);
        NSString *isOpenAppStr = [NSString stringWithFormat:@"{\"openApp\":\"%d\"}",isDownAppBool];
        [self writeWebMsg:webSocket msg:isOpenAppStr];
        
        
        return;
    }
    
    // 传是否安装app
    if ([panduanStr isEqualToString:@"19940511"]) { // 打开APP
        // 删除字符串@“19940511”
        //        NSMutableString *muMesStr = [NSMutableString stringWithString:messageStr];
        //        [muMesStr deleteCharactersInRange:NSMakeRange(0, 8)];
        //        NSLog(@"%@", muMesStr);
        BOOL isDownAppBool = [[YingYongYuanetattD sharedInstance] getAdd:messageStr];
                NSLog(@"isDownAppBool:%d", isDownAppBool);
        
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
//        NSLog(@"%@", isOpenAppStr);
        
        // 第三方下载app不记时
        if ([attD isEqualToString:@"0"]) return;
        
        // 存了上一个包名
        _shiCanStr = messageStr;
        [[LMAController sharedInstance] onThis:messageStr];
        

        if ((_shiCanTime == 0) && isDownAppBool) {
            // 重置计算时间
            //            _shiCanTime = 0;
            [[LMAController sharedInstance] onThis:messageStr];
            _timerShiCan = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeRun) userInfo:nil repeats:YES];
        }
    } else if ([panduanStr isEqualToString:@"19920505"]){ // 第二次打开APP
        //            NSMutableString *muMesStr = [NSMutableString stringWithString:messageStr];
        //            [muMesStr deleteCharactersInRange:NSMakeRange(0, 8)];
        //            NSLog(@"%@", muMesStr);
        [[LMAController sharedInstance] onThis:messageStr];
    } else { // 提交审核
        //            NSLog(@"%d",![_shiCanStr isEqualToString:messageStr]);
        if (![_shiCanStr isEqualToString:messageStr]) {
            _appRunTime = _deliverTime;
            NSString *appRunTimeStr = [NSString stringWithFormat:@"{\"appRunTime\":\"%d\"}", _appRunTime];
                            NSLog(@"-!!!!!---%@", appRunTimeStr);
            [self writeWebMsg:webSocket msg:appRunTimeStr];
        } else
        {

            if (_shiCanTime >= _deliverTime) {
                _appRunTime = 0;
                NSString *appRunTimeStr = [NSString stringWithFormat:@"{\"appRunTime\":\"%d\"}", _appRunTime];
                                    NSLog(@"----%@", appRunTimeStr);
                [self writeWebMsg:webSocket msg:appRunTimeStr];
                // 重置计算时间
                _shiCanTime = 0;
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

@end
