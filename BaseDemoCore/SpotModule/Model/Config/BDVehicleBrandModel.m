//
//  BDVehicleBrandModel.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/25.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDVehicleBrandModel.h"
#import "BDImageLoader.h"
#import "NSDictionary+BD.h"

NSString * const BDTeslaBrandId=@"149";

@interface BDVehicleBrandModel ()

@property (nonatomic,copy) NSString *iconPath;//图片路径
@end

@implementation BDVehicleBrandModel

-(id)initWithAttributes:(NSDictionary *)aAttributes
{
    if (self=[super initWithAttributes:aAttributes])
    {
        _brandId=[aAttributes bd_StringObjectForKey:@"id"];
        _name=[aAttributes bd_StringObjectForKey:@"name"];
        _iconPath=[aAttributes bd_StringObjectForKey:@"icon"];
        _codeBit=[aAttributes bd_StringObjectForKey:@"codeBit"];
        _vehicleModels=[aAttributes bd_modelArrayForKey:@"vehicleModels" class:[BDVehicleModel class]];
        [_vehicleModels enumerateObjectsUsingBlock:^(BDVehicleModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           
            obj.brandInfo=self;
        }];
    }
    return self;
}
-(UIImage *)iconImage
{
    return [[BDImageLoader sharedLoader] getLocalImageWithPath:self.iconPath];
}
-(BOOL)isTesla
{
    return [self.brandId isEqualToString:BDTeslaBrandId];
}

-(NSString *)keyProperty
{
    return self.brandId;
}


@end



@implementation BDVehicleModel

-(id)initWithAttributes:(NSDictionary *)aAttributes
{
    if (self=[super initWithAttributes:aAttributes])
    {
        _modelId=[aAttributes bd_StringObjectForKey:@"id"];
        _name=[aAttributes bd_StringObjectForKey:@"name"];
    }
    return self;
}
-(NSString *)fullName
{
    return [NSString stringWithFormat:@"%@ %@",self.brandInfo.name,self.name];
}
-(NSString *)keyProperty
{
    return self.modelId;
}

@end


