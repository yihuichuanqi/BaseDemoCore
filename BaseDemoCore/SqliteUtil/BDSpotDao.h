//
//  BDSpotDao.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/15.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDDao.h"
#import "BDStationAnnotation.h"

@class BDSpotModel;
@class BDSpotFilter;
typedef NS_ENUM(NSInteger,kClusterType) {
    
    kClusterType_None=0,//不做聚合
    kClusterType_City,//以城市
    kClusterType_Province,//以省份
    kClusterType_All,//总数
    kClusterType_Unkonw,//未知
};

@interface BDSpotDao : BDDao

//删除充电点
-(BOOL)deleteSpotBySpotId:(NSString *)spotId;
//获取Spot
-(BDSpotModel *)getSpotInfoBySpotId:(NSString *)spotId;
-(NSArray *)allSpots:(void(^)(BDSpotModel *spot))block;
-(NSInteger)countBySpotFilter:(BDSpotFilter *)spotFilter;
-(NSInteger)countBySpotFilter:(BDSpotFilter *)spotFilter spotId:(NSString *)spotId;
-(NSArray *)getSpotsBySpotFilter:(BDSpotFilter *)spotFilter;
-(NSArray *)getSpotsBySpotFilter:(BDSpotFilter *)spotFilter page:(NSInteger)page;
-(NSArray *)getSpotsBySpotFilter:(BDSpotFilter *)spotFilter page:(NSInteger)page eachBlock:(void(^)(id model))eachBlock;
-(NSArray *)getSpotsBySpotFilter:(BDSpotFilter *)spotFilter page:(NSInteger)page resultsPerPage:(NSInteger)resultsPerPage eachBlock:(void(^)(id model))eachBlock;

//以中心点过滤出最近的两个点
-(NSArray *)getSpotsBySpotFilter:(BDSpotFilter *)spotFilter orderByCoordinate2D:(CLLocationCoordinate2D)coordinate2D page:(NSInteger)page resultsPerPage:(NSInteger)resultsPerPage eachBlock:(void(^)(id model))eachBlock;
//获取两个经纬度之间站点（矩形区域）
-(NSArray *)getSpotsBySpotFilter:(BDSpotFilter *)spotFilter fromCoordinate:(CLLocationCoordinate2D)fromCoordinate toCoordinate:(CLLocationCoordinate2D)toCoordinate ;
//获取地区上的Annotation点
-(NSArray *)getClusterAnnotations:(kClusterType)clusterType spotFilter:(BDSpotFilter *)spotFilter eachBlock:(void(^)(id<BDAnnotationDelegate>model))eachBlock;
-(NSArray *)getClusterAnnotations:(kClusterType)clusterType spotFilter:(BDSpotFilter *)spotFilter eachBlock:(void(^)(id<BDAnnotationDelegate>model))eachBlock finishBlock:(void(^)(NSArray *models))finishBlock;
-(NSArray *)getStationAnnotations:(CLLocationCoordinate2D)fromCoordinate toCoordinate:(CLLocationCoordinate2D)toCoordinate zoomLevel:(NSUInteger)zoomLevel spotFilter:(BDSpotFilter *)spotFilter eachBlock:(void(^)(id<BDAnnotationDelegate>model))eachBlock;
-(NSArray *)getStationAnnotations:(CLLocationCoordinate2D)fromCoordinate toCoordinate:(CLLocationCoordinate2D)toCoordinate zoomLevel:(NSUInteger)zoomLevel ignoreSpotId:(NSString *)ignoreSpotId spotFilter:(BDSpotFilter *)spotFilter eachBlock:(void(^)(id<BDAnnotationDelegate>model))eachBlock finishBlock:(void(^)(NSArray *models))finishBlock;

//获取SQL语句
-(NSString *)getWhereBySpotFilter:(BDSpotFilter *)spotFilter;
-(NSString *)getDeleteWhere:(NSString *)spotId;




@end
