//
//  BDBLEService.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/30.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*蓝牙服务 主要用于电桩充电*/

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger,BlueStatus) {
  
    kBlueStatus_StartWorking=0,//蓝牙可以正常工作
    kBlueStatus_StopWorking,//蓝牙无法工作（b包括用户不授权使用）
    kBlueStatus_ConnectSuccess,//连接设备成功
    
};
typedef NS_ENUM(NSUInteger,BlueChargeStatus) {

    kBlueChargeStatus_Default=0,//等待连接电桩
    kBlueChargeStatus_WaitingBeginCharge,//等待开始充电
    kBlueChargeStatus_WaitingEndCharge,//等待结束充电（充电中）
    kBlueChargeStatus_EndCharge,//充电结束
};
typedef NS_ENUM(Byte,BlueDeviceStatus) {
    
    kBlueDeviceStatus_Free=0x00,//空闲
    kBlueDeviceStatus_Charging=0x01,//充电中
    kBlueDeviceStatus_Maintain=0x02,//维护中
    kBlueDeviceStatus_Error=0x03,//硬件错误
    kBlueDeviceStatusUnknown=0x04,//未知
};
typedef void (^BlueResultBlock)(BlueStatus status,NSString *errorMsg);


@protocol BDBLEServiceDelegate <NSObject>

//登录回调
-(void)bluetoothChargeDidLogin:(BOOL)success errorMsg:(NSString *)errorMsg detailParams:(NSDictionary *)params;
//意外断开
-(void)bluetoothChargeDidDisconnect;

@end

@interface BDBLEService : NSObject

@property (nonatomic,weak) id<BDBLEServiceDelegate>delegate;

+(instancetype)sharedService;
-(void)connectDeviceName:(NSString *)deviceName resultBlock:(BlueResultBlock)block;
-(void)stopBluetoothService;
@end
