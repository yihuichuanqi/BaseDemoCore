//
//  BDModel.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDModel.h"

@interface BDModel ()

-(void)detaiWithDict:(NSDictionary *)aDict;
@end


@implementation BDModel

//可自定义log样式

-(id)initWithDict:(NSDictionary *)aDict
{
    if (self=[super init])
    {
        [self detailWithDict:aDict];
    }
    return self;
}
-(void)detailWithDict:(NSDictionary *)aDict
{
#ifdef DEBUG
    //需要重载
    assert(0);
#endif
}









@end
