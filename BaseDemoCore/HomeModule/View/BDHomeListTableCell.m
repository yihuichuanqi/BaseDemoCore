//
//  BDHomeListTableCell.m
//  BaseDemoCore
//
//  Created by Admin on 2017/12/1.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDHomeListTableCell.h"

@interface BDHomeListTableCell ()

@property (nonatomic,strong) UILabel *leftLabel;
@property (nonatomic,strong) UIView *bgView;
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
        _leftLabel.textColor=[UIColor redColor];
        _leftLabel.backgroundColor=[UIColor blueColor];
    }
    return _leftLabel;
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
    [self.bgView addSubview:self.leftLabel];
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerY.equalTo(self.bgView);
        make.left.equalTo(self.bgView).with.offset(20);
    }];
    
}
-(void)configureBDHomeListTableCell:(NSString *)value
{
    [self setAddSubViewAndLayout];

    self.leftLabel.text=value;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
