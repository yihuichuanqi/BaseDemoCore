//
//  BDHomeListTableCell.m
//  BaseDemoCore
//
//  Created by Admin on 2017/12/1.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDHomeListTableCell.h"
#import "BDImageLoader.h"
#import "UIImageView+BDWebImageCacheEx.h"
#import "UIImageView+BDAvartar.h"

@interface BDHomeListTableCell ()

@property (nonatomic,strong) UILabel *leftLabel;
@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIImageView *iconImage;
@end



@implementation BDHomeListTableCell

-(UIView *)bgView
{
    if (!_bgView)
    {
        _bgView=[[UIView alloc]init];
        _bgView.backgroundColor=[UIColor purpleColor];
    }
    return _bgView;
}
-(UILabel *)leftLabel
{
    if (!_leftLabel)
    {
        _leftLabel=[[UILabel alloc]init];
        _leftLabel.text=@"女包";
        _leftLabel.numberOfLines=4;
        _leftLabel.textColor=[UIColor redColor];
        _leftLabel.backgroundColor=[UIColor blueColor];
    }
    return _leftLabel;
}
-(UIImageView *)iconImage
{
    if (!_iconImage)
    {
        _iconImage=[[UIImageView alloc]init];
        _iconImage.backgroundColor=[UIColor redColor];
        _iconImage.contentMode=UIViewContentModeScaleAspectFit;
        _iconImage.bd_useDefaultPlaceholder=YES;
        _iconImage.bd_handleLoadFail=YES;

    }
    return _iconImage;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}
-(void)setCellBgViewColor:(UIColor *)color
{
    self.bgView.backgroundColor=color;
}

-(void)setAddSubViewAndLayout
{
    
    [self.contentView addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(self.contentView).with.offset(10);
        make.right.equalTo(self.contentView).with.offset(-10);
        make.top.bottom.equalTo(self.contentView).with.offset(0);
    }];
    [self.bgView addSubview:self.iconImage];
    [self.iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(self.bgView.mas_left).with.offset(10);
        make.centerY.equalTo(self.bgView);
        make.top.equalTo(self.bgView.mas_top).with.offset(5);
        
    }];
    [self.bgView addSubview:self.leftLabel];
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       

        make.centerY.equalTo(self.bgView);
        make.width.mas_equalTo(50);
        make.left.equalTo(self.iconImage.mas_right).with.offset(20);
        make.right.equalTo(self.bgView.mas_right).with.offset(-10);
    }];
    
}
-(void)configureBDHomeListTableCell:(NSString *)value
{
    [self setAddSubViewAndLayout];

    self.leftLabel.text=value;
}
-(void)configureBDHomeListTableCell:(NSString *)value withIconImage:(UIImage *)icon
{
    [self configureBDHomeListTableCell:value];
    self.iconImage.image=icon;
}
-(void)configureBDHomeListTableCell:(NSString *)value withIconName:(NSString *)iconName
{
    [self configureBDHomeListTableCell:value];
//    [self.iconImage bd_setImageWithUrl:[NSURL URLWithString:iconName] preferSize:CGSizeMake(100, 40)];
//    [self.iconImage bd_setAvartarForUrl:[NSURL URLWithString:iconName]];
//    [self.iconImage bd_setContentImageForUrl:[NSURL URLWithString:iconName] placeholderImage:nil size:CGSizeMake(100, 40)];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
