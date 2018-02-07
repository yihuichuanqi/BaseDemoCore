//
//  BDLocationService.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDLocationService.h"
#import <MapKit/MapKit.h>

#import "NSDictionary+BD.h"
#import "BDLocationService+WGS84TOGCL.h"

#import "BDGeoObject.h"
#import "BDLocationObject.h"

#define BDGeoCodeFinishedBlockName @"BDGeoCodeFinishedBlockName"
#define BDDrivingTimeBlockName @"BDDrivingTimeBlockName"
#define BDDrivingPathBlockName @"BDDrivingPathBlockName"
#define BDGaodePOICompleteBlockName @"BDGaodePOICompleteBlockName"

static const NSTimeInterval SearchRequestTimeout=20.0;

@interface BDLocationService ()<AMapSearchDelegate,CLLocationManagerDelegate>

@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,strong) AMapSearchAPI *searchAPI;
//保存应用内定位block
@property (nonatomic,readonly) NSMutableDictionary<NSNumber *, BDCurrentLocationRefreshBlock> *locationRefreshBlocks;
@end


@implementation BDLocationService



-(AMapSearchAPI *)searchAPI
{
    if (!_searchAPI)
    {
        _searchAPI=[[AMapSearchAPI alloc]init];
        _searchAPI.delegate=self;
        _searchAPI.timeout=SearchRequestTimeout;
    }
    return _searchAPI;
}
-(BDLocationObject *)locationObj
{
    if (!_locationObj)
    {
        _locationObj=[self loadLocationObject]?:[[BDLocationObject alloc]init];
    }
    return _locationObj;
}
-(CLLocationManager *)locationManager
{
    if (!_locationManager)
    {
        _locationManager=[[CLLocationManager alloc]init];
        _locationManager.delegate=self;
        _locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
    }
    return _locationManager;
}
+(instancetype)sharedService
{
    static BDLocationService *service=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service=[[BDLocationService alloc]init];
    });
    return service;
}

-(id)init
{
    if(self=[super init])
    {
        _locationRefreshBlocks=[NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark- Location
-(BOOL)locationServiceAvailable
{
    //查询是否禁用掉地理位置信息
    if (![CLLocationManager locationServicesEnabled])
    {
        return NO;
    }
    else
    {
        CLAuthorizationStatus status=[CLLocationManager authorizationStatus];
        if (status!=kCLAuthorizationStatusNotDetermined&&(status==kCLAuthorizationStatusDenied||status==kCLAuthorizationStatusRestricted))
        {
            return NO;
        }
    }
    return YES;
}
//保存获取本地存储的定位信息
-(void)saveLocationObject
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.locationObj] forKey:kUCLocationObject];
}
-(BDLocationObject *)loadLocationObject
{
    return bd_castObj([NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:kUCLocationObject]],[BDLocationObject class]);
}

-(void)startUpdateLocation
{
    CLAuthorizationStatus status=[CLLocationManager authorizationStatus];
    //判断是否可定位
    BOOL authorizedStatus=(status==kCLAuthorizationStatusAuthorizedAlways||status==kCLAuthorizationStatusAuthorizedWhenInUse);
    if (!isIOS8)
    {
        //ios8之前的判断
    }
    if(authorizedStatus)
    {
        [self.locationManager startUpdatingLocation];
    }
    else
    {
        isIOS8?[self.locationManager requestAlwaysAuthorization]:[self.locationManager startUpdatingLocation];
    }
}
-(void)stopUpdateLocation
{
    [self.locationManager stopUpdatingLocation];
}
-(void)getCurrentLocation:(BDCurrentLocationRefreshBlock)complete
{
    @synchronized(self){
        
        if (!kCoordinateIsZeroOrInvalid(self.locationObj.coordinate2D))
        {
            if (complete)
            {
                complete(self.locationObj.coordinate2D,kGetCurrentLocationResult_Success,nil);
            }
        }
        else
        {
            [self getCurrentLocationWithTimeout:60.0 complete:complete];
        }
    }
}
-(void)getCurrentLocationWithTimeout:(NSTimeInterval)timeout complete:(BDCurrentLocationRefreshBlock)complete
{
    if (![self locationServiceAvailable])
    {
        //无法定位
        if (complete)
        {
            complete(CLLocationCoordinate2DMake(0, 0),kGetCurrentLocationResult_NotPermission,nil);
        }
    }
    static int blockCounter=0;
    int blockIndex=blockCounter++;
    [self startUpdateLocation];
    if (complete!=nil)
    {
        //保存block
        [self.locationRefreshBlocks bd_safeSetObject:complete forKey:@(blockIndex)];
        if (timeout>0)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                if ([self.locationRefreshBlocks.allKeys containsObject:@(blockIndex)])
                {
                    BDCurrentLocationRefreshBlock completeBlock=[self.locationRefreshBlocks objectForKey:@(blockIndex)];
                    [self.locationRefreshBlocks removeObjectForKey:@(blockIndex)];
                    completeBlock(CLLocationCoordinate2DMake(0, 0),kGetCurrentLocationResult_Failed,[NSError errorWithDomain:@"RefreshCurrentLocation" code:kCFURLErrorTimedOut userInfo:nil]);
                    
                }
            });
        }
    }    
}
-(void)updateCurrentLocation:(CLLocation *)location
{
    if (!CLLocationCoordinate2DIsValid(location.coordinate))
    {
        return;
    }
    [self stopUpdateLocation];
    [self updateLocationCoordinate:location.coordinate];
}

-(void)updateLocationCoordinate:(CLLocationCoordinate2D)coordinate
{
    //反地址编码
    static CLLocation *currentREGEOLocation=nil;
    CLLocation *location=[[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    if (currentREGEOLocation==nil||[location distanceFromLocation:currentREGEOLocation]>=500.0)
    {
        currentREGEOLocation=location;
        //开始反编译
        [self startGeoCode:currentREGEOLocation];
    }
    self.locationObj.latitude=coordinate.latitude;
    self.locationObj.longitude=coordinate.longitude;
}
#pragma mark-CLLocationManager Delegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    //最新的位置信息
    CLLocation *loca=[locations lastObject];
    if (loca)
    {
        if (CLLocationCoordinate2DIsValid(loca.coordinate))
        {
            //转化后的位置经纬度
            CLLocationCoordinate2D coordinate2D=[BDLocationService transformFromWGSToGCL:loca.coordinate];
            loca=[[CLLocation alloc]initWithLatitude:coordinate2D.latitude longitude:coordinate2D.longitude];
        }
        [self updateLocationCoordinate:loca.coordinate];
        //定位回调
        for (NSInteger index=self.locationRefreshBlocks.allKeys.count-1; index>=0; index--)
        {
            NSNumber *key=self.locationRefreshBlocks.allKeys[index];
            BDCurrentLocationRefreshBlock completeBlock=[self.locationRefreshBlocks objectForKey:key];
            [self.locationRefreshBlocks removeObjectForKey:key];
            completeBlock(loca.coordinate,kGetCurrentLocationResult_Success,nil);
        }
        //保存
        [self saveLocationObject];
    }
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //定位回调
    for (NSInteger index=self.locationRefreshBlocks.allKeys.count-1; index>=0; index--)
    {
        NSNumber *key=self.locationRefreshBlocks.allKeys[index];
        BDCurrentLocationRefreshBlock completeBlock=[self.locationRefreshBlocks objectForKey:key];
        [self.locationRefreshBlocks removeObjectForKey:key];
        completeBlock(CLLocationCoordinate2DMake(0, 0),kGetCurrentLocationResult_Failed,error);
    }
}
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    //此处不一定需要开启定位
    [self.locationManager startUpdatingLocation];
}

#pragma mark-AMapSearch GeoCode
-(void)startGeoCode:(CLLocation *)location
{
    [self startGeoCode:location.coordinate Radius:10000 complete:nil];
}
-(void)startGeoCode:(CLLocationCoordinate2D)coordinate Radius:(NSInteger)radius complete:(BDGeoCodeFinishedBlock)complete
{
    //T变化大才进行计算 节省电量
    AMapReGeocodeSearchRequest *regeoRequest=[[AMapReGeocodeSearchRequest alloc]init];
    regeoRequest.location=[AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeoRequest.radius=radius;
    regeoRequest.requireExtension=YES;
    //设置回调
    [self addAMapSearchCompleteBlock:complete withName:BDGeoCodeFinishedBlockName forRequest:regeoRequest];
    [self.searchAPI AMapReGoecodeSearch:regeoRequest];
}
#pragma mark - AMapSearch Path
-(void)searchDrivingTimeFromCoordinate:(CLLocationCoordinate2D)fromCoordinate ToCoordinate:(CLLocationCoordinate2D)toCoordinate complete:(BDDrivingTimeBlock)complete
{
    AMapDrivingRouteSearchRequest *naviReq=[[AMapDrivingRouteSearchRequest alloc]init];
    naviReq.requireExtension=YES;
    //出发
    naviReq.origin=[AMapGeoPoint locationWithLatitude:fromCoordinate.latitude longitude:fromCoordinate.longitude];
    //目的
    naviReq.destination=[AMapGeoPoint locationWithLatitude:toCoordinate.latitude longitude:toCoordinate.longitude];
    //设置回调
    [self addAMapSearchCompleteBlock:complete withName:BDDrivingTimeBlockName forRequest:naviReq];
    [self.searchAPI AMapDrivingRouteSearch:naviReq];
}
-(void)searchDrivingPathFromCoordinate:(CLLocationCoordinate2D)fromCoordinate ToCoordinate:(CLLocationCoordinate2D)toCoordinate Strategy:(NSInteger)strategy AvoidPolygons:(NSArray<AMapGeoPolygon *> *)avoidPolygons complete:(BDDrivingPathBlock)complete
{
    AMapDrivingRouteSearchRequest *naviReq=[[AMapDrivingRouteSearchRequest alloc]init];
    naviReq.requireExtension=YES;
    naviReq.strategy=strategy;
    //出发
    naviReq.origin=[AMapGeoPoint locationWithLatitude:fromCoordinate.latitude longitude:fromCoordinate.longitude];
    //目的
    naviReq.destination=[AMapGeoPoint locationWithLatitude:toCoordinate.latitude longitude:toCoordinate.longitude];
    naviReq.avoidpolygons=avoidPolygons;
    //设置回调
    [self addAMapSearchCompleteBlock:complete withName:BDDrivingPathBlockName forRequest:naviReq];
    [self.searchAPI AMapDrivingRouteSearch:naviReq];

}

#pragma mark-AMapSearch Delegate
//搜索失败
-(void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSObject *searchRequest=bd_castObj(request, [NSObject class]);
    BDDrivingPathBlock drivingPathCompleteBlock=[self getSearchCompleteBlockForRequest:searchRequest withName:BDDrivingPathBlockName];
    if (drivingPathCompleteBlock!=nil)
    {
        drivingPathCompleteBlock(nil,error);
    }
    
    BDDrivingTimeBlock drivingTimeCompleteBlock=[self getSearchCompleteBlockForRequest:searchRequest withName:BDDrivingTimeBlockName];
    if (drivingTimeCompleteBlock!=nil)
    {
        drivingTimeCompleteBlock(NO,0);
    }
    BDGaodePOICompleteBlcok gaodePOICompleteBlock=[self getSearchCompleteBlockForRequest:searchRequest withName:BDGaodePOICompleteBlockName];
    if (gaodePOICompleteBlock!=nil)
    {
        gaodePOICompleteBlock(nil,0,error);
    }
    [self cleanSearchCompleteBlockForRequst:searchRequest];
    
}
//逆地理编码
-(void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode!=nil)
    {
        //通过AMapReGeocodeSearchResponse 处理搜索结果
    }
    BDGeoCodeFinishedBlock geoCodeCompleteBlock=[self getSearchCompleteBlockForRequest:request withName:BDGeoCodeFinishedBlockName];
    if (geoCodeCompleteBlock!=nil)
    {
        BDGeoObject *object=[BDGeoObject geoObjectWithReGeoCodeSearch:request response:response];
        geoCodeCompleteBlock((response.regeocode!=nil&&response.regeocode.formattedAddress.length>0),object);
    }
    [self cleanSearchCompleteBlockForRequst:request];
    //保存逆编码信息
}
//路线
-(void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    BDDrivingPathBlock drivingPathCompleteBlock=[self getSearchCompleteBlockForRequest:request withName:BDDrivingPathBlockName];
    if (drivingPathCompleteBlock!=nil)
    {
        drivingPathCompleteBlock(response.route,nil);
    }
    BDDrivingTimeBlock drivingTimeCompleteBlcok=[self getSearchCompleteBlockForRequest:request withName:BDDrivingTimeBlockName];
    if (drivingTimeCompleteBlcok!=nil)
    {
        if (response.route.paths.count>0)
        {
            AMapPath *path=response.route.paths.firstObject;
            drivingTimeCompleteBlcok(YES,path.duration);
        }
        else
        {
            drivingTimeCompleteBlcok(NO,0);
        }
    }
    [self cleanSearchCompleteBlockForRequst:request];
}

#pragma mark-AMapSearchRequest Block
-(void)addAMapSearchCompleteBlock:(id)block withName:(NSString *)blockName forRequest:(NSObject *)request
{
    if (block!=nil)
    {
        NSMutableDictionary *blockValues=[bd_castObj(request.bd_exObject, [NSDictionary class]) mutableCopy];
        if (blockValues==nil)
        {
            blockValues=[NSMutableDictionary dictionary];
        }
        [blockValues bd_safeSetObject:block forKey:blockName];
        request.bd_exObject=[blockValues copy];
        
    }
}
-(id)getSearchCompleteBlockForRequest:(NSObject *)request withName:(NSString *)blockName
{
    NSDictionary *blockValues=bd_castObj(request.bd_exObject, [NSDictionary class]);
    return blockValues[blockName];
}
-(void)cleanSearchCompleteBlockForRequst:(NSObject *)request
{
    request.bd_exObject=nil;
}

+(NSString *)durationTimesStringWithTimeStamp:(NSInteger)timeStamp
{
    NSMutableString *string=[NSMutableString string];
    NSString *str_Hour=[NSString stringWithFormat:@"%zd",timeStamp/3600];
    if (![str_Hour isEqualToString:@"0"])
    {
        [string appendFormat:@"%@小时",str_Hour];
    }
    NSString *str_Minute=[NSString stringWithFormat:@"%zd",(timeStamp%3600)/60];
    if (![str_Minute isEqualToString:@"0"])
    {
        [string appendFormat:@"%@分",str_Minute];
    }
    NSString *str_Second=[NSString stringWithFormat:@"%zd",timeStamp%60];
    if (![str_Second isEqualToString:@"0"])
    {
        [string appendFormat:@"%@秒",str_Second];
    }
    if([str_Hour isEqualToString:@"0"]&&[str_Second isEqualToString:@"0"]&&![str_Minute isEqualToString:@"0"])
    {
        [string appendString:@"钟"];
    }
    return string;
    
}







/*
 
 -(void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
 {
 BDGaodePOICompleteBlcok gaodePOIBlock=[self getSearchCompleteBlockForRequest:request withName:BDGaodePOICompleteBlockName];
 if (gaodePOIBlock!=nil)
 {
 gaodePOIBlock(response.pois,response.count,nil);
 }
 }

 
 */



@end


BOOL kCoordinateIsZeroOrInvalid(CLLocationCoordinate2D coordinate2D)
{
    if (!CLLocationCoordinate2DIsValid(coordinate2D))
    {
        return YES;
    }
    if (ABS(coordinate2D.latitude-0)<DBL_EPSILON&&ABS(coordinate2D.longitude-0)<DBL_EPSILON)
    {
        return YES;
    }
    return NO;
}
MKCoordinateRegion kMKCoordinateRegionWithCoordinates(CLLocationDegrees minLatitude,CLLocationDegrees maxLatitude,CLLocationDegrees minLongitude,CLLocationDegrees maxLongitude)
{
    //有可能经度往相反方向计算 从而是负值但是会是同一个点
    //经纬度之间的跨度
    CLLocationDegrees latitudeDelta=fabs(maxLatitude-minLatitude);
    CLLocationDegrees longitideDelta=fabs(maxLongitude-minLongitude);
    //剔除一圈的数值
    CLLocationDegrees reverseLongitudeDelta=fabs(minLongitude+360.0-maxLongitude);
    //是否颠倒一下
    BOOL reverse=reverseLongitudeDelta<longitideDelta;
    if (reverse)
    {
        longitideDelta=reverseLongitudeDelta;
    }
    //中心点
    CLLocationDegrees centerLatitude=(maxLatitude+minLatitude)/2.0;
    CLLocationDegrees centerLongitude=(maxLongitude+minLongitude)/2.0;
    if (reverse)
    {
        centerLongitude=(maxLongitude+minLongitude+360.0)/2.0;
        if (centerLongitude>180.0)
        {
            centerLongitude-=180.0;
        }
    }
    MKCoordinateRegion region;
    region.center=CLLocationCoordinate2DMake(centerLatitude, centerLongitude);
    region.span=MKCoordinateSpanMake(latitudeDelta, longitideDelta);
    return region;
    
}



















