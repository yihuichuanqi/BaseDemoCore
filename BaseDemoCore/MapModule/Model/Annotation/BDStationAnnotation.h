//
//  BDStationAnnotation.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/13.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>
#import <MapKit/MapKit.h>
#import "BDSpotConstant.h"

@class BDSpotModel;

@protocol BDAnnotationDelegate<MKAnnotation>

@required
-(BDSpotModel *)stationSpot; //站点信息
-(NSString *)identifier; //标识
-(BDSpotUpdateType)updateWithObject:(id)object;//页面Annotation更新类型

@end


@interface BDStationAnnotation : NSObject <MKAnnotation,MAAnnotation,BDAnnotationDelegate>

//代理所需属性
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;

@property (nonatomic,copy) NSString *groupTag; //所归属地区
@property (nonatomic,assign) NSInteger type; //所在站点类型
//附带站点信息
@property (nonatomic,strong) BDSpotModel *spot;
@property (nonatomic,copy) NSString *spotId;

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate2D;
-(id)initWithSpotModel:(BDSpotModel *)spot;

@end










