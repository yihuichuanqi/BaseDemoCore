//
//  BDDefaultsConst.m
//  BaseDemoCore
//
//  Created by Admin on 2017/12/20.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDDefaultsConst.h"

NSString *const BDUserIdentifierDefaults=@"BDUserIdentifierDefaults";
NSString *const BDUseStagingDefaults=@"BDUseStagingDefaults";

NSString *const BDStagingApiURLDefaults=@"BDStagingApiURLDefaults";
NSString *const BDStagingWebURLDefaults=@"BDStagingWebURLDefaults";
NSString *const BDStagingDeprecatedMobileWebURLDefaults=@"BDStagingDeprecatedMobileWebURLDefaults";
NSString *const BDStagingMetaphysicsURLDefaults=@"BDStagingMetaphysicsURLDefaults";
NSString *const BDStagingLiveSocketURLDefaults=@"BDStagingLiveSocketURLDefaults";

NSString *const BDAuthTokenDefaults=@"BDAuthTokenDefaults";
NSString *const BDAuthTokenExpiryDefaults=@"BDAuthTokenExpiryDefaults";

NSString *const BDAppTokenKeyChainKeyDefaults=@"BDAppTokenKeyChainKeyDefaults";
NSString *const BDAppTokenExpiryDateDefaults=@"BDAppTokenExpiryDateDefaults";


@implementation BDDefaultsConst

+(void)setup
{
    BOOL useStaging;
#if DEBUG
    useStaging=YES;
#else
    useStaging=NO;
#endif
    
    NSDictionary *regisDic=@{
                             BDUseStagingDefaults:@(useStaging),
                             BDStagingApiURLDefaults:@"http://172.17.9.244:8080",
                             BDStagingWebURLDefaults:@"http://172.17.9.244:8080",
                             BDStagingDeprecatedMobileWebURLDefaults:@"http://172.17.9.244:8080",
                             BDStagingMetaphysicsURLDefaults:@"http://172.17.9.244:8080",
                             BDStagingLiveSocketURLDefaults:@"http://172.17.9.244:8080",
                             };

    [[NSUserDefaults standardUserDefaults] registerDefaults:regisDic];
    
}

+(void)resetDefaults
{
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



@end
