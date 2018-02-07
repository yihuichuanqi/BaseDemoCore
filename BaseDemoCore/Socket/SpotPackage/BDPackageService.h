//
//  BDPackageService.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/18.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*Socket数据包服务 用于控制数据包的各种处理 （下载 暂停等 ）*/

#import <Foundation/Foundation.h>
@class BDHandlePackage;
@interface BDPackageService : NSObject

+(instancetype)sharedService;

//继续定时器
-(void)resumeTimer;
//开始下载
-(void)startDownload;
-(void)endDownloadWith:(BDHandlePackage *)package;
-(void)handlePackage:(BDHandlePackage *)package;
//更新package信息因为其他错误
-(void)replacePackageInfoWithPackage:(BDHandlePackage *)package handleFailTime:(NSInteger)handleFailTime;

//清空队列
-(void)clearExecutingQueue;
-(void)clearPackageTable;
-(void)clearPackageCache;
-(BOOL)canDownloadPackage:(BDHandlePackage *)package;




@end
