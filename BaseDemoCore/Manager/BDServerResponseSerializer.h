//
//  BDServerResponseSerializer.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/19.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*服务器响应数据序列化*/

#import <AFNetworking/AFNetworking.h>

@interface BDServerResponseSerializer : AFHTTPResponseSerializer

@property (nonatomic,assign) NSJSONReadingOptions readingOptions;
@property (nonatomic,assign) BOOL removeKeysWithNullValues;

+(instancetype)bd_serializerWithReadingOptions:(NSJSONReadingOptions)readingOptions;



@end
