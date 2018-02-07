//
//  BDVehicleConfigService.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/25.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*爱车配置类*/

#import <Foundation/Foundation.h>
#import "BDVehicleBrandModel.h"

@interface BDVehicleConfigService : NSObject

@property (nonatomic,strong) NSArray<BDVehicleBrandModel *> *vehicleBrandArray;
@property (nonatomic,strong,readonly) NSArray<BDVehicleBrandModel *> *frontMyVehicleBrandArray; //将我的爱车品牌放置在最前面

+(instancetype)sharedService;

-(void)loadConfigWithAttributes:(id)aAttributes;

-(BDVehicleBrandModel *)getVehicleBrandInfoForId:(NSString *)brandId;
-(BDVehicleBrandModel *)getVehicleBrandInfoForName:(NSString *)brandName;
-(BDVehicleModel *)getVehicleModelForId:(NSString *)modelId;
//根据批量品牌id获取品牌模型
-(NSArray<BDVehicleBrandModel *> *)getVehicleBrandArrayForIds:(NSArray<NSString *> *)idArray;


@end
