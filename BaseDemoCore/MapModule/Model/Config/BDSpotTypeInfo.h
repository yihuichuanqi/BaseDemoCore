//
//  BDSpotTypeInfo.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/21.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*站点不同类型信息 配置图片*/

#import "BDBaseModelObject.h"
#import "BDSpotConstant.h"

@interface BDSpotTypeInfo : BDBaseModelObject

@property (nonatomic,assign) BDSpotType type;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *shortName;
@property (nonatomic,copy) NSString *desc;
@property (nonatomic,copy) NSString *shortDesc;
@property (nonatomic,copy) UIColor *color;

@property (nonatomic,strong,readonly) UIImage *iconImage;
@property (nonatomic,strong,readonly) UIImage *timeLineImage;
@property (nonatomic,strong,readonly) UIImage *annotationImage;
@property (nonatomic,strong,readonly) UIImage *annotationBackgroundImage;
@property (nonatomic,strong,readonly) UIImage *annotationBackground_linkedImage;


-(void)checkSpotConfigImage;




@end
