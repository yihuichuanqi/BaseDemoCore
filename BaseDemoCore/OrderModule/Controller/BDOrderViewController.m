//
//  BDOrderViewController.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/7.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDOrderViewController.h"

@interface BDOrderViewController ()

@end

@implementation BDOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor purpleColor];
    
    
    
    // Do any additional setup after loading the view.
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
