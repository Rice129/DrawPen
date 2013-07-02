//
//  WaterflowCell.h
//  BroBoard
//
//  Created by kinglonghuang on 6/2/12.
//
//  WaterflowView.h
//  BroBoard
//
//  Created by kinglonghuang on 6/2/12.
//
//

#import <UIKit/UIKit.h>

@interface WaterflowCell : UIView

@property (nonatomic, retain) id object;

- (void)prepareForReuse;

- (void)fillViewWithObject:(id)object;

+ (CGFloat)heightForViewWithObject:(id)object inColumnWidth:(CGFloat)columnWidth;

@end
