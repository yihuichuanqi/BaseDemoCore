//
//  BDSpotService.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/14.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*充电站点 数据逻辑操作*/

#import <Foundation/Foundation.h>
#import "BDStationAnnotation.h"

@class BDSpotModel,BDSpotFilter;
//充电点本地时间戳与表名挂钩
#define kUCGetSpotsTime [NSString stringWithFormat:@"%@_UC",[[BDSpotService sharedServices] spotTableName]]
//待下载充电点zip包已完毕
#define kCompletedDownloadZipQueueNotification @"kCompletedDownloadZipQueueNotification"

typedef NS_ENUM(NSUInteger,SpotRefreshStatus) {
    
    SpotRefreshStatus_No=0,//socket推送非头包
    SpotRefreshStatus_isFirst,//socket推送头包
    SpotRefreshStatus_isSpotPackage,//http请求包
};

@protocol BDSpotServiceDelegate <NSObject>

//站点状态发生变化
-(void)changedSpotStatus:(BDSpotModel *)spot;
//收到zip包充电点
-(void)receiveZipSpots:(NSDictionary *)spotsDic insertedSpots:(NSDictionary *)insertedSpots deletedSpots:(NSDictionary *)deletedSpots modifiedSpots:(NSDictionary *)modifiedSpots refreshStatus:(SpotRefreshStatus)refreshStatus;
@end

@interface BDSpotService : NSObject

@property (nonatomic,weak) id<BDSpotServiceDelegate> delegate;

+(instancetype)sharedServices;



-(NSString *)spotTableName;

//下载充电点数据包
-(void)downloadSpotZip:(BOOL)sendVersion;


//获取附近的充电点
-(NSArray *)getSpotsWithNearbyArround:(CLLocationCoordinate2D)coordinate distance:(CLLocationDistance)distance;
-(NSArray *)getSpotsByCoordinate:(CLLocationCoordinate2D)fromCoordinate toCoordinate:(CLLocationCoordinate2D)toCoordinate spotFolter:(BDSpotFilter *)spotFilter;
//获取annotations
-(void)getAnnotations:(CLLocationCoordinate2D)fromCoordinate toCoordinate:(CLLocationCoordinate2D)toCoordinate spotFilter:(BDSpotFilter *)spotFilter zoomLevel:(NSUInteger)zoomLevel ignoreSpotId:(NSString *)ignoreSpotId eachBlock:(void(^)(id<BDAnnotationDelegate>model))eachBlock finishBlock:(void(^)(NSArray *models))finishBlock;

//获取单一充电点 返回模型
-(BDSpotModel *)getSpotModelBySpotId:(NSString *)spotId;
-(BDSpotModel *)getSpotModelBySpotId:(NSString *)spotId block:(void(^)(BDSpotModel *spot,NSError *error))block;

//请求充电点详细信息
-(void)fetchSpotDetailInfo:(NSString *)spotId block:(void(^)(BDSpotModel *spot,NSError *error))block;
//推送充电点状态
-(BOOL)updateSpotStatus:(NSString *)status spot:(BDSpotModel *)spot updatedTime:(NSTimeInterval)updatedTime;
//地图上相关站点
-(void)addSpot:(BDSpotModel *)spot withDict:(NSDictionary *)spotDict;
-(void)removeSpotBySpotId:(NSString *)spotId;




@end
