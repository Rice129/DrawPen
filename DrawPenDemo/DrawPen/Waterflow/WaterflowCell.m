//
//  WaterflowCell.m
//  BroBoard
//
//  Created by kinglonghuang on 6/2/12.
//
//

#import "WaterflowCell.h"

@interface WaterflowCell ()

@end

@implementation WaterflowCell

@synthesize     object = _object;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    self.object = nil;
    [super dealloc];
}

- (void)prepareForReuse {
    for (UIView * subView in self.subviews) {
        [subView removeFromSuperview];
    }
}

- (void)fillViewWithObject:(id)object {
    self.object = object;
}

+ (CGFloat)heightForViewWithObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    return 0.0;
}

@end
