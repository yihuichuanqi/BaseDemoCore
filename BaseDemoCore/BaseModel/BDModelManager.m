//
//  BDModelManager.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDModelManager.h"
#import "BDBaseModelObject.h"
#import "NSDictionary+BD.h"

@interface BDModelManager ()

//字典用于存储以modelKey为key 以MapTable为Value
@property (nonatomic,strong) NSMutableDictionary<NSString *, NSMapTable<NSString *,BDBaseModelObject *>*> *modelObjectHashTable;
@end


@implementation BDModelManager

+(instancetype)shareManager
{
    static BDModelManager *manager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager=[BDModelManager new];
    });
    return manager;
}
-(instancetype)init
{
    if (self=[super init])
    {
        self.modelObjectHashTable=[NSMutableDictionary dictionary];
    }
    return self;
}

-(NSMapTable<NSString *,BDBaseModelObject *> *)getObjectMapForModelClass:(Class)modelClass
{
    if (modelClass==nil)
    {
        return nil;
    }
    //创建模型类 对象池
    NSString *storeKey=nil;
    if ([modelClass respondsToSelector:@selector(modelManagerStoreKey)])
    {
        storeKey=[modelClass modelManagerStoreKey];
    }
    else
    {
        storeKey=NSStringFromClass(modelClass);
    }
    
    if (self.modelObjectHashTable[storeKey]==nil)
    {
        //对象还未存储 则创建空
        self.modelObjectHashTable[storeKey]=[NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsWeakMemory];
    }
    return self.modelObjectHashTable[storeKey];
}
-(id)modelWithAttributes:(NSDictionary *)attributes modelClass:(Class)modelClass
{
    //获取类对象池
    NSMapTable<NSString *, BDBaseModelObject *> *objectMap=[self getObjectMapForModelClass:modelClass];
    //取出已有对象
    NSString *modelKey=[modelClass keyPropertyWithAttributes:attributes];
    BDBaseModelObject *modelObject=[objectMap objectForKey:modelKey];
    if (modelObject!=nil)
    {
        //更新对象
        [modelObject updateWithAttributes:attributes];
    }
    else
    {
        //创建对象
        modelObject =[modelClass createModelWithAttributes:attributes];
        [objectMap setObject:modelObject forKey:modelKey];
    }
    return modelObject;
}
-(id)localModelWithKey:(NSString *)modelKey modelClass:(Class)modelClass
{
    NSMapTable<NSString *,BDBaseModelObject *> *objectMap=[self getObjectMapForModelClass:modelClass];
    return bd_castObj([objectMap objectForKey:modelKey], modelClass);
}








@end


@implementation NSDictionary (BDUpdateAttribute)

-(BOOL)bd_updateObject:(NSObject *)obj propertyName:(NSString *)propertyName withInteger:(NSString *)attributeName
{
    if ([self objectForKey:attributeName]!=nil)
    {
        [obj setValue:@([self bd_IntergerForKey:attributeName]) forKey:propertyName];
        return YES;
    }
    return NO;
}
-(BOOL)bd_updateObject:(NSObject *)obj propertyName:(NSString *)propertyName withString:(NSString *)attributeName
{
    if ([self objectForKey:attributeName]!=nil)
    {
        [obj setValue:[self bd_StringObjectForKey:attributeName] forKey:propertyName];
        return YES;
    }
    return NO;
}
-(BOOL)bd_updateObject:(NSObject *)obj propertyName:(NSString *)propertyName withDate:(NSString *)attributeName
{
    if ([self objectForKey:attributeName]!=nil)
    {
        [obj setValue:[self bd_DateObjectForKey:attributeName] forKey:propertyName];
        return YES;
    }
    return NO;
}
-(BOOL)bd_updateObject:(NSObject *)obj propertyName:(NSString *)propertyName withBDModel:(NSString *)attributeName modelClass:(Class)modelClass
{
    if ([self objectForKey:attributeName]!=nil)
    {
        BDBaseModelObject *modelObject=[self bd_modelObjectForKey:attributeName class:modelClass];
        if (modelObject!=nil)
        {
            //json能够被解析 才会进行赋值
            BDBaseModelObject *propertyObject=[obj valueForKey:propertyName];
            if(propertyObject==nil||![propertyObject isKindOfClass:[modelClass class]])
            {
                [obj setValue:modelObject forKey:propertyName];
            }
            else
            {
                [propertyObject updateWithAttributes:[self bd_DictionaryObjectForKey:attributeName]];
            }
            return YES;
        }
        
    }
    return NO;
}
@end







