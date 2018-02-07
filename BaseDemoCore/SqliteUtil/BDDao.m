//
//  BDDao.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/14.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDDao.h"
#import "NSDictionary+BD.h"
#import "NSObject+AppInfo.h"
#define BD_PATH_OF_DOCUMENT [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]


@implementation BDDao

-(FMDatabaseQueue *)dbQueue
{
    return [[self class] dbQueue];
}
+(FMDatabaseQueue *)dbQueue
{
    static FMDatabaseQueue *dbQueue=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //站点信息文件路径
        NSString *dbPath=[BD_PATH_OF_DOCUMENT stringByAppendingPathComponent:@"bdSpot.sqlite"];
        NSLog(@"%@",dbPath);
        dbQueue=[FMDatabaseQueue databaseQueueWithPath:dbPath];
        [dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
           
            db.logsErrors=YES;
        }];
    });
    return dbQueue;
}

-(id)init
{
    if (self=[super init])
    {
        self.propertyList=[[BDSqlitePropertyList alloc]init];
    }
    return self;
}

#pragma mark-Delegate协议
-(Class)modelClass
{
#if DEBUG
    //需要override
    NSLog(@"FMDB SQLite Please Override Me");
    abort();
#endif
    
    return [NSObject class];
}
-(NSString *)tableName
{
    return NSStringFromClass([self class]);
}

#pragma mark-Method
-(BOOL)deleteFromTable:(NSString *)where
{
    if (!where.length)
    {
        NSLog(@"ERROR: whert is Empty Dangous!!!!");
        return NO;
    }
    NSMutableString *sql=[NSMutableString stringWithFormat:@"DELETE FROM %@",self.tableName];
    if (where)
    {
        [sql appendFormat:@" WHERT %@",where];
    }
    __block BOOL result=NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
       
        result=[db executeUpdate:sql];
    }];
    
    if (!result)
    {
        NSLog(@"ERROR: Failed To Delete,sql:(%@)",sql);
    }
    return result;
}
-(BOOL)deleteFromTableByDict:(NSDictionary *)whereDict
{
    @autoreleasepool{
        
        if (!whereDict.count)
        {
            NSLog(@"ERROR: whereDict is Empty,Dangous!!!!");
            return NO;
        }
        NSMutableString *where=[NSMutableString string];
        NSArray *allKeys=[whereDict allKeys];
        for (NSString *key in allKeys)
        {
            [where appendFormat:@"%@='%@' AND ",key,[whereDict objectForKey:key]];
        }
        [where appendFormat:@"1=1"];
        return [self deleteFromTable:where];
    }
}
-(void)batchDeleteFromTable:(NSArray *)wheres
{
    @autoreleasepool{
        
        if (!wheres.count)
        {
            return;
        }
        [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
           
            for (NSString *where in wheres)
            {
                if (!where.length)
                {
                    NSLog(@"ERROR: where is Empty,Dangous!!!!");
                    continue;
                }
                NSMutableString *sql=[NSMutableString stringWithFormat:@"DELETE FROM %@",self.tableName];
                if (where)
                {
                    [sql appendFormat:@" WHERE %@",where];
                }
                BOOL result=[db executeUpdate:sql];
                if (!result)
                {
                    NSLog(@"ERROR: Failed to BatchDelete Execute %@",sql);
                }
            }
            *rollback=NO;
            
        }];
        
        
    }
}

-(BOOL)updateInToTable:(NSDictionary *)fieldAndValues where:(NSString *)where
{
    @autoreleasepool{
        
        if(!where)
        {
            NSLog(@"ERROR: where is Empty,Dangous!!!!");
            return NO;
        }
        NSMutableString *sql=[NSMutableString stringWithFormat:@"UPDATE %@ SET",self.tableName];
        NSMutableString *updateKeys=[NSMutableString string];
        NSMutableArray *updateValues=[NSMutableArray array];
        NSArray *allKeys=[fieldAndValues allKeys];
        NSInteger keyCount=allKeys.count; //
        NSInteger count=self.propertyList.count; //属性总个数
        for (NSInteger i=0; i<count; i++)
        {
            //依次检索表字段
            BDSqliteProperty *property=(BDSqliteProperty *)[self.propertyList objectInModelsAtIndex:i];
            if ([allKeys containsObject:property.modelFieldName])
            {
                //Dic中存在相对应的字段
                [updateValues addObject:[fieldAndValues objectForKey:property.modelFieldName]];
                //拼接所对应字段的sql语句
                [updateKeys appendFormat:@"%@=?%@",property.dbFieldName,(keyCount==updateValues.count)?@"":@","];
            }
            //已检索完所需修改字段
            if (keyCount<=updateValues.count)
            {
                break;
            }
        }
        [sql appendFormat:@" %@ WHERE %@;",updateKeys,where];
        __block BOOL result=NO;
        [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
           
            result=[db executeUpdate:sql withArgumentsInArray:updateValues];
        }];
        if (!result)
        {
            NSLog(@"ERROR:Failed To Update Table %@",self.tableName);
        }
        return result;
    }
}
-(void)batchReplaceToTable:(NSArray *)objects
{
    [self batchReplaceToTable:objects block:nil];
}
-(void)batchReplaceToTable:(NSArray *)objects block:(void(^)(BOOL isSuccess))block
{
    @autoreleasepool{
        if (objects.count<=0)
        {
            NSLog(@"ERROR:Objects Is Empty And Objects count==0!!!!");
            return;
        }
        NSMutableArray *sqls=[NSMutableArray array];
        NSMutableArray *values=[NSMutableArray array];
        for (NSDictionary *dict in objects)
        {
            NSMutableString *sql=[NSMutableString stringWithFormat:@"REPLACE INTO %@",self.tableName];
            NSMutableString *fileds=[NSMutableString stringWithFormat:@"("];
            NSMutableString *questions=[NSMutableString stringWithFormat:@"("];
            NSMutableArray *fieldsValue=[NSMutableArray array]; //用于保存表字段所对应的value值
            NSInteger count=self.propertyList.count;
            for (NSInteger i=0; i<count; i++)
            {
                BDSqliteProperty *property=(BDSqliteProperty *)[self.propertyList objectInModelsAtIndex:i];
                if (i==count-1)
                {
                    //最后一个
                    [fileds appendFormat:@"'%@')",property.dbFieldName];
                    [questions appendFormat:@"?);"];
                }
                else
                {
                    [fileds appendFormat:@"'%@',",property.dbFieldName];
                    [questions appendFormat:@"?,"];
                }
                id fieldValue=nil;
                if (property.isServerFieldArray)
                {
                    fieldValue=[dict bd_objectForKeyArray:property.serverFieldName withDefault:@""];
                }
                else
                {
                    fieldValue=[dict objectForKey:property.serverFieldName];
                }
                //服务器字段所对应的不存在 则置默认值
                if ([fieldValue isKindOfClass:[NSNull class]]||fieldValue==nil)
                {
                    if (property.modelDataType==kModelDataTypeString||property.modelDataType==kModelDataTypeObject)
                    {
                        [fieldsValue addObject:@""];
                    }
                    else
                    {
                        [fieldsValue addObject:@(0)];
                    }
                }
                else
                {
                    switch (property.modelDataType) {
                        case kModelDataTypeObject:
                        {
                            NSString *jsonString=[fieldValue mj_JSONString];
                            if (!jsonString)
                            {
                                jsonString=@"";
                            }
                            [fieldsValue addObject:jsonString];
                        }
                            break;
                        case kModelDataTypeBool:
                            [fieldsValue addObject:@([fieldValue boolValue])];
                            break;
                        case kModelDataTypeDouble:
                            [fieldsValue addObject:@([fieldValue doubleValue])];
                            break;
                        case kModelDataTypeFloat:
                            [fieldsValue addObject:@([fieldValue floatValue])];
                            break;
                        case kModelDataTypeInterger:
                            [fieldsValue addObject:@([fieldValue integerValue])];
                            break;
                        case kModelDataTypeLong:
                            [fieldsValue addObject:@([fieldValue longLongValue])];
                            break;
                        case kModelDataTypeString:
                            [fieldsValue addObject:fieldValue];
                            break;
                            
                        default:
                            break;
                    }
                }
            }
            [sql appendFormat:@" %@ values %@",fileds,questions];
            [sqls addObject:sql];
            [values addObject:fieldsValue];
        }
        
        __block BOOL success=YES;
        [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
            
            NSInteger count=sqls.count;
            for (NSInteger i=0; i<count; i++)
            {
                NSString *sql=[sqls objectAtIndex:i];
                NSArray *value=[values objectAtIndex:i];
                /*
                 REPLACE INTO SpotDao370 ('spotId','phone','name','quantity','serviceCode','curDistance','destDistance','owner_Json','priceRational','mapIcon','status','link','spotType','currentType','propertyType','score','codeBitList','operatorTypes','operateType','tags','supportChargingType','latitude','longitude','address','cityCode','db_latitude','db_longitude','db_address','db_cityCode','db_provinceCode') values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);
                 */
                BOOL result=[db executeUpdate:sql withArgumentsInArray:value];
                if (!result)
                {
                    NSLog(@"ERROR:Failed To BatchReplace Execute %@",sql);
                    success=NO;
                }
            }
            *rollback=NO;
            
        }];
        if (block)
        {
            block(success);
        }
    }
}

-(id)modelObjectWithResultDictionary:(NSDictionary *)resultDict
{
    Class modelClass=[self modelClass];
    id model=[[modelClass alloc]init];
    for (BDSqliteProperty *property in self.propertyList.models)
    {
        //表字段所对应的模型属性不存在
        if (isEmpty(property.modelFieldName))
        {
            continue;
        }
        switch (property.modelDataType) {
            case kModelDataTypeObject:
                {
                    NSString *objectStr=[resultDict bd_StringObjectForKey:property.dbFieldName];
                    id jsonObject=[objectStr mj_JSONObject];
                    if ([jsonObject isKindOfClass:[NSDictionary class]])
                    {
                        id jsonModel=[[property.modelClass alloc]initWithAttributes:jsonObject];
                        [model setValue:jsonModel forKey:property.modelFieldName];
                    }
                    else if ([jsonObject isKindOfClass:[NSArray class]])
                    {
#pragma mark------代开发
                        NSArray *models=nil;
                        if (models)
                        {
                            [model setValue:models forKey:property.modelFieldName];
                        }
                    }
                    else
                    {
                        //TODO 时间占用比较多5秒左右
                    }
                }
                break;
            case kModelDataTypeString:
            {
                [model setValue:[resultDict bd_StringObjectForKey:property.dbFieldName]?:@"" forKey:property.modelFieldName];
            }
                break;
            case kModelDataTypeBool:
            {
                [model setValue:@([resultDict bd_BoolForKey:property.dbFieldName]) forKey:property.modelFieldName];
            }
                break;
            case kModelDataTypeDouble:
            {
                [model setValue:@([resultDict bd_DoubleForKey:property.dbFieldName]) forKey:property.modelFieldName];
            }
                break;
            case kModelDataTypeFloat:
            {
                [model setValue:@([resultDict bd_DoubleForKey:property.dbFieldName]) forKey:property.modelFieldName];
            }
                break;
            case kModelDataTypeInterger:
            {
                [model setValue:@([resultDict bd_IntergerForKey:property.dbFieldName]) forKey:property.modelFieldName];
            }
                break;
            case kModelDataTypeLong:
            {
                [model setValue:@([resultDict bd_IntergerForKey:property.dbFieldName]) forKey:property.modelFieldName];
            }
                break;
            default:
                break;
        }
    }
    return model;
}
-(NSArray *)modelsWithSQL:(NSString *)sql eachBlock:(void(^)(id model))eachBlock
{
    __unused NSTimeInterval start=[NSDate date].timeIntervalSince1970;
    __block NSMutableArray *result=[NSMutableArray array];
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
       
        @autoreleasepool{
            
            FMResultSet *rs=[db executeQuery:sql];
            Class modelClass=[self modelClass];
            while ([rs next])
            {
                id model=[[modelClass alloc]init];
                for (BDSqliteProperty *property in self.propertyList.models)
                {
                    if (isEmpty(property.modelFieldName))
                    {
                        continue;
                    }
                    if ([property.dbFieldName isEqualToString:@"curDistance"])
                    {
                        NSString *str=[rs stringForColumn:property.dbFieldName];
                        NSLog(@"%@",str);
                    }
                    
                    
                    switch (property.modelDataType) {
                        case kModelDataTypeObject:
                        {
                            NSString *objectStr=[rs stringForColumn:property.dbFieldName];
                            id jsonObject=[objectStr mj_JSONObject];
                            if ([jsonObject isKindOfClass:[NSDictionary class]])
                            {
                                id jsonModel=[[property.modelClass alloc]initWithAttributes:jsonObject];
                                [model setValue:jsonModel forKey:property.modelFieldName];
                            }
                            else if ([jsonObject isKindOfClass:[NSArray class]])
                            {
#pragma mark------代开发
                                NSArray *models=nil;
                                if (models)
                                {
                                    [model setValue:models forKey:property.modelFieldName];
                                }
                            }
                            else
                            {
                                //TODO 时间占用比较多5秒左右
                            }
                        }
                            break;
                        case kModelDataTypeString:
                        {
                            [model setValue:[rs stringForColumn:property.dbFieldName]?:@"" forKey:property.modelFieldName];
                        }
                            break;
                        case kModelDataTypeBool:
                        {
                            [model setValue:@([rs boolForColumn:property.dbFieldName]) forKey:property.modelFieldName];
                        }
                            break;
                        case kModelDataTypeDouble:
                        {
                            [model setValue:@([rs doubleForColumn:property.dbFieldName]) forKey:property.modelFieldName];
                        }
                            break;
                        case kModelDataTypeFloat:
                        {
                            [model setValue:@([rs doubleForColumn:property.dbFieldName]) forKey:property.modelFieldName];
                        }
                            break;
                        case kModelDataTypeInterger:
                        {
                            [model setValue:@([rs intForColumn:property.dbFieldName]) forKey:property.modelFieldName];
                        }
                            break;
                        case kModelDataTypeLong:
                        {
                            [model setValue:@([rs longForColumn:property.dbFieldName]) forKey:property.modelFieldName];
                        }
                            break;
                        default:
                            break;
                    }
                }
                [result addObject:model];
                if (eachBlock)
                {
                    eachBlock(model);
                }
            }
            [rs close];
        }
        
    }];
    
    //block释放
    {
        eachBlock=nil;
    }
    
    __unused NSTimeInterval end=[[NSDate date] timeIntervalSince1970];
    
    return result;
}
-(NSArray *)models:(NSString *)where order:(NSString *)order limit:(NSString *)limit
{
    return [self models:where order:order limit:limit eachBlock:nil];
}
-(NSArray *)models:(NSString *)where order:(NSString *)order limit:(NSString *)limit eachBlock:(void(^)(id model))eachBlock
{
    return [self models:where order:order limit:limit groupBy:nil eachBlock:eachBlock];
}
-(NSArray *)models:(NSString *)where order:(NSString *)order limit:(NSString *)limit groupBy:(NSString *)groupBy eachBlock:(void(^)(id model))eachBlock
{
    NSMutableString *sql=[NSMutableString stringWithFormat:@"SELECT rowid, * FROM %@",self.tableName];
    if (where)
    {
        [sql appendFormat:@" WHERE %@",where];
    }
    if (order)
    {
        [sql appendFormat:@" ORDER BY %@",order];
    }
    if (groupBy)
    {
        [sql appendFormat:@" GROUP BY %@",groupBy];
    }
    if (limit)
    {
        [sql appendFormat:@" %@",limit];
    }
    [sql appendFormat:@";"];
    return [self modelsWithSQL:sql eachBlock:eachBlock];
}


-(NSInteger)rowCount:(NSString *)where
{
    NSMutableString *sql=[NSMutableString stringWithFormat:@"SELECT count(rowid) AS dbCount FROM %@",self.tableName];
    if (where)
    {
        [sql appendFormat:@" WHERE %@",where];
    }
    __block NSInteger result=0;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
        FMResultSet *rs=[db executeQuery:sql];
        if ([rs columnCount]>0&&[rs next])
        {
            result=[[rs stringForColumn:@"dbCount"] integerValue];
        }
        [rs close];
    }];
    return result;
}
-(NSArray *)excuteSql:(NSString *)sql
{
    return [self excuteSql:sql eachBlock:nil];
}
-(NSArray *)excuteSql:(NSString *)sql eachBlock:(void(^)(id each))eachBlock
{
    if (!sql.length)
    {
        NSLog(@"ERROR: SQL is Empty Dangous %@",sql);
        eachBlock=nil;
        return @[];
    }
    __block NSMutableArray *columnValues=[NSMutableArray array];
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
        FMResultSet *rs=[db executeQuery:sql];
        while ([rs next])
        {
            if (rs.resultDictionary.count)
            {
                [columnValues addObject:rs.resultDictionary];
                if (eachBlock)
                {
                    eachBlock(rs.resultDictionary);
                }
            }
        }
        [rs close];
    }];
    
    {
        eachBlock=nil;
    }
    return columnValues;
}

-(void)clearTable
{
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
       
        if ([db tableExists:self.tableName])
        {
            NSString *sql=[NSString stringWithFormat:@"DELETE FROM %@;",self.tableName];
            [db executeUpdate:sql];
            [db executeUpdate:@"VACUUM;"];
        }
        
    }];
}
-(void)dropTable:(BOOL)ifExists
{
    [self dropTableWithName:self.tableName ifExists:ifExists];
}
-(void)dropTableWithName:(NSString *)tableName ifExists:(BOOL)ifExists
{
    if (!tableName.length)
    {
        return;
    }
    NSString *sql=[NSString stringWithFormat:@"DROP TABLE %@ %@",ifExists?@"IF EXISTS":@"",tableName];
    __block BOOL result=NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
       
        result=[db executeUpdate:sql];
    }];
    if (!result)
    {
        NSLog(@"ERROR: Failed To DROP Table:%@",tableName);
    }
}
-(void)createTable:(BOOL)ifNotExists
{
    NSString *constraint=ifNotExists?@"IF NOT EXISTS ":@"";
    NSMutableString *sql=[NSMutableString stringWithFormat:@"CREATE TABLE %@ '%@' (",constraint,self.tableName];
    NSInteger count=self.propertyList.count;
    if (count==0)
    {
        NSLog(@"ERROR Failed To Create Table %@,PropertyList Is Empty",self.tableName);
        return;
    }
    for (NSInteger i=0; i<count; i++)
    {
        BDSqliteProperty *property=(BDSqliteProperty *)[self.propertyList objectInModelsAtIndex:i];
        if (property.sqlitePrimaryKey)
        {
            if (i==count-1)
            {
                [sql appendFormat:@"'%@' %@ PRIMARY KEY NOT NULL);",property.dbFieldName,property.sqliteType];
            }
            else
            {
                [sql appendFormat:@"'%@' %@ PRIMARY KEY NOT NULL,",property.dbFieldName,property.sqliteType];
            }
        }
        else
        {
            if (i==count-1)
            {
                [sql appendFormat:@"'%@' %@);",property.dbFieldName,property.sqliteType];
            }
            else
            {
                [sql appendFormat:@"'%@' %@,",property.dbFieldName,property.sqliteType];
            }
        }
    }
    
    __block BOOL result=NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
       
        result=[db executeUpdate:sql];
    }];
    if(!result)
    {
        NSLog(@"ERROR:Failed To Create Table:%@",self.tableName);
    }
}

#pragma mark-更新表字段
-(void)updateColumns
{
    //需要确保每个版本仅更新一次表结构
    NSString *key=[NSString stringWithFormat:@"kVersionForUpdate_%@",self.tableName];
    NSString *version=[NSObject ai_version];//app版本
    NSString *tableVersion=[[NSUserDefaults standardUserDefaults] stringForKey:key]; //数据库表版本
    if ([tableVersion isEqualToString:version])
    {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //检查表中是否含有属性列表中的所有字段 将新增字段加入表中
    WEAKSELF_DEFINE
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
       STRONGSELF_DEFINE
        if (![db tableExists:strongSelf.tableName])
        {
            return ;
        }
        NSString *sql=nil;
        for (BDSqliteProperty *property in strongSelf.propertyList.models)
        {
            if (![db columnExists:property.dbFieldName inTableWithName:strongSelf.tableName])
            {
                sql=[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@",strongSelf.tableName,property.dbFieldName,property.sqliteType];
                [db executeUpdate:sql];
            }
        }
        
    }];
}




















@end
