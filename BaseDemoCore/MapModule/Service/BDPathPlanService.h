//
//  BDPathPlanService.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class BDPathPlanHistoryModel;
@class BDPathPlanModel,BDManualPathPlanModel,BDRemotePathPlanModel;

@interface BDPathPlanService : NSObject

+(instancetype)sharedService;

#pragma mark-路径历史记录
@property (nonatomic,strong,readonly) NSArray<BDPathPlanHistoryModel *> *pathPlanHistorys;
@property (nonatomic,strong,readonly) NSArray<NSString *> *originHistorys;//出发地
@property (nonatomic,strong,readonly) NSArray<NSString *> *destinationHistorys;//目的地
//存储
-(void)savePathPlanHistory:(BDPathPlanHistoryModel *)pathPlanHistory;
-(void)savePathPlanOriginHistory:(NSString *)pathPlanKeyword;
-(void)savePathPlanDestinationHistory:(NSString *)pathPlanKeyword;
//移除
-(void)removePathPlanHistory:(BDPathPlanHistoryModel *)pathPlanHistory;
-(void)removePathPlanOriginHistory:(NSString *)pathPlanKeyword;
-(void)removePathPlanDestinationHistory:(NSString *)pathPlanKeyword;
-(void)removeAllPathPlanHistory;
-(void)removeAllPathPlanOriginHistory;
-(void)removeAllPathPlanDestinationHistory;

#pragma mark-请求数据
//获取车辆信息
//路线规划信息
//保存规划路线记录
//保存手动规划路线记录 可多条上传
//删除规划路线
//获取路线记录列表
//根据规划结果获取绘制到地图坐标信息
-(void)getPlanInfoWithPathPlan:(BDRemotePathPlanModel *)remotePathPlan complete:(void(^)(NSString *pathPolylineString,NSArray<NSNumber *> *pathDistances,NSArray<NSNumber *> *pathDurations,CLLocationDistance totalDistance,NSTimeInterval totalDuration,NSError *error))complete;

@end
