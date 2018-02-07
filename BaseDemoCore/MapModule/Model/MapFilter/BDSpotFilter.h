//
//  BDSpotFilter.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/15.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*站点过滤 条件选项*/

#import "BDBaseModelObject.h"

typedef NS_ENUM(NSUInteger,SpotFilterSortType) {
    
    SpotFilterSortType_Smart=0,//智能
    SpotFilterSortType_Distance=1,//距离
    SpotFilterSortType_Score=2,//评分
    SpotFilterSortType_FeeAscending=3,//费用（升序 低->高）
    SpotFilterSortType_FeeDescending=4,//费用(降序 高->低)
    SpotFilterSortType_None=99,//无排序
};


@class BDSpotModel;
@class BDSpotSortTypeInfo,BDFilterLocation;
@class BDUserSearchFilter;

#define kSpotFilterAllCodeBitsValue @"all" //全部品牌

typedef NS_OPTIONS(NSUInteger, SpotFilterType) {
    
    SpotFilterType_NearBy=1<<0,//附近
    SpotFilterType_Device=1<<1,//设备《已废弃》
    SpotFilterType_Sort=1<<2,//排序
    SpotFilterType_Selection=1<<3,//筛选
};

@interface BDSpotFilter : BDBaseModelObject<NSCopying>

@property (nonatomic,copy) NSString *keyword; //关键字
@property (nonatomic,assign) BOOL onlyKeyword;//是否带关键字过滤

@property (nonatomic,assign) SpotFilterSortType sortType; //排序类型

@property (nonatomic,assign) double distance; //距离中心点的最远距离(米)
@property (nonatomic,strong) BDFilterLocation *filterLocation; //过滤所设置的位置坐标点

@property (nonatomic,strong) BDUserSearchFilter *searchFilter;//用户搜索偏好

@property (nonatomic,assign,readonly) BOOL hadFilterLocation;
@property (nonatomic,strong,readonly) NSDictionary *filterParams; //过滤参数 用于提交后台搜索

//并非单例 为设置默认条件的过滤
+(instancetype)defaultFilter;
//判断所保存的偏好过滤条件与之是否相同
-(BOOL)isEqualToSpotFilter:(BDSpotFilter *)spotFilter;
//用于搜索历史持久化
-(NSDictionary *)responseDictionary;
//热门城市
+(NSArray *)getHotCityArray;
@end

#pragma mark-充电点过滤项的key value
@interface BDSpotFilterItem : BDBaseModelObject

@property (nonatomic,copy) NSString *title;
@property (nonatomic,assign) NSInteger value;
@end


#pragma mark-站点过滤 中心位置信息
typedef NS_ENUM(NSUInteger,SpotFilterLocationType) {
    
    SpotFilterLocationType_None=0, //默认 不按距离过滤 即使设置了经纬度
    SpotFilterLocationType_NearBy=1, //附近
    SpotFilterLocationType_Destination=2,//目的地
    SpotFilterLocationType_HotCity=3,//热门城市
    SpotFilterLocationType_Country=4,//全国
};

@interface BDFilterLocation : BDBaseModelObject<NSCopying>

@property (nonatomic,assign) SpotFilterLocationType type; //0表示没有设置Location
@property (nonatomic,copy) NSString *address;
@property (nonatomic,assign) double latitude;
@property (nonatomic,assign) double longitude;
@property (nonatomic,copy) NSString *cityCode; //城市代码
//用于搜索历史持久化 模型转化
-(NSDictionary *)responseDictionary;
//返回位置
-(CLLocation *)location;
@end

#pragma mark-站点排序 选项描述
@interface BDSpotSortTypeInfo : BDBaseModelObject

@property (nonatomic,assign) SpotFilterSortType type;
@property (nonatomic,copy) NSString *name;
@end




















