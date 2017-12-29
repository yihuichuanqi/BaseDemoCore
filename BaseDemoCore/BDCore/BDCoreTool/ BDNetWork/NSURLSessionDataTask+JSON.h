//
//  NSURLSessionDataTask+JSON.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/21.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSessionDataTask (JSON)

+(instancetype)JSONRequestSessionTask:(NSURLRequest *)urlRequest completionHandler:(void(^)(NSURLRequest *request,id responseObject,NSError *error))completionHandler;
+(instancetype)JSONRequestSessionTask:(NSURLRequest *)urlRequest removeNulls:(BOOL)removeNulls completionHandler:(void(^)(NSURLRequest *request,id responseObject,NSError *error))completionHandler;

@end
