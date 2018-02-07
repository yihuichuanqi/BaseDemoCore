//
//  BDUserSearchFilter.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/16.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDUserSearchFilter.h"
#import "BDSpotFilter.h"
#import "NSDictionary+BD.h"

@implementation BDUserSearchFilter

-(id)initWithAttributes:(NSDictionary *)aAttributes
{
    self=[super initWithAttributes:aAttributes];
    if (self)
    {
        if (![aAttributes isKindOfClass:[NSDictionary class]])
        {
            aAttributes=nil;
        }
        BDSpotFilter *defaultFilter=[BDSpotFilter defaultFilter];
        if (aAttributes&&[aAttributes isKindOfClass:[NSDictionary class]])
        {
            _spotType=[self integerForObject:[aAttributes objectForKey:@"spotType"] key:@"spotType"];
            _hideBusy=[self integerForObject:[aAttributes objectForKey:@"free"] key:@"hideBusy"];
            _operateType=[self integerForObject:[aAttributes objectForKey:@"operateType"] key:@"operateType"];
            _propertyType=[self integerForObject:[aAttributes objectForKey:@"propertyType"] key:@"propertyType"];
            
            _operatorKeys=[aAttributes objectForKey:@"operatorKeys"];
            _codeBitList=[aAttributes objectForKey:@"codeBitList"];
            _tags=[aAttributes objectForKey:@"tags"];
            
        }
        else
        {
            _hideBusy=defaultFilter.searchFilter.hideBusy;
            _spotType=defaultFilter.searchFilter.spotType;
            _operateType=defaultFilter.searchFilter.operateType;
            _operatorKeys=defaultFilter.searchFilter.operatorKeys;
            _codeBitList=defaultFilter.searchFilter.codeBitList;
            _tags=defaultFilter.searchFilter.tags;
        }
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    BDUserSearchFilter *copy=[[BDUserSearchFilter allocWithZone:zone] init];
    copy.hideBusy=self.hideBusy;
    copy.codeBitList=self.codeBitList;
    copy.operatorKeys=self.operatorKeys;
    copy.spotType=self.spotType;
    copy.operateType=self.operateType;
    copy.propertyType=self.propertyType;
    copy.tags=self.tags;
    return copy;
}
-(NSDictionary *)attributesFromModel
{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic bd_safeSetObject:@(self.hideBusy) forKey:@"free"];
    [dic bd_safeSetObject:self.codeBitList forKey:@"codeBitList"];
    [dic bd_safeSetObject:self.operatorKeys forKey:@"operatorKeys"];
    [dic bd_safeSetObject:@(self.spotType) forKey:@"spotType"];
    [dic bd_safeSetObject:@(self.operateType) forKey:@"operateType"];
    [dic bd_safeSetObject:@(self.propertyType) forKey:@"propertyType"];
    [dic bd_safeSetObject:self.tags forKey:@"tags"];
    return dic;
}
-(void)updateWithAttributes:(NSDictionary *)aAttributes
{
    if (![aAttributes isKindOfClass:[NSDictionary class]])
    {
        return;
    }
    _spotType=[self integerForObject:[aAttributes objectForKey:@"spotType"] key:@"spotType"];
    _hideBusy=[self integerForObject:[aAttributes objectForKey:@"free"] key:@"hideBusy"];
    _operateType=[self integerForObject:[aAttributes objectForKey:@"operateType"] key:@"operateType"];
    _propertyType=[self integerForObject:[aAttributes objectForKey:@"propertyType"] key:@"propertyType"];
    
    _operatorKeys=[aAttributes objectForKey:@"operatorKeys"];
    _codeBitList=[aAttributes objectForKey:@"codeBitList"];
    _tags=[aAttributes objectForKey:@"tags"];

}

-(BOOL)isOnlyTeslaSuperSopt
{
    return ((self.hideBusy==NO)&&
            (self.spotType==BDSpotType_Super)&&
            (self.operateType==0)&&
            ([self.codeBitList isEqualToString:@"T"])&& //匹配品牌位序码
            ([self.tags isEqualToString:@""])&&
            ([self.operatorKeys isEqualToString:@"T"])); //匹配运营类型
}
-(void)setOnlyTeslaSuperSpot:(BOOL)onlyTeslaSuperSpot
{
    if (onlyTeslaSuperSpot)
    {
        _hideBusy=NO;
        _spotType=BDSpotType_Super;
        _operateType=0;
        _codeBitList=@"T";
        _tags=@"";
        _operatorKeys=@"T";
    }
    else
    {
        [self clearUserSearchFilter];
    }
}
-(BOOL)containOperators:(NSString *)operatorsString
{
    BOOL r=NO;
    NSArray *operators_self=[self.operatorKeys componentsSeparatedByString:@","];
    NSArray *operators=[operatorsString componentsSeparatedByString:@","];
    for (NSString *aOperatoe in operators_self)
    {
        if ([operators containsObject:aOperatoe])
        {
            r=YES;
            break;
        }
    }
    return r;
}
-(BOOL)containTags:(NSString *)tagsString
{
    BOOL r=NO;
    NSArray *tags_self=[self.tags componentsSeparatedByString:@","];
    NSArray *tags=[tagsString componentsSeparatedByString:@","];
    for (NSString *aTag in tags_self)
    {
        if ([tags containsObject:aTag])
        {
            r=YES;
            break;
        }
    }
    return r;
}
-(void)clearUserSearchFilter
{
    _hideBusy=NO;
    _spotType=BDSpotType_Unknow;
    _operateType=0;
    _propertyType=0;
    _codeBitList=@"";
    _tags=@"";
    _operatorKeys=@"";
}

#pragma mark-Private Method
//设置 如果对应obj不存在 则获取单例中保存的用户偏好数据
-(NSInteger)integerForObject:(id)obj key:(NSString *)key
{
    if (obj)
    {
        return isEmpty(obj)?0:[obj integerValue];
    }
    else
    {
        BDSpotFilter *defaultFilter=[BDSpotFilter defaultFilter];
        return [[defaultFilter.searchFilter valueForKey:key] integerValue];
    }
}












@end
