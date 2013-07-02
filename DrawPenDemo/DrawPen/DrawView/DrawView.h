//
//  DrawView.h
//  DrawPen
//
//  Created by lingmin on 13-6-29.
//  Copyright (c) 2013年 lingmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawView : UIView

- (UIColor *)LineColor:(CGFloat)r G:(CGFloat)g B:(CGFloat)b Alpha:(CGFloat)alpha;
- (CGFloat)LineWidth :(CGFloat) width;
- (void)backToLastStep;
- (void)clearUp;

@end
