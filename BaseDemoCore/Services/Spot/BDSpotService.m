//
//  BDSpotService.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/14.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDSpotService.h"

#import "BDSpotModel.h"
#import "BDClusterAnnotation.h"
#import "BDStationAnnotation.h"

#import "BDSpotDao.h"
#import "BDSpotFlowService.h"
#import "BDRequestManager.h"
#import "BDSpotFilter.h"


#import "NSError+BD.h"
#import "NSDictionary+BD.h"
#import "EVCrypto.h"

@interface BDSpotService ()<BDSpotFlowServiceDelegate>

@property (nonatomic,strong) BDSpotDao *spotDao;
@end

@implementation BDSpotService


-(BDSpotDao *)spotDao
{
    if (!_spotDao)
    {
        _spotDao=[[BDSpotDao alloc]init];
        [_spotDao createTable:YES];
    }
    return _spotDao;
}

+(instancetype)sharedServices
{
    static BDSpotService *service=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service=[[BDSpotService alloc]init];
    });
    return service;
}

-(id)init
{
    self=[super init];
    if (self)
    {
        [self addSpotFlowDelegateAndNotificatioObservers];
    }
    return self;
}

-(void)addSpotFlowDelegateAndNotificatioObservers
{
    [BDSpotFlowService sharedService].delegate=self;
    [[BDSpotFlowService sharedService].commonDelegates addObject:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completedZipQueue:) name:kCompletedDownloadZipQueueNotification object:nil];
}
-(void)completedZipQueue:(NSNotification *)noti
{
    
}

-(NSString *)spotTableName
{
    return [self.spotDao tableName];
}



-(void)downloadSpotZip:(BOOL)sendVersion
{
    [[BDSpotFlowService sharedService] handleDownloadSpotZip];
    if (sendVersion)
    {
        [[BDSpotFlowService sharedService] handleSendVersionToServer];
    }
}
#pragma mark-BDSpotFlowService Delegate
-(void)unzipData:(NSString *)zipString package:(BDHandlePackage *)package
{
    @autoreleasepool{
        //接手并消化处理zip包数据
        /* *********站点zip字典
         {
         address = "qF3vUA+9MeEnqaDzHcvUGno4EHu0wcIwuXV8wW0oXLyFnEAnuPG5lD3BFN2C0zSaJgRbAmNWDxU=";
         cityCode = AuuxZnaqPsGqH2am;
         codeBitList = "203,201,199,197,195,189,187,185,183,181,179,177,175,173,171,169,167,165,163,161,159,157,155,153,151,149,147";
         ctime = 1490777286;
         currentType = 2;
         currentTypeNum =     {
         1 = 0;
         2 = 2;
         };
         deleted = 0;
         distance = 0;
         favorite = 0;
         id = 257833147985559872;
         latitude = "BQxW+iN+nvYG1oIbHA0eww==";
         link = 1;
         longitude = "7jkRjSbhV2cv6Dtq97/JLg==";
         mtime = 1513922483;
         name = "\U65b0\U4e16\U754c\U5546\U57ce";
         operateType = 2;
         operatorTypes = 1395;
         phone = 4006105288;
         propertyType = 7;
         provinceCode = 310000;
         quantity = 2;
         score = "4.4";
         serviceCode = 1;
         spotType = 2;
         status = 0;
         supportChargingType = 1;
         tags = "1,3,4";
         }
         */
        NSArray *spotArray=[zipString mj_JSONObject];
        NSMutableDictionary *deletedIdsDict=[NSMutableDictionary dictionary];//保存待删除的站点Where语句
        NSMutableDictionary *changedIdsDict=[NSMutableDictionary dictionary];//待更改的站点
        for(NSDictionary *dict in spotArray)
        {
            NSString *spotId=[dict bd_StringObjectForKey:@"id"];
            //deleted:0表示新增或者修改 1表示需删除
            NSUInteger deleted=[dict[@"deleted"] intValue];
            if (deleted==1)
            {
                [deletedIdsDict bd_safeSetObject:[self.spotDao getDeleteWhere:spotId] forKey:spotId];
            }
            else
            {
                NSString *latitude= [EVCrypto decryptXXTEAWithString:[dict bd_StringObjectForKey:@"latitude"]];
                NSString *longitude=[EVCrypto decryptXXTEAWithString:[dict bd_StringObjectForKey:@"longitude"]];
                CLLocationCoordinate2D coordinate2D=CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
                if (CLLocationCoordinate2DIsValid(coordinate2D))
                {
                    //经纬度有效才添加到本地
                    [changedIdsDict bd_safeSetObject:dict forKey:spotId withClass:[NSDictionary class]];
                }
            }
        }
        //保存到数据库
        [self.spotDao batchReplaceToTable:changedIdsDict.allValues];
        [self.spotDao batchDeleteFromTable:deletedIdsDict.allValues];
        dispatch_async(dispatch_get_main_queue(), ^{
           
            //回调到地图
            //回调到Spot流 调用成功
            if(package)
            {
                [[BDSpotFlowService sharedService] handleSuccessWithPackage:package];
            }
            
        });
    }
}
-(void)spotStatus:(NSDictionary *)spotStatusDict package:(BDHandlePackage *)package
{
    @autoreleasepool{
        
        NSInteger ver=[[NSUserDefaults standardUserDefaults] integerForKey:kUCGetSpotsTime];
        //判断站点是否存在
        BDSpotModel *existSpot=[self getSpotModelBySpotId:[spotStatusDict bd_StringObjectForKey:@"spotId"]];
        if (existSpot)
        {
            NSInteger updated_Time=[spotStatusDict bd_IntergerForKey:@"updated_time"];
            //时间是否在最近一次更新之后
            if (updated_Time>ver)
            {
                NSString *status=[spotStatusDict bd_StringObjectForKey:@"status"];
                if ([self updateSpotStatus:status spot:existSpot updatedTime:updated_Time])
                {
                    //回调状态变化
                    if (self.delegate&&[self.delegate respondsToSelector:@selector(changedSpotStatus:)])
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                           
                            [self.delegate changedSpotStatus:existSpot];

                        });
                    }
                }
            }
        }
    }
}
//如果状态是最新的并且发生变化 则更新到数据库
-(BOOL)updateSpotStatus:(NSString *)status spot:(BDSpotModel *)spot updatedTime:(NSTimeInterval)updatedTime
{
    NSInteger zipUpdateTime=[[NSUserDefaults standardUserDefaults] integerForKey:kUCGetSpotsTime];
    if (updatedTime<=zipUpdateTime)
    {
        return NO;
    }
    NSString *statusUpdateId=[NSString stringWithFormat:@"status_updated_id_%@",spot.spotId];
    NSString *updatedTimeStr;
    if (updatedTime<=updatedTimeStr.integerValue)
    {
        return NO;
    }
    
    return YES;
}


-(NSArray *)getSpotsWithNearbyArround:(CLLocationCoordinate2D)coordinate distance:(CLLocationDistance)distance
{
 
    BDFilterLocation *filterLocation=[[BDFilterLocation alloc]init];
    filterLocation.latitude=coordinate.latitude;
    filterLocation.longitude=coordinate.longitude;
    filterLocation.type=SpotFilterLocationType_NearBy;
    BDSpotFilter *filter=[BDSpotFilter defaultFilter];
    filter.filterLocation=filterLocation;
    filter.distance=distance;
    return [self.spotDao getSpotsBySpotFilter:filter];
}
-(NSArray *)getSpotsByCoordinate:(CLLocationCoordinate2D)fromCoordinate toCoordinate:(CLLocationCoordinate2D)toCoordinate spotFolter:(BDSpotFilter *)spotFilter
{
    return [self.spotDao getSpotsBySpotFilter:spotFilter fromCoordinate:fromCoordinate toCoordinate:toCoordinate];
}
-(BDSpotModel *)getSpotModelBySpotId:(NSString *)spotId
{
    return [self.spotDao getSpotInfoBySpotId:spotId];
}
-(BDSpotModel *)getSpotModelBySpotId:(NSString *)spotId block:(void(^)(BDSpotModel *spot,NSError *error))block
{
    BDSpotModel *targetSpot=[self getSpotModelBySpotId:spotId];
    if (block!=nil)
    {
        //本地不存在 则获取网络数据
        if (targetSpot==nil)
        {
            [self fetchSpotDetailInfo:spotId block:block];
        }
        else
        {
            block(targetSpot,nil);
        }
    }
    return targetSpot;
}

-(void)getAnnotations:(CLLocationCoordinate2D)fromCoordinate toCoordinate:(CLLocationCoordinate2D)toCoordinate spotFilter:(BDSpotFilter *)spotFilter zoomLevel:(NSUInteger)zoomLevel ignoreSpotId:(NSString *)ignoreSpotId eachBlock:(void(^)(id<BDAnnotationDelegate>model))eachBlock finishBlock:(void(^)(NSArray *models))finishBlock
{
    kClusterType clusterType=[BDClusterAnnotationHelper shouldClustered:zoomLevel];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        switch (clusterType) {
            case kClusterType_None:
                {
                    [self.spotDao getStationAnnotations:fromCoordinate toCoordinate:toCoordinate zoomLevel:zoomLevel ignoreSpotId:ignoreSpotId spotFilter:spotFilter eachBlock:^(id<BDAnnotationDelegate> model) {
                       
                        if (eachBlock)
                        {
                            eachBlock(model);
                        }
                        
                    } finishBlock:^(NSArray *models) {
                        
                        if (finishBlock)
                        {
                            finishBlock(models);
                        }
                    }];
                }
                break;
            case kClusterType_Province:
            case kClusterType_All:
            case kClusterType_City:
            {
                [self.spotDao getClusterAnnotations:clusterType spotFilter:spotFilter eachBlock:^(id<BDAnnotationDelegate> model) {
                    
                    if (eachBlock)
                    {
                        eachBlock(model);
                    }
                    
                } finishBlock:^(NSArray *models) {
                    
                    if (finishBlock)
                    {
                        finishBlock(models);
                    }
                }];
            }
                break;
                
            default:
                break;
        }
        
    });
}




-(void)fetchSpotDetailInfo:(NSString *)spotId block:(void(^)(BDSpotModel *spot,NSError *error))block
{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params bd_safeSetObject:spotId forKey:@"spotId"];
    [[BDRequestManager requestManager] requestByGetWithPath:@"spot/getSpot" parameter:params responseSuccess:^(BDServerResponse *serverResonse) {
        
        /*
         {
         address = "qF3vUA+9MeEnqaDzHcvUGno4EHu0wcIwuXV8wW0oXLyFnEAnuPG5lD3BFN2C0zSaJgRbAmNWDxU=";
         cityCode = AuuxZnaqPsGqH2am;
         codeBitList = "203,201,199,197,195,189,187,185,183,181,179,177,175,173,171,169,167,165,163,161,159,157,155,153,151,149,147";
         ctime = 1490777286;
         currentType = 2;
         currentTypeNum =     {
         1 = 0;
         2 = 2;
         };
         deleted = 0;
         distance = 0;
         favorite = 0;
         id = 257833147985559872;
         latitude = "BQxW+iN+nvYG1oIbHA0eww==";
         link = 1;
         longitude = "7jkRjSbhV2cv6Dtq97/JLg==";
         mtime = 1515489169;
         name = "\U65b0\U4e16\U754c\U5546\U57ce";
         operateType = 2;
         operatorTypes = 1395;
         phone = 4006105288;
         propertyType = 7;
         provinceCode = 310000;
         quantity = 2;
         score = "4.4";
         serviceCode = 1;
         spotType = 2;
         status = 0;
         supportChargingType = 1;
         tags = "1,3,4";
         }
         */
        if ([serverResonse.objData isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *jsonDic=(NSDictionary *)serverResonse.objData;
            BDSpotModel *spot=[[BDSpotModel alloc]initWithAttributes:jsonDic];
            BOOL isValid=CLLocationCoordinate2DIsValid(spot.coordinate2D);
            if (jsonDic.count>0&&isValid)
            {
                //数据有效 则添加到本地并显示到地图
                [self addSpot:spot withDict:jsonDic];
            }
            if (block)
            {
                block((isValid?spot:nil),(isValid?nil:[NSError bd_Error:@"充电点经纬度不正确！！！"]));
            }
        }
        
        
    } error:^(NSString *msg, NSString *code) {
        
    }];
    
}

-(void)addSpot:(BDSpotModel *)spot withDict:(NSDictionary *)spotDict
{
    NSInteger count=[self.spotDao rowCount:[NSString stringWithFormat:@"spotId='%@'",spot.spotId]];
    if (!count&&[spotDict isKindOfClass:[NSDictionary class]]&&spotDict.count)
    {
        //数据库不存在并且数据有效
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
           
            [self.spotDao batchReplaceToTable:@[spotDict]];
        });
        //如果支持 则添加到内存中
        
    }
}
-(void)removeSpotBySpotId:(NSString *)spotId
{
    
}




@end
