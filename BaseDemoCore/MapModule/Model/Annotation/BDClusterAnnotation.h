//
//  BDClusterAnnotation.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/16.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDStationAnnotation.h"

typedef NS_ENUM(NSUInteger,kMapAnnotationScaleType) {
    
    kMapAnnotationScaleType_Not, //不做聚合
    kMapAnnotationScaleType_City, //城市聚合
    kMapAnnotationScaleType_Privince, //省份聚合
    
};

@interface BDClusterAnnotation : NSObject<BDAnnotationDelegate>

//位置信息
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,assign) MKCoordinateRegion clusterRegion;

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;
@property (nonatomic,assign) NSInteger type;
@property (nonatomic,assign) NSInteger count;
@property (nonatomic,strong) NSArray *spots;

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate2D;


@end


@interface BDClusterAnnotationHelper : NSObject

//以何种方式聚合
+(NSUInteger)shouldClustered:(NSUInteger)zoomLevel;
+(float)clusterWithForZoomLevel:(NSUInteger)zoomLevel;
+(CGFloat)clusterDelta:(NSUInteger)zoomLevel;

@end









