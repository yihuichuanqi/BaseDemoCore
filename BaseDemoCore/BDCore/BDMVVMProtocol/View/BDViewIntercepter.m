-(//
//  BDViewIntercepter.m
//  BaseDemoCore
//
//  Created by Admin on 2017/12/29.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDViewIntercepter.h"
#import "BDViewProtocol.h"
#import <Aspects/Aspects.h>

@implementation BDViewIntercepter

+(void)load
{
    [BDViewIntercepter sharedInstance];
}
+(instancetype)sharedInstance
{
    static BDViewIntercepter *sharedIns;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedIns=[[BDViewIntercepter alloc]init];
    });
    return sharedIns;
}

-(instancetype)init
{
    self=[super init];
    if (self)
    {
        //拦截
        //代码唤醒
        [UIView aspect_hookSelector:@selector(initWithFrame:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo>aspectInfo,CGRect frame){
            
            [self hook_Init:aspectInfo.instance withFrame:frame];
            
        } error:nil];
        //xib唤醒
        [UIView aspect_hookSelector:@selector(initWithCoder:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo>aspectInfo,NSCoder *aDecoder){
            
            //此时IBOut中view都为空 需要Hook awakeFromNib
            [self hook_Init:aspectInfo.instance withCoder:aDecoder];
            
        } error:nil];
        
        [UIView aspect_hookSelector:@selector(awakeFromNib) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo>aspectInfo){
            
            //此时可初始化视图
            [self hook_AwakFromNib:aspectInfo.instance];
            
        } error:nil];
        
    }
    return self;
}
#pragma mark-Hook Methods
-(void)hook_Init:(UIView <BDViewProtocol>*)view withFrame:(CGRect)frame
{
    if ([view respondsToSelector:@selector(bd_initialExtraDataForView)])
    {
        [view bd_initialExtraDataForView];
    }
    
    if ([view respondsToSelector:@selector(bd_setupViewForView)])
    {
        [view bd_setupViewForView];
    }
}

-(void)hook_Init:(UIView<BDViewProtocol>*)view withCoder:(NSCoder *)aDecoder
{
    if ([view respondsToSelector:@selector(bd_initialExtraDataForView)])
    {
        [view bd_initialExtraDataForView];
    }
}
-(void)hook_AwakFromNib:(UIView<BDViewProtocol>*)view
{
    if ([view respondsToSelector:@selector(bd_setupViewForView)])
    {
        [view bd_setupViewForView];
    }
}















@end
