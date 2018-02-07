//
//  BDBasicConfigService.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/18.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*应用基本配置文件服务*/

#import <Foundation/Foundation.h>
#import "BDSpotConstant.h"

@class BDSpotTypeInfo,BDVehicleBrandModel;
//获取配置文件时间
#define kUCGetConfigTime @"kUCGetConfigTime"

@interface BDBasicConfigService : NSObject

//host地址
@property (nonatomic,copy) NSString *imageHost;
@property (nonatomic,copy) NSString *webPageHost;
@property (nonatomic,copy) NSString *sharePageHost;
@property (nonatomic,copy) NSDate *updateTime; //更新日期


@property (nonatomic,strong) NSArray<BDSpotTypeInfo *> *spotTypeInfos;
@property (nonatomic,strong) NSArray<NSString *> *spotHideInMap; //站点隐藏
@property (nonatomic,readonly) NSArray<BDVehicleBrandModel *> *socialBrandArray;//社区品牌类别

//配置文件
@property (nonatomic,strong,readonly) UIImage *clusterAnnotationImage;
@property (nonatomic,strong,readonly) UIImage *shareDefaultImage;

+(instancetype)sharedService;

-(void)loadConfigWithAttributes:(id)attributes;

-(BOOL)supportSpotType:(BDSpotType)type;
//站点类型信息
-(BDSpotTypeInfo *)spotTypeInfoWithType:(BDSpotType)type;



@end
