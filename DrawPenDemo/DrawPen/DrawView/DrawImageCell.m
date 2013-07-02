//
//  DrawImageCell.m
//  DrawPen
//
//  Created by damin ding on 13-7-2.
//  Copyright (c) 2013年 lingmin. All rights reserved.
//

#import "DrawImageCell.h"

@interface DrawImageCell ()

@property (nonatomic, retain) IBOutlet UIImageView * imageView;

@end

@implementation DrawImageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self.imageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer * tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectDrawCell)];
    [self.imageView addGestureRecognizer:tapGR];
}

- (void)setImage:(UIImage *)image
{
    [self.imageView setImage:image];
}

- (void)selectDrawCell{
    if (_delegate && [_delegate respondsToSelector:@selector(selectDrawCellDelegate:)]) {
        [self.delegate selectDrawCellDelegate:_index];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
