//
//  BDDao.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/14.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>
#import "BDSqliteProperty.h"

//数据库Dao所遵循协议
@protocol BDDaoProtocolDelegate <NSObject>
@required
-(Class)modelClass;
@optional
-(NSString *)tableName;
-(void)buildProperties;

@end

@interface BDDao : NSObject<BDDaoProtocolDelegate>

@property (nonatomic,strong) BDSqlitePropertyList *propertyList;

-(FMDatabaseQueue *)dbQueue;
+(FMDatabaseQueue *)dbQueue;

//数据库基本操作（增删查改）
-(BOOL)deleteFromTable:(NSString *)where;
-(BOOL)deleteFromTableByDict:(NSDictionary *)whereDict;
-(void)batchDeleteFromTable:(NSArray *)wheres;//事务 可回滚

-(BOOL)updateInToTable:(NSDictionary *)fieldAndValues where:(NSString *)where;
//批量插入数据
-(void)batchReplaceToTable:(NSArray *)objects;
-(void)batchReplaceToTable:(NSArray *)objects block:(void(^)(BOOL isSuccess))block;

-(id)modelObjectWithResultDictionary:(NSDictionary *)resultDict;
-(NSArray *)modelsWithSQL:(NSString *)sql eachBlock:(void(^)(id model))eachBlock;
-(NSArray *)models:(NSString *)where order:(NSString *)order limit:(NSString *)limit;
-(NSArray *)models:(NSString *)where order:(NSString *)order limit:(NSString *)limit eachBlock:(void(^)(id model))eachBlock;
-(NSArray *)models:(NSString *)where order:(NSString *)order limit:(NSString *)limit groupBy:(NSString *)groupBy eachBlock:(void(^)(id model))eachBlock;
//自定义Fields value such as count(*),avg(lat)...
-(NSInteger)rowCount:(NSString *)where;
-(NSArray *)excuteSql:(NSString *)sql;
-(NSArray *)excuteSql:(NSString *)sql eachBlock:(void(^)(id each))eachBlock;

-(void)clearTable;
-(void)dropTable:(BOOL)ifExists;
-(void)dropTableWithName:(NSString *)tableName ifExists:(BOOL)ifExists;
//创建Table
-(void)createTable:(BOOL)ifNotExists;
//更新Table字段（新增） 需要在设置好PropertyList后调用
-(void)updateColumns;



@end
