//
//  BDStationAnnotation.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/13.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDStationAnnotation.h"
#import "BDSpotModel.h"

@implementation BDStationAnnotation

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate2D
{
    if (self=[super init])
    {
        _coordinate=coordinate2D;
    }
    return self;
}
-(id)initWithSpotModel:(BDSpotModel *)spot
{
    if (self=[super init])
    {
        _spot=spot;
        _coordinate=spot.coordinate2D;
        _spotId=spot.spotId;
        _groupTag=spot.province;
        _type=spot.spotType;
    }
    return self;
}

-(BOOL)isEqual:(BDStationAnnotation *)annotation
{
    if (![annotation isKindOfClass:[BDStationAnnotation class]])
    {
        return NO;
    }
    return (self.coordinate.latitude==annotation.coordinate.latitude&&self.coordinate.longitude==annotation.coordinate.longitude&&[self.title isEqualToString:annotation.title]&&[self.subtitle isEqualToString:annotation.subtitle]&&[self.groupTag isEqualToString:annotation.groupTag]);
}

#pragma mark-delegate
-(BDSpotModel *)stationSpot
{
    return _spot;
}
-(NSString *)identifier
{
    return _spot.spotId;
}


@end
