//
//  BDMapTripService.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/12.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDMapTripService.h"
#import "BDSpotModel.h"
#import "BDSpotService.h"

@implementation BDMapTripService

+(void)findFarestLocationWhichExistSpotInRoadDistance:(NSInteger)roadDistance
                                             amapPath:(AMapPath *)path
                                               radius:(NSInteger)radius
                                        finishedBlock:(void(^)(BOOL noNeedToFind,CLLocationCoordinate2D farestLocationCoor,NSInteger farestLocationRadius,NSArray *spots,NSArray<NSDictionary *> *searchCircles))complete
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        NSInteger currentDistance=0;
        NSInteger k=(roadDistance+radius)/(radius);//行程所包含的半径最大个数
        NSInteger focusRoadDistance=k*(radius);//所能行走的最大安全距离
        NSInteger c=0;
        CLLocationCoordinate2D lastCoordinate=kCLLocationCoordinate2DInvalid;
        NSMutableArray *stepCoordinates=[NSMutableArray array];
        NSMutableArray *stepDistances=[NSMutableArray array];
        BOOL go=YES;
        //遍历路线-路段
        for (NSInteger i=0; (i<path.steps.count&&go); i++)
        {
            AMapStep *step=path.steps[i];
            NSArray *polylineCoordinates=[step.polyline componentsSeparatedByString:@";"];
            if (polylineCoordinates.count>0)
            {
                //构造坐标结构体
                MAMapPoint point1;
                MAMapPoint point2;
                //遍历某路段坐标信息
                for (NSInteger i=0; i<polylineCoordinates.count; i++)
                {
                    NSString *polylineCoordinate=polylineCoordinates[i];
                    NSArray *coordinateArr=[polylineCoordinate componentsSeparatedByString:@","];
                    if (coordinateArr.count==2)
                    {
                        //路线-经纬点
                        CLLocationCoordinate2D coordinate=CLLocationCoordinate2DMake([coordinateArr[1] doubleValue], [coordinateArr[0] doubleValue]);
                        if (i==0)
                        {
                            point2=MAMapPointForCoordinate(coordinate);
                        }
                        else
                        {
                            //依次获取相邻的两个坐标点
                            point1 = point2;
                            point2=MAMapPointForCoordinate(coordinate);
                            CLLocationDistance distance=MAMetersBetweenMapPoints(point1, point2);
                            currentDistance+=distance;
                            //所走总里程
                            if ((currentDistance>(roadDistance+radius-focusRoadDistance+c*radius))&&(c<k))
                            {
                                [stepCoordinates addObject:[NSValue valueWithMKCoordinate:lastCoordinate]];
                                [stepDistances addObject:@(currentDistance)];
                                c++;
                            }
                            if (currentDistance>roadDistance)
                            {
                                go=NO;
                                break;
                            }
                            else
                            {
                                //保存上一次的点坐标
                                lastCoordinate=coordinate;
                            }
                        }
                    }
                }
            }
        }
        CLLocationCoordinate2D farestLocation=kCLLocationCoordinate2DInvalid;
        NSInteger farestRadius=0;
        NSMutableDictionary *spotsDict=[NSMutableDictionary dictionary];
        //最大搜索距离(最后路段长度+半径)
        NSInteger totalSearchRoadDistance=[stepDistances.lastObject integerValue]+radius;
        NSMutableArray *searchCircles=nil;
        searchCircles=[NSMutableArray array];
        for (NSInteger i=stepCoordinates.count-1; i>=0; i--)
        {
            CLLocationCoordinate2D aLocation=[stepCoordinates[i] MKCoordinateValue];
            NSInteger stepRoadDistance=[stepDistances[i] integerValue];
            NSInteger searchRadius=[self searchRadiusOfStepRoadDistance:stepRoadDistance totalSearchRoadDistance:totalSearchRoadDistance];
            if (searchRadius==0)
            {
                searchRadius=1;
            }
            NSArray *searchSpots=[[BDSpotService sharedServices] getSpotsWithNearbyArround:aLocation distance:searchRadius];
            //c圆坐标 d圆半径 s离起点距离
            [searchCircles addObject:@{@"c":[NSValue valueWithMKCoordinate:aLocation],@"d":@(searchRadius),@"s":@(stepRoadDistance)}];
            if (searchSpots.count>0)
            {
                if (!CLLocationCoordinate2DIsValid(farestLocation))
                {
                    farestLocation=aLocation;
                    farestRadius=searchRadius;
                }
                for (BDSpotModel *spot in searchSpots)
                {
                    if (spot.spotId)
                    {
                        spotsDict[spot.spotId]=spot;
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (complete)
            {
                complete(go,farestLocation,farestRadius,spotsDict.allValues,searchCircles);
            }
        });

    });
}

+(CLLocationDistance)searchRadiusOfStepRoadDistance:(NSInteger)roadDistance totalSearchRoadDistance:(NSInteger)totalSearchDistance
{
    //前后半段 按距离*0.4作范围搜索
    return (roadDistance<totalSearchDistance/2)?roadDistance*1:((totalSearchDistance-roadDistance)*1);
}


+(NSString *)makeCoordinatesStringWithAMapPath:(AMapPath *)path
{
    NSString *coordinatesString=nil;
    NSArray *polylines=[path.steps valueForKey:@"polyline"];
    coordinatesString=[polylines componentsJoinedByString:@";"];
    return coordinatesString;
}
+(NSString *)makeCoordinatesStringWithAMapPathsArray:(NSArray<AMapPath *> *)pathArray
{
    NSMutableArray *stringArray=[NSMutableArray array];
    for (AMapPath *path in pathArray)
    {
        NSString *pathString=[self makeCoordinatesStringWithAMapPath:path];
        [stringArray addObject:pathString];
    }
    return [stringArray componentsJoinedByString:@";"];
}


+(NSMutableArray<MAPolyline *> *)makePolyLinesWithAMapPath:(AMapPath *)aMapPath
{
    NSString *coordinatesString=[self makeCoordinatesStringWithAMapPath:aMapPath];
    return [self makePolyLinesWithCoordinatesString:coordinatesString];
}
+(NSMutableArray<MAPolyline *> *)makePolyLinesWithCoordinatesString:(NSString *)coordinatesString
{
    NSMutableArray<MAPolyline *> *mapPolylines=[NSMutableArray array];
    NSArray *polylineCoordinates=[coordinatesString componentsSeparatedByString:@";"];
    if (polylineCoordinates.count>0)
    {
        //构造坐标结构体对象
        CLLocationCoordinate2D *coordinates=malloc(sizeof(CLLocationCoordinate2D)*polylineCoordinates.count);
        for (NSInteger i=0; i<polylineCoordinates.count; i++)
        {
            NSString *polylineCoordinate=[polylineCoordinates objectAtIndex:i];
            NSArray *coordinateArr=[polylineCoordinate componentsSeparatedByString:@","];
            if (coordinateArr.count==2)
            {
                CLLocationCoordinate2D coordinate=CLLocationCoordinate2DMake([coordinateArr[1] doubleValue], [coordinateArr[0] doubleValue]);
                coordinates[i]=coordinate;
            }
        }
        
        MAPolyline *mapPolyline=[MAPolyline polylineWithCoordinates:coordinates count:polylineCoordinates.count];
        free(coordinates);
        if (mapPolyline)
        {
            [mapPolylines addObject:mapPolyline];
        }
    }
    return mapPolylines;

}

+(NSInteger)distanceForCoordinateString:(NSString *)coordinateString
{
    NSInteger currentDistance=0;
    NSArray *polylineCoordinates=[coordinateString componentsSeparatedByString:@";"];
    if (polylineCoordinates.count>0)
    {
        MAMapPoint point1;
        MAMapPoint point2;
        for (NSInteger i=0; i<polylineCoordinates.count; i++)
        {
            NSString *polylineCoordinate=polylineCoordinates[i];
            NSArray *coordinateArr=[polylineCoordinate componentsSeparatedByString:@","];
            if (coordinateArr.count==2)
            {
                CLLocationCoordinate2D coordinate=CLLocationCoordinate2DMake([coordinateArr[1] doubleValue], [coordinateArr[0] doubleValue]);
                if (i==0)
                {
                    point2=MAMapPointForCoordinate(coordinate);
                }
                else
                {
                    point1=point2;
                    point2=MAMapPointForCoordinate(coordinate);
                    CLLocationDistance distance=MAMetersBetweenMapPoints(point1, point2);
                    currentDistance+=distance;
                }
            }
        }
    }
    return currentDistance;
}












@end
