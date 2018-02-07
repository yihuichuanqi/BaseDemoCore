//
//  NSDictionary+BD.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*NSDictionary 通用功能扩展*/

#import <Foundation/Foundation.h>

@interface NSDictionary (BD)

-(id)bd_safeObjectForKey:(id)aKey;
-(id)bd_nilObjectForKey:(id)aKey;
-(id)bd_nilObjectForKey:(id)aKey forClass:(Class)objectClass;
-(id)bd_objectForKey:(id)aKey withDefault:(id)defaultValue;
-(id)bd_objectForKeyArray:(id)aKeyArray withDefault:(id)defaultValue;


//获取响应类型的数据
-(NSString *)bd_StringObjectForKey:(id)aKey;
-(NSInteger)bd_IntergerForKey:(id)aKey;
-(NSInteger)bd_IntergerForKey:(id)aKey withDefault:(NSInteger)defaultValue;
-(double)bd_DoubleForKey:(id)aKey;
-(NSDate *)bd_DateObjectForKey:(id)aKey;
-(BOOL)bd_BoolForKey:(id)aKey;
-(BOOL)bd_BoolForKey:(id)aKey withDefault:(BOOL)defaultValue;
-(NSArray *)bd_ArrayObjectForKey:(id)aKey;
-(NSDictionary *)bd_DictionaryObjectForKey:(id)aKey;

-(id)bd_modelObjectForKey:(id)aKey class:(Class)modelClass;
-(NSArray *)bd_modelArrayForKey:(id)aKey class:(Class)modelClass;

//取Array中字段的某个属性为key 生层Dictionary
+(NSDictionary *)bd_DictionaryWithArray:(NSArray *)aArray keyPropertyName:(NSString *)keyPropertyName;


//错误信息(需与NSError对应)
-(NSString *)bd_ErrorMessage;
-(NSInteger)bd_ErrorCode;
-(NSDictionary *)bd_ResponseData;


@end

@interface NSMutableDictionary (BD)

-(void)bd_safeSetObject:(id)aOject forKey:(id)aKey;
-(void)bd_safeSetObject:(id)aOject forKey:(id)aKey withClass:(Class)aClass;
-(void)bd_safeRemoveObjectForKey:(id)aKey;






@end

