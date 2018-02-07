//
//  BDModelManager.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDModelManager : NSObject

+(instancetype)shareManager;

-(id)modelWithAttributes:(NSDictionary *)attribuyes modelClass:(Class)modelClass;

//获取已存在的模型
-(id)localModelWithKey:(NSString *)modelKey modelClass:(Class)modelClass;

@end


/*用于字典内容更新*/
@interface NSDictionary (BDUpdateAttribute)

-(BOOL)bd_updateObject:(NSObject *)obj propertyName:(NSString *)propertyName withString:(NSString *)attributeName;
-(BOOL)bd_updateObject:(NSObject *)obj propertyName:(NSString *)propertyName withInteger:(NSString *)attributeName;
-(BOOL)bd_updateObject:(NSObject *)obj propertyName:(NSString *)propertyName withDate:(NSString *)attributeName;
-(BOOL)bd_updateObject:(NSObject *)obj propertyName:(NSString *)propertyName withBDModel:(NSString *)attributeName modelClass:(Class)modelClass;




@end





