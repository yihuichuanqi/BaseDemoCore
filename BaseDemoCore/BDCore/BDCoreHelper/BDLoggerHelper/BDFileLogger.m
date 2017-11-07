//
//  BDFileLogger.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/6.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDFileLogger.h"
#import "BDLoggerFormatter.h"

@implementation BDFileLogger

static BDFileLogger *instance=nil;

+(BDFileLogger *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance=[[self alloc]init];
    });
    return instance;
}
-(id)init
{
    self=[super init];
    if (self)
    {
        [self configureLogging];
    }
    return self;
}


-(void)configureLogging
{
    // Enable XcodeColors利用XcodeColors显示色彩（不写没效果）
    setenv("XcodeColors", "YES", 0);
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:self.fileLogger];
    
   //设置颜色值
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor blueColor] backgroundColor:nil forFlag:DDLogFlagInfo];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor purpleColor] backgroundColor:nil forFlag:DDLogFlagDebug];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor redColor] backgroundColor:nil forFlag:DDLogFlagError];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor greenColor] backgroundColor:nil forFlag:DDLogFlagVerbose];
    
    //设置输出样式
    BDLoggerFormatter *formatter=[[BDLoggerFormatter alloc]init];
    [[DDTTYLogger sharedInstance] setLogFormatter:formatter];
    
    
}


-(DDFileLogger *)fileLogger
{
    if (!_fileLogger)
    {
        DDFileLogger *fileLogger=[[DDFileLogger alloc]init];
        fileLogger.rollingFrequency=60*60*24;
        fileLogger.logFileManager.maximumNumberOfLogFiles=7;
        _fileLogger=fileLogger;
    }
    return _fileLogger;

}






@end
