//
//  DrawView.m
//  DrawPen
//
//  Created by lingmin on 13-6-29.
//  Copyright (c) 2013年 lingmin. All rights reserved.
//

#import "DrawView.h"

@interface DrawView ()

@property (nonatomic, retain) NSMutableArray * mutableArray;
@property (nonatomic, retain) NSMutableArray * linesArray;
@property (nonatomic, retain) NSMutableArray * pointsArray;
@property (nonatomic, retain) NSMutableArray * colorsArray;
@property (nonatomic, retain) NSMutableArray * widthsArray;
@property (nonatomic, retain) UIColor        * lineColor;
@property (nonatomic, assign) CGFloat          lineWidth;

@end

@implementation DrawView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.pointsArray = [[NSMutableArray alloc]initWithCapacity:0];
    self.linesArray = [[NSMutableArray alloc] init];
    self.colorsArray = [[NSMutableArray alloc] init];
    self.widthsArray = [[NSMutableArray alloc] init];
    self.lineColor = [UIColor blackColor];
    self.lineWidth = 1.0;
}

#pragma mark - interface

- (UIColor *)LineColor:(CGFloat)r G:(CGFloat)g B:(CGFloat)b Alpha:(CGFloat)alpha
{
    self.lineColor = [UIColor colorWithRed:r green:g blue:b alpha:alpha];
    return self.lineColor;
}

- (CGFloat)LineWidth :(CGFloat) width{
    self.lineWidth = width;
    return self.lineWidth;
}

- (void)backToLastStep{
     NSInteger index = [self.linesArray count];
    if (index) {
        [self.linesArray removeObjectAtIndex:index-1];
        [self.widthsArray removeObjectAtIndex:index-1];
        [self.colorsArray removeObjectAtIndex:index-1];
        [self setNeedsDisplay];
    }
    
}

- (void)clearUp{
    NSInteger index = [self.linesArray count];
    if (index) {
        [self.linesArray removeAllObjects];
        [self.colorsArray removeAllObjects];
        [self.widthsArray removeAllObjects];
        [self setNeedsDisplay];
    }
}

#pragma mark - DrawView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSInteger linesCount = [self.linesArray count];
    if (linesCount) {
        for (NSInteger i = 0;i < linesCount;i++) {
            NSArray * array = [self.linesArray objectAtIndex:i];
            if ([array count]) {
                UIBezierPath * bezierPath = [UIBezierPath bezierPath];
                [bezierPath moveToPoint:CGPointFromString([array objectAtIndex:0])];
                for (NSString * pointString  in array) {
                    [bezierPath addLineToPoint:CGPointFromString(pointString)];
                }
                [bezierPath setLineWidth:[[self.widthsArray objectAtIndex:i] floatValue]];
                [[self.colorsArray objectAtIndex:i] setStroke];
                [bezierPath stroke];
                CGContextSaveGState(context);
                CGContextRestoreGState(context);
            }
        }
    }
    if ([self.pointsArray count]) {
        UIBezierPath * bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint:CGPointFromString([self.pointsArray objectAtIndex:0])];
        for (NSString * pointString in self.pointsArray) {
            CGPoint point = CGPointFromString(pointString);
            [bezierPath addLineToPoint:point];
        }
        [bezierPath setLineWidth:[[self.widthsArray lastObject] floatValue]];
        [[self.colorsArray lastObject] setStroke];
        [bezierPath stroke];
        CGContextSaveGState(context);
    }
}

#pragma mark - touchAction

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch * touch = [touches anyObject];
    CGPoint beginPoint = [touch locationInView:self];
    [self.colorsArray addObject:self.lineColor];
    [self.widthsArray addObject:[NSString stringWithFormat:@"%f",self.lineWidth]];
    [self.pointsArray addObject:NSStringFromCGPoint(beginPoint)];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [self.pointsArray addObject:NSStringFromCGPoint(point)];
    [self.linesArray addObject:self.pointsArray];
    self.pointsArray = [NSMutableArray arrayWithCapacity:0];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch * touch = [touches anyObject];
    CGPoint endPonit = [touch locationInView:self];
    [self.pointsArray addObject:NSStringFromCGPoint(endPonit)];
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
}

@end
