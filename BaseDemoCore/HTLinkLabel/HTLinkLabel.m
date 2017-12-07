//
//  HTLinkLabel.m
//  HTLinkLabel
//
//  Created by 老板 on 16/8/18.
//  Copyright © 2016年 老板. All rights reserved.
//

#import "HTLinkLabel.h"
@interface HTLinkLabel()
{
    NSMutableAttributedString * OriginalMutableAttributedString;
}

@end


@implementation HTLinkLabel

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(!self) return nil;
    
    [self setup];
    
    return self;
}

-(void)setup{
    self.userInteractionEnabled = YES;
    _heightlightbackgroundcolor = [UIColor grayColor];
    _heightlightforegroundcolor = [UIColor whiteColor];
    [self.textStorage addLayoutManager:self.layoutManager];
    [self.layoutManager addTextContainer:self.textContainer];
}

-(void)setAttributedString:(HTAttributedString *)AttributedString
{
    [super setAttributedText:(NSAttributedString *)AttributedString.AttributedString];
    OriginalMutableAttributedString = AttributedString.AttributedString;
    _links = AttributedString.links;
    [self.textStorage setAttributedString:(NSAttributedString *)AttributedString.AttributedString];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //获取自动布局的frame
    self.textContainer.size = self.frame.size;
    
}

#pragma mark 重绘文字和背景
- (void)drawTextInRect:(CGRect)rect
{
    if (_textContainer.size.width<=0||_textContainer.size.height<=0){
        return;
    }
    
    //绘制
    [_layoutManager drawBackgroundForGlyphRange:NSMakeRange(0,_textStorage.mutableString.length) atPoint:CGPointMake(0, 0)];
    
    [_layoutManager drawGlyphsForGlyphRange:NSMakeRange(0,_textStorage.mutableString.length) atPoint:CGPointMake(0, 0)];
 
    
}

#pragma mark 重写触摸事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    
    _activeLink = [self linkAtPoint:[touch locationInView:self]];
    
    if (_activeLink) {
        
        @autoreleasepool {

            NSMutableAttributedString * attrString = [OriginalMutableAttributedString mutableCopy];
            
            NSMutableAttributedString * linkstring = [[NSMutableAttributedString alloc] initWithString:[_textStorage.mutableString substringWithRange:_activeLink.linkRange]];
            
            [linkstring beginEditing];
            [linkstring addAttribute:NSFontAttributeName
                               value:self.font
                               range:NSMakeRange(0, linkstring.length)];
            
            [linkstring addAttribute:NSBackgroundColorAttributeName
                               value:_heightlightbackgroundcolor
                               range:NSMakeRange(0, linkstring.length)];
            
            [linkstring addAttribute:NSForegroundColorAttributeName
                               value:_heightlightforegroundcolor
                               range:NSMakeRange(0, linkstring.length)];
            [linkstring endEditing];
            
            [attrString beginEditing];
            [attrString replaceCharactersInRange:_activeLink.linkRange withAttributedString:linkstring];
            [attrString endEditing];
            
            [_textStorage setAttributedString:attrString];
        }
        
        [self setNeedsDisplay];
    }
    
    //如果已经触发了链接，就不朝上传递消息了
    if (!_activeLink) {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //如果当前位置和之前的active的不一样的话，就认为不选那个链接了
    if (_activeLink) {
        
        UITouch *touch = [touches anyObject];
        
        HTLink * templink = nil;
        
        @autoreleasepool {
            templink = [self linkAtPoint:[touch locationInView:self]];
        }
        
        if (![_activeLink.linkValue isEqualToString:templink.linkValue]) {
            [self performSelector:@selector(delayRecoveryBackgroundColor:) withObject:_activeLink afterDelay:0.1f];
            _activeLink = nil;
        }
        
    } else {
        [super touchesMoved:touches withEvent:event];
    }
    
}

#pragma mark 手指抬起
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_activeLink) {
        
        [self performSelector:@selector(delayRecoveryBackgroundColor:) withObject:_activeLink afterDelay:0.1f];
        
        if ([_delegate respondsToSelector:@selector(didClickLink:)]) {
            [_delegate didClickLink:_activeLink];
        }
        
    } else {
        [super touchesEnded:touches withEvent:event];
    }
    
}

#pragma mark 延迟还原最初样式
-(void)delayRecoveryBackgroundColor:(HTLink *)activeLink{
    
    [_textStorage setAttributedString:self.attributedText];
    
    [self setNeedsDisplay];
}

#pragma mark 触摸取消(被打断)
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_activeLink) {
        [self performSelector:@selector(delayRecoveryBackgroundColor:) withObject:_activeLink afterDelay:0.1f];
        _activeLink = nil;
    } else {
        [super touchesCancelled:touches withEvent:event];
    }
}

#pragma mark - 链接点击交互
- (HTLink *)linkAtPoint:(CGPoint)location
{
    if (_links.count<=0||
        self.attributedText.length == 0||
        self.textContainer.size.width<=0||
        self.textContainer.size.height<=0)
        
        return nil;
    
    //获取触摸的字形
    NSUInteger glyphIdx = [self.layoutManager glyphIndexForPoint:location inTextContainer:self.textContainer];
    
    //找到了charIndex，然后去寻找是否这个字处于链接内部
    for (HTLink * link in self.links) {
        if (NSLocationInRange(glyphIdx,link.linkRange)) {
            return link;
        }
    }
    
    return nil;
}


- (NSTextStorage *)textStorage
{
    if (!_textStorage) {
        _textStorage = [NSTextStorage new];
    }
    return _textStorage;
}

-(NSLayoutManager *)layoutManager
{
    if (!_layoutManager) {
        _layoutManager = [HTLayoutManager new];
        _layoutManager.allowsNonContiguousLayout = NO;
        _layoutManager.delegate = self;
    }
    return _layoutManager;
}

-(NSTextContainer *)textContainer
{
    if (!_textContainer) {
        _textContainer = [NSTextContainer new];
        _textContainer.maximumNumberOfLines = 0;
        _textContainer.lineBreakMode = self.lineBreakMode;
        _textContainer.lineFragmentPadding = 0.0f;
        _textContainer.size = self.frame.size;
    }
    return _textContainer;
}

#pragma mark 设置行数
-(void)setNumberOfLines:(NSInteger)numberOfLines
{
    [super setNumberOfLines:numberOfLines];
    self.textContainer.maximumNumberOfLines = numberOfLines;
}

#pragma mark 设置转换方式
-(void)setLineBreakMode:(NSLineBreakMode)lineBreakMode
{
    [super setLineBreakMode:lineBreakMode];
    [self.textContainer setLineBreakMode:lineBreakMode];
}

@end

@interface HTAttributedString()

@end

@implementation HTAttributedString



@end

@interface HTLink()

@end

@implementation HTLink

@end

@interface HTLayoutManager()


@end

@implementation HTLayoutManager

- (void)drawBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin
{
    [super drawBackgroundForGlyphRange:glyphsToShow atPoint:origin];
}

- (void)fillBackgroundRectArray:(const CGRect *)rectArray count:(NSUInteger)rectCount forCharacterRange:(NSRange)charRange color:(UIColor *)color
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (!ctx) {
        [super fillBackgroundRectArray:rectArray count:rectCount forCharacterRange:charRange color:color];
        return;
    }
    
    CGContextSaveGState(ctx);
    {
        [color setFill];
        
        for (NSInteger i=0; i<rectCount; i++) {
            //找到相交的区域并且绘制
            CGRect validRect = rectArray[i];
            if (!CGRectIsEmpty(validRect)) {
                
                @autoreleasepool {
                    CGFloat width = validRect.size.width;
                    CGFloat height = validRect.size.height;
                    
                    CGFloat radius = 3;
                    CGFloat space = 1;
                    CGFloat originx = validRect.origin.x;
                    // 移动到初始点
                    CGContextMoveToPoint(ctx, originx+radius, space+(height)*i);
                    
                    //右上角圆弧
                    CGContextAddArc(ctx, originx+width-radius, radius+space+(height)*i, radius, -0.5 * M_PI, 0.0, 0);
                    
                    //右下角圆弧
                    CGContextAddArc(ctx, originx+width-radius, height-radius-space+(height)*i, radius, 0.0, 0.5 * M_PI, 0);
                    
                    //左下角圆弧
                    CGContextAddArc(ctx, originx+radius, height-radius-space+(height)*i, radius, 0.5 * M_PI, M_PI, 0);
                    
                    //左上角圆弧
                    CGContextAddArc(ctx, originx+radius, radius+space+(height)*i, radius, M_PI, 1.5 * M_PI, 0);
                    
                    // 闭合路径
                    CGContextClosePath(ctx);
                    
                    CGContextDrawPath(ctx, kCGPathFill);
                }
                
            }
        }
    }
    
    CGContextRestoreGState(ctx);
}



@end
