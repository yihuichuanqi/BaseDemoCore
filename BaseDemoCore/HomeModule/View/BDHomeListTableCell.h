//
//  BDHomeListTableCell.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/1.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "YXJSwipeTableViewCell.h"

@interface BDHomeListTableCell : YXJSwipeTableViewCell

-(void)setCellBgViewColor:(UIColor *)color;
-(void)configureBDHomeListTableCell:(NSString *)value;
-(void)configureBDHomeListTableCell:(NSString *)value withIconImage:(UIImage *)icon;
-(void)configureBDHomeListTableCell:(NSString *)value withIconName:(NSString *)iconName;

@end
