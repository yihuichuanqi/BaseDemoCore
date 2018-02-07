//
//  BDPathPlanPOIModel.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*
 *线路规划坐标点信息(高德POI信息)
 */

#import "BDBaseModelObject.h"
#import <CoreLocation/CoreLocation.h>
#import <AMapSearchKit/AMapSearchKit.h>

@class BDSpotModel,BDPlanTripPointModel;

@interface BDPathPlanPOIModel : BDBaseModelObject

@property (nonatomic,copy) NSString *cityCode;
@property (nonatomic,copy,readonly) NSString *cityName;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *address;
@property (nonatomic,strong) BDSpotModel *spot;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;

-(instancetype)initWithAmapPoi:(AMapPOI *)amapPoi;
-(instancetype)initWithSpot:(BDSpotModel *)spot;
-(instancetype)initWithPoint:(BDPlanTripPointModel *)point;






@end
