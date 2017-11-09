//
//  BDShareMenuView.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/9.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDShareMenuView.h"
#import "BDShare.h"

#define kBtnW 60
#define kBtnH 60
#define kMaginX 15
#define kMaginY 15
#define kFirst 10
#define kTitlePrecent 0.4 //文字所占比例
#define kImageViewWH 40


@interface BDShareItemButton ()

@end

@implementation BDShareItemButton

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self)
    {
        self.titleLabel.textAlignment=NSTextAlignmentCenter;
        self.titleLabel.font=[UIFont systemFontOfSize:10];
        [self setTitleColor:RGB(40, 40, 40) forState:UIControlStateNormal];
        self.imageView.layer.cornerRadius=kImageViewWH*0.5;
    }
    return self;
}
#pragma mark-调整文字位置及尺寸
-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleW=self.frame.size.width;
    CGFloat titleH=self.frame.size.height*kTitlePrecent;
    CGFloat titleX=2;
    CGFloat titleY=self.frame.size.height*(1-kTitlePrecent)+7;
    return CGRectMake(titleX, titleY, titleW, titleH);
}
-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageW=kImageViewWH;
    CGFloat imageH=kImageViewWH;
    CGFloat imageX=(self.frame.size.width-kImageViewWH)*0.5;
    CGFloat imageY=2;
    return CGRectMake(imageX, imageY, imageW, imageH);
}
@end


@interface BDShareMenuView ()
@property (nonatomic,strong) NSArray *shareItems;
@property (nonatomic,strong) UIView *backgroundView;
@property (nonatomic,strong) UIButton *cancelButton;
@property (nonatomic,copy) void(^btnBlock)(NSInteger tag,NSString *title);

@end

@implementation BDShareMenuView

-(void)addShareItemsView:(UIView *)view shareItems:(NSArray *)shareItems selectShareItem:(SelectItemBlock)selectBlock
{
    if (shareItems==nil||shareItems.count<1)
    {
        return;
    }
    
    self.backgroundColor=[UIColor groupTableViewBackgroundColor];
    [self addBackgroundView:view];
    
    NSInteger curRowNumberItem=self.rowNumberItem?:4;
    NSString *cancelText=self.cancelButtonText?:@"取消";
    [shareItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        NSString *name=obj[@"name"];
        NSString *icon=obj[@"icon"];
        BDShareItemButton *btn=[BDShareItemButton buttonWithType:UIButtonTypeCustom];
        btn.titleLabel.font=self.shareItemButtonFont?:[UIFont systemFontOfSize:10];
        [btn setTitleColor:self.shareItemButtonColor?:RGB(40, 40, 40) forState:UIControlStateNormal];
        btn.tag=idx;
        [btn setTitle:name forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
       
        CGFloat marginX=(self.frame.size.width-curRowNumberItem*kBtnW)/(curRowNumberItem+1);
        NSInteger col=idx%curRowNumberItem;
        NSInteger row=idx/curRowNumberItem;
        CGFloat btnX=marginX+(marginX+kBtnW)*col;
        CGFloat btnY=kFirst+(kMaginY+kBtnH)*row;
        btn.frame=CGRectMake(btnX, btnY, kBtnW, kBtnW);
        [self addSubview:btn];
        
    }];
    
    //计算面板大小
    NSUInteger row=(shareItems.count+1)/curRowNumberItem;
    CGFloat height=kFirst+100+(row+1)*(kBtnH+kMaginY);
    
    //分割线
    CGFloat lineMaxY=(row+1)*(kBtnH+kMaginY)+5;
    //取消
    self.cancelButton=[UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.frame=CGRectMake(0, lineMaxY, self.frame.size.width, 44);
    [self.cancelButton setTitle:cancelText forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font=self.cancelButtonFont?:[UIFont systemFontOfSize:16];
    [self.cancelButton setBackgroundColor:self.cacelBackgroundColor?:[UIColor whiteColor]];
    [self.cancelButton setTitleColor:self.cancelButtonColor?:[UIColor grayColor] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelButtonActionClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cancelButton];
    self.btnBlock = ^(NSInteger tag, NSString *title) {
        if (selectBlock)
        {
            selectBlock(tag,title);
        }
    };
    
    [view addSubview:self];
    
    CGFloat originY=[UIScreen mainScreen].bounds.size.height;
    self.frame=CGRectMake(0, originY, 0, height);
    [UIView animateWithDuration:0.25 animations:^{
       
        CGRect sf=self.frame;
        sf.origin.y=Main_Screen_Height-sf.size.height;
        self.frame=sf;
    }];
    
}
-(void)setFrame:(CGRect)frame
{
    frame.size.width=Main_Screen_Width;
    if (frame.size.height<0)
    {
        frame.size.height=0;
        
    }
    frame.origin.x=0;
    [super setFrame:frame];
}

-(void)cancelButtonActionClicked:(id)sender
{
    [_backgroundView removeFromSuperview];
    _backgroundView=nil;
    [UIView animateWithDuration:0.25 animations:^{
       
        CGRect sf=self.frame;
        sf.origin.y=Main_Screen_Height;
        self.frame=sf;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }] ;
}
-(void)btnClicked:(UIButton *)button
{
    if (_btnBlock)
    {
        _btnBlock(button.tag,button.titleLabel.text);
    }
}
-(void)addBackgroundView:(UIView *)view
{
    _backgroundView=[[UIView alloc]initWithFrame:view.bounds];
    _backgroundView.backgroundColor=[UIColor blackColor];
    _backgroundView.alpha=0.4;
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancelButtonActionClicked:)];
    [_backgroundView addGestureRecognizer:tap];
    [view addSubview:_backgroundView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
