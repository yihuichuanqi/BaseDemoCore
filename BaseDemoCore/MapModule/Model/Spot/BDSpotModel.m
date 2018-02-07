//
//  BDSpotModel.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDSpotModel.h"
#import "BDSpotTypeInfo.h"
#import "BDBasicConfigService.h"

@implementation BDSpotModel

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"模型暂时缺少属性%@",key);
}

-(BDSpotTypeInfo *)annotationImageSpotTypeInfo
{
    BDSpotType type=self.status.integerValue==-9999?BDSpotType_Unknow:self.spotType;
    return [[BDBasicConfigService sharedService] spotTypeInfoWithType:type];
}

-(NSString *)spotSummary
{
    NSString *operateString=@"未知";
    NSString *status=@"";
    if (_status.integerValue==-9999)
    {
        status=@"维护中";
    }
    else if (_status.integerValue==-1||!_link)
    {
        status=@"未联网";
    }
    else if (status.integerValue==1)
    {
        status=@"无空闲";
    }
    else
    {
        status=@"有空闲";
    }
    return [NSString stringWithFormat:@"%@|%@",operateString,status];
}

-(CLLocationDistance)refreshDistanceToCoordinate:(CLLocationCoordinate2D)coordinate
{
    _destinationDistance=[self distanceToCoordinate:coordinate];
    return _destinationDistance;
}
-(CLLocationDistance)distanceToCoordinate:(CLLocationCoordinate2D)coordinate
{
    CLLocation *spotLocation=[[CLLocation alloc]initWithLatitude:self.latitude longitude:self.longitude];
    CLLocation *userLocation=[[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    return [spotLocation distanceFromLocation:userLocation];
}



-(UIImage *)spotAnnotationImage
{
    //如果status=-1 维护中或者状态未知的不需要插卡状态标志
    if (self.link&&self.status.integerValue!=-1)
    {
        return [self annotationImageSpotTypeInfo].annotationBackground_linkedImage;
    }
    else
    {
        return [self annotationImageSpotTypeInfo].annotationBackgroundImage;
    }
}




@end
