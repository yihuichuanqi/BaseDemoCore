//
//  BDNetWorkConstants.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/20.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

//网络基本服务器地址
extern NSString *const BDBaseWebURL;
extern NSString *const BDBaseDeprecatedMobileWebURL;
extern NSString *const BDBaseApiURL;
extern NSString *const BDBaseMetaphysicsApiURL;
extern NSString *const BDCausalitySocketURL;


extern NSString *const BDAppTokenURL; //获取AppToken
extern NSString *const BDAuthTokenURL;//获取用户通行token

extern NSString *const BDCreateUserURL; //用户创建

//请求头keys
extern NSString *BDAuthTokenHeaderKey;
extern NSString *BDAppTokenHeaderKey;
extern NSString *BDEigenLocalTemporaryUserHeaderKey;




@interface BDNetWorkConstants : NSObject

@end
