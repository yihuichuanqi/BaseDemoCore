//
//  BDPlanTripModel.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDPlanTripModel.h"
#import "BDPlanTripPointModel.h"
#import "BDMapTripService.h"

@implementation BDPlanTripModel

-(id)initWithAttributes:(NSDictionary *)aAttributes
{
    self=[super initWithAttributes:aAttributes];
    if (self)
    {
        self.title=[aAttributes objectForKey:@"title"];
        self.distance=[[aAttributes objectForKey:@"distance"] integerValue];
        
        //新的数据json格式
        if ([self.tripPoints.firstObject isKindOfClass:[NSDictionary class]])
        {
            
        }
        
    }
    return self;
}

-(NSDictionary *)attributesFromModel
{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    dict[@"title"]=_title?:@"";
    return dict;
}
-(instancetype)initWithTitle:(NSString *)title avatarUrl:(NSString *)avatarUrl tripPoints:(NSArray<BDPlanTripPointModel *> *)tripPoints tripPathString:(NSString *)tripPathString timeStampString:(NSString *)timeStampString duration:(NSInteger)duration
{
    self=[super init];
    if (self)
    {
        self.title=title;
        self.avatarUrl=avatarUrl?:@"";
        self.tripPoints=tripPoints;
        self.tripPathString=tripPathString;
        self.duration=duration;
        self.timeStamp=timeStampString;
        self.distance=[BDMapTripService distanceForCoordinateString:_tripPathString];

    }
    return self;
}












@end
