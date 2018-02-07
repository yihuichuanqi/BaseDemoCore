//
//  BDGeoObject.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/12.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDGeoObject.h"
#import "BDSpotModel.h"

@implementation BDGeoObject

-(NSString *)fullAddress
{
    return [NSString stringWithFormat:@"%@%@%@%@%@%@%@",_province?:@"",_city?:@"",_district?:@"",_township?:@"",_neighborhood?:@"",_building?:@"",_detailAddress?:@""];
}
-(NSString *)shortAddress
{
    NSMutableString *string=[NSMutableString string];
    if (_city)
    {
        [string appendString:_city];
    }
    if(_district)
    {
        [string appendString:_district];
    }
    if (_detailAddress)
    {
        if ([_detailAddress hasPrefix:_city?:@""])
        {
            [string appendString:[_detailAddress substringFromIndex:_city.length]];
        }
        else
        {
            [string appendString:_detailAddress];
        }
    }
    else
    {
        [string appendFormat:@"%@%@%@%@",_district?:@"",_township?:@"",_neighborhood?:@"",_building?:@""];
    }
    return string;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"province=%@,city=%@,district=%@,township=%@,neighborhood=%@,building=%@,location={%f,%f}",_province,_city,_district,_township,_neighborhood,_building,_coordinate2D.latitude,_coordinate2D.longitude];
}


+(BDGeoObject *)geoObjectFromAMapPOI:(AMapPOI *)poi
{
    BDGeoObject *object=nil;
    if (poi)
    {
        object=[[BDGeoObject alloc]init];
        object.province=poi.province;
        object.city=poi.city;
        object.district=poi.district;
        object.detailAddress=poi.name;
        object.detailAddressDdescription=poi.address;
        object.coordinate2D=CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
    }
    return object;
}
+(AMapPOI *)mapPOIFromGeoObject:(BDGeoObject *)geoObject
{
    AMapPOI *poi=[[AMapPOI alloc]init];
    poi.province=geoObject.province;
    poi.city=geoObject.city;
    poi.district=geoObject.district;
    poi.name=geoObject.detailAddress;
    poi.address=geoObject.detailAddressDdescription;
    poi.location.latitude=geoObject.coordinate2D.latitude;
    poi.location.longitude=geoObject.coordinate2D.longitude;
    return poi;
}
+(BDGeoObject *)geoObjectFromSpot:(BDSpotModel *)spot
{
    BDGeoObject *object=nil;
    if (spot)
    {
        object.province=spot.province;
        object.city=spot.city;
        object.detailAddress=spot.address;
        object.coordinate2D=spot.coordinate2D;
    }
    return object;
}

+(instancetype)geoObjectWithReGeoCodeSearch:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    BDGeoObject *object=[[BDGeoObject alloc]init];
    object.formattedAddress=response.regeocode.formattedAddress;
    object.province=response.regeocode.addressComponent.province;
    object.city=response.regeocode.addressComponent.city;
    object.district=response.regeocode.addressComponent.district;
    object.township=response.regeocode.addressComponent.township;
    object.neighborhood=response.regeocode.addressComponent.neighborhood;
    object.building=response.regeocode.addressComponent.building;
    object.coordinate2D=CLLocationCoordinate2DMake(request.location.latitude, request.location.longitude);
    
    NSString *detailAddress=object.formattedAddress;
    if ([detailAddress hasPrefix:object.province])
    {
        detailAddress=[detailAddress substringFromIndex:object.province.length];
    }
    if ([detailAddress hasPrefix:object.city])
    {
        detailAddress=[detailAddress substringFromIndex:object.city.length];
    }
    if ([detailAddress hasPrefix:object.district])
    {
        detailAddress=[detailAddress substringFromIndex:object.district.length];
    }
    if (detailAddress.length>0)
    {
        object.detailAddress=detailAddress;
    }
    return object;
}



-(id)copyWithZone:(NSZone *)zone
{
    BDGeoObject *copyObject=[[BDGeoObject allocWithZone:zone]init];
    copyObject.formattedAddress=[self.formattedAddress copy];
    copyObject.coordinate2D=self.coordinate2D;
    copyObject.province=[self.province copy];
    copyObject.city=[self.city copy];
    copyObject.district=[self.district copy];
    copyObject.township=[self.township copy];
    copyObject.neighborhood=[self.neighborhood copy];
    copyObject.building=[self.building copy];
    copyObject.detailAddress=[self.detailAddress copy];
    copyObject.detailAddressDdescription=[self.detailAddressDdescription copy];
    return copyObject;
}

#pragma mark-NSCoding
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_formattedAddress?:@"" forKey:@"formattedAddress"];
    [aCoder encodeObject:[NSData dataWithBytes:&_coordinate2D length:sizeof(CLLocationCoordinate2D)] forKey:@"coordinate2D"];
    [aCoder encodeObject:_province?:@"" forKey:@"province"];
    [aCoder encodeObject:_city?:@"" forKey:@"city"];
    [aCoder encodeObject:_district?:@"" forKey:@"district"];
    [aCoder encodeObject:_township?:@"" forKey:@"township"];
    [aCoder encodeObject:_neighborhood?:@"" forKey:@"neighborhood"];
    [aCoder encodeObject:_building?:@"" forKey:@"building"];
    [aCoder encodeObject:_detailAddress?:@"" forKey:@"detailAddress"];
    [aCoder encodeObject:_detailAddressDdescription?:@"" forKey:@"detailAddressDdescription"];

}
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super init])
    {
        self.formattedAddress=[aDecoder decodeObjectForKey:@"formattedAddress"];
        [[aDecoder decodeObjectForKey:@"coordinate2D"] getBytes:&_coordinate2D length:sizeof(CLLocationCoordinate2D)];
        self.province=[aDecoder decodeObjectForKey:@"province"];
        self.city=[aDecoder decodeObjectForKey:@"city"];
        self.district=[aDecoder decodeObjectForKey:@"district"];
        self.township=[aDecoder decodeObjectForKey:@"township"];
        self.neighborhood=[aDecoder decodeObjectForKey:@"neighborhood"];
        self.building=[aDecoder decodeObjectForKey:@"building"];
        self.detailAddress=[aDecoder decodeObjectForKey:@"detailAddress"];
        self.detailAddressDdescription=[aDecoder decodeObjectForKey:@"detailAddressDdescription"];

    }
    return self;
}














@end
