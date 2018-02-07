//
//  BDPathPlanService.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDPathPlanService.h"
#import "BDLocationService.h"

#import "BDPathPlanModel.h"
#import "BDPathPlanHistoryModel.h"
#import "BDPathPlanPOIModel.h"
#import "BDPlanTripModel.h"

#import "BDStoreManager.h"

#import "NSArray+BD.h"

@interface BDPathPlanService ()
{
    NSMutableArray<BDPathPlanHistoryModel *> *_pathPlanHistorys;
    NSMutableArray<NSString *> *_originHistorys;
    NSMutableArray<NSString *> *_destinationHistorys;
}

@end



@implementation BDPathPlanService

+(instancetype)sharedService
{
    static BDPathPlanService *service=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service=[[BDPathPlanService alloc]init];
    });
    return service;
}
-(instancetype)init
{
    if (self=[super init])
    {
        [self loadPathPlanHistorys];
    }
    return self;
}
#pragma mark-Historys
//规划历史数据 存储Key
static NSString *const BDPathPlanHistoryKey =@"BDPathPlanHistoryKey";
static NSString *const BDPathPlanOriginHistoryKey =@"BDPathPlanOriginHistoryKey";
static NSString *const BDPathPlanDestinationHistoryKey =@"BDPathPlanDestinationHistoryKey";
//最大存储量
static const NSInteger BDPathPlanHistoryMaxCount=5;
static const NSInteger BDPathPlanOriginHistoryMaxCount=10;
static const NSInteger BDPathPlanDestinationHistoryMaxCount=10;


-(void)loadPathPlanHistorys
{
    _pathPlanHistorys=[NSMutableArray array];
    _originHistorys=[NSMutableArray array];
    _destinationHistorys=[NSMutableArray array];
    
    [_pathPlanHistorys addObjectsFromArray:[BDPathPlanHistoryModel arrayWithAttributesArray:[[BDStoreManager manager] getObjectById:BDPathPlanHistoryKey fromTable:kBDStorePathPlanHistory_Table]]];
    [_originHistorys addObjectsFromArray:[BDPathPlanHistoryModel arrayWithAttributesArray:[[BDStoreManager manager] getObjectById:BDPathPlanOriginHistoryKey fromTable:kBDStorePathPlanHistory_Table]]];
    [_destinationHistorys addObjectsFromArray:[BDPathPlanHistoryModel arrayWithAttributesArray:[[BDStoreManager manager] getObjectById:BDPathPlanDestinationHistoryKey fromTable:kBDStorePathPlanHistory_Table]]];
    
    //剔除非法数据
    [_pathPlanHistorys bd_removeObjectsPassingTest:^BOOL(BDPathPlanHistoryModel *obj, NSUInteger idx, BOOL *stop) {
       
        return ![obj isKindOfClass:[BDPathPlanHistoryModel class]];
    }];
    [_originHistorys bd_removeObjectsPassingTest:^BOOL(NSString *obj, NSUInteger idx, BOOL *stop) {
     
        return ![obj isKindOfClass:[NSString class]];
        
    }];
    [_destinationHistorys bd_removeObjectsPassingTest:^BOOL(NSString *obj, NSUInteger idx, BOOL *stop) {
     
        return ![obj isKindOfClass:[NSString class]];
    }];
    
}
-(void)savePathPlanAllHistorys
{
    [[BDStoreManager manager] putObject:[BDPathPlanHistoryModel attributesArrayFromModelArray:self.pathPlanHistorys] withId:BDPathPlanHistoryKey intoTable:kBDStorePathPlanHistory_Table];
    [[BDStoreManager manager] putObject:self.originHistorys withId:BDPathPlanOriginHistoryKey intoTable:kBDStorePathPlanHistory_Table];
    [[BDStoreManager manager] putObject:self.destinationHistorys withId:BDPathPlanDestinationHistoryKey intoTable:kBDStorePathPlanHistory_Table];

}
-(void)savePathPlanHistory:(BDPathPlanHistoryModel *)pathPlanHistory
{
    [_pathPlanHistorys removeModelObject:pathPlanHistory];
    [_pathPlanHistorys insertObject:pathPlanHistory atIndex:0];
    
    if (self.pathPlanHistorys.count>BDPathPlanHistoryMaxCount)
    {
        [_pathPlanHistorys removeObjectsInRange:NSMakeRange(BDPathPlanHistoryMaxCount, self.pathPlanHistorys.count-BDPathPlanHistoryMaxCount)];
    }
    [[BDStoreManager manager] putObject:[BDPathPlanHistoryModel attributesArrayFromModelArray:self.pathPlanHistorys] withId:BDPathPlanHistoryKey intoTable:kBDStorePathPlanHistory_Table];
}
-(void)savePathPlanOriginHistory:(NSString *)pathPlanKeyword
{
    [_originHistorys removeObject:pathPlanKeyword];
    [_originHistorys insertObject:pathPlanKeyword atIndex:0];
    
    if (self.originHistorys.count>BDPathPlanOriginHistoryMaxCount)
    {
        [_originHistorys removeObjectsInRange:NSMakeRange(BDPathPlanOriginHistoryMaxCount, self.originHistorys.count-BDPathPlanOriginHistoryMaxCount)];
    }
    [[BDStoreManager manager] putObject:self.originHistorys withId:BDPathPlanOriginHistoryKey intoTable:kBDStorePathPlanHistory_Table];

}
-(void)savePathPlanDestinationHistory:(NSString *)pathPlanKeyword
{
    [_destinationHistorys removeObject:pathPlanKeyword];
    [_destinationHistorys insertObject:pathPlanKeyword atIndex:0];
    
    if (self.destinationHistorys.count>BDPathPlanDestinationHistoryMaxCount)
    {
        [_destinationHistorys removeObjectsInRange:NSMakeRange(BDPathPlanDestinationHistoryMaxCount, self.originHistorys.count-BDPathPlanDestinationHistoryMaxCount)];
    }
    [[BDStoreManager manager] putObject:self.destinationHistorys withId:BDPathPlanDestinationHistoryKey intoTable:kBDStorePathPlanHistory_Table];

}
-(void)removePathPlanHistory:(BDPathPlanHistoryModel *)pathPlanHistory
{
    [_pathPlanHistorys removeModelObject:pathPlanHistory];
    [[BDStoreManager manager] putObject:[BDPathPlanHistoryModel attributesArrayFromModelArray:self.pathPlanHistorys] withId:BDPathPlanHistoryKey intoTable:kBDStorePathPlanHistory_Table];
}
-(void)removePathPlanOriginHistory:(NSString *)pathPlanKeyword
{
    [_originHistorys removeObject:pathPlanKeyword];
    [[BDStoreManager manager] putObject:self.originHistorys withId:BDPathPlanOriginHistoryKey intoTable:kBDStorePathPlanHistory_Table];

}
-(void)removePathPlanDestinationHistory:(NSString *)pathPlanKeyword
{
    [_destinationHistorys removeObject:pathPlanKeyword];
    [[BDStoreManager manager] putObject:self.destinationHistorys withId:BDPathPlanDestinationHistoryKey intoTable:kBDStorePathPlanHistory_Table];

}
-(void)removeAllPathPlanHistory
{
    [_pathPlanHistorys removeAllObjects];
    [[BDStoreManager manager] putObject:[BDPathPlanHistoryModel attributesArrayFromModelArray:self.pathPlanHistorys] withId:BDPathPlanHistoryKey intoTable:kBDStorePathPlanHistory_Table];

}
-(void)removeAllPathPlanOriginHistory
{
    [_originHistorys removeAllObjects];
    [[BDStoreManager manager] putObject:self.originHistorys withId:BDPathPlanOriginHistoryKey intoTable:kBDStorePathPlanHistory_Table];

}
-(void)removeAllPathPlanDestinationHistory
{
    [_destinationHistorys removeAllObjects];
    [[BDStoreManager manager] putObject:self.destinationHistorys withId:BDPathPlanDestinationHistoryKey intoTable:kBDStorePathPlanHistory_Table];

}


-(void)getPlanInfoWithPathPlan:(BDRemotePathPlanModel *)remotePathPlan complete:(void(^)(NSString *pathPolylineString,NSArray<NSNumber *> *pathDistances,NSArray<NSNumber *> *pathDurations,CLLocationDistance totalDistance,NSTimeInterval totalDuration,NSError *error))complete
{
    if (remotePathPlan!=nil)
    {
        __block NSMutableArray<AMapPath *> *pathArray=[NSMutableArray array];
        __block void(^requestPathAction)(NSUInteger currentIndex)=^(NSUInteger currentIndex)
        {
            //确保在有效数据范围内
            if (currentIndex+1<remotePathPlan.pathPOIArray.count)
            {
                BDPathPlanPOIModel *fromPOI=remotePathPlan.pathPOIArray[currentIndex];
                BDPathPlanPOIModel *toPOI=remotePathPlan.pathPOIArray[currentIndex+1];
                [[BDLocationService sharedService] searchDrivingPathFromCoordinate:fromPOI.coordinate ToCoordinate:toPOI.coordinate Strategy:0 AvoidPolygons:nil complete:^(AMapRoute *route, NSError *error) {
                    
                    if (error==nil&&route.paths.count>0)
                    {
                        [pathArray addObject:route.paths.firstObject];
                        requestPathAction(currentIndex+1);
                    }
                    else
                    {
                        if (complete!=nil)
                        {
                            complete(nil,nil,nil,0,0,error);
                        }
                    }
                    
                }];
            }
            else
            {
                NSString *pathPolylineString=makeCoordinatesStringWithAMapPathsArray(pathArray);
                NSArray<NSNumber *>*pathDistanceArray=[pathArray valueForKey:@"distance"];
                NSArray<NSNumber *>*pathDurationArray=[pathArray valueForKey:@"duration"];
                CLLocationDistance totalDistance=0;
                for (NSNumber *distanceValue in pathDistanceArray)
                {
                    totalDistance+=distanceValue.doubleValue;
                }
                NSTimeInterval totalDuration=0;
                for (NSNumber *durationValue in pathDurationArray)
                {
                    totalDuration+=durationValue.doubleValue;
                }
                
                //callBack
                if(complete!=nil)
                {
                    complete(pathPolylineString,pathDistanceArray,pathDurationArray,totalDistance,totalDuration,nil);
                }
                requestPathAction=nil;
            }
        };
        requestPathAction(0U);
        return;
    }
    
    if (complete!=nil)
    {
        complete(nil,nil,nil,0,0,[self bd_error:@"规划结果错误" revCode:9999]);
    }
    return;
    
}

-(NSError *)bd_error:(NSString *)errorMessage revCode:(NSInteger)code
{
    NSString *appName=@"应用名称";
    NSError *error=[NSError errorWithDomain:appName code:code userInfo:@{@"userInfo":errorMessage?:@"未知错误"}];
    return error;
}

#pragma mark-内置方法
NSString *makeCoordinatesStringWithAMapPathsArray(NSArray<AMapPath *> *pathArray)
{
    NSMutableArray *stringArray=[NSMutableArray array];
    for (AMapPath *path in pathArray)
    {
        NSString *pathString=makeCoordinatesStringWithAMapPath(path);
        [stringArray addObject:pathString];
    }
    return [stringArray componentsJoinedByString:@";"];
}
NSString *makeCoordinatesStringWithAMapPath(AMapPath *path)
{
    NSString *coordinatesString=nil;
    NSArray *polylines=[path.steps valueForKey:@"polyline"];
    coordinatesString=[polylines componentsJoinedByString:@";"];
    return coordinatesString;
}










@end
