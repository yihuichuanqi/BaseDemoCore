//
//  BDLocationObject.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/12.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMapReGeocodeSearchRequest,AMapReGeocodeSearchResponse;
@interface BDLocationObject : NSObject<NSCopying,NSCoding>

@property (nonatomic,strong) NSString *cityCode;
@property (nonatomic,strong) NSString *cityName;

@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *provinceName;
@property (nonatomic,copy) NSString *districtName;
@property (nonatomic,copy) NSString *detailAddress;
@property (nonatomic,assign) CLLocationDegrees latitude;
@property (nonatomic,assign) CLLocationDegrees longitude;

-(BOOL)hasGeoCoder;
-(CLLocation *)location2D;
-(CLLocationCoordinate2D)coordinate2D;

-(void)updateWithRegeoCodeSearch:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response;


@end









