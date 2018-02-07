//
//  BDModelList.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/14.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDModelList.h"

@implementation BDModelList

-(id)initWithArray:(NSArray *)aArray
{
    if ((self=[super init]))
    {
        self.models=[self modelWithArray:aArray];
    }
    return self;
}
-(id)initWithDict:(NSDictionary *)aDict
{
    //子类重载override
    assert(0);
    if (self=[super init])
    {
        
    }
    return self;
}
-(NSMutableArray *)modelWithArray:(NSArray *)aArray
{
    //子类重载override
    assert(0);
    return [NSMutableArray array];
}
-(BDModel *)objectInModelsAtIndex:(NSUInteger)index
{
    if (index>=[self.models count])
    {
        return nil;
    }
    return [self.models objectAtIndex:index];
}
-(NSInteger)count
{
    return self.models.count;
}

@end

@implementation Pager

-(void)detailWithDict:(NSDictionary *)aDict
{
    self.limit= [self bd_StringObjectForValue:[aDict objectForKey:@"pageSize"]].integerValue;
    self.page= [self bd_StringObjectForValue:[aDict objectForKey:@"page"]].integerValue;
    self.total= [self bd_StringObjectForValue:[aDict objectForKey:@"total"]].integerValue;
    self.totalPages= [self bd_StringObjectForValue:[aDict objectForKey:@"totalPage"]].integerValue;
    
}

-(BOOL)hasMore
{
    if (self.page<self.totalPages)
    {
        return YES;
    }
    return NO;
}

-(id)copyWithZone:(NSZone *)zone
{
    id copyPager=[[Pager allocWithZone:zone]initWithDict:@{@"pageSize":@(self.limit),
                                                           @"page":@(self.page),
                                                           @"total":@(self.total),
                                                           @"totalPage":@(self.totalPages)
                                                           }];
    return copyPager;
}



-(NSString *)bd_StringObjectForValue:(id)obj
{
    if ([obj isKindOfClass:[NSNull class]]||!obj)
    {
        return @"";
    }
    return [NSString stringWithFormat:@"%@",obj];
}


@end

