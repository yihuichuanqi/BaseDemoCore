//
//  BDSpotFilter.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/15.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDSpotFilter.h"
#import "NSDictionary+BD.h"
#import "BDSpotModel.h"
#import "BDUserSearchFilter.h"

@implementation BDSpotFilter

+(instancetype)defaultFilter
{
    static BDSpotFilter *filter=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        filter=[[BDSpotFilter alloc]init];
        filter.onlyKeyword=NO;
        filter.distance=50*1000;//默认搜索范围50公里
        filter.sortType=SpotFilterSortType_Distance;
        filter.filterLocation=[[BDSpotFilter getHotCityArray] firstObject];//默认全国
        filter.searchFilter=[[BDUserSearchFilter alloc]init];
    });
    return [filter copy];
}
-(id)initWithAttributes:(NSDictionary *)aAttributes
{
    self=[super init];
    if (self)
    {
        if (![aAttributes isKindOfClass:[NSDictionary class]])
        {
            aAttributes=nil;
        }
        _keyword=[aAttributes bd_StringObjectForKey:@"keyword"];
        _onlyKeyword=[aAttributes bd_BoolForKey:@"onlyKeyword"];
        _distance=[aAttributes bd_IntergerForKey:@"distance"];
        _sortType=[aAttributes bd_IntergerForKey:@"sortType"];
        
        if ([aAttributes bd_safeObjectForKey:@"filterLocation"])
        {
            _filterLocation=[[BDFilterLocation alloc]initWithAttributes:aAttributes[@"filterLocation"]];
        }
    }
    return self;
}

-(BOOL)isEqualToSpotFilter:(BDSpotFilter *)spotFilter
{
    BOOL result=(self.distance==spotFilter.distance)&&(self.filterLocation.type==spotFilter.filterLocation.type);
    
    NSString *address1=self.filterLocation.address;
    NSString *address2=spotFilter.filterLocation.address;
    if (!isEmpty(address1)&&!isEmpty(address2))
    {
        result=result&&[address1 isEqualToString:address2];
    }
    else if (!isEmpty(address1)||!isEmpty(address2))
    {
        result=NO;
    }
    return result;
    
}

-(NSDictionary *)filterParams
{
    BDSpotFilter *defaultFilter=[BDSpotFilter defaultFilter];
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:@(self.sortType) forKey:@"sort"];
    if (!isEmpty(self.keyword))
    {
        [params setObject:self.keyword forKey:@"keyword"];
    }
    if (self.distance>0&&[self hadFilterLocation])
    {
        [params setObject:@(self.filterLocation.latitude) forKey:@"latitude"];
        [params setObject:@(self.filterLocation.longitude) forKey:@"longitude"];
        if (self.filterLocation.type==SpotFilterLocationType_Country)
        {
            //全国 不限制距离
        }
        else if (self.filterLocation.type==SpotFilterLocationType_HotCity)
        {
            //热门城市
            [params bd_safeSetObject:self.filterLocation.cityCode forKey:@"cityCode"];
        }
        else
        {
            [params setObject:@(self.distance) forKey:@"distance"];
        }
    }
    //其他用户偏好设置
    NSMutableDictionary *data=[NSMutableDictionary dictionary];
    //站点速率
    //支持品牌 默认全选则不过滤
    //运营商
    //运营类型
    //标签
    //是否仅显示空闲
    if(data.allKeys.count)
    {
        [params setObject:data forKey:@"userFilter"];
    }
    return params;
    
}

-(BOOL)hadFilterLocation
{
    return self.filterLocation.type!=SpotFilterLocationType_None;
}
-(NSDictionary *)responseDictionary
{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    [dict bd_safeSetObject:@(self.onlyKeyword) forKey:@"onleKeyword"];
    [dict bd_safeSetObject:@(self.sortType) forKey:@"sortType"];
    [dict bd_safeSetObject:@(self.distance) forKey:@"distance"];
    if ([self hadFilterLocation])
    {
        [dict bd_safeSetObject:[self.filterLocation responseDictionary] forKey:@"filterLocation"];
    }
    [dict bd_safeSetObject:@"" forKey:@"searchFilter"];
    return dict;
}

+(NSArray *)getHotCityArray
{
    BDFilterLocation *countryLoc=[[BDFilterLocation alloc]initWithAttributes:@{@"type":@(SpotFilterLocationType_Country),@"address":@"全国"}];
    //首先添加（全国）类型
    NSMutableArray *cityArray=[NSMutableArray arrayWithObject:countryLoc];
    NSArray *hotCity=@[];
    
    return cityArray;
}

#pragma mark-NSCopying
-(id)copyWithZone:(NSZone *)zone
{
    BDSpotFilter *copy=[[[self class] allocWithZone:zone] init];
    copy.distance=_distance;
    copy.sortType=_sortType;
    copy.keyword=_keyword;
    copy.onlyKeyword=_onlyKeyword;
    if (_filterLocation)
    {
        copy.filterLocation=[_filterLocation copy];
    }
    return copy;
}

@end


@implementation BDSpotFilterItem

-(id)initWithAttributes:(NSDictionary *)aAttributes
{
    self=[super init];
    if (self)
    {
        if (![aAttributes isKindOfClass:[NSDictionary class]])
        {
            aAttributes=nil;
        }
        _title=[aAttributes bd_StringObjectForKey:@"title"];
        _value=[aAttributes bd_IntergerForKey:@"value"];
    }
    return self;
}
@end



@implementation BDFilterLocation

-(id)initWithAttributes:(NSDictionary *)aAttributes
{
    self=[super initWithAttributes:aAttributes];
    if (self)
    {
        if (![aAttributes isKindOfClass:[NSDictionary class]])
        {
            aAttributes=nil;
        }
        
        _type=[aAttributes bd_IntergerForKey:@"type"];
        _address=[aAttributes bd_objectForKeyArray:@[@"address",@"name"] withDefault:nil];
        _latitude=[aAttributes bd_DoubleForKey:@"latitude"];
        _longitude=[aAttributes bd_DoubleForKey:@"longitude"];
        _cityCode=[aAttributes bd_StringObjectForKey:@"cityCode"];
    }
    return self;
}
-(id)copyWithZone:(NSZone *)zone
{
    BDFilterLocation *copy=[[[self class]allocWithZone:zone] init];
    copy.type=_type;
    copy.latitude=_latitude;
    copy.longitude=_longitude;
    copy.address=_address;
    copy.cityCode=_cityCode;
    return copy;
}

-(NSDictionary *)responseDictionary
{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    [dict bd_safeSetObject:@(self.type) forKey:@"type"];
    [dict bd_safeSetObject:self.address forKey:@"address"];
    [dict bd_safeSetObject:@(self.latitude) forKey:@"latitude"];
    [dict bd_safeSetObject:@(self.longitude) forKey:@"longitude"];
    [dict bd_safeSetObject:self.cityCode forKey:@"cityCode"];

    return dict;
}

-(CLLocation *)location
{
    CLLocationCoordinate2D coordinate2D=CLLocationCoordinate2DMake(self.latitude, self.longitude);
    if (CLLocationCoordinate2DIsValid(coordinate2D))
    {
        return [[CLLocation alloc]initWithLatitude:self.latitude longitude:self.longitude];
    }
    return nil;
}

@end


@implementation BDSpotSortTypeInfo

-(id)initWithAttributes:(NSDictionary *)aAttributes
{
    if (self=[super initWithAttributes:aAttributes])
    {
        _type=[aAttributes bd_IntergerForKey:@"key"];
        _name=[aAttributes bd_StringObjectForKey:@"name"];
    }
    return self;
}

@end










