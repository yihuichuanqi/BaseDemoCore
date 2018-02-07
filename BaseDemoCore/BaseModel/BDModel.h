//
//  BDModel.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*不依赖第三方 自定义模型转化*/

#import <Foundation/Foundation.h>

@interface BDModel : NSObject

//字典生成对象
-(id)initWithDict:(NSDictionary *)aDict;
-(void)detailWithDict:(NSDictionary *)aDict;


@end
