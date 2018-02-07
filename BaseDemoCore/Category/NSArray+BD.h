//
//  NSArray+BD.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*NSArray 通用功能扩展*/

#import <Foundation/Foundation.h>

@interface NSArray (BD)

@property (nonatomic,readonly) id randomObject;

-(id)bd_safeObjectAtIndex:(NSUInteger)index;
-(id)bd_objectPassingTest:(BOOL (^)(id obj,NSUInteger idx,BOOL *stop))predicate;

//逆序
-(NSArray *)bd_reverseArray;
-(NSArray *)bd_objectClassArray;
@end

@interface NSMutableArray <ObjectType> (BD)

-(void)bd_safeAddObject:(ObjectType)anObject;
-(void)bd_safeInsertObject:(ObjectType)anObject atIndex:(NSUInteger)index;
-(void)bd_safeRemoveObjectAtIndex:(NSUInteger)index;

-(void)bd_removeObjectsPassingTest:(BOOL (NS_NOESCAPE ^)(ObjectType obj,NSUInteger idx,BOOL *stop))predicate;

@end



