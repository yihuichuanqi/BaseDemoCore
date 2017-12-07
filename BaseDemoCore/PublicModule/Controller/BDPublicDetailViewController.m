//
//  BDPublicDetailViewController.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/8.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDPublicDetailViewController.h"
#import "BDInputTableViewCell.h"
#import "BDPublicModulePrefix.h"

@interface BDPublicDetailViewController ()<UITableViewDataSource,UITableViewDelegate,BDInputTableViewCellDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation BDPublicDetailViewController

-(UITableView *)tableView
{
    if(!_tableView){
        _tableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate=self;
        _tableView.showsVerticalScrollIndicator=YES;
        _tableView.dataSource=self;
        [_tableView registerClass:[BDInputTableViewCell class] forCellReuseIdentifier:[BDInputTableViewCell description]];
    }
    return _tableView;
}

-(NSMutableArray *)dataArray
{
    if(!_dataArray)
    {
        _dataArray=[NSMutableArray array];
        
        NSString *placeHolders[6]={
            @"输入姓名",
            @"输入身份",
            @"输入卡号",
            @"输入地址",
            @"输入密码",
            @"输入金额",
        };
        NSString *titles[6]={
            @"姓名",
            @"身份整",
            @"卡号",
            @"地址",
            @"密码",
            @"金额",
        };
        NSString *events[6]={
            @"cell.type.name",
            @"cell.type.id",
            @"cell.type.card.no",
            @"cell.type.address",
            @"cell.type.pwd",
            @"cell.type.amount",
        };
        NSString *texts[6]={
            @"",
            @"",
            @"",
            @"",
            @"",
            @"",
        };
        NSString *icons[6]={
            @"",
            @"uid_icom",
            @"",
            @"",
            @"pw_icon",
            @"pw_icon",
        };
        
        for (NSInteger i=0; i<6; i++)
        {
            BDInputModel *model=[[BDInputModel alloc]init];
            model.placeHolder=placeHolders[i];
            model.title=titles[i];
            model.text=texts[i];
            model.cellEvent=events[i];
            model.iconName=icons[i];
            model.textColor=[UIColor redColor];
            
//            model.clickEnabled=(i==0);
            model.alignmentBothEnds=(i==1);
            model.cellccessoryView=(i==3)?[self accessoryView]:nil;
            model.accessoryType=(i==3)?UITableViewCellAccessoryDetailButton:UITableViewCellAccessoryNone;
            model.keyBoardType=(i==2||i==5)?UIKeyboardTypeDecimalPad:UIKeyboardTypeDefault;
            
            model.titleMaxWidth=70;
            model.secureTextEntry=(i==4);
            model.inputAlignment=(i==3)?NSTextAlignmentRight:NSTextAlignmentLeft;
            [_dataArray addObject:model];
        }
        
    }
    return _dataArray;
}

-(UIView *)accessoryView
{
    UIView *v=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    v.backgroundColor=[UIColor redColor];
    return v;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BDInputTableViewCell *cell=[BDInputTableViewCell bd_InitInputTabelViewCellWithTableView:tableView identifier:NSStringFromClass([self class]) delegate:self];
    [cell setObject:self.dataArray[indexPath.row]];
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma mark-CellDelegate
-(void)bd_InputTableViewCell:(BDInputTableViewCell *)cell DidSelectEvent:(NSString *)event
{
    if([cell.event isEqualToString:@"cell.type.address"])
    {
        NSLog(@"地址想");
    }
    else
    {
        NSLog(@"其他");
    }

}
-(void)bd_InputTableViewCell:(BDInputTableViewCell *)cell textFieldEditingChanged:(NSString *)value
{
    if([cell.event isEqualToString:@"cell.type.id"])
    {
        NSLog(@"身份：%@",value);
    }
    else
    {
        NSLog(@"其他");
    }
}

-(BOOL)bd_InputTableViewCell:(BDInputTableViewCell *)cell textFieldShouldChangeCharacterInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL result=YES;
    if([cell.event isEqualToString:@"cell.type.id"])
    {
        result=[cell bd_InputLimitLength:18 allowString:nil inputCharacter:string];
    }
    else if ([cell.event isEqualToString:@"cell.type.amount"])
    {
        result=[cell bd_AmountFormatWithInterBitLength:8 digitsLength:2 inputCharacter:string];
    }
    
    return result;
}


-(void)readAllData
{
    NSLog(@"获取所有数据");
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor groupTableViewBackgroundColor];
    
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
         UIEdgeInsets edges=UIEdgeInsetsMake(0, 0, 0, 0);
         make.edges.mas_equalTo(edges);
         
     }];
    
    
    
    
    
    
    
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
