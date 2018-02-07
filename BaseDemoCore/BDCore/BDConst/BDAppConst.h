//
//  BDAppConst.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/21.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>


//是否运行demo模式
extern const BOOL BDIsRunningInDemoMode;






static inline BOOL isEmpty(id thing)
{
    return thing==nil||[thing isKindOfClass:[NSNull class]]||([thing respondsToSelector:@selector(length)]&&[(NSData *)thing length]==0)||([thing respondsToSelector:@selector(count)]&&[(NSArray *)thing count]==0);
}



@interface BDAppConst : NSObject



@end
