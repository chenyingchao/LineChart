//
//  LineChartView.h
//  LeTuiWei
//
//  Created by 陈营超 on 2017/4/11.
//  Copyright © 2017年 陈营超. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WS(weakSelf)                __weak __typeof(&*self)weakSelf = self;

typedef NS_ENUM(NSUInteger, LineChartViewType) {
    LineChartViewType24Hours = 0,
    LineChartViewTypeDays,

};


@interface LineChartView : UIView

@property (nonatomic, copy) void (^didSelectPointBlock)(NSString *dateStr, NSString *moneyStr);

@property (nonatomic, assign) LineChartViewType lineChartViewType;


@property (nonatomic, copy) NSString *checkInDateStr;

@property (nonatomic, copy) NSString *checkOutDateStr;



@property (nonatomic, strong) UIColor *gradientColor;


@property (nonatomic, strong) NSArray * valueArr;

@property (nonatomic, assign) UIEdgeInsets contentInsets;


@property (assign, nonatomic)  CGPoint chartOrigin;


@property (nonatomic, strong) NSArray * xLineDataArr;


@property (nonatomic, strong) NSArray * yLineDataArr;



@property (nonatomic,assign) BOOL showYLine;


@property (nonatomic,assign) BOOL showYLevelLine;


@property (nonatomic, strong) NSArray * valueLineColorArr;

-(void)showAnimation;

@end
