//
//  BDHomeListViewController.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/8.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDHomeListViewController.h"
#import "BDHomeModulePrefix.h"

@interface BDHomeListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSArray *dataArray;
@end

@implementation BDHomeListViewController

-(UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:[UITableViewCell description]];
        
    }
    return _tableView;
}
-(NSArray *)dataArray
{
    if(!_dataArray)
    {
        _dataArray=@[@"ShowSuccess",@"showAuto",@"showIconRemainTime",@"showLoad",@"showProgress"];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor purpleColor];
    
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.edges.equalTo(self.view);
    }];
    
    
    // Do any additional setup after loading the view.
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:[UITableViewCell description]];
    cell.textLabel.text=self.dataArray[indexPath.row];
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *rowString=self.dataArray[indexPath.row];
    if ([rowString isEqualToString:@"ShowSuccess"])
    {
        [MBProgressHUD showSuccess:@"成功" ToView:nil];
    }
    else if ([rowString isEqualToString:@"showAuto"])
    {
        [MBProgressHUD showAutoMessage:@"自动显示" ToView:self.view];
    }
    else if ([rowString isEqualToString:@"showIconRemainTime"])
    {
        [MBProgressHUD showIconMessage:@"保持消失" ToView:self.view RemainTime:5];
    }
    else if ([rowString isEqualToString:@"showLoad"])
    {
        [MBProgressHUD showLoadToView:self.view];
    }
    else if ([rowString isEqualToString:@"showProgress"])
    {
        [MBProgressHUD showProgressToView:self.view ToText:@"进度展示"];
    }
}




-(UIButton *)set_LeftButton
{
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"关闭" forState: UIControlStateNormal];
    btn.frame=CGRectMake(0, 0, 20, 20);
    btn.backgroundColor=[UIColor redColor];
    return btn;
}
-(void)left_Button_Event:(UIButton *)sender{
    NSLog(@"关闭当前页面");
    [self.navigationController popViewControllerAnimated:YES];
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