//
//  ViewController.m
//  LineChartView
//
//  Created by 陈营超 on 2017/5/3.
//  Copyright © 2017年 陈营超. All rights reserved.
//

#import "ViewController.h"
#import "LineChartView.h"
#import "Masonry.h"



#define kScreenHeight                   [UIScreen mainScreen].bounds.size.height

#define kScreenWidth                    [UIScreen mainScreen].bounds.size.width

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 50)];
    [self.view addSubview:dateLabel];
    dateLabel.font = [UIFont systemFontOfSize:14];
    dateLabel.text = @"时间:";
    
    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 100, 100, 50)];
    [self.view addSubview:moneyLabel];
    moneyLabel.font = [UIFont systemFontOfSize:14];
    moneyLabel.text = @"金额:";
    
    LineChartView *lineChart = [[LineChartView alloc] initWithFrame:CGRectMake(0, 200, kScreenWidth, 135)];
    lineChart.contentInsets = UIEdgeInsetsMake(20,50, 20, 50);
    lineChart.xLineDataArr = @[@"0:00",@"4:00",@"8:00",@"12:00",@"16:00",@"20:00",@"24:00"];
    lineChart.valueArr = @[@1000,@3000,@7000,@1000,@5000,@10000,@4000];
    lineChart.yLineDataArr = @[@2500,@5000,@7500,@10000];
    lineChart.showYLine = NO;
    lineChart.showYLevelLine = YES;
    [lineChart showAnimation];
    [self.view addSubview:lineChart];
    lineChart.didSelectPointBlock = ^(NSString *dateStr, NSString *moneyStr){
        
        NSLog(@"%@  %@", dateStr , moneyStr);
        dateLabel.text = [NSString stringWithFormat:@"时间：%@", dateStr];
        moneyLabel.text = [NSString stringWithFormat:@"金额：%@", moneyStr];
        
    };
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
