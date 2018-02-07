//
//  BDMQTTService.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/16.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDMQTTService.h"
#import "XLUDIDSolution.h"

#import "BdspotComInst.pbobjc.h"
#import "BDMQTTConfigService.h"
#import "BDSpotService.h"
#import "BDConfigService.h"
#import "BDSpotFlowService.h"

#import "BDHandlePackage.h"

#import "NSString+Hash.h"
#import "NSDictionary+BD.h"

//主机、端口
#define MQTTHOST [BDMQTTConfigService sharedService].host
#define MQTTPORT [BDMQTTConfigService sharedService].port


//设备识别号
#define DEVID [BDMQTTService devId]
//通用广播
#define TOPIC_BROADCAST @"/mobile/broadcast"
//专属广播
#define TOPIC_DEVID_SUB [BDMQTTService topicSub]
#define TOPIC_DEVID_PUB [BDMQTTService topicPub]



//上次重启APP时间Key
#define kLastRestartAppTime @"kLastRebootTime"
#define kRestartAppTimeInterval 864000 //10天内只能重启一次

@interface BDMQTTService ()<MQTTSessionDelegate>

@property (nonatomic,strong) MQTTSession *session;
@property (nonatomic,strong) BDHeartBeat *connectedBeat; //L连接超时包
@end


@implementation BDMQTTService

-(BDHeartBeat *)connectedBeat
{
    if (!_connectedBeat)
    {
        _connectedBeat=[BDHeartBeat heartBeat];
        _connectedBeat.timeInterval=0;
    }
    return _connectedBeat;
}

+(instancetype)sharedService
{
    static BDMQTTService *service=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service=[[BDMQTTService alloc]init];
    });
    return service;
}
-(id)init
{
    if (self=[super init])
    {
        [self connectMQTT];
        [self addNotificationObservers];
    }
    return self;
}
-(void)addNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActice:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeMqttService) name:BDMQTTConfigDidChangedNotification object:nil];
}

-(void)appDidBecomeActice:(NSNotification *)noti
{
    if (self.connectStatus==BDMQTTConnectStatus_Connected)
    {
        //发送充电站点版本
        [self sendSpotVersion];
    }
    else if (self.connectStatus==BDMQTTConnectStatus_Close)
    {
        //后台回来 条件合适直接重连 不等30s间隔
        [self.connectedBeat expireReceiveHeartBeat];
        [self connectMQTT];
    }
}

-(void)closeMqttService
{
    [self.session close];
    self.connectStatus=BDMQTTConnectStatus_Close;
}


#pragma mark-Public Method
-(void)connectMQTT
{
    //30s后 如果连接不上才重连
    if (!self.connectedBeat.timeOut||self.session.status==MQTTSessionStatusConnected)
    {
        return;
    }
    self.connectStatus=BDMQTTConnectStatus_Connecting;
    [self.connectedBeat updateReceiveHeartBeat];
    
    NSString *userName=[BDMQTTConfigService sharedService].userName;;
    NSString *passWord=[BDMQTTConfigService sharedService].passWord;
    userName=isEmpty(userName)?nil:userName;
    passWord=isEmpty(passWord)?nil:passWord;
    if (![self connectMQTTWithUserName:userName passWord:passWord])
    {
        NSLog(@"ERROR: MQTT Service Connected Error!!!!");
    }
    
}
-(BOOL)connectMQTTWithUserName:(NSString *)userName passWord:(NSString *)passWord
{
    if (!_session)
    {
        _session=[[MQTTSession alloc]init];
        _session.clientId=DEVID;
        _session.delegate=self;
        
        //设置信息传递（ProtoBuf）
        Base *baseMsg=[[Base alloc]init];
        baseMsg.cmd=MSG_MsgSetWill;
        baseMsg.timestamp=[[NSDate date] timeIntervalSince1970];
        baseMsg.payload=[[[SetWill alloc]init] data];
        baseMsg.devId=DEVID;
        
        _session.willMsg=[baseMsg data];
        _session.willFlag=YES;
        _session.willTopic=TOPIC_DEVID_PUB;
        _session.willQoS=MQTTQosLevelAtLeastOnce;
        _session.willRetainFlag=YES;
    }
    else
    {
        NSError *error=nil;
        Base *baseMsg=[Base parseFromData:_session.willMsg error:&error];
        if (!error)
        {
            baseMsg.timestamp=[[NSDate date] timeIntervalSince1970];
            _session.willMsg=[baseMsg data];
        }
    }
    
    MQTTCFSocketTransport *transport= [[MQTTCFSocketTransport alloc]init];
    transport.host=MQTTHOST;
    transport.port=MQTTPORT;
    self.session.transport=transport;
    self.session.userName=userName;
    self.session.password=passWord;
    
    return [self.session connectAndWaitTimeout:10];
}

#pragma mark-MQTT Operation
-(void)timerTrigger
{
    //断线重连
    if (self.session.status==MQTTSessionStatusClosed)
    {
        [self connectMQTT];
        return;
    }
    
}
-(void)sendClientInfo
{
    UserInfo *userInfo=[[UserInfo alloc]init];
    userInfo.uid=(int32_t)@(1000000001);
    ReportDevInfo *payload=[[ReportDevInfo alloc]init];
    payload.req.userinfo=userInfo;
    Base *baseMsg=[[Base alloc]init];
    baseMsg.cmd=MSG_MsgReportUserLogout;
    baseMsg.timestamp=[[NSDate date] timeIntervalSince1970];
    baseMsg.devId=DEVID;
    baseMsg.payload=[payload data];
    [self sendData:[baseMsg data] onTopic:TOPIC_DEVID_PUB qos:MQTTQosLevelAtMostOnce];
}
-(void)sendSpotVersion
{
    NSInteger spotVer=[[NSUserDefaults standardUserDefaults] integerForKey:kUCGetSpotsTime];
    ReportSpotUpdateTime *payload=[[ReportSpotUpdateTime alloc]init];
    payload.req.updateTime=spotVer;
    Base *baseMsg=[[Base alloc]init];
    baseMsg.cmd=MSG_MsgReportSpotUpdateTime;
    baseMsg.timestamp=[[NSDate date] timeIntervalSince1970];
    baseMsg.devId=DEVID;
    baseMsg.payload=[payload data];
    [self sendData:[baseMsg data] onTopic:TOPIC_DEVID_PUB qos:MQTTQosLevelAtMostOnce];
}

//发送数据
-(void)sendData:(NSData *)date onTopic:(NSString *)topic qos:(MQTTQosLevel)qos
{
    if (_session&&_session.status==MQTTSessionStatusConnected)
    {
        
        [self.session publishData:date onTopic:topic retain:NO qos:qos];
        NSLog(@"发送数据：%@",[Base parseFromData:date error:nil]);
    }
}
//发送确认包(status=0 接受命令 非0表示错误)
-(void)sendDoneMsgWith:(Base *)baseMsg payload:(NSData *)payload
{
    Base *msg=[baseMsg copy];
    msg.devId=DEVID;
    msg.payload=payload;
    [self sendData:[msg data] onTopic:TOPIC_DEVID_PUB qos:MQTTQosLevelAtMostOnce];
}


#pragma mark-业务逻辑
//用cmd和timestamp拼接个64位的msgId
-(NSString *)msgIdWith:(Base *)baseMsg
{
    int64_t cmd=baseMsg.cmd;
    int64_t uniqueId=cmd<<32|baseMsg.timestamp;
    return [NSString stringWithFormat:@"%@",@(uniqueId)];
}
//根据msgId解析获取cmd和timestamp
-(int32_t)cmdWithMsdId:(NSString *)msgId
{
    int64_t iMsgId=[msgId integerValue];
    int32_t cmd=iMsgId>>32;
    return cmd;
}
-(int32_t)timestampWithMsgId:(NSString *)msgId
{
    int64_t iMsgId=[msgId integerValue];
    int32_t timestamp=iMsgId&0xFFFFFFFF;
    return timestamp;
}

#pragma mark-Privte Method
+(NSString *)devId
{
    static NSString *deviceId=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        deviceId=[XLUDIDSolution xlUDID_MD5];
    });
    return deviceId;
}
+(NSString *)topicSub
{
    static NSString *topicSub=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        topicSub=[NSString stringWithFormat:@"/mobile/%@/sub",[self devId]];
    });
    return topicSub;
}

+(NSString *)topicPub
{
    static NSString *topicPub=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        topicPub=[NSString stringWithFormat:@"/mobile/%@/pub",[self devId]];
    });
    return topicPub;

}
//注册订阅MQTT广播
-(void)subScribeTopic
{
    //广播
    [self.session subscribeToTopic:TOPIC_BROADCAST atLevel:MQTTQosLevelAtMostOnce];
    //专用通道
    [self.session subscribeToTopic:TOPIC_DEVID_SUB atLevel:MQTTQosLevelAtMostOnce];
}

#pragma mark-MQTTSession Delegate
//连接状态
-(void)handleEvent:(MQTTSession *)session event:(MQTTSessionEvent)eventCode error:(NSError *)error
{
    switch (eventCode) {
        case MQTTSessionEventConnected:
            {
                NSLog(@"MQTT连接成功！！！");
                self.connectStatus=BDMQTTConnectStatus_Connected;
                [self subScribeTopic];
                [self sendClientInfo];
                [self sendSpotVersion];
            }
            break;
        case MQTTSessionEventConnectionRefused:
        case MQTTSessionEventConnectionClosed:
        case MQTTSessionEventConnectionError://连接错误
        case MQTTSessionEventProtocolError://协议错误
        case MQTTSessionEventConnectionClosedByBroker://服务器关闭连接
        {
            self.connectStatus=BDMQTTConnectStatus_Close;
        }
            break;
        default:
            break;
    }
}
//接受到订阅信息
-(void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid
{
    @autoreleasepool{
        NSError *error=nil;
        Base *baseMsg=[Base parseFromData:data error:&error];
        if (error)
        {
            NSLog(@"ERROR:包解析错误!!!");
            return;
        }
        if ([topic isEqualToString:TOPIC_BROADCAST])
        {
            //广播信息 无需回复确认包
            [self mqttBroadcastEventWith:baseMsg];
        }
        if ([topic isEqualToString:TOPIC_DEVID_SUB])
        {
            //专属广播、需要回复服务器
        }
    }
}
#pragma mark-不同类型的MQTT通知
-(void)mqttBroadcastEventWith:(Base *)baseMsg
{
    switch (baseMsg.cmd) {
        case MSG_MsgSpotStatusChange:
            [self handleSpotStatusChangedWith:baseMsg];
            break;
        case MSG_MsgSpotInfoChange:
            [self sendSpotVersion];
            break;
        case MSG_MsgConfigChange:
            [self handleConfigChangedWith:baseMsg];
        default:
            break;
    }
}
-(void)mqttDevidSubcribeEventWith:(Base *)baseMsg
{
    
}

#pragma mark-各类处理事件
//单个站点状态发生改变
-(void)handleSpotStatusChangedWith:(Base *)baseMsg
{
    NSError *error=nil;
    SpotStatusChange *payload=[SpotStatusChange parseFromData:baseMsg.payload error:&error];
    if (error)
    {
        return;
    }
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    [dict bd_safeSetObject:@(payload.req.spotId) forKey:@"spotId"];
    [dict bd_safeSetObject:@(payload.req.status) forKey:@"status"];
    [dict bd_safeSetObject:@(payload.req.updateTime) forKey:@"updated_time"];
    
    BDHandlePackage *package=[BDHandlePackage package:dict msgId:[self msgIdWith:baseMsg]];
    [[BDSpotFlowService sharedService] handleSpotStatusPackage:package];

}
//配置文件
-(void)handleConfigChangedWith:(Base *)baseMsg
{
    [[BDConfigService sharedService] requestConfigByMQTTNotification];
}
//清除缓存
-(void)handleAppRemoveCacheWith:(Base *)baseMsg
{
    
}
//重启请求
-(void)handleRestartAppWith:(Base *)baseMsg
{
    //上一次重启时间戳
    int32_t lastTime=[[NSUserDefaults standardUserDefaults] integerForKey:kLastRestartAppTime];
    NSTimeInterval currentTime=[[NSDate date] timeIntervalSince1970];
    NSCalendar *cal=[[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComp=[cal components:NSCalendarUnitHour fromDate:[NSDate date]];
    //重启命令10天内只接收一次 且在凌晨2-4点处理此命令
    NSInteger status=1;
    if ((lastTime==0||(currentTime-lastTime)>kRestartAppTimeInterval)&&(dateComp.hour>=2&&dateComp.hour<4))
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
           
            NSLog(@"App Will Quit!!!!");
            exit(0);
        });
        [[NSUserDefaults standardUserDefaults] setObject:@(currentTime) forKey:kLastRestartAppTime];
        [[NSUserDefaults standardUserDefaults] synchronize];
        status=0;
    }
    //回包给服务器
    ResetReq *feedBack=[[ResetReq alloc]init];
    feedBack.conf.status=status;
    [self sendDoneMsgWith:baseMsg payload:[feedBack data]];
}
//充电点下载
-(void)handleSpotDownloadWith:(Base *)baseMsg
{
    
}
//更新私信
-(void)handleChatMessageChangedWith:(Base *)baseMsg
{
    
}
//红点
-(void)handleRedDotMessageWith:(Base *)baseMsg
{
    
}
//订单状态
-(void)handleOrderStatusChangedWith:(Base *)baseMsg
{
    
}
//上报客户端信息



@end


const static int BDHeartBeatTimeOut =30;
const static int BDHeartBeatLoginTimeOut =30;
const static int BDHeartBeatDefaultTimeOut =30;
const static int BDHeartBeatConnectedTimeOut =30;

@implementation BDHeartBeat

+(BDHeartBeat *)heartBeat
{
    return [BDHeartBeat heartBeat:BDHeartBeatType_Default];
}

+(BDHeartBeat *)heartBeat:(BDHeartBeatType)beatType
{
    BDHeartBeat *heartBeat=[[BDHeartBeat alloc]init];
    heartBeat.beatType=beatType;
    return heartBeat;
}
-(id)init
{
    if (self=[super init])
    {
        self.timeInterval=[[NSDate date] timeIntervalSince1970];
    }
    return self;
}

-(void)updateReceiveHeartBeat
{
    self.timeInterval=[[NSDate date] timeIntervalSince1970];
}
-(void)expireReceiveHeartBeat
{
    self.timeInterval=self.timeInterval - self.typeHeartBartTime;
}
-(BOOL)timeOut
{
    NSTimeInterval currentTimeInterval=[[NSDate date] timeIntervalSince1970];
    if ((currentTimeInterval-self.timeInterval)>self.typeHeartBartTime)
    {
        return YES;
    }
    return NO;
    
}

//不同类型心跳的超时时长
-(int)typeHeartBartTime
{
    switch (self.beatType) {
        case BDHeartBeatType_HeartBeat:
            return BDHeartBeatTimeOut;
            break;
        case BDHeartBeatType_Connected:
            return BDHeartBeatConnectedTimeOut;
            break;
        case BDHeartBeatType_Login:
            return BDHeartBeatLoginTimeOut;
            break;
        case BDHeartBeatType_Default:
            return BDHeartBeatDefaultTimeOut;
            break;
        default:
            return BDHeartBeatDefaultTimeOut;
            break;
    }
}




@end







