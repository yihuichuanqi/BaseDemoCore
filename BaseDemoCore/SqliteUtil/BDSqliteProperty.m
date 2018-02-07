//
//  BDSqliteProperty.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/14.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDSqliteProperty.h"

@implementation BDSqliteProperty

-(BOOL)sqlitePrimaryKey
{
    return self.isPrimaryKey;
}
-(NSString *)sqliteType
{
    NSString *sqliteType=@"TEXT";
    switch (self.modelDataType) {
        case kModelDataTypeBool:
        case kModelDataTypeInterger:
            sqliteType=@"INTEGER";
            break;
        case kModelDataTypeFloat:
        case kModelDataTypeDouble:
        case kModelDataTypeLong:
            sqliteType=@"REAL";
            break;
        case kModelDataTypeString:
        case kModelDataTypeObject:
            sqliteType=@"TEXT";
            break;
            
        default:
            sqliteType=@"TEXT";
            break;
    }
    return sqliteType;
}

+(BDSqliteProperty *)property:(NSString *)dbFieldName serverFieldName:(NSString *)serverFieldName modelDataType:(kModelDataType)modelDataType
{
    return [BDSqliteProperty property:dbFieldName serverFieldName:serverFieldName modelFieldName:dbFieldName modelDataType:modelDataType];
}
+(BDSqliteProperty *)property:(NSString *)dbFieldName serverFieldName:(NSString *)serverFieldName modelFieldName:(NSString *)modelFieldName modelDataType:(kModelDataType)modelDataType
{
    return [BDSqliteProperty property:dbFieldName serverFieldName:serverFieldName modelFieldName:modelFieldName modelClass:nil modelDataType:modelDataType];
}
+(BDSqliteProperty *)property:(NSString *)dbFieldName serverFieldName:(NSString *)serverFieldName modelFieldName:(NSString *)modelFieldName modelClass:(__unsafe_unretained Class)modelClass modelDataType:(kModelDataType)modelDataType
{
    return [BDSqliteProperty property:dbFieldName serverFieldName:serverFieldName modelFieldName:modelFieldName isPrimaryKey:NO modelClass:modelClass modelDataType:modelDataType];
}
+(BDSqliteProperty *)property:(NSString *)dbFieldName serverFieldName:(NSString *)serverFieldName modelFieldName:(NSString *)modelFieldName isPrimaryKey:(BOOL)isPrimaryKey modelClass:(__unsafe_unretained Class)modelClass modelDataType:(kModelDataType)modelDataType
{
    BDSqliteProperty *property=[[BDSqliteProperty alloc]init];
    property.dbFieldName=dbFieldName;
    if ([serverFieldName containsString:@","])
    {
        property.isServerFieldArray=YES;
        property.serverFieldName=[serverFieldName componentsSeparatedByString:@","];
    }
    else
    {
        property.isServerFieldArray=NO;
        property.serverFieldName=serverFieldName;
    }
    property.modelClass=modelClass;
    property.modelFieldName=modelFieldName;
    property.modelDataType=modelDataType;
    property.isPrimaryKey=isPrimaryKey;
    return property;
}


@end

@implementation BDSqlitePropertyList

-(void)addModel:(BDModel *)model
{
    if (!self.models)
    {
        self.models=[NSMutableArray array];
    }
    [self.models addObject:model];
}

-(void)addFieldName:(NSString *)dbFieldName serverFieldName:(NSString *)serverFieldName modelDataType:(kModelDataType)modelDataType
{
    [self addFieldName:dbFieldName serverFieldName:serverFieldName modelFieldName:dbFieldName modelDataType:modelDataType];
}
-(void)addFieldName:(NSString *)dbFieldName serverFieldName:(NSString *)serverFieldName isPrimaryKey:(BOOL)isPrimaryKey modelDataType:(kModelDataType)modelDataType
{
    BDSqliteProperty *property=[BDSqliteProperty property:dbFieldName serverFieldName:serverFieldName modelFieldName:dbFieldName isPrimaryKey:isPrimaryKey modelClass:nil modelDataType:modelDataType];
    [self addModel:property];
}

-(void)addFieldName:(NSString *)dbFieldName serverFieldName:(NSString *)serverFieldName modelFieldName:(NSString *)modelFieldName modelDataType:(kModelDataType)modelDataType
{
    [self addFieldName:dbFieldName serverFieldName:serverFieldName modelFieldName:modelFieldName modelClass:nil modelDataType:modelDataType];
}
-(void)addFieldName:(NSString *)dbFieldName serverFieldName:(NSString *)serverFieldName modelFieldName:(NSString *)modelFieldName modelClass:(__unsafe_unretained Class)modelClass modelDataType:(kModelDataType)modelDataType
{
    BDSqliteProperty *property=[BDSqliteProperty property:dbFieldName serverFieldName:serverFieldName modelFieldName:modelFieldName modelClass:modelClass modelDataType:modelDataType];
    [self addModel:property];

}






@end











