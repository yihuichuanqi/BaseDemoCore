//
//  BDTextField.h
//  BaseDemoCore
//
//  Created by Admin on 2017/11/15.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDTextField : UITextField

@property (nonatomic,strong) UIColor *placeHolderColor;

@end

@interface UIResponder (BDResponderCategory)

+(id)currentTextFieldFirstResponder;
@end
