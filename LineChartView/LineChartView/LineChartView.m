//
//  LineChartView.m
//  LeTuiWei
//
//  Created by 陈营超 on 2017/4/11.
//  Copyright © 2017年 陈营超. All rights reserved.
//

#import "LineChartView.h"


#define P_M(x,y) CGPointMake(x, y)

#define UIColorFromRGB(rgbValue)    [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UIColorFromAlphaRGB(rgbValue,a) \
[UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

#define FoldLineColor [UIColor colorWithRed:0 green:255 blue:254 alpha:1]

@interface LineChartView ()

@property (nonatomic, assign) CGFloat  xLength;

@property (nonatomic, assign) CGFloat  yLength;

@property (nonatomic, assign) CGFloat  perXLen ;

@property (nonatomic, assign) CGFloat  perYlen ;

@property (nonatomic,strong)  NSMutableArray * drawDataArr;

@property (nonatomic,strong)  CAShapeLayer *shapeLayer;

@property (nonatomic, assign)  BOOL isEndAnimation ;

@property (nonatomic, strong)  CAShapeLayer *markLayerX;

@property (nonatomic, strong)  CAShapeLayer *markLayerY;

@property (nonatomic, strong)  CAShapeLayer *littleRingLayer;

@property (nonatomic, assign)  CGFloat  maxValue ;

@property (nonatomic, assign)  CGFloat  maxYValue ;

@end

@implementation LineChartView

-(instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];//UIColorFromRGB(0x1c2249);

    }
    return self;
}


#pragma mark 开始绘图
-(void)showAnimation{
   
    [self configChartXAndYLength];//xy 长度
    [self configChartOrigin]; //坐标原点
    [self configPerXAndPerY];//xy间隔
    [self configValueDataArray]; //将数据转换为点坐标
    
}


#pragma mark  绘制xy轴
- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self drawXAndYLineWithContext:context];
    
    [self drawXYLineAtMaxPointWithDataArr:_drawDataArr WithContext:context];
}


#pragma mark  获取 坐标原点
- (void)configChartOrigin{

    self.chartOrigin = CGPointMake(self.contentInsets.left, self.frame.size.height-self.contentInsets.bottom);
    
}

#pragma mark  获取 xy的长度
- (void)configChartXAndYLength{
    _xLength = CGRectGetWidth(self.frame)-self.contentInsets.left-self.contentInsets.right;
    _yLength = CGRectGetHeight(self.frame)-self.contentInsets.top-self.contentInsets.bottom;
}

#pragma mark 获取xy上的间隔
- (void)configPerXAndPerY{
    _perXLen = _xLength/(_xLineDataArr.count-1);
    _perYlen = _yLength/_yLineDataArr.count;
}

#pragma mark  将坐标 转换为数据
-(void)ponitToData:(CGPoint) p{
    
    
    _maxYValue = [[_yLineDataArr valueForKeyPath:@"@max.floatValue"] floatValue];
    
    CGFloat x  =  p.x - self.contentInsets.left;
     CGFloat y = p.y - self.contentInsets.bottom;
    
    CGFloat kDate;
    CGFloat kMoney;
    
    kDate = (x / _xLength) * 24;
    kMoney = _maxYValue - (y / _yLength) * _maxYValue;
    
    NSString *dataStr = [NSString stringWithFormat:@"%.0f:00", round(kDate)];
    NSString *moneyStr = [NSString stringWithFormat:@"%.2f", roundf(kMoney*100)/100];
    self.didSelectPointBlock(dataStr, moneyStr);

}

#pragma mark  将数据 转换为坐标
- (void)configValueDataArray{
    
    _drawDataArr = [[NSMutableArray alloc] init];
   
        for (NSInteger i = 0; i<_valueArr.count; i++) {
            
            CGPoint p = P_M(i*_perXLen+self.chartOrigin.x,
                            
                            self.contentInsets.top + _yLength - [_valueArr[i] floatValue] / [_yLineDataArr.lastObject floatValue] * _yLength);
            
            NSValue *value = [NSValue valueWithCGPoint:p];
            [_drawDataArr addObject:value];
        }

    
    if (_drawDataArr.count==0) {
        return;
    }
    
//开始画折线
 [self drawPathWithDataArr:_drawDataArr andIndex:0];


}

#pragma mark  找到最高点 画十字线
- (void)drawXYLineAtMaxPointWithDataArr:(NSArray *)dataArr WithContext:(CGContextRef)contex {

    
    CGFloat markMaxL = CGFLOAT_MAX;
    CGFloat markMaxX = CGFLOAT_MAX;
    for (NSInteger i = 0; i<dataArr.count; i++) {
        
        NSValue *value = dataArr[i];
        CGPoint p = value.CGPointValue;
        
        if (p.y < markMaxL) {
            markMaxL = p.y;
            markMaxX = p.x;
        }

    }
    
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    // 起点
    [linePath moveToPoint:P_M(self.chartOrigin.x,markMaxL)];
    // 其它点
    [linePath addLineToPoint:P_M(self.contentInsets.left +_xLength, markMaxL)];

    
    _markLayerX = [CAShapeLayer layer];
    _markLayerX.path = linePath.CGPath;
    _markLayerX.strokeColor = UIColorFromRGB(0xff9900).CGColor;
    _markLayerX.lineWidth = 0.5;

    [self.layer addSublayer:_markLayerX];
 

    UIBezierPath *linePath1 = [UIBezierPath bezierPath];
    // 起点
    [linePath1 moveToPoint:P_M(markMaxX,self.chartOrigin.y)];
    // 其它点
    [linePath1 addLineToPoint:P_M(markMaxX, 10)];
    
    _markLayerY = [CAShapeLayer layer];
    _markLayerY.path = linePath1.CGPath;
    _markLayerY.strokeColor = UIColorFromRGB(0xff9900).CGColor;
    _markLayerY.lineWidth = 0.5;
    
    [self.layer addSublayer:_markLayerY];
    

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:P_M(markMaxX, markMaxL) radius:3 startAngle:0.0 endAngle:180.0 clockwise:YES];

    _littleRingLayer = [CAShapeLayer layer];
    _littleRingLayer.path = path.CGPath;
    _littleRingLayer.strokeColor = UIColorFromRGB(0xff9900).CGColor;
    _littleRingLayer.lineWidth = 0.5;
    _littleRingLayer.fillColor = [UIColor whiteColor].CGColor;
  
    [self.layer insertSublayer:_littleRingLayer above:_markLayerY];
        
    
}

#pragma mark 开始画图
- (void)drawPathWithDataArr:(NSArray *)dataArr andIndex:(NSInteger )colorIndex{
    
    
    UIBezierPath *firstPath = [UIBezierPath bezierPathWithOvalInRect:CGRectZero];
    UIBezierPath *secondPath = [UIBezierPath bezierPath];
    

    for (NSInteger i = 0; i<dataArr.count; i++) {

        NSValue *value = dataArr[i];
        CGPoint p = value.CGPointValue;
       
        if (i==0) {
            [secondPath moveToPoint:P_M(p.x, self.chartOrigin.y)];
            [secondPath addLineToPoint:p];
             [firstPath moveToPoint:p];
        } else {
            [firstPath addLineToPoint:p];
            [secondPath addLineToPoint:p];
        }
        
        if (i==dataArr.count-1) {
            
            [secondPath addLineToPoint:P_M(p.x, self.chartOrigin.y)];
            
        }
        
    }
    
  [secondPath closePath];
    //第二、UIBezierPath和CAShapeLayer关联
     
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.bounds;
    shapeLayer.path = firstPath.CGPath;
    UIColor *color = UIColorFromRGB(0x1aa5e5);
    shapeLayer.strokeColor = color.CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth = 0.5;
    
    //第三，动画
    
    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    
    ani.fromValue = @0;
    
    ani.toValue = @1;
    
    ani.duration = 0.5;
    
    [shapeLayer addAnimation:ani forKey:NSStringFromSelector(@selector(strokeEnd))];
    
    [self.layer addSublayer:shapeLayer];
    
    WS(weakSelf)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ani.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        CAShapeLayer *shaperLay = [CAShapeLayer layer];
        shaperLay.frame = weakSelf.bounds;
        shaperLay.path = secondPath.CGPath;
        shaperLay.fillColor = UIColorFromRGB(0x1b3fa6).CGColor;
        shaperLay.strokeColor = UIColorFromRGB(0x1b3fa6).CGColor;
        [weakSelf.layer addSublayer:shaperLay];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = weakSelf.bounds;
        gradientLayer.colors = @[(__bridge id)UIColorFromAlphaRGB(0x1b3fa6, 0.1).CGColor,
                                 (__bridge id)UIColorFromAlphaRGB(0x1b3fa6, 0.8).CGColor,
                                 (__bridge id)UIColorFromAlphaRGB(0x1b3fa6, 0.6).CGColor,
                                 (__bridge id)UIColorFromAlphaRGB(0x1b3fa6, 0.4).CGColor,
                                 (__bridge id)UIColorFromAlphaRGB(0x1b3fa6, 0.2).CGColor,
                                 (__bridge id)UIColorFromAlphaRGB(0x1b3fa6, 0.0).CGColor,
                                 ];
        
        gradientLayer.startPoint = CGPointMake(0,0);
        gradientLayer.endPoint = CGPointMake(1,1);
        
        [self.layer addSublayer:gradientLayer];
        
        gradientLayer.mask = shaperLay;
    });

    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {

    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint point = [touch locationInView:self]; //返回触摸点在视图中的当前坐标
    CGFloat touchX = point.x;
    CGFloat touchY = point.y;
    
    if (touchX < self.contentInsets.left || touchX > self.contentInsets.left + _xLength || touchY < self.contentInsets.top || touchY > self.contentInsets.top + _yLength) {
        return;
    }
    
    CGPoint intersectionPoint;
    
    for (NSInteger i = 0; i < _drawDataArr.count; i++) {
        if (i + 1 > _drawDataArr.count - 1) {  //5
            break;
        }

        NSValue *valueA = _drawDataArr[i];
        CGPoint A = valueA.CGPointValue;
        
        NSValue *valueB = _drawDataArr[i + 1];
        
        CGPoint B = valueB.CGPointValue;

        if (touchX < A.x  || touchX > B.x) {
            continue;
        }
        
        CGPoint p = [self twoLineWithFistLine:P_M(A.x, -A.y) :P_M(B.x, -B.y) withSecondLine:P_M(touchX, 0.0) :P_M(touchX, -1000.0)];

        intersectionPoint = P_M(p.x, - p.y);
        
    }
    
    [self ponitToData:CGPointMake(intersectionPoint.x, intersectionPoint.y)];
    
    //横线
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    
    [linePath moveToPoint:P_M(self.chartOrigin.x,intersectionPoint.y)];
    
    [linePath addLineToPoint:P_M(self.contentInsets.left +_xLength, intersectionPoint.y)];
    
    self.markLayerX.path = linePath.CGPath;
    UIBezierPath *linePath1 = [UIBezierPath bezierPath];
    
    [linePath1 moveToPoint:P_M(intersectionPoint.x ,self.chartOrigin.y)];
    
    [linePath1 addLineToPoint:P_M(intersectionPoint.x, 10)];
    self.markLayerY.path = linePath1.CGPath;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:P_M(intersectionPoint.x, intersectionPoint.y) radius:3 startAngle:0.0 endAngle:180.0 clockwise:YES];
    
    _littleRingLayer.path = path.CGPath;
        
    
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint point = [touch locationInView:self]; //返回触摸点在视图中的当前坐标
    CGFloat touchX = point.x;
    
    CGFloat touchY = point.y;
    
    if (touchX < self.contentInsets.left || touchX > self.contentInsets.left + _xLength || touchY < self.contentInsets.top || touchY > self.contentInsets.top + _yLength) {
        return;
    }
    
    CGPoint intersectionPoint;
    for (NSInteger i = 0; i < _drawDataArr.count; i++) {
     
        if (i + 1 > _drawDataArr.count - 1) {  //5
            break;
        }

        NSValue *valueA = _drawDataArr[i];//4
        CGPoint A = valueA.CGPointValue;
        
        NSValue *valueB = _drawDataArr[i + 1];//3
        
        CGPoint B = valueB.CGPointValue;
        //判处不在触摸点范围内的线段
        if (touchX < A.x  || touchX > B.x) {
            continue;
        }
        
        //AB 为数组中取得的线段
        //获得交点
     CGPoint p = [self twoLineWithFistLine:P_M(A.x, -A.y) :P_M(B.x, -B.y) withSecondLine:P_M(touchX, 0.0) :P_M(touchX, -1000.0)];
  
        intersectionPoint = P_M(p.x, - p.y);
        
    }
    
    [self ponitToData:CGPointMake(intersectionPoint.x, intersectionPoint.y)];
    
    //横线
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    
    [linePath moveToPoint:P_M(self.chartOrigin.x,intersectionPoint.y)];
    
    [linePath addLineToPoint:P_M(self.contentInsets.left +_xLength, intersectionPoint.y)];
    
    self.markLayerX.path = linePath.CGPath;
    
    
    UIBezierPath *linePath1 = [UIBezierPath bezierPath];
    
    [linePath1 moveToPoint:P_M(intersectionPoint.x ,self.chartOrigin.y)];
    
    [linePath1 addLineToPoint:P_M(intersectionPoint.x, 10)];
    self.markLayerY.path = linePath1.CGPath;
    

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:P_M(intersectionPoint.x, intersectionPoint.y) radius:3 startAngle:0.0 endAngle:180.0 clockwise:YES];

    _littleRingLayer.path = path.CGPath;
}


- (CGPoint)twoLineWithFistLine:(CGPoint)a :(CGPoint)b withSecondLine:(CGPoint)c :(CGPoint)d {
    CGFloat x1 = a.x, y1 = a.y, x2 = b.x, y2 = b.y;
    
    CGFloat x3 = c.x, y3 = c.y, x4 = d.x, y4 = d.y;
    CGFloat x = ((x1 - x2) * (x3 * y4 - x4 * y3) - (x3 - x4) * (x1 * y2 - x2 * y1))
    / ((x3 - x4) * (y1 - y2) - (x1 - x2) * (y3 - y4));
    
    CGFloat y = ((y1 - y2) * (x3 * y4 - x4 * y3) - (x1 * y2 - x2 * y1) * (y3 - y4))
    / ((y1 - y2) * (x3 - x4) - (x1 - x2) * (y3 - y4));
    
    return P_M(x, y);
}

#pragma mark  绘制xy轴 方法
- (void)drawXAndYLineWithContext:(CGContextRef)context{
    
    //x 轴
    [self drawLineWithContext:context andStarPoint:self.chartOrigin andEndPoint:P_M(self.contentInsets.left +_xLength, self.chartOrigin.y) andIsDottedLine:NO andColor:UIColorFromRGB(0x313d80)];

    if (_showYLine) {
        //Y轴
        [self drawLineWithContext:context andStarPoint:self.chartOrigin andEndPoint:P_M(self.chartOrigin.x,self.chartOrigin.y-_yLength) andIsDottedLine:NO andColor:[UIColor blackColor]];
    }
    
    if (_xLineDataArr.count>0) {
        CGFloat xPace = _perXLen;
        
        for (NSInteger i = 0; i<_xLineDataArr.count;i++ ) {
            CGPoint p = P_M(i*xPace+self.chartOrigin.x, self.chartOrigin.y);
            CGFloat len = [self sizeOfStringWithMaxSize:CGSizeMake(CGFLOAT_MAX, 30) textFont:10 aimString:_xLineDataArr[i]].width;


            [self drawText:[NSString stringWithFormat:@"%@",_xLineDataArr[i]] andContext:context atPoint:P_M(p.x-len/2, p.y+2) WithColor:[UIColor blackColor] andFontSize:10];
            
        }
        
        
        
    }
    
    if (_yLineDataArr.count>0) {
        CGFloat yPace = _perYlen;
        for (NSInteger i = 0; i<_yLineDataArr.count; i++) {
            CGPoint p = P_M(self.chartOrigin.x, self.chartOrigin.y - (i+1)*yPace);
            
            CGFloat len = [self sizeOfStringWithMaxSize:CGSizeMake(CGFLOAT_MAX, 30) textFont:10 aimString:_yLineDataArr[i]].width;
            CGFloat hei = [self sizeOfStringWithMaxSize:CGSizeMake(CGFLOAT_MAX, 30) textFont:10 aimString:_yLineDataArr[i]].height;
           
            
           
            if (_showYLevelLine) {
                [self drawLineWithContext:context andStarPoint:p andEndPoint:P_M(self.contentInsets.left+_xLength, p.y) andIsDottedLine:NO andColor:[UIColor blackColor]];
            
                
            }else{
                [self drawLineWithContext:context andStarPoint:p andEndPoint:P_M(p.x+3, p.y) andIsDottedLine:NO andColor:[UIColor blackColor]];
            }
            
            
                      [self drawText:[NSString stringWithFormat:@"%@",_yLineDataArr[i]] andContext:context atPoint:P_M(p.x-len-3, p.y-hei / 2) WithColor:[UIColor blackColor] andFontSize:10];
        }
    }

    
}

#pragma mark 返回字符串尺寸
- (CGSize)sizeOfStringWithMaxSize:(CGSize)maxSize textFont:(CGFloat)fontSize aimString:(NSString *)aimString{
    
    
    return [[NSString stringWithFormat:@"%@",aimString] boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil].size;
    
}



/**
 *  绘制线段
 *
 *  @param context  图形绘制上下文
 *  @param start    起点
 *  @param end      终点
 *  @param isDotted 是否是虚线
 *  @param color    线段颜色
 */
- (void)drawLineWithContext:(CGContextRef )context andStarPoint:(CGPoint )start andEndPoint:(CGPoint)end andIsDottedLine:(BOOL)isDotted andColor:(UIColor *)color{


    //    移动到点
    CGContextMoveToPoint(context, start.x, start.y);
    //    连接到
    CGContextAddLineToPoint(context, end.x, end.y);
    
    
    CGContextSetLineWidth(context, 0.5);
    
    
    [color setStroke];
    
    if (isDotted) {
        CGFloat ss[] = {1.5,2};
        
        CGContextSetLineDash(context, 0, ss, 2);
        
    } else {
        CGFloat ss[] = {1.5,0};
        
        CGContextSetLineDash(context, 0, ss, 2);
    
    }
    CGContextMoveToPoint(context, end.x, end.y);
    
    CGContextDrawPath(context, kCGPathFillStroke);
}

/**
 *  绘制文字
 *
 *  @param text    文字内容
 *  @param context 图形绘制上下文
 *  @param rect    绘制点
 *  @param color   绘制颜色
 */
- (void)drawText:(NSString *)text andContext:(CGContextRef )context atPoint:(CGPoint )rect WithColor:(UIColor *)color andFontSize:(CGFloat)fontSize{
    
    [[NSString stringWithFormat:@"%@",text] drawAtPoint:rect withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize],NSForegroundColorAttributeName:color}];
    
    [color setFill];
    
    CGContextDrawPath(context, kCGPathFill);
    
}

@end
