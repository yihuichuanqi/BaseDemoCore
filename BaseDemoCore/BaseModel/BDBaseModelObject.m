//
//  BDBaseModelObject.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDBaseModelObject.h"
#import <dlfcn.h>

@implementation BDBaseModelObject

//可自定义log样式

-(id)initWithAttributes:(NSDictionary *)aAttributes
{
    if (self=[super init])
    {
        [self updateWithAttributes:aAttributes];
    }
    return self;
}
-(void)updateWithAttributes:(NSDictionary *)aAttributes
{
    //do nothing 需子类重载
}


+(instancetype)modelWithAttributes:(NSDictionary *)aAttributes
{
    return [self createModelWithAttributes:aAttributes];
}
+(instancetype)createModelWithAttributes:(NSDictionary *)aAttributes
{
    return aAttributes==nil?nil:[[self alloc]initWithAttributes:aAttributes];
}

+(NSString *)modelManagerStoreKey
{
    return NSStringFromClass(self);
}

+(NSArray *)arrayWithAttributesArray:(NSArray *)aArray
{
    NSMutableArray *arrayBuilder=[NSMutableArray array];
    if ([aArray isKindOfClass:[NSArray class]])
    {
        for (NSDictionary *attributeDic in aArray)
        {
            if ([attributeDic isKindOfClass:[NSDictionary class]])
            {
                //可修改 安全加载方式
                [arrayBuilder addObject:[self modelWithAttributes:attributeDic]];
            }
        }
    }
    return [NSArray arrayWithArray:arrayBuilder];
}
-(NSDictionary *)attributesFromModel
{
    //子类重载
    return @{};
}
+(NSArray *)attributesArrayFromModelArray:(NSArray *)aArray
{
    NSMutableArray *arrayBuilder=[NSMutableArray array];
    if ([aArray isKindOfClass:[NSArray class]])
    {
        for (id subObject in aArray)
        {
            if ([subObject isKindOfClass:[BDBaseModelObject class]])
            {
                BDBaseModelObject *modelObject=(BDBaseModelObject *)subObject;
                [arrayBuilder addObject:[modelObject attributesFromModel]];
            }
        }
    }
    return [NSArray arrayWithArray:arrayBuilder];
}


-(NSString *)keyProperty
{
    //未实现 可以使用 -(BOOL)containsInArray:withKeyPropertyName:替代
    return nil;
}
+(NSString *)keyPropertyWithAttributes:(NSDictionary *)aAttributes
{
    return nil;
}
-(BOOL)isEqualToModel:(BDBaseModelObject *)model
{
    if (model.class==self.class||[model.class isSubclassOfClass:self.class]||[self.class isSubclassOfClass:model.class])
    {
        return model==self||[model.keyProperty isEqualToString:self.keyProperty];
    }
    return NO;
}


#pragma mark-NSCoding
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self attributesFromModel] forKey:@"attributes"];
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    id attributes=[aDecoder decodeObjectForKey:@"attributes"];
    return attributes==nil?nil:[self initWithAttributes:attributes];
}






@end

@implementation NSArray (BaseModelObjectEx)

-(NSUInteger)indexOfModelObject:(BDBaseModelObject *)aObject
{
    if (aObject!=nil&&[aObject isKindOfClass:[BDBaseModelObject class]])
    {
        return [self indexOfObjectPassingTest:^BOOL(BDBaseModelObject *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            return [aObject isEqualToModel:obj];
        }];
    }
    return NSNotFound;
}
-(NSUInteger)indexOfModelKey:(NSString *)aKey
{
    if (aKey!=nil&&[aKey isKindOfClass:[NSString class]])
    {
        return [self indexOfObjectPassingTest:^BOOL(BDBaseModelObject * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return [obj.keyProperty isEqualToString:aKey];
        }];
    }
    return NSNotFound;
}

-(BOOL)containsModelObject:(BDBaseModelObject *)aObject
{
    return [self indexOfModelObject:aObject]!=NSNotFound;
}
-(BOOL)containsModelKey:(NSString *)aKey
{
    return [self indexOfModelKey:aKey]!=NSNotFound;
}
-(id)modelObjectForKey:(NSString *)aKey
{
    NSUInteger index=[self indexOfModelKey:aKey];
    if (index>=self.count)
    {
        return nil;
    }
    return self[index];
}
@end


@implementation NSMutableArray (BaseModelObjectEx)

-(BOOL)removeModelObject:(BDBaseModelObject *)aObject
{
    NSUInteger index=[self indexOfModelObject:aObject];
    if (index!=NSNotFound)
    {
        [self removeObjectAtIndex:index];
        return YES;
    }
    return NO;
}
@end

















