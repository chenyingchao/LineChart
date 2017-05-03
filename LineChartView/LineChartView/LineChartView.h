//
//  LineChartView.h
//  LeTuiWei
//
//  Created by 陈营超 on 2017/4/11.
//  Copyright © 2017年 陈营超. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LineChartViewType) {
    LineChartViewType24Hours = 0,
    LineChartViewTypeDays,

};


@interface LineChartView : UIView

@property (nonatomic, copy) void (^didSelectPointBlock)(NSString *dateStr, NSString *moneyStr);


@property (nonatomic, assign) LineChartViewType lineChartViewType;

@property (nonatomic, assign) BOOL isDataChartView;

@property (nonatomic, copy) NSString *checkInDateStr;

@property (nonatomic, copy) NSString *checkOutDateStr;


@property (nonatomic, strong) UIColor *xTextColor;

@property (nonatomic, strong) UIColor *yTextColor;

@property (nonatomic, strong) UIColor *yLineColor;

@property (nonatomic, strong) UIColor *gradientColor;

/**
 *  An array of values that are about to be drawn.
 */
@property (nonatomic, strong) NSArray * valueArr;
/**
 *  The margin value of the content view chart view
 *  图表的边界值
 */
@property (nonatomic, assign) UIEdgeInsets contentInsets;

/**
 *  The origin of the chart is different from the meaning of the origin of the chart.
 As a pie chart and graph center ring. The line graph represents the origin.
 *  图表的原点值（如果需要）
 */
@property (assign, nonatomic)  CGPoint chartOrigin;


/**
 *  X axis scale data of a broken line graph, the proposed use of NSNumber or the number of strings
 */
@property (nonatomic, strong) NSArray * xLineDataArr;


/**
 *  Y axis scale data of a broken line graph, the proposed use of NSNumber or the number of strings
 */
@property (nonatomic, strong) NSArray * yLineDataArr;



@property (nonatomic,assign) BOOL showYLine;


/**
 *  whether this chart shows the Y level lines or not.Default is NO
 */
@property (nonatomic,assign) BOOL showYLevelLine;


@property (nonatomic, strong) NSArray * valueLineColorArr;

-(void)showAnimation;

@end
