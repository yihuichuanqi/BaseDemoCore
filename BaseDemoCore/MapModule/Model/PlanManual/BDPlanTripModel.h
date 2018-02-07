//
//  BDPlanTripModel.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDBaseModelObject.h"

@class BDPlanTripPointModel;

@interface BDPlanTripModel : BDBaseModelObject

@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *avatarUrl; //头像路径
@property (nonatomic,strong) NSArray<BDPlanTripPointModel *> *tripPoints; //途径点
@property (nonatomic,strong) NSString *tripPathString; //经纬度字符串
@property (nonatomic,assign) NSInteger distance; //行程距离
@property (nonatomic,strong) NSString *timeStamp; //时间戳
@property (nonatomic,assign) NSInteger duration; //行程时长

-(instancetype)initWithTitle:(NSString *)title
                   avatarUrl:(NSString *)avatarUrl
                  tripPoints:(NSArray<BDPlanTripPointModel *> *)tripPoints
              tripPathString:(NSString *)tripPathString
             timeStampString:(NSString *)timeStampString
                    duration:(NSInteger)duration;





@end
