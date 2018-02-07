//
//  BDActionSheetTableCell.m
//  BaseDemoCore
//
//  Created by scl on 2017/11/22.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDActionSheetTableCell.h"
#import "BDActionSheetViewController.h"

@interface BDActionSheetTableCell ()
@property (weak, nonatomic) IBOutlet UILabel *centerLabel;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@end

@implementation BDActionSheetTableCell

-(void)setActionSheetItem:(ActionSheetItem *)actionSheetItem
{
    if ([_actionSheetItem isEqual:actionSheetItem])
    {
        return;
    }
    
    _actionSheetItem=actionSheetItem;
    if (_actionSheetItem)
    {
        self.centerLabel.text=actionSheetItem.title;
        if (_actionSheetItem.textColor)
        {
            self.centerLabel.textColor=_actionSheetItem.textColor;
        }
        else
        {
            self.centerLabel.textColor=[UIColor grayColor];
        }
        if (fabs(_actionSheetItem.fontSize-0)>DBL_EPSILON)
        {
            self.centerLabel.font=[UIFont systemFontOfSize:_actionSheetItem.fontSize];
        }
        else
        {
            self.centerLabel.font=[UIFont systemFontOfSize:17];
        }
    }
    else
    {
        self.centerLabel.textColor=[UIColor grayColor];
        self.centerLabel.font=[UIFont systemFontOfSize:17];
        self.centerLabel.text=@"";
    }
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
