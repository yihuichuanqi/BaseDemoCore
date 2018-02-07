//
//  BDActionSheetViewController.m
//  BaseDemoCore
//
//  Created by scl on 2017/11/21.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDActionSheetViewController.h"
#import "UIViewController+BDSemiModal.h"
#import "BDActionSheetTableCell.h"

static const CGFloat DefaultItemHeight=47;
static const CGFloat DefaultItemFontSize=17;

@interface BDActionSheetViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *dataArray;
@end

@implementation BDActionSheetViewController


-(UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        [_tableView registerNib:[UINib nibWithNibName:[BDActionSheetTableCell description] bundle:nil] forCellReuseIdentifier:[BDActionSheetTableCell description]];
    }
    return _tableView;
}
-(id)init
{
    return [self initWithDismissBlock:nil];
}
-(id)initWithDismissBlock:(ActionSheetDismissBlock)dismissBlock
{
    if (self=[super init])
    {
        [self.view addSubview:self.tableView];
        
        self.dismissBlock = dismissBlock;
    }
    return self;
}
-(id)initWithDataSource:(NSArray *)dataArray
{
    return [self initWithDataSource:dataArray dismissBlock:nil];
}
-(id)initWithDataSource:(NSArray *)dataArray dismissBlock:(ActionSheetDismissBlock)dismissBlock
{
    if (self=[super init])
    {
        for (NSArray *items in dataArray)
        {
#if DEBUG
            NSAssert(items.count, @"不能为空");
#endif
      
            ActionSheetItemGroup *group=[[ActionSheetItemGroup alloc]initWithArray:items];
            [self.dataArray addObject:group];
            
        }
        self.dismissBlock = dismissBlock;
        [self.tableView reloadData];
    }
    return self;
}
+(void)showWithDataSource:(NSArray *)array viewController:(UIViewController *)viewController dismissBlock:(ActionSheetDismissBlock)dismissBlock
{
    BDActionSheetViewController *sheetController=[[BDActionSheetViewController alloc]initWithDataSource:array];
    sheetController.dismissBlock = ^(ActionSheetItem *item, NSIndexPath *indexPath) {
      
        if (dismissBlock)
        {
            dismissBlock(item,indexPath);
        }
        
    };
}
//仅有标题
-(ActionSheetItem *)addButtonTitle:(NSString *)title atGroup:(NSInteger)group
{
    return [self addButtonTitle:title height:DefaultItemHeight atGroup:group];
}
-(ActionSheetItem *)addButtonTitle:(NSString *)title  height:(CGFloat)height atGroup:(NSInteger)group
{
    return [self addButtonTitle:title height:height isCancel:NO atGroup:group];
}
-(ActionSheetItem *)addButtonTitle:(NSString *)title  height:(CGFloat)height isCancel:(BOOL)isCancel atGroup:(NSInteger)group
{
    return [self addButtonTitle:title height:height isCancel:isCancel atGroup:group selectHandler:nil];
}
-(ActionSheetItem *)addButtonTitle:(NSString *)title atGroup:(NSInteger)group selectHandler:(void(^)(ActionSheetItem *item))handler
{
    return [self addButtonTitle:title height:DefaultItemHeight isCancel:NO atGroup:group selectHandler:handler];
}
-(ActionSheetItem *)addButtonTitle:(NSString *)title  height:(CGFloat)height isCancel:(BOOL)isCancel atGroup:(NSInteger)group selectHandler:(void(^)(ActionSheetItem *item))selectHandler
{
    return [self addButtonTitle:title iconImage:nil height:height isCancel:isCancel atGroup:group selectHandler:selectHandler];
    
}
//取消按钮在底部
-(ActionSheetItem *)addCancelButtonTitle:(NSString *)title atGroup:(NSInteger)group selectHandler:(void(^)(ActionSheetItem *item))handler
{
   return [self addButtonTitle:title height:DefaultItemHeight isCancel:YES atGroup:group selectHandler:handler];
}

//附带图片
-(ActionSheetItem *)addButtonTitle:(NSString *)title iconImage:(NSString *)icon atGroup:(NSInteger)group
{
    return [self addButtonTitle:title iconImage:icon height:DefaultItemHeight atGroup:group];
}
-(ActionSheetItem *)addButtonTitle:(NSString *)title iconImage:(NSString *)icon height:(CGFloat)height atGroup:(NSInteger)group
{
    return [self addButtonTitle:title iconImage:icon height:height isCancel:NO atGroup:group];
}
-(ActionSheetItem *)addButtonTitle:(NSString *)title iconImage:(NSString *)icon height:(CGFloat)height isCancel:(BOOL)isCancel atGroup:(NSInteger)group
{
    return [self addButtonTitle:title iconImage:icon height:height isCancel:isCancel atGroup:group selectHandler:nil];
}
-(ActionSheetItem *)addButtonTitle:(NSString *)title iconImage:(NSString *)icon atGroup:(NSInteger)group selectHandler:(void(^)(ActionSheetItem *item))handler;
{
    return [self addButtonTitle:title iconImage:icon height:DefaultItemHeight isCancel:NO atGroup:group selectHandler:handler];
}
-(ActionSheetItem *)addButtonTitle:(NSString *)title iconImage:(NSString *)icon height:(CGFloat)height isCancel:(BOOL)isCancel atGroup:(NSInteger)group selectHandler:(void(^)(ActionSheetItem *item))selectHandler
{
    ActionSheetItem *returnItem=nil;
    ActionSheetItemGroup *itemGroup=nil;
    if (self.dataArray.count>group)
    {
        itemGroup=[self.dataArray objectAtIndex:group];
    }
    else if (self.dataArray.count==group)
    {
        itemGroup=[[ActionSheetItemGroup alloc]init];
        [self.dataArray addObject:itemGroup];
    }
    else
    {
#ifdef DEBUG
        NSAssert(1, @"group大于总数量");
#endif
    }
    
    if (itemGroup)
    {
        NSMutableDictionary *itemDict=[NSMutableDictionary dictionary];
        [itemDict setObject:title forKey:kActionSheetTitle];
        [itemDict setObject:@(height) forKey:kActionSheetHeight];
        [itemDict setObject:@(isCancel) forKey:kActionSheetIsCancel];
        if (icon&&[icon length]>0)
        {
            [itemDict setObject:icon forKey:kActionSheetIconImage];
        }
        ActionSheetItem *item=[[ActionSheetItem alloc]initWithDict:itemDict];
        item.selectHandler = selectHandler;
        [itemGroup.models addObject:item];
        returnItem=item;
    }
    return returnItem;
}

-(void)showInViewController:(UIViewController *)viewController
{
    [self ajustFrame];
    [viewController bd_presentSemiViewController:self];
}
-(void)ajustFrame
{
    if (!self.dataArray.count)
    {
        CGRect viewRect=self.view.frame;
        viewRect.size.height=DefaultItemHeight;
        self.view.frame=viewRect;
    }
    else
    {
        CGFloat height=(self.dataArray.count-1)*8;
        for (ActionSheetItemGroup *group in self.dataArray)
        {
            for (ActionSheetItem *item in group.models)
            {
                height+=item.height;
            }
        }
        if (height>[UIScreen mainScreen].bounds.size.height)
        {
            height=[UIScreen mainScreen].bounds.size.height;
            self.tableView.bounces=YES;
        }
        else
        {
            self.tableView.bounces=NO;
        }
        CGRect viewFrame=self.view.frame;
        viewFrame.size.height=height;
        self.view.frame=viewFrame;
        self.view.backgroundColor=[UIColor redColor];
    }
    [self.tableView reloadData];
}


-(BOOL)bd_dismissSemiViewTapOnBackground
{
    [self.bd_extPresentingSemiViewController bd_dismissSemiModalView];
    if (self.dismissBlock)
    {
        self.dismissBlock(nil, [NSIndexPath indexPathForRow:-1 inSection:-1]);
        self.dismissBlock = nil;
    }
    return YES;
}


-(NSMutableArray *)dataArray
{
    if(!_dataArray)
    {
        _dataArray=[NSMutableArray array];
    }
    return _dataArray;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section) {
        return 8.f;
    }
    return 0.f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataArray.count>indexPath.section)
    {
        ActionSheetItemGroup *group=[self.dataArray objectAtIndex:indexPath.section];
        if (group.count>indexPath.row)
        {
            ActionSheetItem *item=(ActionSheetItem *)[group objectInModelsAtIndex:indexPath.row];
            return item.height;
        }
    }
    return 47.0f;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataArray.count>section)
    {
        ActionSheetItemGroup *group=[self.dataArray objectAtIndex:section];
        return group.count;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BDActionSheetTableCell *cell=[tableView dequeueReusableCellWithIdentifier:[BDActionSheetTableCell description]];
    cell.userInteractionEnabled=YES;
    if (self.dataArray.count>indexPath.section)
    {
        ActionSheetItemGroup *group=[self.dataArray objectAtIndex:indexPath.section];
        if (group.count>indexPath.row)
        {
            ActionSheetItem *item=(ActionSheetItem *)[group objectInModelsAtIndex:indexPath.row];
            cell.userInteractionEnabled=!item.cannotTouch;
            [cell setActionSheetItem:item];
        }
        else
        {
            [cell setActionSheetItem:nil];
        }
    }
    else
    {
        [cell setActionSheetItem:nil];
    }
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataArray.count>indexPath.section)
    {
        ActionSheetItemGroup *group=[self.dataArray objectAtIndex:indexPath.section];
        if (group.count>indexPath.row)
        {
            ActionSheetItem *item=(ActionSheetItem *)[group objectInModelsAtIndex:indexPath.row];
            if (item.selectHandler!=nil)
            {
                item.selectHandler(item);
                self.dismissBlock = nil;
            }
            else if (self.dismissBlock)
            {
                self.dismissBlock(item, indexPath);
                self.dismissBlock = nil;
            }
        }
        else
        {
            if (self.dismissBlock)
            {
                self.dismissBlock(nil, indexPath);
                self.dismissBlock = nil;
            }
        }
    }
    else
    {
        if (self.dismissBlock)
        {
            self.dismissBlock(nil, indexPath);
            self.dismissBlock = nil;
        }
    }
    if ([self respondsToSelector:@selector(bd_extPresentingSemiViewController)])
    {
        [self.bd_extPresentingSemiViewController bd_dismissSemiModalView];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end





@implementation ActionSheetItem

-(id)initWithDict:(NSDictionary *)aDict
{
    if (self=[super init])
    {
        [self detailWithDict:aDict];
    }
    return self;
}
-(void)detailWithDict:(NSDictionary *)aDict
{
    self.title=[aDict objectForKey:kActionSheetTitle];
    self.iconImage=[aDict objectForKey:kActionSheetIconImage];
    self.isCancel=[[aDict objectForKey:kActionSheetIsCancel] boolValue];
    self.height=[[aDict objectForKey:kActionSheetHeight] floatValue];
    self.fontSize=[[aDict objectForKey:kActionSheetFontSize] integerValue]?:DefaultItemFontSize;
    self.textColor=[aDict objectForKey:kActionSheetTextColor]?:[UIColor grayColor];
}


@end

@implementation ActionSheetItemGroup

-(instancetype)init
{
    if (self=[super init])
    {
        self.models=[NSMutableArray array];
    }
    return self;
}
-(NSInteger)count
{
    return self.models.count;
}
-(id)initWithArray:(NSArray *)aArray
{
    if (self=[super init])
    {
        self.models=[self modelsWithArray:aArray];
    }
    return self;
}
-(NSMutableArray *)modelsWithArray:(NSArray *)aArray
{
    NSMutableArray *items=[NSMutableArray array];
    for (NSDictionary *dict in aArray)
    {
        ActionSheetItem *item=[[ActionSheetItem alloc]initWithDict:dict];
        [items addObject:item];
    }
    return items;
}
-(id)objectInModelsAtIndex:(NSUInteger)index
{
    if (index>=[self.models count])
    {
        return nil;
    }
    return [self.models objectAtIndex:index];
}
@end












