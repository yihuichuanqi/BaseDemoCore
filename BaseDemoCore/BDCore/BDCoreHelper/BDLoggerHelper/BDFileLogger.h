//
//  BDFileLogger.h
//  BaseDemoCore
//
//  Created by Admin on 2017/11/6.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDCocoaLumberjack.h"

@interface BDFileLogger : NSObject

@property (nonatomic,strong,readwrite) DDFileLogger *fileLogger;

+(BDFileLogger *)sharedManager;



@end
