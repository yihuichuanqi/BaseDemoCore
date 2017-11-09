//
//  BDHomeViewController.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/7.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDHomeViewController.h"
#import "CTMediator+BDHomeModuleActions.h"

static NSString *kTosatView=@"Toast显示";
static NSString *kMBProgressView=@"MBProgress显示";

@interface BDHomeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray *dataArray;
@end

@implementation BDHomeViewController


-(UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource=self;
        _tableView.delegate=self;
        _tableView.tableFooterView=[[UIView alloc]init];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:[UITableViewCell description]];
    }
    return _tableView;
}
-(NSArray *)dataArray
{
    if (!_dataArray)
    {
        _dataArray=@[kTosatView,kMBProgressView,kTosatView,kTosatView,kTosatView,kTosatView,kTosatView,kTosatView,kTosatView,kTosatView,kTosatView];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor blueColor];

    //设置Toast不多次显示
    [CSToastManager setQueueEnabled:NO];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.edges.equalTo(self.view);
    }];
    
    
    // Do any additional setup after loading the view.
}

-(UIButton *)set_RightButton
{
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"下一页" forState:UIControlStateNormal];
    btn.backgroundColor=[UIColor redColor];
    [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
-(void)btnClicked:(UIButton *)button
{
    [MBProgressHUD hideHudForView:self.view];
//    UIViewController *viewController=[[CTMediator sharedInstance] CTMediator_Home_ViewControllerForHomeList:nil];
//    [self.navigationController pushViewController:viewController animated:YES];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:[UITableViewCell description]];
    
    NSString *cellString=[self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text=cellString;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellString=[self.dataArray objectAtIndex:indexPath.row];
    if ([cellString isEqualToString:kTosatView])
    {
        CSToastStyle *style=[[CSToastStyle alloc]initWithDefaultStyle];
        NSValue *pointValue=[NSValue valueWithCGPoint:CGPointMake(CGRectGetWidth(self.view.frame)/2,CGRectGetHeight(self.view.frame)-80)];
        [self.view makeToast:@"Toast显示详细信息" duration:2 position:pointValue title:nil image:nil style:style completion:^(BOOL didTap) {
           
        }];
    }
    else if ([cellString isEqualToString:kMBProgressView])
    {
        [MBProgressHUD showWarn:@"系统繁忙，请稍后重试" ToView:self.view];
//        [MBProgressHUD showProgressToView:self.view ToText:@"加载中..."];
//        [MBProgressHUD showLoadToView:self.tabBarController.view];
    }
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
