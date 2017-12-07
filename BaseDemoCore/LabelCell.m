//
//  LabelCell.m
//  HTLinkLabel
//
//  Created by 老板 on 16/8/22.
//  Copyright © 2016年 老板. All rights reserved.
//

#import "LabelCell.h"
#import "HTLinkLabel.h"
@implementation LabelCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;
    
    _htlabel = [[HTLinkLabel alloc] init];
    
    _htlabel.translatesAutoresizingMaskIntoConstraints = NO;
//    _htlabel.backgroundColor = [UIColor redColor];
    _htlabel.numberOfLines = 0;
    _htlabel.lineBreakMode = NSLineBreakByWordWrapping;
    _htlabel.heightlightbackgroundcolor = [UIColor blueColor];
    [self.contentView addSubview:_htlabel];
    
    
    
    NSMutableArray *ctr = [[NSMutableArray alloc] init];
    
    [ctr addObject:[NSLayoutConstraint constraintWithItem:_htlabel
                                                attribute:NSLayoutAttributeCenterX
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:self.contentView
                                                attribute:NSLayoutAttributeCenterX
                                               multiplier:1
                                                 constant:0.0]];
    
    [ctr addObject:[NSLayoutConstraint constraintWithItem:_htlabel
                                                attribute:NSLayoutAttributeCenterY
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:self.contentView
                                                attribute:NSLayoutAttributeCenterY
                                               multiplier:1
                                                 constant:0.0]];
    
    [self.contentView addConstraints:ctr];
    
    
    return self;
}

@end
