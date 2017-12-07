//
//  HTLinkLabel.h
//  HTLinkLabel
//
//  Created by 老板 on 16/8/18.
//  Copyright © 2016年 老板. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HTLink;
@class HTAttributedString;
@class HTLayoutManager;

@protocol HTLinkLabelDelegate <NSObject>

-(void)didClickLink:(HTLink *)link;

@end

@interface HTLinkLabel : UILabel <NSLayoutManagerDelegate>

@property(nonatomic , strong)NSArray * links;//存放HTLink对象
@property(nonatomic , strong)HTLink * activeLink;//被点击的HTLink
@property(nonatomic , strong)HTAttributedString * AttributedString;
@property(nonatomic , strong)UIColor * heightlightbackgroundcolor;//高亮背景色
@property(nonatomic , strong)UIColor * heightlightforegroundcolor;//高亮文字色
@property(nonatomic , assign)id<HTLinkLabelDelegate> delegate;

@property(nonatomic , strong)NSTextStorage *textStorage;
@property(nonatomic , strong)HTLayoutManager *layoutManager;
@property(nonatomic , strong)NSTextContainer * textContainer;

@end

@interface HTLink : NSObject

@property (nonatomic, copy)     NSString *linkValue;
@property (nonatomic, assign)   NSRange linkRange;

@end


@interface HTAttributedString : NSObject

@property(nonatomic , strong)NSArray *links;
@property(nonatomic , copy)NSMutableAttributedString * AttributedString;

@end

@interface HTLayoutManager : NSLayoutManager

@end