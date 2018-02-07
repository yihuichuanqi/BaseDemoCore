//
//  BDClusterAnnotation.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/16.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDClusterAnnotation.h"
#import "BDSpotDao.h"

@implementation BDClusterAnnotation

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate2D
{
    if(self=[super init])
    {
        _coordinate=coordinate2D;
    }
    return self;
}

-(BOOL) isEqualClusterAnnotation:(BDClusterAnnotation *)annotation
{
    if (![annotation isKindOfClass:[BDClusterAnnotation class]])
    {
        return NO;
    }
    return (self.coordinate.latitude==annotation.coordinate.latitude&&
            self.coordinate.longitude==annotation.coordinate.longitude&&
            [self.title isEqualToString:annotation.title]&&
            [self.subtitle isEqualToString:annotation.subtitle]);
}
-(BDSpotModel *)stationSpot
{
    return nil;
}
-(NSString *)identifier
{
    return [NSString stringWithFormat:@"%@_%@",_title,@(_count)];
}
-(BDSpotUpdateType)updateWithObject:(id)object
{
    if ([object isKindOfClass:[BDClusterAnnotation class]])
    {
        BDClusterAnnotation *annotation=(BDClusterAnnotation *)object;
        _count=annotation.count;
        _coordinate=annotation.coordinate;
        _title=annotation.title;
        _subtitle=annotation.subtitle;
    }
    return BDSpotUpdateType_None;
}


@end



static const CGFloat kMinCity  =1.0; //最小放大倍数
static const CGFloat kMaxCity  =2.0; //最大放大倍数
static const CGFloat kMaxProvince =1.0;

@implementation BDClusterAnnotationHelper

/*
 0 不做聚合
 1 以城市聚合
 2 以省份聚合
 3 以全部聚合
 */

+(NSUInteger)shouldClustered:(NSUInteger)zoomLevel
{
    if (zoomLevel>=kMaxCity)
    {
        return kClusterType_None;
    }
    else if (zoomLevel>kMinCity&&zoomLevel<kMaxCity)
    {
        return kClusterType_City;
    }
    else if (zoomLevel<=kMinCity&&zoomLevel>kMaxProvince)
    {
        return kClusterType_Province;
    }
    return kClusterType_All;
}
+(float)clusterWithForZoomLevel:(NSUInteger)zoomLevel
{
    if (zoomLevel>=18.0)
    {
        return 0.0;
    }
    if (zoomLevel>=17.0)
    {
        return 0.0;
    }
    if (zoomLevel>=16.0)
    {
        return 0.0002;
    }
    if (zoomLevel>=15.0)
    {
        return 0.0006;
    }
    if (zoomLevel>=14.0)
    {
        return 0.0012;
    }
    if (zoomLevel>=13.0)
    {
        return 0.0028;
    }
    if (zoomLevel>=12.0)
    {
        return 0.006;
    }
    if (zoomLevel>=11.0)
    {
        return 0.01;
    }
    if (zoomLevel>=10.0)
    {
        return 0.02;
    }
    if (zoomLevel>=9.0)
    {
        return 0.04;
    }
    if (zoomLevel>=8.0)
    {
        return 0.085;
    }
    if (zoomLevel>=7.0)
    {
        return 0.2;
    }
    if (zoomLevel>=6.0)
    {
        return 0.7;
    }
    if (zoomLevel>=0.5)
    {
        return 1.0;
    }
    if (zoomLevel>=4.0)
    {
        return 2.0;
    }
    if (zoomLevel>=3.0)
    {
        return 4.0;
    }
    if (zoomLevel>=2.0)
    {
        return 6.0;
    }
    if (zoomLevel>=1.0)
    {
        return 8.0;
    }
    return 0.0;
}
+(CGFloat)clusterDelta:(NSUInteger)zoomLevel
{
    NSInteger clusterType=[[self class] shouldClustered:zoomLevel];
    CGFloat clusterDelta=0;
    switch (clusterType) {
        case kClusterType_None:
        case kClusterType_City:
            clusterDelta=8;
            break;
        case kClusterType_Province:
            clusterDelta=4;
            break;
        case kClusterType_All:
            clusterDelta=2;
            break;
        default:
            clusterDelta=13;
            break;
    }
    return clusterDelta;
}



@end









