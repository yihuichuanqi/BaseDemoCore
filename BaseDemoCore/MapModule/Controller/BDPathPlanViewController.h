//
//  BDPathPlanViewController.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/12.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*路径规划 选择出发、目的地及出行爱车 获取最优行车路线*/

#import "BDBaseViewController.h"

@class BDPathPlanPOIModel;
//路径规划数据存储目录
#define kMapPlanFolderPath [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"bdTripPlan"]

@interface BDPathPlanViewController : BDBaseViewController

//页面数据初始化
-(void)setupMapOrigin:(BDPathPlanPOIModel *)origin andDestination:(BDPathPlanPOIModel *)destination;

//改变路线策略状态进而影响页面布局
-(void)changeToSelectStrategyState;

@end
