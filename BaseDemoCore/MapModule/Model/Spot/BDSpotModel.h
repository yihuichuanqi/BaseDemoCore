//
//  BDSpotModel.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*站点信息模型 */

#import "BDBaseModelObject.h"
#import <CoreLocation/CoreLocation.h>
#import "BDSpotConstant.h"

@interface BDSpotModel : BDBaseModelObject

#pragma mark-基础信息
@property (nonatomic,copy,readonly) NSString *spotId;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSDate *cTime;

#pragma mark-位置信息
@property (nonatomic,assign,readonly) float latitude;
@property (nonatomic,assign,readonly) float longitude;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate2D; //经纬度

@property (nonatomic,copy) NSString *province;
@property (nonatomic,copy) NSString *provinceCode;
@property (nonatomic,copy) NSString *city;
@property (nonatomic,copy) NSString *cityCode;
@property (nonatomic,copy) NSString *address;

@property (nonatomic,assign) CLLocationDistance distance; //距离当前位置距离
@property (nonatomic,assign) CLLocationDistance destinationDistance; //设置充电点与指定坐标的距离

#pragma mark-站点属性
@property (nonatomic,assign) BDSpotType spotType; //站点类型：慢充 快充 超速充
@property (nonatomic,copy) NSString *codeBitList;//品牌的位序码集合 逗号分隔
@property (nonatomic,readonly) NSInteger priceRational; //收费合理性 0免费 1便宜 2正常 3贵 999999未知
@property (nonatomic,copy) NSString *quantity;


#pragma mark-站点状态
@property (nonatomic,assign) BOOL link;
@property (nonatomic,readonly,getter=isMaintance) BOOL maintance; //是否维护中
@property (nonatomic,copy) NSString *status; //-1未知状态 0可用 1全占用 -9999维护中
#pragma mark-物业运营商
@property (nonatomic,readonly) NSInteger propertyType;//物业类型
@property (nonatomic,copy) NSString *mapIcon;//运营商图标(1充电点 2特斯拉 3国家电网 4启辰 5第三方)
@property (nonatomic,copy) NSString *oreatorTypes;//存储多运营商

-(NSString *)spotSummary;//充电点基本概述

#pragma mark-Distance
-(CLLocationDistance)refreshDistanceToCoordinate:(CLLocationCoordinate2D)coordinate;
-(CLLocationDistance)distanceToCoordinate:(CLLocationCoordinate2D)coordinate;//与站点的距离


#pragma mark-Spot Image
-(UIImage *)spotAnnotationImage; //充电点圆形对应图片
-(UIImage *)spotAnnotationBackgroundImage; //背景图片
+(UIImage *)spotAnnotationImageForType:(BDSpotType)spotType;

-(UIImage *)spotTypeIconImage;//充电点类型图标 线圈风格
+(UIImage *)spotTypeIconImageForType:(BDSpotType)spotType;

-(UIImage *)timeLineImage; //timeLine图标



@end
