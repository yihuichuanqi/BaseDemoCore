//
//  BDZipService.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/17.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BDHandlePackage;
@protocol BDZipServiceDelegate <NSObject>

@optional
-(void)zipDidFinished:(NSString *)zipFilePath unZipFilePath:(NSString *)unZipFilePath success:(BOOL)success package:(BDHandlePackage *)package;
@end

@interface BDZipService : NSObject

@property (nonatomic,weak) id<BDZipServiceDelegate>delegate;

+(instancetype)sharedService;
//将某路径zip包解压缩到指定路径
-(void)unZipPath:(NSString *)filePath toPath:(NSString *)toPath;
-(void)unZipPath:(NSString *)filePath toPath:(NSString *)toPath package:(BDHandlePackage *)package;
-(void)unZipPathWithoutPassword:(NSString *)filePath toPath:(NSString *)toPath;


@end
