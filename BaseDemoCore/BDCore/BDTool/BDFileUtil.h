//
//  BDFileUtil.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/21.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDFileUtil : NSObject

//用户数据目录路径
+(NSString *)userDataDocumentsFolder;
+(NSString *)userDataDocumentsPathWithFile:(NSString *)fileName;
+(NSString *)userDataDocumentsPathWithFolder:(NSString *)folderName fileName:(NSString *)fileName;

//缓存
+(NSString *)cachesFolder;
+(NSString *)cachesPathWithFolder:(NSString *)folderName fileName:(NSString *)fileName;

//App Documents路径
+(NSString *)appDocumentsPathWithFolder:(NSString *)folderName fileName:(NSString *)fileName;

//App Support 路径
+(NSString *)appSupportFolder;
+(NSString *)appSupportPathWithFolder:(NSString *)folderName fileName:(NSString *)fileName;


@end
