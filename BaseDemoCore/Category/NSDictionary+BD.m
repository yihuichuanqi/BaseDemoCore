//
//  NSDictionary+BD.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

#define kDictionaryValueChangeKey @"allKeys"

#import "NSDictionary+BD.h"

@implementation NSDictionary (BD)

-(id)bd_safeObjectForKey:(id)aKey
{
    id obj=[self objectForKey:aKey];
    if ([obj isKindOfClass:[NSNull class]])
    {
        return @"";
    }
    if (!obj)
    {
        return @"";
    }
    return obj;
}
-(id)bd_nilObjectForKey:(id)aKey
{
    id obj=[self objectForKey:aKey];
    if ([obj isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    if (!obj)
    {
        return nil;
    }
    return obj;
}
-(id)bd_nilObjectForKey:(id)aKey forClass:(Class)objectClass
{
    id obj=[self bd_nilObjectForKey:aKey];
    return [obj isKindOfClass:objectClass]?obj:nil;
}
-(id)bd_objectForKey:(id)aKey withDefault:(id)defaultValue
{
    if (self[aKey]!=nil&&![self[aKey] isKindOfClass:[NSNull class]])
    {
        return [self bd_objectWithoutNSNumber:self[aKey]];
    }
    return defaultValue;
}
-(id)bd_objectForKeyArray:(id)aKeyArray withDefault:(id)defaultValue
{
    for (id aKey in aKeyArray)
    {
        if ([self.allKeys containsObject:aKey]&&![self[aKey] isKindOfClass:[NSNull class]])
        {
            return [self bd_objectWithoutNSNumber:self[aKey]];
        }
    }
    return defaultValue;
}


-(NSString *)bd_StringObjectForKey:(id)aKey
{
    id obj=[self bd_safeObjectForKey:aKey];
    return [NSString stringWithFormat:@"%@",obj];
}
-(NSInteger)bd_IntergerForKey:(id)aKey
{
    return [self bd_IntergerForKey:aKey withDefault:0];
}
-(NSInteger)bd_IntergerForKey:(id)aKey withDefault:(NSInteger)defaultValue
{
    if ([self.allKeys containsObject:aKey])
    {
        return [[self bd_StringObjectForKey:aKey] integerValue];
    }
    return defaultValue;
}
-(double)bd_DoubleForKey:(id)aKey
{
    return [[self bd_safeObjectForKey:aKey] doubleValue];
}
-(NSDate *)bd_DateObjectForKey:(id)aKey
{
    return [NSDate dateWithTimeIntervalSince1970:[self bd_DoubleForKey:aKey]];
}
-(BOOL)bd_BoolForKey:(id)aKey
{
    return [self bd_IntergerForKey:aKey]>0;
}
-(BOOL)bd_BoolForKey:(id)aKey withDefault:(BOOL)defaultValue
{
    return [self bd_IntergerForKey:aKey withDefault:defaultValue?1:0]>0;
}
-(NSArray *)bd_ArrayObjectForKey:(id)aKey
{
    return [self bd_nilObjectForKey:aKey forClass:[NSArray class]];
}
-(NSDictionary *)bd_DictionaryObjectForKey:(id)aKey
{
    return [self bd_nilObjectForKey:aKey forClass:[NSDictionary class]];
}

-(id)bd_modelObjectForKey:(id)aKey class:(Class)modelClass
{
    if(modelClass==nil)
    {
        return nil;
    }
    NSAssert([modelClass isSubclassOfClass:[BDBaseModelObject class]], @"modelClass Must Be SubClass Of <BDBaseModelObject>!!!!");
    NSDictionary *dict=[self bd_DictionaryObjectForKey:aKey];
    return [modelClass modelWithAttributes:dict&&dict.count?dict:nil];
}
-(NSArray *)bd_modelArrayForKey:(id)aKey class:(Class)modelClass
{
    NSAssert([modelClass isSubclassOfClass:[BDBaseModelObject class]], @"modelClass Must Be SubClass Of <BDBaseModelObject>!!!!");
    return [modelClass arrayWithAttributesArray:[self bd_ArrayObjectForKey:aKey]?:@[]];
}

+(NSDictionary *)bd_DictionaryWithArray:(NSArray *)aArray keyPropertyName:(NSString *)keyPropertyName
{
    __block NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithCapacity:aArray.count];
    [aArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        id key=[obj valueForKey:keyPropertyName];
        if (key!=nil)
        {
            dict[key]=obj;
        }
        
    }];
    return [dict copy];
}

-(id)bd_objectWithoutNSNumber:(id)object
{
    if ([object isKindOfClass:[NSNumber class]])
    {
        return [NSString stringWithFormat:@"%@",object];
    }
    return object;
}

-(NSString *)bd_ErrorMessage
{
    return [self bd_StringObjectForKey:@"error"];
}
-(NSInteger)bd_ErrorCode
{
    return [self bd_IntergerForKey:@"code" withDefault:1];
}
-(NSDictionary *)bd_ResponseData
{
    return [self bd_DictionaryObjectForKey:@"data"];
}




@end

@implementation NSMutableDictionary (BD)

-(void)bd_safeSetObject:(id)aOject forKey:(id)aKey
{
    if (aOject==nil)
    {
        return;
    }
    if (aKey==nil)
    {
        return;
    }
    
    [self willChangeValueForKey:kDictionaryValueChangeKey];
    [self setObject:aOject forKey:aKey];
    [self didChangeValueForKey:kDictionaryValueChangeKey];
    
}
-(void)bd_safeSetObject:(id)aOject forKey:(id)aKey withClass:(Class)aClass
{
    if (![aOject isKindOfClass:aClass])
    {
        return;
    }
    [self bd_safeSetObject:aOject forKey:aKey];
}
-(void)bd_safeRemoveObjectForKey:(id)aKey
{
    if (aKey!=nil)
    {
        [self willChangeValueForKey:kDictionaryValueChangeKey];
        [self removeObjectForKey:aKey];
        [self didChangeValueForKey:kDictionaryValueChangeKey];
    }
}



@end
