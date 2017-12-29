//
//  BDFunctionConst.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/29.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark-日志打印
//打印--->BDLog
#ifdef DEBUG
#  define BDLog(fmt,...) NSLog((@"%s [Line %d]" fmt),__PRETTY_FUNCTION__,__LINE__,##__VA_ARGS__);
#else
#  define BDLog(...)
#endif

#pragma mark-Assert functions 断言
#define BDAssert(expression,...)\
do { if(!(expression)) {\
BDLog(@"%@",\
[NSString stringWithFormat:@"Assertion failure:%s in %s on line %s:%d. %@",\
#expression, \
__PRETTY_FUNCTION__,\
__FILE__,__LINE__,\
[NSString stringWithFormat:@"" __VA_ARGS__]]);\
abort();}\
} while(0)



//是否为空或是[NSNull null]
#define NotNilAndNull(_ref) (((_ref)!=nil)&&(![(_ref) isEqual:[NSNull null]]))
#define IsNilOrNull(_ref) (((_ref)==nil)||([(_ref) isEqual:[NSNull null]]))
//字符串是否为空
#define IsStrEmpty(_ref) (((_ref)==nil)||([(_ref) isEqual:[NSNull null]])||([(_ref) isEqualToString:@""]))
//数组是否为空
#define IsArrEmpty(_ref) (((_ref)==nil)||([(_ref) isEqual:[NSNull null]])||([(_ref) count]==0))

#pragma mark- Extern and Inline functions 内联、外联函数
//内联
#if !defined(BD_EXTERN)
#   if defined(__cplusplus)
#      define BD_EXTERN extern "C"
#   else
#      define BD_EXTERN extern
#   endif
#endif
//外联
#if !defined(BD_INLINE)
#   if defined(__STDC_VERSION__) && __STDC_VERSION__>=199901L
#      define BD_INLINE static inline
#   elif defined(__cplusplus)
#      define BD_INLINE static inline
#   elif defined(__GNUC__)
#      define BD_INLINE static __inline__
#   else
#      define BD_INLINE static
#   endif
#endif


#pragma mark-Encode Decode 方法
//NSDictionary->NSString
BD_EXTERN NSString *DecodeObjectFromDic(NSDictionary *dic,NSString *key);
//NSArray + index -> id
BD_EXTERN id DecodeSafeObjectAtIndex(NSArray *arr,NSInteger index);
//NSDictionary->NSString
BD_EXTERN NSString *DecodeStringFromDic(NSDictionary *dic,NSString *key);
//NSDictionary->NSString ? NSString:defaultStr
BD_EXTERN NSString *DecodeDefaultStrFromDic(NSDictionary *dic,NSString *key,NSString *defaultStr);


@interface BDFunctionConst : NSObject

@end
