//
//  BDRedHotRegister.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/28.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

/*需要确保唯一性*/

//TabBar红点Key
extern NSString *const BD_RedHot_TabBar_Home;
extern NSString *const BD_RedHot_TabBar_Mine;
extern NSString *const BD_RedHot_TabBar_TimeLine;

//朋友圈红点key（联动效果 前者依赖于后者）
extern NSString *const BD_RedHot_TimeLineGroup;
extern NSString *const BD_RedHot_TimeLineComment; //评论数
extern NSString *const BD_RedHot_TimeLineFabulous; //赞数

@interface BDRedHotRegister : NSObject


+(NSArray *)redhotRegisterProfiles;
@end
