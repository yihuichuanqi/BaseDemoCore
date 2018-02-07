//
//  BDImageCache.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/24.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*简单将图片存入单例内存中*/

#import <Foundation/Foundation.h>

@interface BDImageCache : NSObject

@property (nonatomic,assign) NSInteger capacity;

+(instancetype)sharedCache;
-(UIImage *)imageNamed:(NSString *)name;
-(UIImage *)imageWithContentOfFile:(NSString *)file;
//key为（图片名或图片路径的MD5格式）
-(void)removeImageWithKey:(NSString *)key;
-(void)removeAllImage;

@end
