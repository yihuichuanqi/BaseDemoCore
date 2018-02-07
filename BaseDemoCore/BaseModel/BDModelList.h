//
//  BDModelList.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/14.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDModel.h"

@interface BDModelList : BDModel

@property (nonatomic,strong) NSMutableArray *models;

-(id)initWithArray:(NSArray *)aArray;
//子类override
-(id)initWithDict:(NSDictionary *)aDict;
-(NSMutableArray *)modelWithArray:(NSArray *)aArray;

-(BDModel *)objectInModelsAtIndex:(NSUInteger)index;
-(NSInteger)count;

@end

//列表数据分页获取 专用
@interface Pager: BDModel<NSCopying>

@property (nonatomic,assign) NSInteger limit;
@property (nonatomic,assign) NSInteger page;
@property (nonatomic,assign) NSInteger total;
@property (nonatomic,assign) NSInteger totalPages;

-(BOOL)hasMore;


@end

