//
//  BDGeoObject.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/12.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*高德地图 点信息*/

#import <Foundation/Foundation.h>
#import <AMapSearchKit/AMapSearchKit.h>

@class BDSpotModel;
@interface BDGeoObject : NSObject<NSCopying,NSCoding>

@property (nonatomic,copy) NSString *formattedAddress; //格式化地址

@property (nonatomic,copy) NSString *province;
@property (nonatomic,copy) NSString *city;
@property (nonatomic,copy) NSString *district;
@property (nonatomic,copy) NSString *township;
@property (nonatomic,copy) NSString *neighborhood;
@property (nonatomic,copy) NSString *building;
@property (nonatomic,copy) NSString *detailAddress;//去除省市区乡镇之后的详细地址 可能为空
@property (nonatomic,copy) NSString *detailAddressDdescription;//detailAddress的地址信息、某路某号
@property (nonatomic,assign) CLLocationCoordinate2D coordinate2D;


-(NSString *)fullAddress;
-(NSString *)shortAddress;

//模型转换
+(BDGeoObject *)geoObjectFromAMapPOI:(AMapPOI *)poi;
+(AMapPOI *)mapPOIFromGeoObject:(BDGeoObject *)geoObject;
+(BDGeoObject *)geoObjectFromSpot:(BDSpotModel *)spot;

+(instancetype)geoObjectWithReGeoCodeSearch:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response;



@end
