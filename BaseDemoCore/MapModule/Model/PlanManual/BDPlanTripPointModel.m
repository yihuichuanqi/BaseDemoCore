//
//  BDPlanTripPointModel.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDPlanTripPointModel.h"
#import "BDPathPlanPOIModel.h"

@implementation BDPlanTripPointModel

#pragma mark-NSCoding
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self attributesFromModel] forKey:@"attributes"];
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self=[super init];
    if (self)
    {
        NSDictionary *attributes=[aDecoder decodeObjectForKey:@"attributes"];
        [self updateWithAttributes:attributes];
    }
    return self;
}

-(id)initWithAttributes:(NSDictionary *)aAttributes
{
    self=[super init];
    if (self)
    {
        [self updateWithAttributes:aAttributes];
    }
    return self;
}
-(void)updateWithAttributes:(NSDictionary *)aAttributes
{
    self.city=[aAttributes objectForKey:@"city"];
}
-(NSDictionary *)attributesFromModel
{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    
    return dict;
}

+(instancetype)pointWithPathPlanPOI:(BDPathPlanPOIModel *)pathPlanPOI
{
    if (pathPlanPOI==nil)
    {
        return nil;
    }
    
    BDPlanTripPointModel *point=[BDPlanTripPointModel new];
    point.address=pathPlanPOI.name;
    point.province=@"";
    point.city=@"";
    point.location=pathPlanPOI.coordinate;
    point.spot=pathPlanPOI.spot;
    return point;
    
}

+(BDPlanTripPointModel *)objectFromAmapPOI:(AMapPOI *)poi
{
    BDPlanTripPointModel *object=nil;
    if (poi)
    {
        object=[[BDPlanTripPointModel alloc]init];
        object.province=poi.province;
        object.city=poi.city;
        NSMutableString *address=[NSMutableString string];
        if (poi.city)
        {
            [address appendString:poi.city];
        }
        if (poi.district)
        {
            [address appendString:poi.district];
        }
        if (poi.name.length==0||[poi.name isEqualToString:poi.district]||[poi.name isEqualToString:poi.city])
        {
            object.address=[address copy];
        }
        else
        {
            object.address=poi.name;
        }
        object.location=CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
    }
    return object;
}











@end
