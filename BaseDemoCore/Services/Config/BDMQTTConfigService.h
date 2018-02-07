//
//  BDMQTTConfigService.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/18.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

//MQTT配置改变
extern NSString * const BDMQTTConfigDidChangedNotification;

@interface BDMQTTConfigService : NSObject

@property (nonatomic,copy) NSString *host;
@property (nonatomic,assign) NSInteger port;

@property (nonatomic,copy) NSString *userName;
@property (nonatomic,copy) NSString *passWord;


+(instancetype)sharedService;

-(void)loadConfigWithAttributes:(id)aAttributes;




@end
