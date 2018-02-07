//
//  NSURL+BD.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/24.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (BD)

-(BOOL)bd_isEqualToUrl:(NSURL *)url;

@end

//专属于应用的扩展
@interface NSURL (BDAppDomainUrl)

//获取随机的url
+(instancetype)bd_AppDomainUrlForPreviewImage;
@end


