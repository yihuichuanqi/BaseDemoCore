//
//  BDSocialTopicModel.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/25.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDSocialModel.h"

@interface BDSocialTopicModel : BDSocialModel
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *summary;
@property (nonatomic,assign) NSInteger popularity; //热度
@property (nonatomic,copy) NSString *iconUrl;
@property (nonatomic,copy) NSString *imageUrl;
@property (nonatomic,copy) NSString *coverUrl;
@property (nonatomic,strong) NSDate *publishTime;
@property (nonatomic,copy) NSString *topicLabel;

@property (nonatomic,assign) BOOL isUserIgnore; //是否被屏蔽
@property (nonatomic,copy) NSString *detailUrl;

@property (nonatomic,assign) BOOL follow;//是否被关注

@end
