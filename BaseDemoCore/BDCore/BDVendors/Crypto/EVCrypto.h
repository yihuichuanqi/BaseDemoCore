//
//  EVCrypto.h
//  EVCrypto
//
//  Created by sam on 15/1/20.
//  Copyright (c) 2015年 sam. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface EVCrypto : NSObject

// just XXTEA
/**
 *  @author
 *
 *  默认密码是：key
 *
 *  @param ciphertext 密文
 *  @param length     密文长度
 *
 *  @return unsigned char 返回明文内容
 */
+ (unsigned char *)decryptBytesXXTEA:(char *)ciphertext length:(int)length;
/**
 *  @author
 *
 *  默认密码是：key
 *
 *  @param ciphertext 密文
 *  @param length     密文长度
 *  @param retLen     返回明文长度
 *
 *  @return unsigned char 返回明文内容
 */
+ (unsigned char *)decryptBytesXXTEA:(char *)ciphertext length:(int) length retLen:(int *)retLen;
/**
 *  @author
 *
 *  默认密码是：key
 *
 *  @param plainText 明文
 *  @param length    明文长度
 *  @param retLen    加密后，密文长度，一定要用这个长度，因为字符串中可能有\0结束符
 *
 *  @return unsigned char 返回密文内容
 */
+ (unsigned char *)encryptBytesXXTEA:(char *)plainText length:(int)length retLen:(int *)retLen;
// 传入password
/**
 *  @author
 *
 *  密码由外部指定
 *
 *  @param ciphertext 密文
 *  @param password   密码
 *  @param length     密文长度
 *  @param retLen     明文长度
 *
 *  @return unsigned char 明文内容
 */
+ (unsigned char *)decryptBytesXXTEA:(char *)ciphertext password:(char *)password length:(int)length retLen:(int *)retLen;
/**
 *  @author
 *
 *  密码由外部指定
 *
 *  @param plainText 明文
 *  @param password  密码
 *  @param length    明文长度
 *  @param retLen    密文长度
 *
 *  @return unsigned char 密文内容
 */
+ (unsigned char *)encryptBytesXXTEA:(char *)plainText password:(char *)password length:(int)length retLen:(int *)retLen;

// Base 64
/**
 *  @author
 *
 *  xxtea后base64字符串解密
 *
 *  @param ciphertext 密文
 *
 *  @return 返回明文，直接是对应字符串
 */
+ (NSString *)decryptXXTEAWithString:(NSString *)ciphertext;
+ (NSString *)decryptXXTEAWithString:(NSString *)ciphertext password:(char *)password;
/**
 *  @author
 *
 *  加密成xxtea后Base64的字符串
 *
 *  @param plainText 明文
 *
 *  @return 返回密文，xxtea后再Base64
 */
+ (NSString *)encryptXXTEAWithString:(NSString *)plainText;
+ (NSString *)encryptXXTEAWithString:(NSString *)plainText password:(char *)password;
/**
 *  @author
 *
 *  xxtea后base64字符串解密
 *
 *  @param ciphertext 密文
 *  @param length     密文长度
 *
 *  @return 返回明文，直接是字符串
 */
+ (NSString *)decryptXXTEA:(char *)ciphertext length:(int)length;
+ (NSString *)decryptXXTEA:(char *)ciphertext password:(char *)password length:(int)length;
/**
 *  @author
 *
 *  明文经过xxtea后base64的加密
 *
 *  @param plainText 明文
 *  @param length    明文长度
 *
 *  @return 返回密文，base64的字符串
 */
+ (NSString *)encryptXXTEA:(unsigned char *)plainText length:(int)length;
+ (NSString *)encryptXXTEA:(unsigned char *)plainText password:(char *)password length:(int)length;

@end
