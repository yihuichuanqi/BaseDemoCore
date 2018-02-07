//
//  BDServerResponse.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/19.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*服务器响应返回信息*/

#import "BDBaseModel.h"

#define kServerCode_Ok @"0" //数据正确code值
#define kServerCode_Token_Expire @"1234" //token过期

@interface BDServerResponse : BDBaseModel

@property (nonatomic,assign) BOOL success;
@property (nonatomic,copy) NSString *code;
@property (nonatomic,copy) NSString *msg;
//数据
@property (nonatomic,strong) id objData;
@property (nonatomic,strong) NSError *serializationError;

//构造模型
+(BDServerResponse *)responseFromServerJson:(id)dictObj;

//是否返回正确
-(BOOL)isOk;
//数据是否为空
-(BOOL)isEmpty;







@end
