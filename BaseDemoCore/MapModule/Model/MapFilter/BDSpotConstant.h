//
//  BDSpotConstant.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/16.
//  Copyright © 2018年 Admin. All rights reserved.
//

#ifndef BDSpotConstant_h
#define BDSpotConstant_h

//站点充电速率类型
typedef  NS_ENUM(NSUInteger,BDSpotType){
    
    BDSpotType_Unknow=0,
    BDSpotType_Slow=1, //慢充
    BDSpotType_Fast=1<<1,//快充
    BDSpotType_Super=1<<2,//超级充
};
//站点归属类型
typedef NS_ENUM(NSInteger,BDSpotOperatorType) {
    
    BDSpotOperatorType_Personal=1, //个人
    BDSpotOperatorType_Public=1<<1, //公共
    BDSpotOperatorType_Operating=1<<2, //营运
};
//站点后台Socket更新类型
typedef NS_ENUM(NSUInteger,BDSpotUpdateType){
    
    BDSpotUpdateType_None=0,
    BDSpotUpdateType_BoxId,
    BDSpotUpdateType_Status,
    BDSpotUpdateType_Type,
    BDSpotUpdateType_Other,
};
//站点充电标准
typedef NS_OPTIONS(NSUInteger, BDSpotCurrentType) {
    
    BDSpotCurrentType_None=0,
    BDSpotCurrentType_Direct=1<<0, //直流
    BDSpotCurrentType_Alternating=1<<1,//交流
    BDSpotCurrentType_Three=1<<2,//三相
    BDSpotCurrentType_Single=1<<3,//单相
    BDSpotCurrentType_Industry=1<<4,//工业插座
};
//充电订单状态
typedef NS_ENUM(NSInteger,BDChargerOrderStatus) {
    
    BDChargerOrderStatus_Chargering=30, //充电中
    BDChargerOrderStatus_Ready=20, //连接中
    BDChargerOrderStatus_Free=0,//空闲
    BDChargerOrderStatus_Unkonw=-1,//未知
    BDChargerOrderStatus_Maintance=-2, //维护中
    BDChargerOrderStatus_Occupy=-3,//占用中
};
//站点开放类型
typedef NS_ENUM(NSInteger,BDSpotServiceCode) {
    
    BDSpotServiceCode_Interior=0,//内部使用
    BDSpotServiceCode_Open=1,//对外开放
    BDSpotServiceCode_Bool=2,//预约开发
};
//充电锁状态
typedef NS_ENUM(NSInteger,BDChargerLockStatus) {
    
    BDChargerLockStatus_Error=-200, //出错中
    BDChargerLockStatus_Maintanice=-100, //维修中
    BDChargerLockStatus_Inactice=0, //未激活
    BDChargerLockStatus_UnLock=10, //处于解锁状态 需要上锁
    BDChargerLockStatus_Lock=70, //处于上锁状态 需要解锁
};
//充电停车厂状态
typedef NS_ENUM(NSInteger,BDChargerPackStatus) {
    
    BDChargerPackStatus_Maintance=-100, //维护中
    BDChargerPackStatus_Unkonw=0, //未知
    BDChargerPackStatus_Free=10, //空闲
    BDChargerPackStatus_Busy=70, //占用中
};
//充电停车厂收费类型
typedef NS_ENUM(NSInteger,BDParkingChargeType) {
    
    BDParkingChargerType_Unknow=0,
    BDParkingChargerType_Free=1, //免费
    BDParkingChargerType_Charge=2, //收费
};
//所支持充电标准
typedef NS_ENUM(NSUInteger,BDSupportChargerType) {
    
    BDSupportChargerType_None=0,
    BDSupportChargerType_ChineseStandard=1<<0, //国标
    BDSupportChargerType_Tesla=1<<1,//特斯拉
};



#endif /* BDSpotConstant_h */
