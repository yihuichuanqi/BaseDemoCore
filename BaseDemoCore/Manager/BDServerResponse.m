//
//  BDServerResponse.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/19.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDServerResponse.h"
#import "NSDictionary+BD.h"


#define Tag_Server_Success @"success"
#define Tag_Server_Code @"code"
#define Tag_Server_Msg @"error"
#define Tag_Server_Data @"data"

NSString * const BDAFUrlReaponseSerializationErrorDomain=@"com.alamofire.error.serialization.response";

@implementation BDServerResponse


+(BDServerResponse *)responseFromServerJson:(NSDictionary *)dictObj
{
    if (dictObj==nil)
    {
        return nil;
    }
    if (![dictObj isKindOfClass:[NSDictionary class]])
    {
        return nil;
    }
    NSDictionary *dict=(NSDictionary *)dictObj;
    BDServerResponse *response=[[BDServerResponse alloc]init];
    response.success=[dict bd_BoolForKey:Tag_Server_Success];
    response.code=[@([dict bd_IntergerForKey:Tag_Server_Code withDefault:-1]) stringValue];
    response.msg=[dict bd_StringObjectForKey:Tag_Server_Msg];
    response.objData=[dict bd_safeObjectForKey:Tag_Server_Data];
    if (response.msg&&response.code&&![response.code isEqualToString:kServerCode_Ok])
    {
        response.serializationError=[self makeSerializaError:response.msg withObject:response.code];
    }
    return response;
}

-(BOOL)isOk
{
    if ([self.code isEqualToString:kServerCode_Ok])
    {
        return YES;
    }
    return NO;
}
-(BOOL)isEmpty
{
    if (self.objData==nil)
    {
        return YES;
    }
    if([self.objData isKindOfClass:[NSArray class]])
    {
        NSArray *tempArr=(NSArray *)self.objData;
        if (tempArr==nil||tempArr.count<1)
        {
            return YES;
        }
    }
    if ([self.objData isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *tempDic=(NSDictionary *)self.objData;
        if (tempDic==nil||tempDic.allKeys.count<1)
        {
            return YES;
        }
    }
    return NO;
}

+(NSError *)makeSerializaError:(NSString *)errorMsg withObject:(id)obj
{
    NSDictionary *userInfo=@{NSLocalizedDescriptionKey:NSLocalizedStringFromTable(@"Cannot Do Serialization Worj",@"AFNetworking",nil),NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"%@ Orig:%@",errorMsg,obj]};
    NSError *error=[NSError errorWithDomain:BDAFUrlReaponseSerializationErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:userInfo];
    return error;
}





@end
