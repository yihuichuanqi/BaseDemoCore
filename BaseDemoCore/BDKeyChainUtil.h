//
//  BDKeyChainUtil.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/20.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BDKeyChainUtilDelegate<NSObject>

-(void)removeKeyChainStringForKey:(NSString *)key;
-(NSString *)keyChainStringForKey:(NSString *)key;
-(void)setKeyChainStringForKey:(NSString *)key value:(NSString *)value;

@end

@interface BDKeyChainUtil : NSObject <BDKeyChainUtilDelegate>

@end


@interface BDDictionaryBackedKeyChain : NSObject<BDKeyChainUtilDelegate>

@property (nonatomic,strong) NSMutableDictionary *dict;
@end






