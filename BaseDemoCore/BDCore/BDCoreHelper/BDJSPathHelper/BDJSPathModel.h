//
//  BDJSPathModel.h
//  BaseDemoCore
//
//  Created by Admin on 2017/11/8.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

//补丁枚举值
typedef enum : NSUInteger{
    
    BDJSPathModelStatus_UnknownError, //未知错误
    BDJSPathModelStatus_UnInstall,//尚未安装 （应用初始化时所有补丁默认，补丁更新或新增下载完成后也默认）
    BDJSPathModelStatus_Success,//安装成功
    BDJSPathModelStatus_FileNoxit,//本地补丁不存在
    BDJSPathModelStatus_FileNoMatch,//补丁MD5不匹配
    BDJSPathModelStatus_Update,//此补丁有更新，服务器最新返回的列表中包含此，但md5或url已改变
    BDJSPathModelStatus_Add,//此补丁为新增，服务器最新返回的列表中新增
}BDJSPathModelStatus;


@interface BDJSPathModel : NSObject

@property (nonatomic,copy) NSString *jsPathId; //补丁id用于唯一标识
@property (nonatomic,copy) NSString *md5;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) NSString *ver; //补丁对应的版本，不需要服务器返回，但需要本地保存，在涉及到多版本补丁共存，应用升级时会有使用价值
@property (nonatomic,assign) BDJSPathModelStatus status; //补丁状态 本地维护管理









@end
