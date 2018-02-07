//
//  BDSpotDao.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/15.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDSpotDao.h"
#import "BDSpotModel.h"
#import "BDLocationObject.h"
#import "BDStationAnnotation.h"
#import "BDClusterAnnotation.h"

#import "BDLocationService.h"
#import "BDSpotFilter.h"
#import "BDUserSearchFilter.h"

#import "BDSpotConstant.h"
#import "NSDictionary+BD.h"
#import "EVCrypto.h"

//每页最大值
#define kSpotDaoResultsPerPage 10

@implementation BDSpotDao

#pragma mark-Dao Protocol
-(void)buildProperties
{
    if (!self.propertyList)
    {
        self.propertyList=[[BDSqlitePropertyList alloc]init];
    }
    //添加表字段
    [self.propertyList addFieldName:@"spotId" serverFieldName:@"id,pid" isPrimaryKey:YES modelDataType:kModelDataTypeString];
    [self.propertyList addFieldName:@"phone" serverFieldName:@"phone" modelDataType:kModelDataTypeString];
    [self.propertyList addFieldName:@"name" serverFieldName:@"name" modelDataType:kModelDataTypeString];
    [self.propertyList addFieldName:@"quantity" serverFieldName:@"quantity" modelDataType:kModelDataTypeString];
    [self.propertyList addFieldName:@"serviceCode" serverFieldName:@"serviceCode" modelDataType:kModelDataTypeInterger];
    
    //服务端不存在此字段 仅用于中间计算转化使用
    [self.propertyList addFieldName:@"curDistance" serverFieldName:nil modelFieldName:@"distance" modelDataType:kModelDataTypeDouble];
    [self.propertyList addFieldName:@"destDistance" serverFieldName:nil modelFieldName:@"destinationDistance" modelDataType:kModelDataTypeDouble];
    //自己添加字段
    [self.propertyList addFieldName:@"owner_Json" serverFieldName:@"owner" modelFieldName:@"owner" modelClass:nil modelDataType:kModelDataTypeObject];
    [self.propertyList addFieldName:@"priceRational" serverFieldName:@"priceRational" modelDataType:kModelDataTypeInterger];
    [self.propertyList addFieldName:@"mapIcon" serverFieldName:@"mapIcon" modelDataType:kModelDataTypeString];
    
    [self.propertyList addFieldName:@"status" serverFieldName:@"status" modelDataType:kModelDataTypeString];
    [self.propertyList addFieldName:@"link" serverFieldName:@"link" modelDataType:kModelDataTypeBool];
    [self.propertyList addFieldName:@"spotType" serverFieldName:@"spotType" modelDataType:kModelDataTypeInterger];
    [self.propertyList addFieldName:@"currentType" serverFieldName:@"currentType" modelDataType:kModelDataTypeInterger];
    [self.propertyList addFieldName:@"propertyType" serverFieldName:@"propertyType" modelDataType:kModelDataTypeInterger];
    [self.propertyList addFieldName:@"score" serverFieldName:@"score,avgScore" modelDataType:kModelDataTypeString];
    [self.propertyList addFieldName:@"codeBitList" serverFieldName:@"codeBitList" modelDataType:kModelDataTypeString];
    [self.propertyList addFieldName:@"operatorTypes" serverFieldName:@"operatorTypes" modelDataType:kModelDataTypeString];
    [self.propertyList addFieldName:@"operateType" serverFieldName:@"operateType" modelDataType:kModelDataTypeInterger];
    [self.propertyList addFieldName:@"tags" serverFieldName:@"tags" modelDataType:kModelDataTypeString];
    [self.propertyList addFieldName:@"supportChargingType" serverFieldName:@"supportChargingType" modelDataType:kModelDataTypeInterger];
    
    //读库时 忽略加密字段，由解密字段赋值
    [self.propertyList addFieldName:@"latitude" serverFieldName:@"latitude" modelFieldName:@"" modelDataType:kModelDataTypeString];
    [self.propertyList addFieldName:@"longitude" serverFieldName:@"longitude" modelFieldName:@"" modelDataType:kModelDataTypeString];
    [self.propertyList addFieldName:@"address" serverFieldName:@"address" modelFieldName:@"" modelDataType:kModelDataTypeString];
    [self.propertyList addFieldName:@"cityCode" serverFieldName:@"cityCode" modelFieldName:@"" modelDataType:kModelDataTypeString];
    //额外增加字段 将原加密字段解密后存入 对应的model字段由modelFieldName设定
    [self.propertyList addFieldName:@"db_latitude" serverFieldName:@"db_latitude" modelFieldName:@"latitude" modelDataType:kModelDataTypeFloat];
    [self.propertyList addFieldName:@"db_longitude" serverFieldName:@"db_longitude" modelFieldName:@"longitude" modelDataType:kModelDataTypeFloat];
    [self.propertyList addFieldName:@"db_address" serverFieldName:@"db_address" modelFieldName:@"address" modelDataType:kModelDataTypeString];
    [self.propertyList addFieldName:@"db_cityCode" serverFieldName:@"db_cityCode" modelFieldName:@"cityCode" modelDataType:kModelDataTypeString];
    [self.propertyList addFieldName:@"db_provinceCode" serverFieldName:@"db_provinceCode" modelFieldName:@"" modelDataType:kModelDataTypeString];

}
-(Class)modelClass
{
    return [BDSpotModel class];
}
-(NSString *)tableName
{
    return @"SpotDao370";
}

#pragma mark-override
-(void)batchReplaceToTable:(NSArray *)objects block:(void (^)(BOOL))block
{
    @autoreleasepool{
        
        //额外增加字段(解密经纬度、地址、城市等)存入数据库 供搜索使用
        NSMutableArray *dbArray=[NSMutableArray array];
        for (id obj in objects)
        {
            NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:obj];
            NSString *latitude=[EVCrypto decryptXXTEAWithString:[obj bd_StringObjectForKey:@"latitude"]];
            NSString *longitude=[EVCrypto decryptXXTEAWithString:[obj bd_StringObjectForKey:@"longitude"]];
            CLLocationCoordinate2D coordinate2D=CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
            if (CLLocationCoordinate2DIsValid(coordinate2D))
            {
                NSString *address=[EVCrypto decryptXXTEAWithString:[obj bd_StringObjectForKey:@"address"]];
                NSString *cityCode=[EVCrypto decryptXXTEAWithString:[obj bd_StringObjectForKey:@"cityCode"]];
                [dict bd_safeSetObject:latitude forKey:@"db_latitude"];
                [dict bd_safeSetObject:longitude forKey:@"db_longitude"];
                [dict bd_safeSetObject:address forKey:@"db_address"];
                [dict bd_safeSetObject:cityCode forKey:@"db_cityCode"];
                [dict setObject:@"" forKey:@"db_provinceCode"]; //城市上层code值
                
                [dbArray addObject:dict];
            }
        }
        [super batchReplaceToTable:dbArray block:block];
        
    }
    
}




-(instancetype)init
{
    if (self=[super init])
    {
        [self buildProperties];
        [self addSqliteFunction];
        [self updateColumns];
    }
    return self;
}

#pragma mark-Method
//自定义sqlite功能
#define kSqliteFunction_GetDistance @"getDistance"
#define kSqliteFunction_IsIntersects @"isIntersects"
#define kSqliteFunction_ChangePriceRational @"changePriceRational"

-(void)addSqliteFunction
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
           
            //计算两个坐标点的距离 [getDistance（latitude1,longitude1,latitude2,longitude2）]
            [db makeFunctionNamed:kSqliteFunction_GetDistance arguments:4 block:^(void * _Nonnull context, int argc, void * _Nonnull * _Nonnull argv) {
                
                @autoreleasepool{
                    
                    if (argc<4)
                    {
                        return ;
                    }
                    double lat1=0.0,lng1=0.0,lat2=0.0,lng2=0.0;
                    SqliteValueType lat1ValueType=[db valueType:argv[0]];
                    SqliteValueType lng1ValueType=[db valueType:argv[1]];
                    SqliteValueType lat2ValueType=[db valueType:argv[2]];
                    SqliteValueType lng2ValueType=[db valueType:argv[3]];
                    //指定变量类型
                    if (lat1ValueType==SqliteValueTypeFloat)
                    {
                        lat1=[db valueDouble:argv[0]];
                    }
                    if (lng1ValueType==SqliteValueTypeFloat)
                    {
                        lng1=[db valueDouble:argv[1]];
                    }
                    if (lat2ValueType==SqliteValueTypeFloat)
                    {
                        lat2=[db valueDouble:argv[2]];
                    }
                    if (lng2ValueType==SqliteValueTypeFloat)
                    {
                        lng2=[db valueDouble:argv[3]];
                    }
                    CLLocation *loc1=[[CLLocation alloc]initWithLatitude:lat1 longitude:lng1];
                    CLLocation *loc2=[[CLLocation alloc]initWithLatitude:lat2 longitude:lng2];
                    double distance=[loc1 distanceFromLocation:loc2];
                    [db resultDouble:distance context:context];
                }
                
            }];
            
            //比较两个以逗号隔开元素的字符串 是否包含相同元素isIntersects("1,2,4,7,9","1,6")
            [db makeFunctionNamed:kSqliteFunction_IsIntersects arguments:2 block:^(void * _Nonnull context, int argc, void * _Nonnull * _Nonnull argv) {
               
                @autoreleasepool{
                 
                    if (argc<2)
                    {
                        return ;
                    }
                    NSString *string=nil;
                    NSString *otherString=nil;
                    SqliteValueType string1ValueType=[db valueType:argv[0]];
                    SqliteValueType string2ValueType=[db valueType:argv[1]];
                    if (string1ValueType==SqliteValueTypeText)
                    {
                        NSString *string1Value=[db valueString:argv[0]];
                        string=[string1Value stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:nil];
                    }
                    if (string2ValueType==SqliteValueTypeText)
                    {
                        NSString *string2Value=[db valueString:argv[1]];
                        otherString=[string2Value stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:nil];
                    }
                    NSSet *elements=[[NSSet alloc]initWithArray:[string componentsSeparatedByString:@","]];
                    NSSet *otherElements=[[NSSet alloc]initWithArray:[otherString componentsSeparatedByString:@","]];
                    int result=[elements intersectsSet:otherElements];
                    [db resultInt:result context:context];
                    
                }
                
            }];
            
            //将费用级别为未知的改为指定值changePriceRational(value,toValue)
            [db makeFunctionNamed:kSqliteFunction_ChangePriceRational arguments:2 block:^(void * _Nonnull context, int argc, void * _Nonnull * _Nonnull argv) {
               
                @autoreleasepool{
                    
                    if (argc<2)
                    {
                        return ;
                    }
                    
                    int value=0,toValue=0,result=0;
                    SqliteValueType value1Type=[db valueType:argv[0]];
                    SqliteValueType value2Type=[db valueType:argv[1]];
                    if (value1Type==SqliteValueTypeInteger)
                    {
                        value=[db valueInt:argv[0]];
                    }
                    if (value2Type==SqliteValueTypeInteger)
                    {
                        toValue=[db valueInt:argv[1]];
                    }
                    if (value==4)
                    {
                        result=toValue;
                    }
                    else
                    {
                        result=value;
                    }
                    [db resultInt:result context:context];
                }
            }];
            
            
        }];
        
    });
}


-(BOOL)deleteSpotBySpotId:(NSString *)spotId
{
    NSString *where=[NSString stringWithFormat:@"spotId='%@'",spotId];
    return [self deleteFromTable:where];
}
//获取Spot
-(BDSpotModel *)getSpotInfoBySpotId:(NSString *)spotId
{
    NSString *where=[NSString stringWithFormat:@"spotId='%@'",spotId];
    NSArray *spots=[self models:where order:nil limit:nil];
    return [spots firstObject];
}
-(NSArray *)allSpots:(void(^)(BDSpotModel *spot))block
{
    return [self models:nil order:nil limit:nil eachBlock:^(id model) {
       
        if (block)
        {
            block(model);
        }
    }];
}
//过滤符合条件的充电点
-(NSInteger)countBySpotFilter:(BDSpotFilter *)spotFilter
{
    return [self countBySpotFilter:spotFilter spotId:nil];
}
-(NSInteger)countBySpotFilter:(BDSpotFilter *)spotFilter spotId:(NSString *)spotId
{
    __block NSInteger count=0;
    NSMutableString *sql=[NSMutableString stringWithFormat:@"SELECT count(*) AS dbCount FROM %@",self.tableName];
    NSString *where=[self getWhereBySpotFilter:spotFilter];
    if (!isEmpty(spotId))
    {
        if (!isEmpty(where))
        {
            where =[NSString stringWithFormat:@"spotId = '%@' AND %@",spotId,where];
        }
        else
        {
            where =[NSString stringWithFormat:@"spotId = '%@'",spotId];
        }
    }
    
    if (!isEmpty(where))
    {
        [sql appendFormat:@" WHERE %@",where];
    }
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
       
        FMResultSet *rs=[db executeQuery:sql];
        while ([rs next])
        {
            count=@([rs intForColumn:@"dbCount"]).integerValue;
        }
        
    }];
    return count;
    
}
-(NSArray *)getSpotsBySpotFilter:(BDSpotFilter *)spotFilter
{
    return [self getSpotsBySpotFilter:spotFilter page:0];
}
-(NSArray *)getSpotsBySpotFilter:(BDSpotFilter *)spotFilter page:(NSInteger)page
{
    return [self getSpotsBySpotFilter:spotFilter page:page eachBlock:nil];
}
-(NSArray *)getSpotsBySpotFilter:(BDSpotFilter *)spotFilter page:(NSInteger)page eachBlock:(void(^)(id model))eachBlock
{
    return [self getSpotsBySpotFilter:spotFilter page:page resultsPerPage:kSpotDaoResultsPerPage eachBlock:eachBlock];
}
-(NSArray *)getSpotsBySpotFilter:(BDSpotFilter *)spotFilter page:(NSInteger)page resultsPerPage:(NSInteger)resultsPerPage eachBlock:(void(^)(id model))eachBlock
{
    BDLocationObject *locObj=[BDLocationService sharedService].locationObj;
    //距离用户位置距离
    NSString *distance=[NSString stringWithFormat:@"%@(db_latitude,db_longitude,%@,%@)",kSqliteFunction_GetDistance,@(locObj.latitude),@(locObj.longitude)];
    //距离目的地位置距离
    NSString *distanceTo=[NSString stringWithFormat:@"%@(db_latitude,db_longitude,%@,%@)",kSqliteFunction_GetDistance,@(spotFilter.filterLocation.latitude),@(spotFilter.filterLocation.longitude)];
    NSMutableString *sql=[NSMutableString stringWithFormat:@"SELECT rowid, *, %@ as curDistance, %@ as destDistance",distance,distanceTo];

    [sql appendFormat:@" FROM %@",self.tableName];
    NSString *where=[self getWhereBySpotFilter:spotFilter];
    if (!isEmpty(where))
    {
        [sql appendFormat:@" WHERE %@",where];

    }
    NSString *orderBy=[self getOrderBySpotFilter:spotFilter];
    if (!isEmpty(orderBy))
    {
        [sql appendFormat:@" ORDER BY %@",orderBy];
    }
    if (page>0)
    {
        [sql appendFormat:@" LIMIT %@ OFFSET %@",@(resultsPerPage),@(resultsPerPage*(page-1))];
    }

    return [self modelsWithSQL:sql eachBlock:eachBlock];
}

-(NSArray *)getSpotsBySpotFilter:(BDSpotFilter *)spotFilter orderByCoordinate2D:(CLLocationCoordinate2D)coordinate2D page:(NSInteger)page resultsPerPage:(NSInteger)resultsPerPage eachBlock:(void(^)(id model))eachBlock
{
    NSString *distanceTo=[NSString stringWithFormat:@"%@(db_latitude,db_longitude,%@,%@)",kSqliteFunction_GetDistance,@(coordinate2D.latitude),@(coordinate2D.longitude)];
    NSMutableString *sql=[NSMutableString stringWithFormat:@"SELECT rowid, *"];
    [sql appendFormat:@" FROM %@",self.tableName];
    NSString *where=[self getWhereBySpotFilter:spotFilter];
    if (!isEmpty(where))
    {
        [sql appendFormat:@" WHERE %@",where];
    }
    [sql appendFormat:@" ORDER BY %@",distanceTo];
    if (page>0)
    {
        [sql appendFormat:@" LIMIT %@ OFFSET %@",@(resultsPerPage),@(resultsPerPage*(page-1))];
    }
    return [self modelsWithSQL:sql eachBlock:eachBlock];
    
}
//获取两个经纬度之间站点（矩形区域）
-(NSArray *)getSpotsBySpotFilter:(BDSpotFilter *)spotFilter fromCoordinate:(CLLocationCoordinate2D)fromCoordinate toCoordinate:(CLLocationCoordinate2D)toCoordinate
{
    NSString *where=[NSString stringWithFormat:@"(db_latitude < %@ and db_latitude > %@) and (db_longitude > %@ and db_longitude < %@) and %@",@(fromCoordinate.latitude+1),@(toCoordinate.latitude-1),@(fromCoordinate.longitude-1),@(toCoordinate.longitude+1),[self getWhereBySpotFilter:spotFilter]];
    NSString *orderBy=[NSString stringWithFormat:@"spotType DESC"];
    return [self models:where order:orderBy limit:nil];
}
//获取地区上的Annotation点
-(NSArray *)getClusterAnnotations:(kClusterType)clusterType spotFilter:(BDSpotFilter *)spotFilter eachBlock:(void(^)(id<BDAnnotationDelegate>model))eachBlock
{
    return [self getClusterAnnotations:clusterType spotFilter:spotFilter eachBlock:eachBlock finishBlock:nil];
}
-(NSArray *)getClusterAnnotations:(kClusterType)clusterType spotFilter:(BDSpotFilter *)spotFilter eachBlock:(void(^)(id<BDAnnotationDelegate>model))eachBlock finishBlock:(void(^)(NSArray *models))finishBlock
{
    NSMutableString *sql=[NSMutableString string];
    NSString *where=[self getWhereBySpotFilter:spotFilter];
    
    switch (clusterType) {
        case kClusterType_All:
            
            break;
        case kClusterType_City:
            
            break;
        case kClusterType_Province:
            
            break;
        default:
            
            NSLog(@"ERROR:clusterType Unknow:%@",@(clusterType));
            break;
    }
    [sql appendFormat:@" FROM %@ WHERE %@",self.tableName,where];
    
    NSMutableArray *clusterAnnotations=[NSMutableArray array];
    [self excuteSql:sql eachBlock:^(id each) {
       
        NSDictionary *fieldsDict=(NSDictionary *)each;
        //获取平均经纬度位置信息
        CLLocationCoordinate2D coordinate2D=CLLocationCoordinate2DMake([fieldsDict bd_DoubleForKey:@"avLat"], [fieldsDict bd_DoubleForKey:@"avLng"]);
        if(CLLocationCoordinate2DIsValid(coordinate2D))
        {
            BDClusterAnnotation *clusterAnnotation=[[BDClusterAnnotation alloc]initWithCoordinate:coordinate2D];
            clusterAnnotation.title=[fieldsDict bd_StringObjectForKey:@"title"];
            clusterAnnotation.count=[fieldsDict bd_IntergerForKey:@"total"];
            clusterAnnotation.clusterRegion=kMKCoordinateRegionWithCoordinates([fieldsDict bd_DoubleForKey:@"minLat"], [fieldsDict bd_DoubleForKey:@"maxLat"], [fieldsDict bd_DoubleForKey:@"minLog"], [fieldsDict bd_DoubleForKey:@"maxLng"]);
            //总数为0的则不显示
            if (clusterAnnotation.count>0)
            {
                [clusterAnnotations addObject:clusterAnnotation];
                if (clusterType==kClusterType_All)
                {
                    clusterAnnotation.title=@"全国";
                }
                if(eachBlock)
                {
                    eachBlock(clusterAnnotation);
                }
            }
        }
    }];
    
    eachBlock=nil;
    if (finishBlock)
    {
        finishBlock(clusterAnnotations);
        finishBlock=nil;
    }
    return clusterAnnotations;
    
}
-(NSArray *)getStationAnnotations:(CLLocationCoordinate2D)fromCoordinate toCoordinate:(CLLocationCoordinate2D)toCoordinate zoomLevel:(NSUInteger)zoomLevel spotFilter:(BDSpotFilter *)spotFilter eachBlock:(void(^)(id<BDAnnotationDelegate>model))eachBlock
{
    return [self getStationAnnotations:fromCoordinate toCoordinate:toCoordinate zoomLevel:zoomLevel ignoreSpotId:nil spotFilter:spotFilter eachBlock:eachBlock finishBlock:nil];
}
-(NSArray *)getStationAnnotations:(CLLocationCoordinate2D)fromCoordinate toCoordinate:(CLLocationCoordinate2D)toCoordinate zoomLevel:(NSUInteger)zoomLevel ignoreSpotId:(NSString *)ignoreSpotId spotFilter:(BDSpotFilter *)spotFilter eachBlock:(void(^)(id<BDAnnotationDelegate>model))eachBlock finishBlock:(void(^)(NSArray *models))finishBlock
{
    float clusterWidth=[BDClusterAnnotationHelper clusterWithForZoomLevel:zoomLevel];

    if (clusterWidth==0.0)
    {
        NSString *where=[NSString stringWithFormat:@"(db_latitude < %@ and db_latitude > %@) and (db_longitude > %@ and db_longitude < %@) and %@",@(fromCoordinate.latitude),@(toCoordinate.latitude),@(fromCoordinate.longitude),@(toCoordinate.longitude),[self getWhereBySpotFilter:spotFilter]];
        NSString *orderBy=[NSString stringWithFormat:@"spotType DESC"];
        NSMutableArray *stationAnnotations=[NSMutableArray array];
        [self models:where order:orderBy limit:nil eachBlock:^(id model) {
           
            BDSpotModel *spot=(BDSpotModel *)model;
            if (CLLocationCoordinate2DIsValid(spot.coordinate2D))
            {
                BDStationAnnotation *stationAnnotation=[[BDStationAnnotation alloc]initWithSpotModel:spot];
                [stationAnnotations addObject:stationAnnotation];
                if (eachBlock)
                {
                    eachBlock(stationAnnotation);
                }
            }
        }];
        eachBlock=nil;
        if (finishBlock)
        {
            finishBlock(stationAnnotations);
            finishBlock=nil;
        }
        return stationAnnotations;
    }
    else
    {
        NSMutableString *sql=[NSMutableString string];
        NSString *where=[NSString stringWithFormat:@"(db_latitude < %@ and db_latitude > %@) and (db_longitude > %@ and db_longitude < %@) and %@",@(fromCoordinate.latitude+0.1),@(toCoordinate.latitude-0.1),@(fromCoordinate.longitude-0.1),@(toCoordinate.longitude+0.1),[self getWhereBySpotFilter:spotFilter]];
        if (ignoreSpotId.length!=0)
        {
            where=[NSString stringWithFormat:@"%@ and spotId not like '%@'",where,ignoreSpotId];
        }
        //-0.5是为了实现向下取整 让网格对齐
        //一次聚合
        //二次聚合
        [sql appendFormat:@" FROM %@ WHERE %@",self.tableName,where];
        
        NSMutableArray *clusterAnnotations=[NSMutableArray array];
        [self excuteSql:sql eachBlock:^(id each) {
           
            NSDictionary *fieldsDict=(NSDictionary *)each;
            CLLocationCoordinate2D coordinate=CLLocationCoordinate2DMake([fieldsDict bd_DoubleForKey:@"avgLat"], [fieldsDict bd_DoubleForKey:@"avgLng"]);
            if (CLLocationCoordinate2DIsValid(coordinate))
            {
                id<BDAnnotationDelegate> annotation;
                NSInteger spotNumber=[fieldsDict bd_IntergerForKey:@"total"];
                if (spotNumber==1)
                {
                    BDSpotModel *spot=[self modelObjectWithResultDictionary:fieldsDict];
                    BDStationAnnotation *stationAnnotation=[[BDStationAnnotation alloc]initWithSpotModel:spot];
                    annotation=stationAnnotation;
                }
                else if (spotNumber>1)
                {
                    BDClusterAnnotation *clusterAnnotation=[[BDClusterAnnotation alloc]initWithCoordinate:coordinate];
                    clusterAnnotation.title=[fieldsDict bd_StringObjectForKey:@"GRID_ID"];
                    clusterAnnotation.count=[fieldsDict bd_IntergerForKey:@"total"];
                    clusterAnnotation.clusterRegion=kMKCoordinateRegionWithCoordinates([fieldsDict bd_DoubleForKey:@"minLat"], [fieldsDict bd_DoubleForKey:@"maxLng"], [fieldsDict bd_DoubleForKey:@"minLat"], [fieldsDict bd_DoubleForKey:@"maxLng"]);
                    annotation=clusterAnnotation;
                }
                if (annotation!=nil)
                {
                    [clusterAnnotations addObject:annotation];
                    if (eachBlock)
                    {
                        eachBlock(annotation);
                    }
                }
            }
        }];
        
        eachBlock=nil;
        if (finishBlock)
        {
            finishBlock(clusterAnnotations);
            finishBlock=nil;
        }
        return clusterAnnotations;
    }
}
- (NSString *)getDeleteWhere:(NSString *)spotId
{
    return [NSString stringWithFormat:@"spotId='%@'",spotId];
}
#pragma mark-Private Method
-(NSString *)getOrderBySpotFilter:(BDSpotFilter *)spotFilter
{
    NSString *orderBy=nil;
    BDLocationObject *locObj=[BDLocationService sharedService].locationObj;
    NSString *distance=[NSString stringWithFormat:@"%@(db_latitude,db_longitude,%@,%@)",kSqliteFunction_GetDistance,@(locObj.latitude),@(locObj.longitude)];
    NSString *distanceTo=[NSString stringWithFormat:@"%@(db_latitude,db_longitude,%@,%@)",kSqliteFunction_GetDistance,@(spotFilter.filterLocation.latitude),@(spotFilter.filterLocation.longitude)];
    NSString *distanceCol=spotFilter.filterLocation.type==SpotFilterLocationType_Destination?distanceTo:distance;
    switch (spotFilter.sortType) {
        case SpotFilterSortType_Distance:
            orderBy=[NSString stringWithFormat:@"%@",distanceCol];
            break;
        case SpotFilterSortType_Score:
            orderBy=[NSString stringWithFormat:@"cast(score as double) DESC, %@",distanceCol];
            break;
        case SpotFilterSortType_FeeAscending:
            orderBy=[NSString stringWithFormat:@"priceRational, %@",distanceCol];
            break;
        case SpotFilterSortType_FeeDescending:
            orderBy=[NSString stringWithFormat:@"%@(priceRational,-1) DESC,%@",kSqliteFunction_ChangePriceRational,distanceCol];
            break;
        default:
            orderBy=[NSString stringWithFormat:@"%@",distanceCol];
            break;
    }
    return orderBy;
}
-(NSString *)getWhereBySpotFilter:(BDSpotFilter *)spotFilter
{
    NSMutableString *where=[NSMutableString stringWithFormat:@"1=1"];
    if (spotFilter==nil)
    {
        return where;
    }
    //关键字
    if (!isEmpty(spotFilter.keyword))
    {
        [where appendFormat:@" AND (name like '%%%@%%' OR db_address like '%%%@%%')",spotFilter.keyword,spotFilter.keyword];
    }
    //仅按关键字过滤,则忽略其他条件
    if (spotFilter.onlyKeyword)
    {
        return where;
    }
    BDSpotFilter *defaultFilter=[BDSpotFilter defaultFilter];
    //站点速率(存在并且与默认的条件不同)
    if (spotFilter.searchFilter.spotType&&spotFilter.searchFilter.spotType!=defaultFilter.searchFilter.spotType)
    {
        [where appendFormat:@" AND (%@ & spotType) > 0",@(spotFilter.searchFilter.spotType)];
    }
    //支持品牌 默认全选不过滤
    if (!isEmpty(spotFilter.searchFilter.codeBitList)&&![spotFilter.searchFilter.codeBitList isEqualToString:kSpotFilterAllCodeBitsValue])
    {
        [where appendFormat:@" AND %@('%@', codeBitList)==1",kSqliteFunction_IsIntersects,spotFilter.searchFilter.codeBitList];
    }
    //是否显示空闲
    if (spotFilter.searchFilter.hideBusy)
    {
        [where appendFormat:@" AND status='0'"];
    }
    //距离
    if(spotFilter.distance>0&&[spotFilter hadFilterLocation])
    {
        if (spotFilter.filterLocation.type==SpotFilterLocationType_HotCity)
        {
            //热门城市
            //省市代码后4位全部为0即为省（针对直辖市的处理）
            NSString *subStr=[spotFilter.filterLocation.cityCode substringFromIndex:2];
            if (subStr.integerValue>0)
            {
                [where appendFormat:@" AND db_cityCode = '%@'",spotFilter.filterLocation.cityCode];
            }
            else
            {
                [where appendFormat:@" AND db_provinceCode = '%@'",spotFilter.filterLocation.cityCode];
            }
        }
        else if (spotFilter.filterLocation.type==SpotFilterLocationType_Country)
        {
            //全国不做限制
        }
        else
        {
            NSString *distanceTo=[NSString stringWithFormat:@"%@(db_latitude,db_longitude,%@,%@)",kSqliteFunction_GetDistance,@(spotFilter.filterLocation.latitude),@(spotFilter.filterLocation.longitude)];
            [where appendFormat:@" AND %@ <= %@",distanceTo,@(spotFilter.distance)];

        }
    }
    //运营商类型
    if (spotFilter.searchFilter.operateType&&spotFilter.searchFilter.operateType!=defaultFilter.searchFilter.operateType)
    {
        [where appendFormat:@" AND (%@ & operateType) > 0",@(spotFilter.searchFilter.operateType)];
    }
    //运营商名称
    if (!isEmpty(spotFilter.searchFilter.operatorKeys))
    {
        [where appendFormat:@" AND %@('%@',operatorTypes) == 1",kSqliteFunction_IsIntersects,spotFilter.searchFilter.operatorKeys];
    }
    //标签
    if (!isEmpty(spotFilter.searchFilter.tags))
    {
        [where appendFormat:@" AND %@('%@',tags) == 1",kSqliteFunction_IsIntersects,spotFilter.searchFilter.tags];
    }
    return where;
}








@end
