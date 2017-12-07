//
//  BDInputTableViewCell.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/15.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDInputTableViewCell.h"
#import <CoreText/CoreText.h>

static const CGFloat leftPadding =15.0;
static const CGFloat rightPadding =10.0;
static const CGFloat bothSidePadding =10.0;
static const CGFloat titleWidth =80;


@implementation BDInputTableViewCell


+(instancetype)bd_InitInputTabelViewCellWithTableView:(UITableView *)tableView identifier:(NSString *)identifier delegate:(id<BDInputTableViewCellDelegate>)delegate
{
    BDInputTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil)
    {
        cell=[[BDInputTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.delegate=delegate;
    return cell;
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self=[super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor=[UIColor whiteColor];
        self.contentView.backgroundColor=[UIColor lightGrayColor];
        
        
        _iconImage=[[UIImageView alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:_iconImage];
        
        _titleLabel=[[UILabel alloc]initWithFrame:CGRectZero];
        _titleLabel.textAlignment=NSTextAlignmentLeft;
        _titleLabel.font=[UIFont systemFontOfSize:15.0];
        _titleLabel.textColor=[UIColor blackColor];
        _titleLabel.backgroundColor=[UIColor blueColor];
        _titleLabel.adjustsFontSizeToFitWidth=YES;
        _titleLabel.numberOfLines=0;
        [self.contentView addSubview:_titleLabel];
        
        _inputField=[[BDTextField alloc]initWithFrame:CGRectZero];
        _inputField.clearsOnBeginEditing=NO;
        _inputField.textColor=[UIColor blackColor];
        _inputField.backgroundColor=[UIColor yellowColor];
        _inputField.clearButtonMode=UITextFieldViewModeWhileEditing;
        _inputField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
        _inputField.font=[UIFont systemFontOfSize:15.0];
        _inputField.delegate=self;
        [_inputField addTarget:self action:@selector(cellTextFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        [self.contentView addSubview:_inputField];
        
        _maskControl=[[UIControl alloc]initWithFrame:self.contentView.bounds];
        [_maskControl addTarget:self action:@selector(cellRespondEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_maskControl];
        _maskControl.hidden=YES;
        
        _line=[CALayer layer];
        _line.frame=CGRectZero;
        _line.backgroundColor=[UIColor colorWithHue:0.2 saturation:0.5 brightness:0.9 alpha:1].CGColor;
        [self.contentView.layer addSublayer:_line];
        
        
        
    }
    return self;
}
-(void)setObject:(BDInputModel *)object
{
    if(![object isKindOfClass:[BDInputModel class]])
    {
        return;
    }
    
    self.inputModel=object;
    if(![self isEmpty:object.iconName])
    {
        _iconImage.image=[UIImage imageNamed:object.iconName];
    }
    
    _titleLabel.text=object.title?:@"";
    
    _inputField.text=object.text?:@"";
    _inputField.textColor=object.textColor?:[UIColor blackColor];
    _inputField.placeholder=object.placeHolder?:@"";
    _inputField.textAlignment=object.inputAlignment?:NSTextAlignmentLeft;
    _inputField.keyboardType=object.keyBoardType?:UIReturnKeyDefault;
    _inputField.secureTextEntry=object.secureTextEntry;
    
    //输入框可编辑则覆盖层隐藏，交互性打开
    _maskControl.hidden=object.editEnabled;
    _inputField.enabled=object.editEnabled;
    //整体视图可点击则覆盖层显示，输入框交互性关闭
    _maskControl.hidden=!object.clickEnabled;
    _inputField.enabled=!object.clickEnabled;
    
    self.accessoryView=object.cellccessoryView?:nil;
    self.accessoryType=object.accessoryType?:UITableViewCellAccessoryNone;
    
    self.event=object.cellEvent?:@"";
    
}

-(BOOL)bd_InputLimitLength:(NSInteger)length allowString:(NSString *)allowString inputCharacter:(NSString *)character
{
    NSLog(@"输入的单个字符：%@",character);
    if([self isEmpty:allowString])
    {
        if([self.inputField.text length]<length || [character length]==0)
        {
            return YES;
        }
        else
        {
            [self.inputField shakeAnimation];
            return NO;
        }
    }
    else
    {
        NSCharacterSet *cs=[[NSCharacterSet characterSetWithCharactersInString:allowString] invertedSet];
        NSString *filtered=[[character componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        BOOL canChange=[character isEqualToString:filtered];
        if((canChange && [self.inputField.text length]<length) || [character length]==0)
        {
            return YES;
        }
        else
        {
            [self.inputField shakeAnimation];
            return NO;
        }
    }
    return YES;
}
-(BOOL)bd_AmountFormatWithInterBitLength:(NSInteger)lenth digitsLength:(NSInteger)digitsLength inputCharacter:(NSString *)character
{
    if([character isEqualToString:@""])
    {
        return YES;
    }
    if(self.inputField.text.length==0)
    {
        if([character isEqualToString:@"."])
        {
            [self.inputField shakeAnimation];
            return NO;
        }
    }
    if([self.inputField.text hasPrefix:@"0"])
    {
        if(self.inputField.text.length==1&&[character isEqualToString:@"0"])
        {
            [self.inputField shakeAnimation];
            return NO;
        }
    }
    if([self.inputField.text containsString:@"."])
    {
        if([character isEqualToString:@"."])
        {
            [self.inputField shakeAnimation];
            return NO;
        }
        NSRange rangeOfPoint=[self.inputField.text rangeOfString:@"."];
        //超过小数点后长度
        if(self.inputField.text.length>rangeOfPoint.location+digitsLength)
        {
            [self.inputField shakeAnimation];
            return NO;
        }
        if(self.inputField.text.length==lenth+digitsLength+1)
        {
            [self.inputField shakeAnimation];
            return NO;
        }
    }
    else
    {
        if(self.inputField.text.length==lenth)
        {
            if([character isEqualToString:@"."])
            {
                return YES;
            }
            [self.inputField shakeAnimation];
            return NO;
        }
    }
    return YES;
}

#pragma mark-Private
-(BOOL)isEmpty:(NSString *)string
{
    if(string ==nil || string==NULL)
    {
        return YES;
    }
    if([string isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    if([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0)
    {
        return YES;
    }
    return NO;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    //默认 accessoryView右边距空出20 因此需重置frame让其为0
    CGRect accessoryViewFrame=self.accessoryView.frame;
    accessoryViewFrame.origin.x=CGRectGetWidth(self.bounds)-CGRectGetWidth(accessoryViewFrame);
    self.accessoryView.frame=accessoryViewFrame;
    
    CGSize imageSize=_iconImage.image.size;
    _iconImage.frame=CGRectMake(leftPadding, (self.height-imageSize.height)/2, imageSize.width, imageSize.height);
    
    //相邻元素之间的间隔
    CGFloat padding0=bothSidePadding;
    if(CGSizeEqualToSize(imageSize, CGSizeZero))
    {
        //图片不存在则取消间隔距离
        padding0=0;
    }
    CGFloat title_w=self.inputModel.titleMaxWidth?:titleWidth;
    _titleLabel.frame=CGRectMake(_iconImage.right+padding0, 0, [self isEmpty:_titleLabel.text]?0.f:title_w, self.height);
    
    if(self.inputModel.alignmentBothEnds)
    {
        [_titleLabel alignmentBothEnds];
    }
    
    CGFloat padding=bothSidePadding;
    if([self isEmpty:_titleLabel.text])
    {
        padding=0;
    }
    
    if (self.accessoryView)
    {
        _inputField.frame=CGRectMake(_titleLabel.right+padding, 0, self.width-(_titleLabel.right+padding)-self.accessoryView.width-rightPadding, self.height);
    }
    else if(self.accessoryType!=UITableViewCellAccessoryNone)
    {
        //可能是系统样式留出间隔区域
        _inputField.frame=CGRectMake(_titleLabel.right+padding, 0, self.width-(_titleLabel.right+padding)-rightPadding-25, self.height);
    }
    else
    {
        _inputField.frame=CGRectMake(_titleLabel.right+padding, 0, self.width-(_titleLabel.right+padding)-rightPadding, self.height);
    }
    
    if(!_maskControl.isHidden)
    {
        _maskControl.frame=self.contentView.bounds;
    }
    
    if(CGRectEqualToRect(self.inputModel.lineFrame, CGRectZero))
    {
        
    }
    else
    {
        _line.frame=self.inputModel.lineFrame;
    }
    
    
}



#pragma mark-相应事件
-(void)cellRespondEvent:(id)sender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    if(self.delegate && [self.delegate respondsToSelector:@selector(bd_InputTableViewCell:DidSelectEvent:)])
    {
        [self.delegate bd_InputTableViewCell:self DidSelectEvent:self.event];
    }
}
-(void)cellTextFieldEditingChanged:(UITextField *)textField
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(bd_InputTableViewCell:textFieldEditingChanged:)])
    {
        self.inputModel.text=textField.text;
        [self.delegate bd_InputTableViewCell:self textFieldEditingChanged:textField.text];
    }
}

#pragma mark-UITextField Delegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL result=[self callBackTextField:textField ShouldChangeCharacterInRange:range replacementString:string];
    return result;
}
-(BOOL)callBackTextField:(UITextField *)textField ShouldChangeCharacterInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL result=YES;
    if(self.delegate && [self.delegate respondsToSelector:@selector(bd_InputTableViewCell:textFieldShouldChangeCharacterInRange:replacementString:)])
    {
        result=[self.delegate bd_InputTableViewCell:self textFieldShouldChangeCharacterInRange:range replacementString:string];
    }
    return result;
}




- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

@implementation BDInputModel

@end

@implementation UILabel (BDCellLabelCategory)

-(void)alignmentBothEnds
{
    if(!self.text)
    {
        return;
    }
    CGSize textSize=[self.text boundingRectWithSize:CGSizeMake(self.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.font} context:nil].size;
    //字符间隔
    CGFloat margin=(self.frame.size.width-textSize.width)/(self.text.length-1);
    NSNumber *number=[NSNumber numberWithFloat:margin];
    NSMutableAttributedString *attri=[[NSMutableAttributedString alloc]initWithString:self.text];
    [attri addAttribute:(id)kCTKernAttributeName value:number range:NSMakeRange(0, self.text.length-1)];
    self.attributedText=attri;
    
}

@end

@implementation UIView (BDCellViewCategory)

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

-(void)shakeAnimation
{
    CALayer *layer=[self layer];
    CGPoint position=[layer position];
    CGPoint y=CGPointMake(position.x-3.0f, position.y);
    CGPoint x=CGPointMake(position.x+3.0f, position.y);
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    [animation setAutoreverses:YES];
    [animation setDuration:0.08f];
    [animation setRepeatCount:3];
    [layer addAnimation:animation forKey:nil];
    
}


@end


























