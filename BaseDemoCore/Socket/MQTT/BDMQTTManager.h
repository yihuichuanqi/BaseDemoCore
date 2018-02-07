//
//  BDMQTTManager.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/16.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDMQTTManager : NSObject

+(instancetype)sharedManager;
//继续定时器连接
-(void)resumeConnectedTimer;


@end
