//
//  BDActionSheetViewController.h
//  BaseDemoCore
//
//  Created by scl on 2017/11/21.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ActionSheetItem;

typedef void (^ActionSheetDismissBlock)(ActionSheetItem *item,NSIndexPath *indexPath);

@interface BDActionSheetViewController : UIViewController

@property(nonatomic,copy) ActionSheetDismissBlock dismissBlock;

//仅有标题
-(ActionSheetItem *)addButtonTitle:(NSString *)title atGroup:(NSInteger)group;
-(ActionSheetItem *)addButtonTitle:(NSString *)title  height:(CGFloat)height atGroup:(NSInteger)group;
-(ActionSheetItem *)addButtonTitle:(NSString *)title  height:(CGFloat)height isCancel:(BOOL)isCancel atGroup:(NSInteger)group;
-(ActionSheetItem *)addButtonTitle:(NSString *)title atGroup:(NSInteger)group selectHandler:(void(^)(ActionSheetItem *item))handler;//默认高度及常规视图的附带block
//取消按钮在底部
-(ActionSheetItem *)addCancelButtonTitle:(NSString *)title atGroup:(NSInteger)group selectHandler:(void(^)(ActionSheetItem *item))handler;

//附带图片
-(ActionSheetItem *)addButtonTitle:(NSString *)title iconImage:(NSString *)icon atGroup:(NSInteger)group;
-(ActionSheetItem *)addButtonTitle:(NSString *)title iconImage:(NSString *)icon height:(CGFloat)height atGroup:(NSInteger)group;
-(ActionSheetItem *)addButtonTitle:(NSString *)title iconImage:(NSString *)icon height:(CGFloat)height isCancel:(BOOL)isCancel atGroup:(NSInteger)group;
-(ActionSheetItem *)addButtonTitle:(NSString *)title iconImage:(NSString *)icon atGroup:(NSInteger)group selectHandler:(void(^)(ActionSheetItem *item))handler;//默认高度及常规视图的附带block

-(void)showInViewController:(UIViewController *)viewController;
-(void)ajustFrame;

-(id)initWithDismissBlock:(ActionSheetDismissBlock)dismissBlock;
-(id)initWithDataSource:(NSArray *)dataArray;
-(id)initWithDataSource:(NSArray *)dataArray dismissBlock:(ActionSheetDismissBlock)dismissBlock;

+(void)showWithDataSource:(NSArray *)array viewController:(UIViewController *)viewController dismissBlock:(ActionSheetDismissBlock)dismissBlock;

@end


#define kActionSheetTitle @"title"
#define kActionSheetIconImage @"image"
#define kActionSheetHeight @"height"
#define kActionSheetIsCancel @"isCancel"
#define kActionSheetFontSize @"fontSize"
#define kActionSheetTextColor @"textColor"

@interface ActionSheetItem : NSObject

@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) UIColor *textColor;
@property (nonatomic,assign) CGFloat fontSize;
@property (nonatomic,strong) NSString *iconImage;
@property (nonatomic,assign) CGFloat height;
@property (nonatomic,assign) BOOL isCancel;
@property (nonatomic,assign) BOOL cannotTouch;

@property (nonatomic,copy) void(^selectHandler)(ActionSheetItem *item);

-(id)initWithDict:(NSDictionary *)aDict;
-(void)detailWithDict:(NSDictionary *)aDict;

@end

@interface ActionSheetItemGroup : NSObject

@property (nonatomic,strong) NSMutableArray *models;
-(NSInteger)count;
-(id)initWithArray:(NSArray *)aArray;
-(NSMutableArray *)modelsWithArray:(NSArray *)aArray;
-(id)objectInModelsAtIndex:(NSUInteger)index;
@end




