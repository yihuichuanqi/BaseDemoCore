//
//  BDPathPlanModel.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDBaseModelObject.h"
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSUInteger,BDPathPlanType) {
    
    BDPathPlanType_UnKnown=0,
    BDPathPlanType_Remote=1, //远端服务规划
    BDPathPlanType_Manual=2, //本地手动规划
};


@interface BDPathPlanModel : BDBaseModelObject

//规划路线信息
@property (nonatomic,copy) NSString *planId;
@property (nonatomic,assign) BDPathPlanType planType;
@property (nonatomic,copy) NSDate *createTime;


@end

//手动规划
@class BDPlanTripModel;
@interface BDManualPathPlanModel : BDPathPlanModel

@property (nonatomic,strong) BDPlanTripModel *planTrip;
+(instancetype)pathPlanWithTripModel:(BDPlanTripModel *)tripModel;

@end

//远端规划
@class BDPathPlanPOIModel,BDSpotModel,BDPlanTripPointModel;
@interface BDRemotePathPlanModel : BDPathPlanModel

//起点、终点
@property (nonatomic,strong) BDPathPlanPOIModel *originModel;
@property (nonatomic,strong) BDPathPlanPOIModel *destinationModel;
//途径电站点
@property (nonatomic,strong) NSArray<BDSpotModel *> *viaSpots;
@property (nonatomic,strong) NSArray *viaSpotsAttributes;

@property (nonatomic,assign) CLLocationDistance distance;
@property (nonatomic,assign) NSInteger durations;
@property (nonatomic,copy) NSString *planDescription;
@property (nonatomic,strong) NSArray<NSNumber *>*pathDistances;
//路线地图坐标点数据
@property (nonatomic,readonly) NSArray<BDPathPlanPOIModel *> *pathPOIArray;

-(instancetype)initWithBDManualPlan:(BDManualPathPlanModel *)manualPlan;

@end







