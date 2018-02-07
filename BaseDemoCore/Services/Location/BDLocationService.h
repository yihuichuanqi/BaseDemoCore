//
//  BDLocationService.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <MapKit/MapKit.h>

#define kUCLocationObject @"kUCLocationObject" //当前定位信息

@class BDLocationObject,BDGeoObject;

//获取当前位置结果
typedef NS_ENUM(NSUInteger,kGetCurrentLocationResult) {
    
    kGetCurrentLocationResult_Success=0,
    kGetCurrentLocationResult_NotPermission=1,
    kGetCurrentLocationResult_Failed=2,
};
//定位刷新Block
typedef void (^BDCurrentLocationRefreshBlock)(CLLocationCoordinate2D coordinate,kGetCurrentLocationResult result,NSError *error);
//高德逆编码Block
typedef void (^BDGeoCodeFinishedBlock)(BOOL success,BDGeoObject *geoObject);
//驾驶时间Block
typedef void (^BDDrivingTimeBlock)(BOOL success,NSInteger duration);
//驾驶路线Block
typedef void (^BDDrivingPathBlock)(AMapRoute *route,NSError *error);
//高德POIBlock
typedef void (^BDGaodePOICompleteBlcok)(NSArray<AMapPOI *>*pois,NSInteger count,NSError *error);

@interface BDLocationService : NSObject

+(instancetype)sharedService;
//定位是否可用
@property (nonatomic,readonly) BOOL locationServiceAvailable;
@property (nonatomic,strong) BDLocationObject *locationObj;//定位信息


//开始结束定位
-(void)startUpdateLocation;
-(void)stopUpdateLocation;
//获取当前位置 如果当前未定位 则先定位
-(void)getCurrentLocation:(BDCurrentLocationRefreshBlock)complete;
-(void)getCurrentLocationWithTimeout:(NSTimeInterval)timeout complete:(BDCurrentLocationRefreshBlock)complete;
//外部更新定位信息
-(void)updateCurrentLocation:(CLLocation *)location;

//逆地理编码
-(void)startGeoCode:(CLLocationCoordinate2D)coordinate Radius:(NSInteger)radius complete:(BDGeoCodeFinishedBlock)complete;
//搜索AB两点的驾驶时间
-(void)searchDrivingTimeFromCoordinate:(CLLocationCoordinate2D)fromCoordinate ToCoordinate:(CLLocationCoordinate2D)toCoordinate complete:(BDDrivingTimeBlock)complete;
//搜索AB两点的驾驶路线 （驾驶策略strategy=0 速度优先）
-(void)searchDrivingPathFromCoordinate:(CLLocationCoordinate2D)fromCoordinate ToCoordinate:(CLLocationCoordinate2D)toCoordinate Strategy:(NSInteger)strategy AvoidPolygons:(NSArray<AMapGeoPolygon *> *)avoidPolygons complete:(BDDrivingPathBlock)complete;
//格式化字符串
+(NSString *)durationTimesStringWithTimeStamp:(NSInteger)timeStamp;

@end

//判断位置是否合法或者为zero
BOOL kCoordinateIsZeroOrInvalid(CLLocationCoordinate2D coordinate2D);
//获取两个经纬度之间的坐标范围(相应的扩大一倍)
MKCoordinateRegion kMKCoordinateRegionWithCoordinates(CLLocationDegrees minLatitude,CLLocationDegrees maxLatitude,CLLocationDegrees minLongitude,CLLocationDegrees maxLongitude);










