//
//  NSString+BD.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/25.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*通用功能扩展*/

#import <Foundation/Foundation.h>

@interface NSString (BD)

@property (nonatomic,copy,readonly) NSString *bd_MD5;
-(int)bd_wordsCount;

//比较两个以某分隔符隔开的字符串元素 是否包含相同元素
-(BOOL)bd_intersectsElementString:(NSString *)otherString btSeparator:(NSString *)separator;
-(BOOL)bd_isEqualToElementString:(NSString *)otherString btSeparator:(NSString *)separator;
-(BOOL)bd_isSubOfElementString:(NSString *)otherString btSeparator:(NSString *)separator;




@end
