//
//  BDSpotFlowService.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/17.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*站点包下载及其他socket命令*/

#import <Foundation/Foundation.h>
@class BDHandlePackage,BDSpotFlowService;
@protocol BDSpotFlowServiceDelegate <NSObject>

@optional
//站点
//包解压缩并解析成功
-(void)unzipData:(NSString *)zipString package:(BDHandlePackage *)package;
-(void)spotStatus:(NSDictionary *)spotStatusDict package:(BDHandlePackage *)package;

//聊天
//订单
//其他Socket
-(BOOL)spotFlowService:(BDSpotFlowService *)spotFlowService didReviceMessagePackage:(BDHandlePackage *)package;

@end

@interface BDSpotFlowService : NSObject

//不同逻辑遵循不同的协议方法
@property (nonatomic,weak) id<BDSpotFlowServiceDelegate>delegate;
@property (nonatomic,weak) id<BDSpotFlowServiceDelegate>chatDelegate;
@property (nonatomic,weak) id<BDSpotFlowServiceDelegate>orderDelegate;

@property (nonatomic,readonly) NSHashTable *commonDelegates;


+(instancetype)sharedService;
-(void)handleDownloadSpotZip;//下载spot包
-(void)handleDownloadWithPackage:(BDHandlePackage *)package;//下载网络包 解压入库
-(void)handleSuccessWithPackage:(BDHandlePackage *)package;//解压入库成功
-(void)handleFailureWithPackage:(BDHandlePackage *)package;//解压或者入库失败
-(void)handleSpotStatusPackage:(BDHandlePackage *)package; //充电点状态更新
-(void)handleCommonEventPackage:(BDHandlePackage *)package; //其他socket推送消息

//及时回消息给服务器
-(void)handleSocketPackage:(BDHandlePackage *)package;
-(void)handleRememberPackage:(BDHandlePackage *)package;//表示已经收到Socket
-(void)handleSendVersionToServer; //充电列表更新失败 及时给服务器消息
@end
