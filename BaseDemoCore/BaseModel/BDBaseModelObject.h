//
//  BDBaseModelObject.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*自定义模型、字典相互转化*/

#import "BDModel.h"

@interface BDBaseModelObject : BDModel<NSCoding>

-(id)initWithAttributes:(NSDictionary *)aAttributes;
//子类需要override
-(void)updateWithAttributes:(NSDictionary *)aAttributes;

/*
 *引入ModelManager后，解析获取对象（modelWithAttributes）可能是创建一个新对象，也可能是取已有对象进行更新，所以提出创建对象的方法（createModelWithAttributes）
 */
//解析获取模型对象
+(instancetype)modelWithAttributes:(NSDictionary *)aAttributes;
//解析创建模型对象
+(instancetype)createModelWithAttributes:(NSDictionary *)aAttributes;

/*基于ModelManager*/
//在ModelManager存储的key值
+(NSString *)modelManagerStoreKey;

//模型批量转化
+(NSArray *)arrayWithAttributesArray:(NSArray *)aArray;
+(NSArray *)attributesArrayFromModelArray:(NSArray *)aArray;
//子类需要override
-(NSDictionary *)attributesFromModel;

/*
 *用于替代containsObject 如果确认了isEqual可用，可以换回containsObject
 */
//Model的key主键 一般为Id
//子类需要override
-(NSString *)keyProperty;
+(NSString *)keyPropertyWithAttributes:(NSDictionary *)aAttributes;
//判断是否相同
-(BOOL)isEqualToModel:(BDBaseModelObject *)model;


@end

@interface NSArray<__covariant ObjectType> (BaseModelObjectEx)

-(NSUInteger)indexOfModelObject:(BDBaseModelObject *)aObject;
-(NSUInteger)indexOfModelKey:(NSString *)aKey;
-(BOOL)containsModelObject:(BDBaseModelObject *)aObject;
-(BOOL)containsModelKey:(NSString *)aKey;
-(ObjectType)modelObjectForKey:(NSString *)aKey;

@end



@interface NSMutableArray (BaseModelObjectEx)

-(BOOL)removeModelObject:(BDBaseModelObject *)aObject;
@end;












