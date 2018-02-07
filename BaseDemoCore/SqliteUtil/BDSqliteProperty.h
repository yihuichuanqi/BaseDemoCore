//
//  BDSqliteProperty.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/14.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*Sqlite 建模属性*/

#import "BDModel.h"
#import "BDModelList.h"

typedef NS_ENUM(NSInteger,kModelDataType) {
    kModelDataTypeObject=0,
    kModelDataTypeBool=1,
    kModelDataTypeInterger=2,
    kModelDataTypeFloat=3,
    kModelDataTypeDouble=4,
    kModelDataTypeLong=5,
    kModelDataTypeString=6,
};

@interface BDSqliteProperty : BDModel

@property (nonatomic,copy) NSString *dbFieldName; //数据库字段名
@property (nonatomic,copy) NSString *modelFieldName; //模型字段名
@property (nonatomic,copy) id serverFieldName; //服务器字段名

@property (nonatomic,copy) Class modelClass;
@property (nonatomic,assign) BOOL isPrimaryKey; //是否主键
@property (nonatomic,assign) BOOL isServerFieldArray; //是否多值
@property (nonatomic,assign) kModelDataType modelDataType; //字段类型


-(BOOL)sqlitePrimaryKey;
-(NSString *)sqliteType;//字段类型相对应的数据库描述

//构造属性
+(BDSqliteProperty *)property:(NSString *)dbFieldName serverFieldName:(NSString *)serverFieldName modelDataType:(kModelDataType)modelDataType;
+(BDSqliteProperty *)property:(NSString *)dbFieldName serverFieldName:(NSString *)serverFieldName modelFieldName:(NSString *)modelFieldName modelDataType:(kModelDataType)modelDataType;
+(BDSqliteProperty *)property:(NSString *)dbFieldName serverFieldName:(NSString *)serverFieldName modelFieldName:(NSString *)modelFieldName modelClass:(__unsafe_unretained Class)modelClass modelDataType:(kModelDataType)modelDataType;
+(BDSqliteProperty *)property:(NSString *)dbFieldName serverFieldName:(NSString *)serverFieldName modelFieldName:(NSString *)modelFieldName isPrimaryKey:(BOOL)isPrimaryKey modelClass:(__unsafe_unretained Class)modelClass modelDataType:(kModelDataType)modelDataType;


@end

@interface BDSqlitePropertyList : BDModelList

-(void)addModel:(BDModel *)model;
-(void)addFieldName:(NSString *)dbFieldName serverFieldName:(NSString *)serverFieldName modelDataType:(kModelDataType)modelDataType;
-(void)addFieldName:(NSString *)dbFieldName serverFieldName:(NSString *)serverFieldName isPrimaryKey:(BOOL)isPrimaryKey modelDataType:(kModelDataType)modelDataType;

-(void)addFieldName:(NSString *)dbFieldName serverFieldName:(NSString *)serverFieldName modelFieldName:(NSString *)modelFieldName modelDataType:(kModelDataType)modelDataType;
-(void)addFieldName:(NSString *)dbFieldName serverFieldName:(NSString *)serverFieldName modelFieldName:(NSString *)modelFieldName modelClass:(__unsafe_unretained Class)modelClass modelDataType:(kModelDataType)modelDataType;

@end








