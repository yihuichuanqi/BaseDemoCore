//
//  BDUserSearchFilter.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/16.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*用户偏好搜索*/

#import "BDBaseModelObject.h"
#import "BDSpotConstant.h"

@class BDSpotFilter;
@interface BDUserSearchFilter : BDBaseModelObject<NSCopying>

@property (nonatomic,assign) BOOL hideBusy; //仅显示空闲充电点
@property (nonatomic,assign) BDSpotType spotType; //充电速率:001慢充 010快充 100超速充
@property (nonatomic,assign) BDSpotOperatorType operateType; //站点类型: 公共 个人 营运
@property (nonatomic,copy) NSString *tags;//标签Id:逗号分隔
@property (nonatomic,copy) NSString *operatorKeys; //运营商:逗号拼接
@property (nonatomic,copy) NSString *codeBitList;//品牌:位序码集合 逗号拼接

@property (nonatomic,assign) NSInteger propertyType;//目前仅在路线规划中使用
@property (nonatomic,assign,getter=isOnlyTeslaSuperSopt) BOOL onlyTeslaSuperSpot; //仅显示特斯拉超充站

//判断是否包含运营商(有交集即为YES)
-(BOOL)containOperators:(NSString *)operatorsString;
//判断是否包含Tag(有交集即为YES)
-(BOOL)containTags:(NSString *)tagsString;
//清空保存的用户偏好
-(void)clearUserSearchFilter;


@end
