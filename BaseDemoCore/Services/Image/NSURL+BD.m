//
//  NSURL+BD.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/24.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "NSURL+BD.h"

@implementation NSURL (BD)

-(BOOL)bd_isEqualToUrl:(NSURL *)url
{
    return YES;
}


@end


@implementation NSURL (BDAppDomainUrl)

+(instancetype)bd_AppDomainUrlForPreviewImage
{
    NSString *randomImageId=[NSUUID UUID].UUIDString;
    return [NSURL URLWithString:[NSString stringWithFormat:@"appdomain://previewimage/%@",randomImageId]];
}
@end






