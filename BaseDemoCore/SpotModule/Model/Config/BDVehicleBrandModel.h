//
//  BDVehicleBrandModel.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/25.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*车辆品牌模型*/

#import "BDBaseModelObject.h"

extern NSString * const BDTeslaBrandId;

@class BDVehicleModel;

@interface BDVehicleBrandModel : BDBaseModelObject

@property (nonatomic,copy) NSString *brandId;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *codeBit;
@property (nonatomic,strong) NSArray<BDVehicleModel *> *vehicleModels;
@property (nonatomic,strong,readonly) UIImage *iconImage;

//是否特斯拉
-(BOOL)isTesla;

@end


/*车辆型号模型*/
@interface BDVehicleModel : BDBaseModelObject

@property (nonatomic,copy) NSString *modelId;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,strong) BDVehicleBrandModel *brandInfo;
@property (nonatomic,copy,readonly) NSString *fullName;

@end






