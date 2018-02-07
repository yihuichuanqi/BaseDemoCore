//
//  NSString+BD.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/25.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "NSString+BD.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (BD)


-(NSString *)bd_MD5
{
    // Create pointer to the string as UTF8
    const char *ptr=[self UTF8String];
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    // Create 16 bytes MD5 hash value, store in buffer
    CC_MD5(ptr, (int)strlen(ptr), md5Buffer);
    // Convert unsigned char buffer to NSString of hex values
    NSMutableString *output=[NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x",md5Buffer[i]];
    }
    return output;
}


-(BOOL)bd_intersectsElementString:(NSString *)otherString btSeparator:(NSString *)separator
{
    NSSet *selfSet=[NSSet setWithArray:[self componentsSeparatedByString:separator]];
    NSSet *otherSet=[NSSet setWithArray:[otherString componentsSeparatedByString:separator]];
    return [selfSet intersectsSet:otherSet];
}
-(BOOL)bd_isEqualToElementString:(NSString *)otherString btSeparator:(NSString *)separator
{
    NSSet *selfSet=[NSSet setWithArray:[self componentsSeparatedByString:separator]];
    NSSet *otherSet=[NSSet setWithArray:[otherString componentsSeparatedByString:separator]];
    return [selfSet isEqualToSet:otherSet];

}
-(BOOL)bd_isSubOfElementString:(NSString *)otherString btSeparator:(NSString *)separator
{
    NSSet *selfSet=[NSSet setWithArray:[self componentsSeparatedByString:separator]];
    NSSet *otherSet=[NSSet setWithArray:[otherString componentsSeparatedByString:separator]];
    return [selfSet isSubsetOfSet:otherSet];

}




@end
