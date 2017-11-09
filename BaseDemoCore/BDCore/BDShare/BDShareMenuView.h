//
//  BDShareMenuView.h
//  BaseDemoCore
//
//  Created by Admin on 2017/11/9.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SelectItemBlock)(NSInteger tag, NSString *title);

@interface BDShareItemButton : UIButton

@end


@interface BDShareMenuView : UIView

@property (nonatomic) NSInteger rowNumberItem;
@property (nonatomic,strong) UIFont *shareItemButtonFont;
@property (nonatomic,strong) UIColor *shareItemButtonColor;

@property (nonatomic,strong) UIColor *cacelBackgroundColor;
@property (nonatomic,strong) NSString *cancelButtonText;
@property (nonatomic,strong) UIFont *cancelButtonFont;
@property (nonatomic,strong) UIColor *cancelButtonColor;

-(void)addShareItemsView:(UIView *)view shareItems:(NSArray *)shareItems selectShareItem:(SelectItemBlock)selectBlock;



@end
