//
//  BDOrderViewController.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/7.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDOrderViewController.h"

@interface BDOrderViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@end

@implementation BDOrderViewController

-(UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        _tableView.tableFooterView=[[UIView alloc]init];
    }
    return _tableView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor purpleColor];
    
    self.dataArray=[[NSMutableArray alloc]init];
    [self.view addSubview:self.tableView];
    
    
    // Do any additional setup after loading the view.
}
#pragma mark-Table
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:[UITableViewCell description]];
    cell.textLabel.text=@"订单ID";
    return cell;
}


-(NSMutableAttributedString *)setTitle
{
    return [[NSMutableAttributedString alloc]initWithString:@"订单"];
}

-(UIButton *)set_RightButton
{
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@".." forState:UIControlStateNormal];
    btn.frame=CGRectMake(0, 0, 10, 10);
    btn.backgroundColor=[UIColor redColor];
    return btn;
}

-(void)right_Button_Event:(UIButton *)sender
{
    NSLog(@"%@ 订单",[self class]);
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
