//
//  NSURLSessionDataTask+JSON.m
//  BaseDemoCore
//
//  Created by Admin on 2017/12/21.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "NSURLSessionDataTask+JSON.h"

@implementation NSURLSessionDataTask (JSON)

+(instancetype)JSONRequestSessionTask:(NSURLRequest *)urlRequest completionHandler:(void (^)(NSURLRequest *, id, NSError *))completionHandler
{
    return [self JSONRequestSessionTask:urlRequest removeNulls:NO completionHandler:completionHandler];
}
+(instancetype)JSONRequestSessionTask:(NSURLRequest *)urlRequest removeNulls:(BOOL)removeNulls completionHandler:(void (^)(NSURLRequest *, id, NSError *))completionHandler
{


    return nil;
    
}














@end
