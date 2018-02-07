//
//  BDSocialTopicModel.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/25.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDSocialTopicModel.h"
#import "BDModelManager.h"

@implementation BDSocialTopicModel


-(void)updateWithAttributes:(NSDictionary *)aAttributes
{
    [super updateWithAttributes:aAttributes];
    [aAttributes bd_updateObject:self propertyName:@"name" withString:@"name"];
    [aAttributes bd_updateObject:self propertyName:@"summary" withString:@"summary"];
    [aAttributes bd_updateObject:self propertyName:@"popularity" withInteger:@"popularity"];
    
    [aAttributes bd_updateObject:self propertyName:@"iconUrl" withString:@"iconUrl"];
    [aAttributes bd_updateObject:self propertyName:@"imageUrl" withString:@"imageUrl"];
    [aAttributes bd_updateObject:self propertyName:@"coverUrl" withString:@"coverUrl"];

    [aAttributes bd_updateObject:self propertyName:@"publishTime" withDate:@"publishTime"];
}






@end
