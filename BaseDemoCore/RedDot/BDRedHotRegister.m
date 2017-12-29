//
//  BDRedHotRegister.m
//  BaseDemoCore
//
//  Created by Admin on 2017/12/28.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDRedHotRegister.h"

NSString *const BD_RedHot_TabBar_Home=@"BD_RedHot_TabBar_Home";
NSString *const BD_RedHot_TabBar_Mine=@"BD_RedHot_TabBar_Mine";
NSString *const BD_RedHot_TabBar_TimeLine=@"BD_RedHot_TabBar_TimeLine";

NSString *const BD_RedHot_TimeLineGroup=@"BD_RedHot_TimeLineGroup";
NSString *const BD_RedHot_TimeLineComment=@"BD_RedHot_TimeLineComment"; //评论数
NSString *const BD_RedHot_TimeLineFabulous=@"BD_RedHot_TimeLineFabulous"; //赞数




@implementation BDRedHotRegister


+(NSArray *)redhotRegisterProfiles
{
    return @[
             @{
                 BD_RedHot_TabBar_TimeLine:
                     @{
                         BD_RedHot_TimeLineGroup:
                             @[
                                 BD_RedHot_TimeLineComment,
                                 BD_RedHot_TimeLineFabulous
                                 ]
                         }
               
               }
             ];
}
@end
