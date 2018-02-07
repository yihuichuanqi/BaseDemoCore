//
//  BDCustomAnnotationView.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/21.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDCustomAnnotationView.h"

#define kAnimationDuration 0.425
#define kGap 1.5
#define kCircle_R 30
#define kIcon_Width 20

@interface BDCustomAnnotationView ()

@property (nonatomic,strong)  UIView *detailView;
@property (nonatomic,strong) UIImageView *backImageView;
@property (nonatomic,strong) UIImageView *iconImageView;
@property (nonatomic,strong) UIImageView *tickImageView;
@property (nonatomic,strong) UILabel *textLabel;

@property (nonatomic,assign) CGFloat originalWidth;
@property (nonatomic,assign) BOOL open;
@property (nonatomic,assign) BOOL isSelectedView;

@end


@implementation BDCustomAnnotationView

-(UIView *)detailView
{
    if (!_detailView)
    {
        _detailView=[[UIView alloc]init];
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(annotationViewDidTaped:)];
        [_detailView addGestureRecognizer:tap];
        _detailView.clipsToBounds=YES;
        _detailView.backgroundColor=[UIColor groupTableViewBackgroundColor];
        [_detailView addSubview:self.textLabel];
        [_detailView addSubview:self.iconImageView];
        [_detailView addSubview:self.tickImageView];
        
        [self addSubview:_detailView];
    }
    return _detailView;
}
-(void)annotationViewDidTaped:(UITapGestureRecognizer *)tap
{
    self.isSelectedView=!_isSelectedView;
}

-(UIImageView *)iconImageView
{
    if (!_iconImageView)
    {
        _iconImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kIcon_Width, kIcon_Width)];
    }
    return _iconImageView;
}
-(UILabel *)textLabel
{
    if (!_textLabel)
    {
        _textLabel=[[UILabel alloc]init];
        _textLabel.font=[UIFont systemFontOfSize:15];
    }
    return _textLabel;
}
-(UIImageView *)tickImageView
{
    if (!_tickImageView)
    {
        _tickImageView=[[UIImageView alloc]initWithImage:kImage(@"") highlightedImage:kImage(@"")];
    }
    return _tickImageView;
}
-(UIImageView *)backImageView
{
    if (!_backImageView)
    {
        _backImageView=[[UIImageView alloc]init];
    }
    return _backImageView;
}

-(instancetype)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self setExclusiveTouch:YES];
        [self setupSubViews];
    }
    return self;
}
-(void)setupSubViews
{
    [self addSubview:self.backImageView];
    [self addSubview:self.detailView];
    
}

-(void)setIsSelectedView:(BOOL)isSelectedView
{
    _isSelectedView=isSelectedView;
    self.tickImageView.highlighted=isSelectedView;
    if (_open)
    {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(BDCustomAnnotationView:DidSelected:)])
        {
            [self.delegate BDCustomAnnotationView:self DidSelected:isSelectedView];
        }
    }
}

-(void)setOpen:(BOOL)open
{
    _open=open;
    self.detailView.userInteractionEnabled=open;
}

-(void)setupBackImage:(UIImage *)backImage iconImage:(UIImage *)iconImage detailText:(NSString *)detailText
{
    self.backImageView.image=backImage;
    self.iconImageView.image=iconImage;
    self.textLabel.text=detailText;
    if (!_open)
    {
        [self refreshSubView];
    }
    else
    {
        [self.textLabel sizeToFit];
        self.open=NO;
        [self animateToShowAnnotationViewDetail];
    }
}
-(void)refreshSubView
{
    [self.backImageView sizeToFit];
    [self.textLabel sizeToFit];
    if (self.normalAnnotation)
    {
        self.tickImageView.hidden=YES;
        self.frame=CGRectMake(0, 0, self.backImageView.frame.size.width, self.backImageView.frame.size.height);
        self.originalWidth=self.frame.size.width;
        self.open=NO;
        self.centerOffset=CGPointMake(0, -self.frame.size.height/2);
        self.detailView.frame=CGRectMake((self.frame.size.width-kCircle_R)/2+kGap, 0, kCircle_R-kGap*2, kCircle_R-kGap);
        self.detailView.layer.cornerRadius=self.detailView.frame.size.width/2;
        self.iconImageView.center=CGPointMake(self.detailView.frame.size.width/2, self.detailView.frame.size.height/2);
        self.textLabel.center=self.iconImageView.center;
        CGRect textLabelFrame=self.textLabel.frame;
        textLabelFrame.origin.x=self.iconImageView.frame.origin.x+self.iconImageView.frame.size.width;
        self.textLabel.frame=textLabelFrame;
        self.textLabel.alpha=0;
    }
    else
    {
        self.frame=CGRectMake(0, 0, self.backImageView.frame.size.width, self.backImageView.frame.size.height);
        self.originalWidth=self.frame.size.width;
        self.open=NO;
    }
}
-(void)animateToShowAnnotationViewDetail
{
    if (!_open)
    {
        self.isSelectedView=NO;
        CGFloat targetWidth=0.0*kIcon_Width/2+self.textLabel.frame.size.width+kCircle_R-4+10;
        if (self.normalAnnotation)
        {
            targetWidth=0.6*kIcon_Width/2+self.textLabel.frame.size.width+kCircle_R-4;
        }
        [UIView animateKeyframesWithDuration:kAnimationDuration delay:0 options:0 animations:^{
           
            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.35 animations:^{
               
                if (self.normalAnnotation)
                {
                    self.iconImageView.transform=CGAffineTransformScale(CGAffineTransformIdentity, 0.6, 0.6);
                }
                else
                {
                    self.iconImageView.transform=CGAffineTransformScale(CGAffineTransformIdentity, 0, 0);
                }
                
            }];
            
            [UIView addKeyframeWithRelativeStartTime:0.35 relativeDuration:0.65 animations:^{
               
                self.frame=CGRectMake(self.frame.origin.x-(targetWidth-self.frame.size.width)/2, self.frame.origin.y, targetWidth, self.frame.size.height);
                self.detailView.frame=CGRectMake(0, 0, self.frame.size.width, self.detailView.frame.size.height);
                self.backImageView.frame=CGRectMake((self.frame.size.width-self.backImageView.frame.size.width)/2, 0, self.backImageView.frame.size.width, self.backImageView.frame.size.height);
                
            }];
            
            
            [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
               
                self.textLabel.alpha=1;
            }];
            
            
        } completion:^(BOOL finished) {
            
        }];
        self.open=YES;
    }
}
-(void)animateToHideAnnotationViewDetail
{
    if (_open)
    {
        
        [UIView animateKeyframesWithDuration:kAnimationDuration delay:0 options:0 animations:^{
            
            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.3 animations:^{
                
                self.textLabel.alpha=1;
            }];
            
            [UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.5 animations:^{
                
                self.frame=CGRectMake(self.frame.origin.x+(self.frame.size.width-_originalWidth)/2, self.frame.origin.y, _originalWidth, self.frame.size.height);
                self.detailView.frame=CGRectMake((self.frame.size.width-kCircle_R)/2+kGap, 0, kCircle_R-kGap*2, kCircle_R-kGap);
                self.backImageView.frame=CGRectMake(0, 0, self.backImageView.frame.size.width, self.backImageView.frame.size.height);
                
            }];
            [UIView addKeyframeWithRelativeStartTime:0.7 relativeDuration:0.3 animations:^{
                
                self.iconImageView.transform=CGAffineTransformIdentity;
                
            }];

            
        } completion:^(BOOL finished) {
            
        }];
        self.open=NO;
    }
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
