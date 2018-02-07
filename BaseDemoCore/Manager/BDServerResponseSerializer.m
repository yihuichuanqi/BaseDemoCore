//
//  BDServerResponseSerializer.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/19.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDServerResponseSerializer.h"
#import "BDServerResponse.h"

//获取AF底层error信息
static NSError *AFErrorWithUnderlyingError(NSError *error,NSError *underlyingError)
{
    if (!error)
    {
        return underlyingError;
    }
    if (!underlyingError||error.userInfo[NSUnderlyingErrorKey])
    {
        return error;
    }
    //自构造
    NSMutableDictionary *mutUserInfo=[error.userInfo mutableCopy];
    mutUserInfo[NSUnderlyingErrorKey]=underlyingError;
    
    return [[NSError alloc]initWithDomain:error.domain code:error.code userInfo:mutUserInfo];
}
//判断是否是指定domain返回的值
static BOOL AFErrorOrUnderlyingErrorHasCodeInDimain(NSError *error,NSInteger code, NSString *domain)
{
    if ([error.domain isEqualToString:domain]&&error.code==code)
    {
        return YES;
    }
    else if (error.userInfo[NSUnderlyingErrorKey])
    {
        return AFErrorOrUnderlyingErrorHasCodeInDimain(error.userInfo[NSUnderlyingErrorKey], code, domain);
    }
    return NO;
}
//获取并移除空对象
static id AFJsonObjectByRemovingKeysWithNullValues(id jsonObject,NSJSONReadingOptions readingOptions)
{
    if ([jsonObject isKindOfClass:[NSArray class]])
    {
        NSArray *tempArray=(NSArray *)jsonObject;
        NSMutableArray *mutArray=[NSMutableArray arrayWithCapacity:[tempArray count]];
        for (id value in tempArray)
        {
            [mutArray addObject:AFJsonObjectByRemovingKeysWithNullValues(value, readingOptions)];
        }
        return (readingOptions & NSJSONReadingMutableContainers)?mutArray:[NSArray arrayWithArray:mutArray];
    }
    else if ([jsonObject isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *tempDic=(NSDictionary *)jsonObject;
        NSMutableDictionary *mutDict=[NSMutableDictionary dictionaryWithDictionary:tempDic];
        for (id<NSCopying> key in [tempDic allKeys])
        {
            id value=jsonObject[key];
            if (!value||[value isEqual:[NSNull null]])
            {
                [mutDict removeObjectForKey:key];
            }
            else if ([value isKindOfClass:[NSArray class]]||[value isKindOfClass:[NSDictionary class]])
            {
                mutDict[key]=AFJsonObjectByRemovingKeysWithNullValues(value, readingOptions);
            }
            return (readingOptions & NSJSONReadingMutableContainers)?mutDict:[NSDictionary dictionaryWithDictionary:mutDict];
            
        }
    }
    return jsonObject;
}


@implementation BDServerResponseSerializer


+(instancetype)serializer
{
    return [self bd_serializerWithReadingOptions:(NSJSONReadingOptions)0];
}
+(instancetype)bd_serializerWithReadingOptions:(NSJSONReadingOptions)readingOptions
{
    BDServerResponseSerializer *serializar=[[self alloc]init];
    serializar.readingOptions=readingOptions;
    return serializar;
}
-(id)init
{
    self=[super init];
    if (!self)
    {
        return nil;
    }
    //集合
    /*
    NSSet *contentSet=[NSSet setWithObjects:
                       @"application/json",
                       @"text/plain",
                       @"text/javascript",
                       @"text/json",
                       @"text/html",
                       @"application/x-www-form-urlencoded", nil];
     */
    
    [self.acceptableContentTypes setByAddingObject:@""];

    return self;
}

//重写该类
-(id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing  _Nullable *)error
{
    //判断是否有效
    if(![self validateResponse:(NSHTTPURLResponse *)response data:data error:error])
    {
        if (!error||AFErrorOrUnderlyingErrorHasCodeInDimain(*error, NSURLErrorCannotDecodeContentData,AFURLResponseSerializationErrorDomain))
        {
            return nil;
        }
    }
    id responseObject=nil;
    NSError *serialzationError=nil;
    // Workaround for behavior of Rails to return a single space for `head :ok` (a workaround for a bug in Safari), which is not interpreted as valid input by NSJSONSerialization.
    BOOL isSpace=[data isEqualToData:[NSData dataWithBytes:@" " length:1]];
    if (data.length>0 && !isSpace)
    {
        responseObject=[NSJSONSerialization JSONObjectWithData:data options:self.readingOptions error:&serialzationError];
    }
    else
    {
        return nil;
    }
    //数据校验&解析
    NSStringEncoding stringEncoding=self.stringEncoding;
    if (response.textEncodingName)
    {
        CFStringEncoding encoding=CFStringConvertIANACharSetNameToEncoding((CFStringRef)response.textEncodingName);
        if (encoding!=kCFStringEncodingInvalidId)
        {
            //编码方式有效
            stringEncoding=CFStringConvertEncodingToNSStringEncoding(encoding);
        }
    }
    
    
    @autoreleasepool{
        
        //用定义的编码方式解析
        NSString *responseString=[[NSString alloc]initWithData:data encoding:stringEncoding];
        if (responseString&&![responseString isEqualToString:@" "])
        {
            //然后用UTF-8归档
            data=[responseString dataUsingEncoding:NSUTF8StringEncoding];
            if (data)
            {
                if ([data length]>0)
                {
                    responseObject=[NSJSONSerialization JSONObjectWithData:data options:self.readingOptions error:&serialzationError];
                    if (!serialzationError)
                    {
                        BDServerResponse *serverResponse=[BDServerResponse responseFromServerJson:responseObject];
                        responseObject=serverResponse;
                    }
                    else
                    {
                        //错误 无法解析
                        serialzationError=[self makeSerialError:@"Couldont Decode String!!!" withObject:responseString];
                    }
                }
                else
                {
                    //错误 数据为空
                    serialzationError=[self makeSerialError:@"Original Response Data Empty!!!" withObject:responseString];
                }
            }
            else
            {
                //错误 UTF-8无法归档
                NSDictionary *userInfo=@{NSLocalizedDescriptionKey:NSLocalizedStringFromTable(@"Data Failed Decoding as a UTF-8 String!!!", @"AFNetworking", nil),
                                         NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:NSLocalizedStringFromTable(@"Coundont Decode String:%@!!!",@"AFNetworking",nil)]
                                         };
                serialzationError=[NSError errorWithDomain:AFURLResponseSerializationErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:userInfo];
            }
        }
    }
    if (self.removeKeysWithNullValues&&responseObject)
    {
        responseObject=AFJsonObjectByRemovingKeysWithNullValues(responseObject, self.readingOptions);
    }
    if (error)
    {
        *error=AFErrorWithUnderlyingError(serialzationError, *error);
    }
    return responseObject;
}


-(NSError *)makeSerialError:(NSString *)errorMsg withObject:(NSObject *)obj
{
    NSDictionary *userInfo=@{NSLocalizedDescriptionKey:NSLocalizedStringFromTable(@"Cannot Do Serilize work!!!", @"AFNetworking", nil),
                             NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"%@==Orig:%@",errorMsg,obj]
                             };
    NSError *error=[NSError errorWithDomain:AFURLResponseSerializationErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:userInfo];
    return error;
}


#pragma mark-Secure Coding

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if (!self)
    {
        return nil;
    }
    self.readingOptions=[[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(readingOptions))] unsignedIntegerValue];
    self.removeKeysWithNullValues=[[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(removeKeysWithNullValues))] boolValue];
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@(self.readingOptions) forKey:NSStringFromSelector(@selector(readingOptions))];
    [aCoder encodeObject:@(self.removeKeysWithNullValues) forKey:NSStringFromSelector(@selector(removesKeysWithNullValues))];
}
#pragma mark-Copying
-(id)copyWithZone:(NSZone *)zone
{
    AFJSONResponseSerializer *serialCopy=[[[self class] allocWithZone:zone] init];
    serialCopy.readingOptions=self.readingOptions;
    serialCopy.removesKeysWithNullValues=self.removeKeysWithNullValues;
    return serialCopy;
}



@end
