//
//  NSArray+BD.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "NSArray+BD.h"

@implementation NSArray (BD)

-(id)randomObject
{
    if (self.count==0)
    {
        return nil;
    }
    NSUInteger randomIndex=arc4random()%self.count;
    return [self bd_safeObjectAtIndex:randomIndex];
}

-(id)bd_safeObjectAtIndex:(NSUInteger)index
{
    if (index<self.count)
    {
        return [self objectAtIndex:index];
    }
    return nil;
}
-(id)bd_objectPassingTest:(BOOL (^)(id, NSUInteger, BOOL *))predicate
{
    NSUInteger index=[self indexOfObjectPassingTest:predicate];
    return [self bd_safeObjectAtIndex:index];
}
-(NSArray *)bd_reverseArray
{
    return self.reverseObjectEnumerator.allObjects;
}
-(NSArray *)bd_objectClassArray
{
    NSMutableArray *classArray=[NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        [classArray addObject:[obj class]];
    }];
    return [classArray copy];
}





@end


@implementation NSMutableArray (BD)


-(void)bd_safeAddObject:(id)anObject
{
    if (anObject!=nil)
    {
        [self addObject:anObject];
    }
}
-(void)bd_safeInsertObject:(id)anObject atIndex:(NSUInteger)index
{
    if (anObject!=nil)
    {
        [self insertObject:anObject atIndex:index];
    }
}
-(void)bd_safeRemoveObjectAtIndex:(NSUInteger)index
{
    if(index<self.count)
    {
        [self removeObjectAtIndex:index];
    }
}


-(void)bd_removeObjectsPassingTest:(BOOL (^)(id, NSUInteger, BOOL *))predicate
{
    [self removeObjectsAtIndexes:[self indexesOfObjectsPassingTest:predicate]];
}
@end
