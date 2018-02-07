//
//  BDVehicleConfigService.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/25.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDVehicleConfigService.h"
#import "NSDictionary+BD.h"
#import "NSArray+BD.h"
#import "NSString+BD.h"

@interface BDVehicleConfigService ()

//爱车品牌(以品牌id为key)
@property (nonatomic,copy) NSDictionary<NSString *,BDVehicleBrandModel *> *vehicleBrandDict;
//车辆型号
@property (nonatomic,copy) NSDictionary<NSString *,BDVehicleModel *> *vehicleModelDict;
@end

@implementation BDVehicleConfigService

+(instancetype)sharedService
{
    static BDVehicleConfigService *service=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service=[[BDVehicleConfigService alloc]init];
    });
    return service;
}

-(void)loadConfigWithAttributes:(id)aAttributes
{
    self.vehicleBrandArray=[BDVehicleBrandModel arrayWithAttributesArray:aAttributes];
    self.vehicleBrandDict=[NSDictionary bd_DictionaryWithArray:self.vehicleBrandArray keyPropertyName:@"brandId"];
    
    NSMutableDictionary<NSString *,BDVehicleModel *> *modelDict=[NSMutableDictionary dictionary];
    [self.vehicleBrandArray enumerateObjectsUsingBlock:^(BDVehicleBrandModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        [modelDict setValuesForKeysWithDictionary:[NSDictionary bd_DictionaryWithArray:obj.vehicleModels keyPropertyName:@"modelId"]];
    }];
    self.vehicleModelDict=[modelDict copy];
}

-(BDVehicleBrandModel *)getVehicleBrandInfoForId:(NSString *)brandId
{
    if (![brandId isKindOfClass:[NSString class]])
    {
        brandId=[NSString stringWithFormat:@"%@",brandId];
    }
    return self.vehicleBrandDict[brandId];
}
-(BDVehicleModel *)getVehicleModelForId:(NSString *)modelId
{
    return self.vehicleModelDict[modelId];
}
-(BDVehicleBrandModel *)getVehicleBrandInfoForName:(NSString *)brandName
{
    //暂时未实现 需要使用语法糖
    return nil;
}
-(NSArray<BDVehicleBrandModel *> *)getVehicleBrandArrayForIds:(NSArray<NSString *> *)idArray
{
    __block NSMutableArray<BDVehicleBrandModel *> *modelArray=[NSMutableArray arrayWithCapacity:idArray.count];
    [idArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        BDVehicleBrandModel *model=[self getVehicleBrandInfoForId:obj];
        [modelArray bd_safeAddObject:model];
        
    }];
    return [modelArray copy];
}
-(NSArray<BDVehicleBrandModel *> *)frontMyVehicleBrandArray
{
    NSString *myCarBrands=@"";
    if (!isEmpty(myCarBrands))
    {
        NSMutableArray *supportBrands=[NSMutableArray array];
        NSMutableArray *unSupportBrands=[NSMutableArray array];
        for (BDVehicleBrandModel *model in self.vehicleBrandArray)
        {
            if ([myCarBrands bd_intersectsElementString:model.codeBit btSeparator:@","])
            {
                [supportBrands addObject:model];
            }
            else
            {
                [unSupportBrands addObject:model];
            }
        }
        [supportBrands addObjectsFromArray:unSupportBrands];
        return supportBrands;
    }
    return self.vehicleBrandArray;
}




@end
