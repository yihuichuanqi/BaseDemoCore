//
//  BDFunctionConst.m
//  BaseDemoCore
//
//  Created by Admin on 2017/12/29.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDFunctionConst.h"

BD_EXTERN NSString *DecodeObjectFromDic(NSDictionary *dic,NSString *key)
{
    if (![dic isKindOfClass:[NSDictionary class]])
    {
        return nil;
    }
    id temp=[dic objectForKey:key];
    NSString *value=@"";
    if (NotNilAndNull(temp))
    {
        if ([temp isKindOfClass:[NSString class]])
        {
            value=temp;
        }
        else if ([temp isKindOfClass:[NSNumber class]])
        {
            value=[temp stringValue];
        }
        return value;
    }
    return nil;
}
BD_EXTERN id DecodeSafeObjectAtIndex(NSArray *arr,NSInteger index)
{
    if (IsArrEmpty(arr))
    {
        return nil;
    }
    if ([arr count]-1<index)
    {
        BDAssert([arr count]-1<index);
        return nil;
    }
    return [arr objectAtIndex:index];
}
BD_EXTERN NSString *DecodeStringFromDic(NSDictionary *dic,NSString *key)
{
    if (IsNilOrNull(dic))
    {
        return nil;
    }
    id temp=[dic objectForKey:key];
    if ([temp isKindOfClass:[NSString class]])
    {
        if ([temp isEqualToString:@"(null)"])
        {
            return @"";
        }
        return temp;
    }
    else if ([temp isKindOfClass:[NSNumber class]])
    {
        return [temp stringValue];
    }
    return nil;
}
BD_EXTERN NSString *DecodeDefaultStrFromDic(NSDictionary *dic,NSString *key,NSString *defaultStr)
{
    if (![dic isKindOfClass:[NSDictionary class]])
    {
        return nil;
    }
    id temp=[dic objectForKey:key];
    NSString *value=defaultStr;
    if (NotNilAndNull(temp))
    {
        if ([temp isKindOfClass:[NSString class]])
        {
            value=temp;
        }
        else if ([temp isKindOfClass:[NSNumber class]])
        {
            value=[temp stringValue];
        }
        return value;
    }
    return nil;

}



@implementation BDFunctionConst

@end
