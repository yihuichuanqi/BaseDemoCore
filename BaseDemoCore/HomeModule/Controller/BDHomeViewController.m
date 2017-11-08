//
//  BDHomeViewController.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/7.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDHomeViewController.h"
#import "CTMediator+BDHomeModuleActions.h"

@interface BDHomeViewController ()

@end

@implementation BDHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor blueColor];
    
    
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"下一页" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor=[UIColor yellowColor];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.view).with.offset(74);
        make.centerX.equalTo(self.view);
        
    }];

    
    
    // Do any additional setup after loading the view.
}



-(void)btnClicked:(UIButton *)button
{
    UIViewController *viewController=[[CTMediator sharedInstance] CTMediator_Home_ViewControllerForHomeList:nil];
    [self.navigationController pushViewController:viewController animated:YES];
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
