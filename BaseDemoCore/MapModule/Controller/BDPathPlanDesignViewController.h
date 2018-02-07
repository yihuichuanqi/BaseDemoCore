//
//  BDPathPlanDesignViewController.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/13.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*路径规划 逐步设计沿线停留站点*/


#import "BDBaseViewController.h"
#import <AMapNaviKit/AMapNaviKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <MAMapKit/MAMapKit.h>

@class BDPlanTripModel,BDPlanTripPointModel;
@interface BDPathPlanDesignViewController : BDBaseViewController

@property (nonatomic,strong) BDPlanTripPointModel *fromPosition;
@property (nonatomic,strong) BDPlanTripPointModel *toPosition;
@property (nonatomic,strong) AMapPath *originPath; //所选路线

@property (nonatomic,assign) NSInteger currentLeftMileage; //爱车剩余里程
@property (nonatomic,assign) NSInteger carMileage; //爱车最大里程
@property (nonatomic,assign) NSInteger stregety; //高德路线策略

@property (nonatomic,strong) BDPlanTripModel *tripModel; //路线模型  存在即为展示模式
@end








