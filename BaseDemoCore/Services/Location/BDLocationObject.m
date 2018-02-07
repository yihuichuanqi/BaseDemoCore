//
//  BDLocationObject.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/12.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDLocationObject.h"
#import <AMapSearchKit/AMapSearchKit.h>
@implementation BDLocationObject

-(id)copyWithZone:(NSZone *)zone
{
    BDLocationObject *copyObject=[[BDLocationObject allocWithZone:zone]init];
    copyObject.latitude=self.latitude;
    copyObject.longitude=self.longitude;
    copyObject.cityCode=[self.cityCode copy];
    copyObject.cityName=[self.cityName copy];
    return copyObject;
}

-(NSString *)cityName
{
    if (!_cityName||!_cityName.length)
    {
        return @"";
    }
    return _cityName;
}
-(NSString *)cityCode
{
    if (!_cityCode||!_cityCode.length)
    {
        return @"";
    }
    return _cityCode;
}
-(NSString *)provinceName
{
    return _provinceName?:@"";
}


-(BOOL)hasGeoCoder
{
    if (_cityCode.length&&_cityName.length&&CLLocationCoordinate2DIsValid(self.coordinate2D))
    {
        return YES;
    }
    return NO;
}
-(CLLocation *)location2D
{
    CLLocation *location=[[CLLocation alloc]initWithLatitude:_latitude longitude:_longitude];
    return location;
}
-(CLLocationCoordinate2D)coordinate2D
{
    return CLLocationCoordinate2DMake(_latitude, _longitude);
}

-(void)updateWithRegeoCodeSearch:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    self.latitude=request.location.latitude;
    self.longitude=request.location.longitude;
    
    self.name=response.regeocode.pois.firstObject.name;
    self.provinceName=response.regeocode.addressComponent.province;
    self.cityCode=response.regeocode.addressComponent.adcode;
    self.cityName=response.regeocode.addressComponent.city;
    self.districtName=response.regeocode.addressComponent.district;
    self.detailAddress=[NSString stringWithFormat:@"%@%@%@",response.regeocode.addressComponent.township,response.regeocode.addressComponent.neighborhood,response.regeocode.addressComponent.building];
    if (isEmpty(self.cityName))
    {
        self.cityName=response.regeocode.addressComponent.province;
    }
}

#pragma mark-NSCoding
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.cityCode forKey:@"cityCode"];
    [aCoder encodeObject:self.cityName forKey:@"cityName"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.provinceName forKey:@"provinceName"];
    [aCoder encodeObject:self.districtName forKey:@"districtName"];
    [aCoder encodeObject:self.detailAddress forKey:@"detailAddress"];
    [aCoder encodeDouble:self.latitude forKey:@"latitude"];
    [aCoder encodeDouble:self.longitude forKey:@"longitude"];

}
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super init])
    {
        _cityCode=[aDecoder decodeObjectForKey:@"cityCode"];
        _cityName=[aDecoder decodeObjectForKey:@"cityName"];
        _name=[aDecoder decodeObjectForKey:@"name"];
        _provinceName=[aDecoder decodeObjectForKey:@"provinceName"];
        _districtName=[aDecoder decodeObjectForKey:@"districtName"];
        _detailAddress=[aDecoder decodeObjectForKey:@"detailAddress"];
        _latitude=[aDecoder decodeDoubleForKey:@"latitude"];
        _longitude=[aDecoder decodeDoubleForKey:@"longitude"];
    }
    return self;
}








@end
