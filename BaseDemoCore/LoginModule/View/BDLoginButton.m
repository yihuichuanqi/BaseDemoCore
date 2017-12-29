//
//  BDLoginButton.m
//  BaseDemoCore
//
//  Created by Admin on 2017/12/29.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDLoginButton.h"

@interface BDLoginButton ()<BDViewProtocol>

@property (nonatomic,strong) UIActivityIndicatorView *loginActivityView;
@end

@implementation BDLoginButton

-(UIActivityIndicatorView *)loginActivityView
{
    if (!_loginActivityView)
    {
        _loginActivityView=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _loginActivityView.hidesWhenStopped=YES;
    }
    return _loginActivityView;
}
-(void)setupCustomButtonUIStyle
{
    self.titleLabel.font=[UIFont systemFontOfSize:15];
    self.layer.masksToBounds=YES;
    self.layer.cornerRadius=5.f;
    [self setBadgeColor:[UIColor blueColor]];
    [self setTitle:@"登录" forState:UIControlStateNormal];
    [self addSubview:self.loginActivityView];
    [self setNeedsUpdateConstraints];
}

-(void)updateConstraints
{
    [self.loginActivityView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.center.mas_equalTo(self);
    }];
    [super updateConstraints];
}

-(void)startLoadingAnimation
{
    [self.loginActivityView startAnimating];
    [self setTitle:@"" forState:UIControlStateNormal];
}
-(void)stopLoadingAnimation
{
    [self.loginActivityView stopAnimating];
    [self setTitle:@"登录" forState:UIControlStateNormal];
}


#pragma mark-Protocol
-(void)bd_setupViewForView
{
    [self setupCustomButtonUIStyle];
}
-(void)bd_initialExtraDataForView
{
    
}
-(void)bd_bindViewModel:(id<BDViewProtocol>)viewModel withParams:(NSDictionary *)params
{
    
}









/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
