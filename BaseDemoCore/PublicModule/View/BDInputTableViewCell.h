//
//  BDInputTableViewCell.h
//  BaseDemoCore
//
//  Created by Admin on 2017/11/15.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDTextField.h"

@class BDInputTableViewCell,BDInputModel;

//只允许输入数字
#define kAllow_Numbers @"0123456789\n"
//只允许输入字母、数字
#define kAllow_AlphaNum @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789\n"

@protocol BDInputTableViewCellDelegate <NSObject>

@optional
//cell可点击
-(void)bd_InputTableViewCell:(BDInputTableViewCell *)cell DidSelectEvent:(NSString *)event;
//输入编辑时
-(void)bd_InputTableViewCell:(BDInputTableViewCell *)cell textFieldEditingChanged:(NSString *)value;
//输入框编辑时控制输入(是否接受继续编辑 默认YES)
-(BOOL)bd_InputTableViewCell:(BDInputTableViewCell *)cell textFieldShouldChangeCharacterInRange:(NSRange)range replacementString:(NSString *)string;

@end




@interface BDInputTableViewCell : UITableViewCell<UITextFieldDelegate>

@property (nonatomic,strong) BDInputModel *inputModel;

@property (nonatomic,strong) BDTextField *inputField;
@property (nonatomic,strong) UIImageView *iconImage;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIControl *maskControl;
@property (nonatomic,strong) CALayer *line;
@property (nonatomic,copy) NSString *event;

@property (nonatomic,weak) id<BDInputTableViewCellDelegate>delegate;


+(instancetype)bd_InitInputTabelViewCellWithTableView:(UITableView *)tableView identifier:(NSString *)identifier delegate:(id<BDInputTableViewCellDelegate>)delegate;
-(void)setObject:(BDInputModel *)object;
//输入限制(最大长度、允许的字符集nil或者为空允许所有、单个字符)
-(BOOL)bd_InputLimitLength:(NSInteger)length allowString:(NSString *)allowString inputCharacter:(NSString *)character;
//输入限制(金额最大长度、小数位最大长度、单个字符)
-(BOOL)bd_AmountFormatWithInterBitLength:(NSInteger)lenth digitsLength:(NSInteger)digitsLength inputCharacter:(NSString *)character;




@end

@interface BDInputModel : NSObject

//左视图
@property (nonatomic,copy) NSString *iconName;
//左标题
@property (nonatomic,copy) NSString *title;
//内容
@property (nonatomic,copy) NSString *text;
//内容颜色
@property (nonatomic,strong) UIColor *textColor;
//placeHolder
@property (nonatomic,strong) NSString *placeHolder;
//输入框对齐
@property (nonatomic,assign) NSTextAlignment inputAlignment;
//键盘类型
@property (nonatomic,assign) UIKeyboardType keyBoardType;
//输入框是否可编辑
@property (nonatomic,assign) BOOL editEnabled;
//是否可点击 YES时不可编辑可点击
@property (nonatomic,assign) BOOL clickEnabled;
//明密显示
@property (nonatomic,assign) BOOL secureTextEntry;
//title是否两端对齐
@property (nonatomic,assign) BOOL alignmentBothEnds;
//标题最大宽度，默认80px
@property (nonatomic,assign) CGFloat titleMaxWidth;
//line默认隐藏 设置后自动显示
@property (nonatomic,assign) CGRect lineFrame;
//cell事件标识
@property (nonatomic,copy) NSString *cellEvent;

/*（两者不会兼容存在,优先显示自定义view）*/
//右视图View
@property (nonatomic,strong) UIView *cellccessoryView;
//右视图类型
@property (nonatomic,assign) UITableViewCellAccessoryType accessoryType;


@end

@interface UILabel (BDCellLabelCategory)

//两端对齐
-(void)alignmentBothEnds;
@end

@interface UIView (BDCellViewCategory)

@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize  size;

//抖动效果
-(void)shakeAnimation;
@end









