//
//  BDPlanTripPointModel.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

/* 路线规划 途径点信息 存在Spot时 province、city等皆使用Spot*/

#import "BDBaseModelObject.h"
#import <CoreLocation/CoreLocation.h>
#import <AMapSearchKit/AMapSearchKit.h>

@class BDSpotModel,BDPathPlanPOIModel;
@interface BDPlanTripPointModel : BDBaseModelObject<NSCoding>

@property (nonatomic,strong) NSString *province;
@property (nonatomic,strong) NSString *city;
@property (nonatomic,strong) NSString *address;
@property (nonatomic,assign) CLLocationCoordinate2D location;

@property (nonatomic,assign) NSInteger distance; //距离出发点距离
@property (nonatomic,assign) NSInteger leftMileage; //从该点出发时 剩余里程
@property (nonatomic,assign) NSInteger stayTime; //该点停留时长 （小时）

@property (nonatomic,copy) NSString *spotId;
@property (nonatomic,strong) BDSpotModel *spot;


+(BDPlanTripPointModel *)objectFromAmapPOI:(AMapPOI *)poi;
+(instancetype)pointWithPathPlanPOI:(BDPathPlanPOIModel *)pathPlanPOI;


@end
