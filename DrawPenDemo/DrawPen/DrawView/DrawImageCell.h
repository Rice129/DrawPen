//
//  DrawImageCell.h
//  DrawPen
//
//  Created by damin ding on 13-7-2.
//  Copyright (c) 2013年 lingmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DrawImageCellDelegate ;

@interface DrawImageCell : UIView

@property (nonatomic, assign) NSInteger  index;
@property (nonatomic, assign) id <DrawImageCellDelegate> delegate;

- (void)setImage:(UIImage *)image;

@end

@protocol DrawImageCellDelegate <NSObject>

- (void)selectDrawCellDelegate:(NSInteger)index;

@end