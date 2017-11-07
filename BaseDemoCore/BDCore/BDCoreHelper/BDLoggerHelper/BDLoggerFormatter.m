//
//  BDLoggerFormatter.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/6.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDLoggerFormatter.h"

@implementation BDLoggerFormatter
-(NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *logLevel=nil;
    switch (logMessage.flag) {
        case DDLogFlagError:
            logLevel=@"[ERROR]";
            break;
        case DDLogFlagWarning:
            logLevel=@"[WARN]";
            break;
        case DDLogFlagInfo:
            logLevel=@"[INFO]";
            break;
        case DDLogFlagDebug:
            logLevel=@"[DEBUG]";
            break;
            
        default:
            logLevel=@"[VBOSE]";
            break;
    }
    NSString *formatStr=[NSString stringWithFormat:@"%@ %@ [%@][line %ld] %@ %@",logLevel,[self stringWithFormat:@"yyyy-MM-dd HH:mm:ss" dateTime:logMessage.timestamp],logMessage.fileName,logMessage.line,logMessage.function,logMessage.message];
    return formatStr;
}

-(NSString *)stringWithFormat:(NSString *)format dateTime:(NSDate *)dateTime
{
    NSDateFormatter *outputFormatter=[[NSDateFormatter alloc]init];
    [outputFormatter setDateFormat:format];
    NSString *retStr=[outputFormatter stringFromDate:dateTime];
    return retStr;
}



@end
