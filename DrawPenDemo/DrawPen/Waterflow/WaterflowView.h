//
//  WaterflowView.h
//  BroBoard
//
//  Created by kinglonghuang on 6/2/12.
//
//

#import <UIKit/UIKit.h>
#import "WaterflowRefreshHeaderView.h"
#import "WaterflowRefreshFooterView.h"

@class WaterflowCell;

@protocol WaterflowViewDelegate, WaterflowViewDataSource;

@interface WaterflowView : UIScrollView <WaterflowRefreshHeaderDelegate,UIScrollViewDelegate>{}

@property (nonatomic, assign) NSInteger                     pageCount;

@property (nonatomic, assign) NSInteger                     currentPage;

@property (nonatomic, retain) WaterflowRefreshHeaderView    * refreshView;

@property (nonatomic, retain) UIView                        * headerView;

@property (nonatomic, retain) WaterflowRefreshFooterView    * footerView;

@property (nonatomic, assign) BOOL                          shouldDragUpdate;

@property (nonatomic, assign, readonly) CGFloat             columnWidth;

@property (nonatomic, assign, readonly) NSInteger           numOfColumns;

@property (nonatomic, assign) NSInteger                     numOfColInLandscape;

@property (nonatomic, assign) NSInteger                     numOfColInPortrait;

@property (nonatomic, assign) id <WaterflowViewDelegate>    flowDelegate;

@property (nonatomic, assign) id <WaterflowViewDataSource>  flowDataSource;

@property (nonatomic, assign) CGFloat                     leftMargin;

- (void)reloadData;

- (UIView *)dequeueReusableView;

@end

#pragma mark - Delegate

@protocol WaterflowViewDelegate <NSObject>

@optional

- (void)waterflowView:(WaterflowView *)flowView didSelectCell:(WaterflowCell *)cell atIndex:(NSInteger)index;

- (void)waterflowViewAskToReloadDataSource:(WaterflowView*)flowView;

- (void)waterflowViewAskToLoadNextPage:(WaterflowView*)flowView;

- (NSDate *)waterflowViewLastUpdateDate:(WaterflowView*)flowView;

@end

@protocol WaterflowViewDataSource <NSObject>

@required

- (NSInteger)numberOfViewsPerPage:(WaterflowView *)flowView;

- (NSInteger)numberOfViewsInWaterflowView:(WaterflowView *)flowView;

- (WaterflowCell *)waterflowView:(WaterflowView *)flowView cellAtIndex:(NSInteger)index;

- (CGFloat)heightForCellAtIndex:(NSInteger)index;

@end



