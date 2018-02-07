//
//  BDMQTTService.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/16.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MQTTClient/MQTTClient.h>


extern NSString * const BDMQTTConfigDidChangedNotification;

typedef NS_ENUM(NSUInteger,BDMQTTConnectStatus) {
    
    BDMQTTConnectStatus_Close=0, //无连接
    BDMQTTConnectStatus_Connecting, //连接中
    BDMQTTConnectStatus_Connected, //连接完成
    
};


@interface BDMQTTService : NSObject

@property (nonatomic,assign) BDMQTTConnectStatus connectStatus; //连接状态

+(instancetype)sharedService;

-(void)connectMQTT;
//定时器触发
-(void)timerTrigger;
-(void)sendSpotVersion;
-(void)sendClientInfo;


@end


typedef NS_ENUM(NSUInteger,BDHeartBeatType) {
  
    BDHeartBeatType_Login=0,
    BDHeartBeatType_HeartBeat=1,
    BDHeartBeatType_Connected=2,
    BDHeartBeatType_Default=3,
};

@interface BDHeartBeat : NSObject
@property (nonatomic,assign) BDHeartBeatType beatType;
@property (nonatomic,assign) NSTimeInterval timeInterval;

+(BDHeartBeat *)heartBeat;

//更新心跳时长
-(void)updateReceiveHeartBeat;
//置为过期
-(void)expireReceiveHeartBeat;
//是否超时
-(BOOL)timeOut;
@end







