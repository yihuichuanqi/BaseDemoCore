//
//  BDJSPathHelper.h
//  BaseDemoCore
//
//  Created by Admin on 2017/11/8.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDJSPathHelper : NSObject

-(instancetype)initWithPatchArray:(NSMutableArray *)array;

//加载热更新
-(void)loadPatchFile;

@end
