//
//  BDMapTripService.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/12.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapNaviKit/AMapNaviKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface BDMapTripService : NSObject

//在AMapPath上寻找指定距离能保证该点半径内的存在充电点的最远位置
+(void)findFarestLocationWhichExistSpotInRoadDistance:(NSInteger)roadDistance
                                             amapPath:(AMapPath *)path
                                               radius:(NSInteger)radius
                                        finishedBlock:(void(^)(BOOL noNeedToFind,CLLocationCoordinate2D farestLocationCoor,NSInteger farestLocationRadius,NSArray *spots,NSArray<NSDictionary *> *searchCircles))complete;

//使用AMapPath返回坐标字符串
+(NSString *)makeCoordinatesStringWithAMapPath:(AMapPath *)path;
//使用AMapPath数组返回坐标字符串
+(NSString *)makeCoordinatesStringWithAMapPathsArray:(NSArray<AMapPath *> *)pathArray;

//使用AMapPath返回画线路径
+(NSMutableArray<MAPolyline *> *)makePolyLinesWithAMapPath:(AMapPath *)aMapPath;
//使用坐标字符串返回画线路径
+(NSMutableArray<MAPolyline *> *)makePolyLinesWithCoordinatesString:(NSString *)coordinatesString;

//坐标字符串的总长度(米)
+(NSInteger)distanceForCoordinateString:(NSString *)coordinateString;








@end
