//
//  ViewController.m
//  testlib
//
//  Created by APPLE on 2/2/15.
//  Copyright (c) 2015年 hsl. All rights reserved.
//

#import "ViewController.h"
#import "MyGLViewController.h"
#import "HSLSDK/inc/IPCClientNetLib.h"
#import "HSLSDK/inc/StreamPlayLib.h"
#import "HSLSearchDevice.h"
#import <MediaPlayer/MediaPlayer.h>

void STDCALL CallBack_Event(unsigned int nType, void *pUser)
{
    id pThiz = (id)pUser;
    [pThiz ProcessEvent:nType];
}

/*
 * P2P模式回调
 */
void STDCALL CallBack_P2PMode(unsigned int nType, void *pContext)
{
    id pThiz = (id)pContext;
    [pThiz ProcessP2pMode:nType];
}

/*
 * 警报消息回调
 */
void STDCALL CallBack_AlarmMessage(unsigned int nType, void *pContext)
{
    id pThiz = (id)pContext;
    [pThiz ProcessAlarmMessage:nType];
}

/*
 * 获取参数结果回调函数
 */
void STDCALL CallBack_GetParam(unsigned int nType, const char *pszMessage, unsigned int nLen, void *pUser)
{
    id pThiz = (id)pUser;
    [pThiz ProcessGetParam:nType Data:pszMessage DataLen:nLen];
}

/*
 * 设置参数结果回调函数
 */
void STDCALL CallBack_SetParam(unsigned int nType, unsigned int nResult, void *pUser)
{
    id pThiz = (id)pUser;
    [pThiz ProcessSetParam:nType Result:nResult];
}

// 解码后的YUV420数据
void STDCALL CallBack_YUV420Data(unsigned char *pYUVData, int width, int height, void *pUserData)
{
    id pThiz = (id)pUserData;
    [pThiz ProcessYUV420Data:pYUVData Width:width Height:height];
}



@interface ViewController ()<HSLSearchDeviceDelegate>
{
    MyGLViewController *m_glView;
    int userid;
    int playid;
    
    BOOL bSnapshot;
    UILabel *lblMsg;
    int event_type;
    HSLSearchDevice *SDevice;
}
@end


@implementation ViewController

/*
 * 音视频数据回调
 */
void STDCALL CallBack_AVData(const char *pBuffer, unsigned int nBufSize, void *pUser)
{
    //    NSLog(@"data size:%d", nBufSize);
    ViewController* pThiz = (ViewController *)pUser;
    // 写入解码库解码
    x_player_inputNetFrame(pThiz->playid, pBuffer, nBufSize);
    
    Frame_Head *head = (Frame_Head*)pBuffer;
    if (head->type == 6) {
        NSLog(@"head.type=%d", head->type);
    }
    
    
    // record
    //[pThiz ProcessRecord:(void*)pBuffer Size:nBufSize];
}

// 压缩后的音频数据
void STDCALL CallBack_EncodeAudioData(const char *pData, int nSize, void *pUserData)
{
    id pThiz = (id)pUserData;
    [pThiz ProcessEncodeAudioData:pData Len:nSize];
}

- (void)ProcessRecord:(void*)buf Size:(int)size
{
    //int ret = [rec InputFrame:buf size:size];
    //NSLog(@"input frame to buf ret=%d", ret);
}

- (void)ProcessEncodeAudioData:(const char *)pData Len:(int)len
{
    NSLog(@"encode audio data len=%d", len);
    device_net_work_sendTalkData(userid, pData, len);
}

- (void)viewDidAppear:(BOOL)animated
{
//    [m_gl20 clearFrame];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    bSnapshot = YES;
    
    // render view
    float h = 220;//self.view.frame.size.width*9/16;
//    RenderView = [[UIView alloc]init];
//    RenderView.frame = CGRectMake(0, 20, self.view.frame.size.width, h);
//    [self.view addSubview:RenderView];
    
//    m_gl20 = [[OpenGLView20 alloc]init];
//    [m_gl20 SetView:RenderView];
//    [m_gl20 setVideoSize:1280 height:720];
    
//    m_gles20 = [[OpenGLES20View alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, /*300*/h)];
    //[RenderView addSubview:m_gles20];
//    m_gles20 = [[OpenGLES20View alloc]init];
//    [m_gles20 setView:RenderView];
    
    
    m_glView = [[MyGLViewController alloc] init];
    m_glView.view.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.width*9/16);
    [self.view addSubview:m_glView.view];
    
    
    lblMsg = [[UILabel alloc] initWithFrame:CGRectMake(10, h-10, 120, 30)];
    lblMsg.backgroundColor = [UIColor grayColor];
    [self.view addSubview:lblMsg];
    
    // connect
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"连接设备" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor grayColor];
    btn.frame = CGRectMake(10, h+30, 80, 40);
    [btn addTarget:self action:@selector(btnConnect) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    // free
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"释放" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor grayColor];
    btn.frame = CGRectMake(100, h+30, 80, 40);
    [btn addTarget:self action:@selector(btnStop) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    // open video
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"查看视频" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor grayColor];
    btn.frame = CGRectMake(10, h+80, 80, 50);
    [btn addTarget:self action:@selector(btnOpenVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"关闭视频" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor grayColor];
    btn.frame = CGRectMake(100, h+80, 80, 50);
    [btn addTarget:self action:@selector(btnCloseVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    // open audio
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"监听" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor grayColor];
    btn.frame = CGRectMake(10, h+140, 80, 40);
    [btn addTarget:self action:@selector(btnOpenSound) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    // close audio
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"关闭监听" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor grayColor];
    btn.frame = CGRectMake(100, h+140, 80, 40);
    [btn addTarget:self action:@selector(btnCloseSound) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    // open talk
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"对讲" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor grayColor];
    btn.frame = CGRectMake(10, h+190, 80, 40);
    [btn addTarget:self action:@selector(btnOpenTalk) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    // close talk
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"关闭对讲" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor grayColor];
    btn.frame = CGRectMake(100, h+190, 80, 40);
    [btn addTarget:self action:@selector(btnCloseTalk) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    // capture picture
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"抓拍" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor grayColor];
    btn.frame = CGRectMake(10, h+240, 80, 40);
    [btn addTarget:self action:@selector(btnSnapshot) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    // get param
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"获取参数" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor grayColor];
    btn.frame = CGRectMake(100, h+240, 80, 40);
    [btn addTarget:self action:@selector(btnGetParam) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    // 录像
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"录像" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor grayColor];
    btn.frame = CGRectMake(10, h+290, 80, 40);
    [btn addTarget:self action:@selector(btnRecord) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    // 停止录像
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"停止录像" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor grayColor];
    btn.frame = CGRectMake(100, h+290, 80, 40);
    [btn addTarget:self action:@selector(btnStopRecord) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    // 播放录像
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"播放录像" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor grayColor];
    btn.frame = CGRectMake(190, h+290, 80, 40);
    [btn addTarget:self action:@selector(btnPlayRecord) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    userid = -1;
    playid = -1;
    playid = x_player_createPlayInstance(0, 0);
    if (playid < 0) {
        NSLog(@"x_player_createPlayInstance failed.");
        return;
    }
    // 提供播放view
//    x_player_setPlayWnd(playid, (void*)RenderView);
    
    //rec = [[HSLRecord alloc]init];
    //[rec StartRecord:@"abc" Width:1280 Height:720 FrameRate:20];
    SDevice = [[HSLSearchDevice alloc] init];
    
}

- (void)dealloc
{
    // 释放解码实例
    x_player_destroyPlayInstance(playid);
    playid = -1;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnConnect
{
    if (userid >= 0) return;
    struct __login_user_info_t info = {0};
    strcpy(info.szDid, "XLT-153410-VLPDT");
    strcpy(info.szUser, "admin");
    strcpy(info.szPwd, "123");
    strcpy(info.szServIp, "192.168.1.116");
    info.iServPort = 81;
    int nettype = 1;  // 0/1 tcp/p2p
    userid = device_net_work_createInstance(info, nettype);
    if (userid >= 0)
    {
        device_net_work_set_event_callback(userid, CallBack_Event, self);
        device_net_work_set_p2pmode_callback(userid, CallBack_P2PMode, self);
        device_net_work_set_alarmMessage_callback(userid, CallBack_AlarmMessage, self);
        device_net_work_param_callback(userid, CallBack_GetParam, CallBack_SetParam, self);
        device_net_work_start(userid);
    }
    [self LANSearch];
}

- (void)btnStop
{
    if (userid >= 0) {
        device_net_work_destroyInstance(userid);
        userid = -1;
    }
    
    //[rec StopRecord];
}

int sid = 80;
- (void)btnOpenVideo
{
    
    if (userid >= 0) {
        if (playid < 0) {
            NSLog(@"x_player_createPlayInstance failed.");
            return;
        }
        
        // 启动视频解码
        int ret = x_player_startPlay(playid);
        if (ret != AP_ERROR_SUCC) {
            // 释放解码实例
            x_player_destroyPlayInstance(playid);
            playid = -1;
            return;
        }
        // 注册函数接收解码后YUV数据
        x_player_RegisterVideoCallBack(playid, CallBack_YUV420Data, self);
        
        // substream 0/1/2 主/子/次码流
        device_net_work_startStreamV2(userid, sid, 0, CallBack_AVData, self);
        sid++;
        if (sid == 83) {
            sid = 80;
        }
    }
    
    
    // 开始录像
//    NSString *betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mp4"];
//    NSLog(@"record path:%@", betaCompressionDirectory);
//    x_player_StartRecord(playid, [betaCompressionDirectory UTF8String], 320, 180, 15);
}

- (void)btnCloseVideo
{
    if (userid >= 0) {
        // 结束实时视频请求
        device_net_work_stopStream(userid);
        x_player_stopPlay(playid);
        
        // 录像结束
        x_player_StopRecord(playid);
    }

}

/*!!!!!!!!!!!!!!请注意监听和对讲互斥!!!!!!!!!!!!!!!!!!!!*/
- (void)btnOpenSound
{
    // 打开音频解码
    if (x_player_openSound(playid) != AP_ERROR_SUCC) {
        return;
    }
    // 注册接收音频
    //x_player_RegisterAudioCallBack(playid, NULL, self);
    // 请求音频数据
    device_net_work_startAudio(userid, 1, CallBack_AVData, self);

}

     
- (void)btnCloseSound
{
    // 结束音频数据
    device_net_work_stopAudio(userid);
    // 关闭音频解码
    x_player_closeSound(playid);
    
}

- (void)btnOpenTalk
{
    if (playid < 0 || userid < 0) {
        return;
    }
    x_player_StartTalk(playid, CallBack_EncodeAudioData, self);
}

- (void)btnCloseTalk
{
    if (playid < 0 || userid < 0) {
        return;
    }
    x_player_StopTalk(playid);
}

- (void)btnSnapshot
{
    //bSnapshot = YES;
    
    if (playid < 0) {
        return;
    }
    
    NSString *betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/2.jpg"];
    if (x_player_CapturePicture(playid, [betaCompressionDirectory UTF8String])) {
        NSLog(@"capture picture ok");
    } else {
        NSLog(@"capture picture failed.");
    }
}

- (void)btnGetParam
{
    
    if (userid < 0) {
        return;
    }
    
    device_net_work_get_param(userid, GET_PARAM_NETWORK);
}

- (void)btnRecord{
    if (playid < 0 || userid < 0) {
        return;
    }
    if (playid >= 0) {
        NSString *betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mp4"];
            NSLog(@"record path:%@", betaCompressionDirectory);
            x_player_StartRecord(playid, [betaCompressionDirectory UTF8String], 320, 180, 15);
    }
}

- (void)btnStopRecord{
    if (playid >= 0) {
        x_player_StopRecord(playid);
    }
}

- (void)btnPlayRecord{
    NSString *betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mp4"];
    NSLog(@"record path:%@", betaCompressionDirectory);
    MPMoviePlayerViewController *MoviePlayerView = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:betaCompressionDirectory]];
    //MoviePlayerView.moviePlayer.controlStyle = MPMovieControlStyleNone;
    [self presentMoviePlayerViewControllerAnimated:MoviePlayerView];
    [MoviePlayerView.moviePlayer play];
}

- (void)LANSearch{
    SDevice.searchDelegate = self;
    [SDevice Search];
}

#pragma mark - HSLSearchDeviceDelegate
- (void)SearchDevice:(int)DeviceType MAC:(NSString *)mac Name:(NSString *)name Addr:(NSString *)addr Port:(int)port DeviceID:(NSString *)did SmartConnect:(int)smartconnection{
    NSLog(@"#####");
}

/*
 * 事件处理，若显示到控件必须转到主线程处理
 */
- (void)ProcessEvent:(int)nType
{
    NSLog(@"event type=%d\n", nType);
    event_type = nType;
    [self performSelectorOnMainThread:@selector(showEvent) withObject:nil waitUntilDone:NO];
}

- (void)ProcessP2pMode:(int)mode
{
    NSLog(@"P2P Mode = %d",mode);
}

- (void)ProcessAlarmMessage:(int)nType
{
    NSLog(@"alarm type = %d", nType);
}

- (void)ProcessGetParam:(int)nType Data:(const char*)szMsg DataLen:(int)len
{
    NSLog(@"GetParam type:%x len:%d", nType, len);
    switch (nType) {
        case GET_PARAM_NETWORK:     // 网络参数
        {
            STRU_NETWORK_PARAMS *param = (STRU_NETWORK_PARAMS*)szMsg;
            char szbuf[1024] = {0};
            sprintf(szbuf, "\nIPAddr:%s\nPort:%d\nGateway:%s\nMask:%s\n", param->ipaddr, param->port, param->gatway, param->netmask);
            NSLog(@"-------------------WIFI PARAM--------------------");
            NSLog(@"%s", szbuf);
            NSLog(@"-------------------WIFI PARAM END-----------------");
        }
            break;
        default:
            break;
    }
}

- (void)ProcessSetParam:(int)nType Result:(int)result
{

}

- (void)ProcessYUV420Data:(Byte *)yuv420 Width:(int)width Height:(int)height
{
//    NSLog(@"yuv data");
    [m_glView WriteYUVFrame:yuv420 Len:width * height * 3 / 2 width:width height:height];
    
    
}

- (void)showEvent
{
    NSString *str;
    switch (event_type) {
        case NET_EVENT_CONNECTTING:
            str = [NSString stringWithFormat:@"%s", "connect..."];
            break;
        case NET_EVENT_CONNECTED:
            str = [NSString stringWithFormat:@"%s", "online"];
            break;
        case NET_EVENT_CONNECT_ERROR:
            str = [NSString stringWithFormat:@"%s", "connect failed"];
            break;
        case NET_EVENT_ERROR_USER_PWD:
            str = [NSString stringWithFormat:@"%s", "auth failed"];
            break;
        case NET_EVENT_ERROR_INVALID_ID:
            str = [NSString stringWithFormat:@"%s", "invalid id"];
            break;
        case NET_EVENT_P2P_NOT_ON_LINE:
            str = [NSString stringWithFormat:@"%s", "offline"];
            break;
        case NET_EVENT_CONNECT_TIMEOUT:
            str = [NSString stringWithFormat:@"%s", "connect timeout"];
            break;
        case NET_EVENT_DISCONNECT:
            str = [NSString stringWithFormat:@"%s", "disconnect"];
            break;
        case NET_EVENT_CHECK_ACCOUNT:
            str = [NSString stringWithFormat:@"%s", "auth user info"];
            break;
            
        default:
            break;
    }
    lblMsg.text = str;
    

    
}

@end
