//
//  BDHandlePackage.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/17.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*Socket 站点数据包信息*/

#import <Foundation/Foundation.h>
#import "BDDao.h"

@interface BDHandlePackage : NSObject

@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) NSString *msgId;
@property (nonatomic,copy) NSString *key;
@property (nonatomic,copy) NSString *urlRoot;
@property (nonatomic,copy) NSString *packages; //分包
@property (nonatomic,assign) NSInteger cmd;

@property (nonatomic,strong) NSDictionary *bodyDict;
@property (nonatomic,assign) BOOL isFirst;
@property (nonatomic,assign) BOOL isSpotPackage;//是否本地构建站点包

@property (nonatomic,assign) NSInteger updateTime;
@property (nonatomic,assign) NSInteger handleFaildTime;//记录解压缩失败时间 失败后间隔5分钟才会重新下载
@property (nonatomic,assign) NSInteger packageOrderBy; //同一条充电点下载的推送消息里的包下载顺序


-(id)initWithDict:(NSDictionary *)dict withMsgId:(NSString *)msgId;
-(id)initWithDict:(NSDictionary *)dict withMsgId:(NSString *)msgId cmd:(NSInteger)cmd;
-(BOOL)hasUrl;
-(BOOL)isEqualToPackage:(BDHandlePackage *)package;

-(NSInteger)subCmd;
-(BOOL)isMulPackages; //是否多包
-(BOOL)isFirstOrSpotPackage;

//包解压路径
-(NSString *)zipCachePath;
-(NSString *)unZipCachePath;

+(BDHandlePackage *)package:(NSString *)url;
+(BDHandlePackage *)package:(NSDictionary *)dict msgId:(NSString *)msgId;
+(BDHandlePackage *)package:(NSDictionary *)dict msgId:(NSString *)msgId cmd:(NSInteger)cmd;


@end


/*用于socket包本地存储及操作*/
@interface BDHandlePackageDao : BDDao

-(NSInteger)countWithUrl:(NSString *)url;
-(NSArray *)getAllPackagesWithEachBlock:(void(^)(id model))eachBlock;
-(NSArray *)getFirstPackages;
-(void)replaceWithPackage:(BDHandlePackage *)package handleFailTime:(NSInteger)handleFailTime;
-(BOOL)deletePackageWithUrl:(NSString *)url;
@end






