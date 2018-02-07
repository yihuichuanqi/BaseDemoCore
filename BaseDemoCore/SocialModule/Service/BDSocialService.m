//
//  BDSocialService.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/25.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDSocialService.h"
#import "BDSocialTopicModel.h"
#import "BDRequestManager.h"
#import "NSDictionary+BD.h"
#import "NSError+BD.h"

@implementation BDSocialService

+(instancetype)sharedService
{
    static BDSocialService *service=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service=[[BDSocialService alloc]init];
    });
    return service;
}
-(id)init
{
    if (self=[super init])
    {
        
    }
    return self;
}



-(void)getSocialTopicListForType:(NSInteger)topicListType brandId:(NSString *)brandId userId:(NSString *)userId keyword:(NSString *)keyword page:(NSUInteger)page pageSize:(NSUInteger)pageSize complete:(void (^)(NSArray *, NSError *))complete
{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params bd_safeSetObject:brandId forKey:@"brandId"];
    [params bd_safeSetObject:@(0) forKey:@"type"];
    [params bd_safeSetObject:userId forKey:@"userId"];
    [params bd_safeSetObject:@(page) forKey:@"page"];
    [params bd_safeSetObject:@(pageSize) forKey:@"pageSize"];
    [params bd_safeSetObject:keyword forKey:@"keyword"];
    
    [[BDRequestManager requestManager] requestByPostWithPath:@"topic/list" parameter:params responseSuccess:^(BDServerResponse *serverResonse) {
        
        if (!serverResonse.serializationError)
        {
            if ([serverResonse.objData isKindOfClass:[NSArray class]])
            {
                NSArray *array=(NSArray *)serverResonse.objData;
                NSArray<BDSocialTopicModel *> *topicArray=[BDSocialTopicModel arrayWithAttributesArray:array];
                if (complete)
                {
                    complete(topicArray,nil);
                }

            }
        }
        else
        {
            if (complete)
            {
                complete(nil,serverResonse.serializationError?:nil);
            }
        }
        
    } error:^(NSString *msg, NSString *code) {
        
        if (complete)
        {
            complete(nil,[NSError bd_Error:msg revCode:code]);
        }
    }];
}

@end
