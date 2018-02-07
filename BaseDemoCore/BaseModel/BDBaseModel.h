//
//  BDBaseModel.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/21.
//  Copyright © 2017年 Admin. All rights reserved.
//

/*使用第三方 模型转化*/

#import <Foundation/Foundation.h>

@interface BDBaseModel : NSObject

/*调用 默认使用MJExtension*/
+(instancetype)initWithServerJson:(id)data;

@end
