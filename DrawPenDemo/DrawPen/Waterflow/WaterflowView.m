//
//  WaterflowView.m
//  BroBoard
//
//  Created by kinglonghuang on 6/2/12.
//
//
#import "WaterflowRefreshFooterView.h"
#import "WaterflowView.h"
#import "WaterflowCell.h"

#define kMargin                 8.0

static inline NSString * PSCollectionKeyForIndex(NSInteger index) {
    return [NSString stringWithFormat:@"%d", index];
}

static inline NSInteger PSCollectionIndexForKey(NSString *key) {
    return [key integerValue];
}

#pragma mark - UIView Category

@interface UIView (WaterflowView)

@property(nonatomic) CGFloat left;
@property(nonatomic) CGFloat top;
@property(nonatomic, readonly) CGFloat right;
@property(nonatomic, readonly) CGFloat bottom;
@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;

@end

@implementation UIView (WaterflowView)

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

@end

@interface WaterflowView () <UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL              isRefreshing;
@property (nonatomic, assign) BOOL              isLoadingMore;

@property (nonatomic, assign, readwrite) CGFloat columnWidth;
@property (nonatomic, assign, readwrite) NSInteger numOfColumns;
@property (nonatomic, assign) UIInterfaceOrientation orientation;

@property (nonatomic, retain) NSMutableSet *reuseableViews;
@property (nonatomic, retain) NSMutableDictionary *visibleViews;
@property (nonatomic, retain) NSMutableArray *viewKeysToRemove;
@property (nonatomic, retain) NSMutableDictionary *indexToRectMap;

- (void)relayoutViews;

- (void)enqueueReusableView:(WaterflowCell *)view;

- (void)removeAndAddCellsIfNecessary;

@end

@implementation WaterflowView

// Public Views
@synthesize refreshView             = _refreshView;
@synthesize headerView              = _headerView;
@synthesize footerView              = _footerView;
@synthesize isRefreshing            = _isRefreshing;
@synthesize isLoadingMore           = _isLoadingMore;
@synthesize currentPage             = _currentPage;
@synthesize shouldDragUpdate        = _shouldDragUpdate;
@synthesize columnWidth             = _columnWidth;
@synthesize numOfColumns            = _numOfColumns;
@synthesize numOfColInLandscape     = _numOfColInLandscape;
@synthesize numOfColInPortrait      = _numOfColInPortrait;
@synthesize flowDelegate            = _flowDelegate;
@synthesize flowDataSource          = _flowDataSource;

@synthesize orientation             = _orientation;
@synthesize reuseableViews          = _reuseableViews;
@synthesize visibleViews            = _visibleViews;
@synthesize viewKeysToRemove        = _viewKeysToRemove;
@synthesize indexToRectMap          = _indexToRectMap;

@synthesize leftMargin              = _leftMargin;

#pragma mark - Private

- (BOOL)shouldShowFooterView {
    if (self.currentPage >= (self.pageCount-1)) {
        return NO;
    }
    return YES;
}

#pragma mark - LifeCycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.alwaysBounceVertical = YES;
        self.delegate = self;
        self.shouldDragUpdate = YES;
        self.columnWidth = 0.0;
        self.numOfColumns = 0;
        self.numOfColInPortrait = 2;
        self.numOfColInLandscape = 0;
        self.leftMargin = -1.0f;
        self.orientation = [UIApplication sharedApplication].statusBarOrientation;
        
        self.reuseableViews = [NSMutableSet set];
        self.visibleViews = [NSMutableDictionary dictionary];
        self.viewKeysToRemove = [NSMutableArray array];
        self.indexToRectMap = [NSMutableDictionary dictionary];
        
        self.refreshView = [[[WaterflowRefreshHeaderView alloc] initWithFrame:CGRectMake((self.frame.size.width-REFRESHINGVIEW_WIDTH)/2.0,  -REFRESHINGVIEW_HEIGHT, REFRESHINGVIEW_WIDTH,REFRESHINGVIEW_HEIGHT)] autorelease];
        self.refreshView.delegate = self;
        self.footerView = [[[WaterflowRefreshFooterView alloc] initWithFrame:CGRectMake((self.frame.size.width-FOOTERVIEW_WIDTH)/2.0,  0, FOOTERVIEW_WIDTH,FOOTERVIEW_HEIGHT)] autorelease];
        self.footerView.delegate = self;
        self.footerView.alpha = .0;
        [self addSubview:self.refreshView];
        [self addSubview:self.footerView];
        self.isLoadingMore = NO;
        self.isRefreshing = NO;
        self.currentPage = 0;
    }
    return self;
}

- (void)dealloc {
    // clear flowDelegates
    self.refreshView.delegate = nil;
    self.footerView.delegate = nil;
    self.flowDelegate = nil;
    self.flowDataSource = nil;
    self.flowDelegate = nil;
    
    // release retains
    self.refreshView = nil;
    self.headerView = nil;
    self.footerView = nil;
    
    self.reuseableViews = nil;
    self.visibleViews = nil;
    self.viewKeysToRemove = nil;
    self.indexToRectMap = nil;
    [super dealloc];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y <= 0) {
        if (self.shouldDragUpdate) {
            [self.refreshView waterflowRefreshScrollViewDidScroll:scrollView];
        }else {
            scrollView.contentOffset = CGPointMake(0, 0);
        }
    }else if (scrollView.contentOffset.y > 0) {
        if ([self shouldShowFooterView]) {
            [self.footerView waterflowRefreshScrollViewDidScroll:scrollView];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.shouldDragUpdate) {
        [self.refreshView waterflowRefreshScrollViewDidEndDragging:scrollView];
    }
    
    if ([self shouldShowFooterView]) {
        [self.footerView waterflowRefreshScrollViewDidEndDragging:scrollView];
    }
}

#pragma mark - WaterflowRefreshHeaderDelegate

- (void)waterfolwRefreshTableHeaderDidTriggerRefresh:(WaterflowRefreshHeaderView*)view {
    self.isRefreshing = YES;
    self.currentPage = 0;
    if ([_flowDelegate respondsToSelector:@selector(waterflowViewAskToReloadDataSource:)]) {
        [_flowDelegate waterflowViewAskToReloadDataSource:self];
    }
}

- (BOOL)waterflowRefreshTableHeaderDataSourceIsLoading:(WaterflowRefreshHeaderView*)view {
    return self.isRefreshing;
}

- (NSDate*)waterfolwRefreshTableHeaderDataSourceLastUpdated:(WaterflowRefreshHeaderView*)view {
    if ([_flowDelegate respondsToSelector:@selector(waterflowViewLastUpdateDate:)]) {
        return [_flowDelegate waterflowViewLastUpdateDate:self];
    }
    return [NSDate date];
}

#pragma mark - WaterflowRefreshFooterDelegate

- (void)waterfolwRefreshTableFooterDidTriggerRefresh:(WaterflowRefreshFooterView*)view {
    self.isLoadingMore = YES;
    self.currentPage ++;
    if (_flowDelegate && [_flowDelegate respondsToSelector:@selector(waterflowViewAskToLoadNextPage:)]) {
        [_flowDelegate waterflowViewAskToLoadNextPage:self];
    }
}

- (BOOL)waterflowRefreshTableFooterDataSourceIsLoading:(WaterflowRefreshFooterView*)view {
    return self.isLoadingMore;
}

- (NSDate*)waterfolwRefreshTableFooterDataSourceLastUpdated:(WaterflowRefreshFooterView*)view {
    if ([_flowDelegate respondsToSelector:@selector(waterflowViewLastUpdateDate:)]) {
        return [_flowDelegate waterflowViewLastUpdateDate:self];
    }
    return [NSDate date];
}

#pragma mark - flowDataSource

- (void)reloadData {
    [self relayoutViews];
}

#pragma mark - View

- (void)layoutSubviews {
    [super layoutSubviews];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (self.orientation != orientation) {
        self.orientation = orientation;
        [self relayoutViews];
    } else {
        [self removeAndAddCellsIfNecessary];
    }
}

- (void)relayoutViews {
    self.numOfColumns = UIInterfaceOrientationIsPortrait(self.orientation) ? self.numOfColInPortrait : self.numOfColInLandscape;
    
    // Reset all state
    [self.visibleViews enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        WaterflowCell *view = (WaterflowCell *)obj;
        [self enqueueReusableView:view];
    }];
    [self.visibleViews removeAllObjects];
    [self.viewKeysToRemove removeAllObjects];
    [self.indexToRectMap removeAllObjects];
    
    // This is where we should layout the entire grid first
    NSInteger numViews = [self.flowDataSource numberOfViewsInWaterflowView:self];
    NSInteger numOfViewPerPage = [self.flowDataSource numberOfViewsPerPage:self];
    NSInteger viewCountOfShouldBeLoad = numOfViewPerPage * (self.currentPage+1);
    viewCountOfShouldBeLoad = MIN(viewCountOfShouldBeLoad, numViews);
    
    CGFloat totalHeight = 0.0;
    CGFloat top = kMargin;
    
    // Add headerView if it exists
    if (self.headerView) {
        self.headerView.top = kMargin;
        top = self.headerView.top;
        [self addSubview:self.headerView];
        top += self.headerView.height;
        top += kMargin;
    }
    
    if (viewCountOfShouldBeLoad > 0) {
        // This array determines the last height offset on a column
        NSMutableArray *colOffsets = [NSMutableArray arrayWithCapacity:self.numOfColumns];
        for (int i = 0; i < self.numOfColumns; i++) {
            [colOffsets addObject:[NSNumber numberWithFloat:top]];
        }
        
        // Calculate index to rect mapping
        self.columnWidth = floorf((self.width - (self.leftMargin>=0.0f? self.leftMargin:kMargin) * (self.numOfColumns + 1)) / self.numOfColumns);
        for (NSInteger i = 0; i < viewCountOfShouldBeLoad; i++) {
            NSString *key = PSCollectionKeyForIndex(i);
            
            // Find the shortest column
            NSInteger col = 0;
            CGFloat minHeight = [[colOffsets objectAtIndex:col] floatValue];
            for (int i = 1; i < [colOffsets count]; i++) {
                CGFloat colHeight = [[colOffsets objectAtIndex:i] floatValue];
                
                if (colHeight < minHeight) {
                    col = i;
                    minHeight = colHeight;
                }
            }
            
            CGFloat left = self.leftMargin>=0.0f?self.leftMargin:kMargin + (col * kMargin) + (col * self.columnWidth);
            CGFloat top = [[colOffsets objectAtIndex:col] floatValue];
            CGFloat colHeight = [self.flowDataSource heightForCellAtIndex:i];
            if (colHeight == 0) {
                colHeight = self.columnWidth;
            }
            
            if (top != top) {
                // NaN
            }
            
            CGRect viewRect = CGRectMake(left, top, self.columnWidth, colHeight);
            // Add to index rect map
            [self.indexToRectMap setObject:NSStringFromCGRect(viewRect) forKey:key];
            
            // Update the last height offset for this column
            CGFloat test = top + colHeight + kMargin;
            
            if (test != test) {
                // NaN
            }
            [colOffsets replaceObjectAtIndex:col withObject:[NSNumber numberWithFloat:test]];
        }
        
        for (NSNumber *colHeight in colOffsets) {
            totalHeight = (totalHeight < [colHeight floatValue]) ? [colHeight floatValue] : totalHeight;
        }
    } else {
        totalHeight = self.height - 20;
    }
    
    self.contentSize = CGSizeMake(self.width, totalHeight);
    // Add footerView if exists
    if ([self shouldShowFooterView]) {
        self.footerView.alpha = 1.0;
        self.footerView.top = self.contentSize.height;
    }else {
        self.footerView.alpha = 0.0;
    }
    
    if (self.isRefreshing) {
        self.isRefreshing = NO;
        [self.refreshView waterflowRefreshScrollViewDataSourceDidFinishedLoading:self];
    }
    if (self.isLoadingMore) {
        self.isLoadingMore = NO;
        [self.footerView waterflowRefreshScrollViewDataSourceDidFinishedLoading:self];
    }
    [self removeAndAddCellsIfNecessary];
}

- (void)removeAndAddCellsIfNecessary {
    static NSInteger bufferViewFactor = 5;
    static NSInteger topIndex = 0;
    static NSInteger bottomIndex = 0;
    
    NSInteger numViews = [self.flowDataSource numberOfViewsInWaterflowView:self];
    NSInteger numOfViewPerPage = [self.flowDataSource numberOfViewsPerPage:self];
    NSInteger viewCountOfShouldBeLoad = numOfViewPerPage * (self.currentPage+1);
    viewCountOfShouldBeLoad = MIN(viewCountOfShouldBeLoad, numViews);
    
    if (viewCountOfShouldBeLoad == 0) return;
    
    // Find out what rows are visible
    CGRect visibleRect = CGRectMake(self.contentOffset.x, self.contentOffset.y, self.width, self.height);
    
    // Remove all rows that are not inside the visible rect
    [self.visibleViews enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        WaterflowCell *view = (WaterflowCell *)obj;
        CGRect viewRect = view.frame;
        if (!CGRectIntersectsRect(visibleRect, viewRect)) {
            [self enqueueReusableView:view];
            [self.viewKeysToRemove addObject:key];
        }
    }];
    
    [self.visibleViews removeObjectsForKeys:self.viewKeysToRemove];
    [self.viewKeysToRemove removeAllObjects];
    
    if ([self.visibleViews count] == 0) {
        topIndex = 0;
        bottomIndex = viewCountOfShouldBeLoad;
    } else {
        NSArray *sortedKeys = [[self.visibleViews allKeys] sortedArrayUsingComparator:^(id obj1, id obj2) {
            if ([obj1 integerValue] < [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if ([obj1 integerValue] > [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            } else {
                return (NSComparisonResult)NSOrderedSame;
            }
        }];
        topIndex = [[sortedKeys objectAtIndex:0] integerValue];
        bottomIndex = [[sortedKeys lastObject] integerValue];
        
        topIndex = MAX(0, topIndex - (bufferViewFactor * self.numOfColumns));
        bottomIndex = MIN(viewCountOfShouldBeLoad, bottomIndex + (bufferViewFactor * self.numOfColumns));
    }
    //    NSLog(@"topIndex: %d, bottomIndex: %d", topIndex, bottomIndex);
    
    // Add views
    for (NSInteger i = topIndex; i < bottomIndex; i++) {
        NSString *key = PSCollectionKeyForIndex(i);
        CGRect rect = CGRectFromString([self.indexToRectMap objectForKey:key]);
        
        // If view is within visible rect and is not already shown
        if (![self.visibleViews objectForKey:key] && CGRectIntersectsRect(visibleRect, rect)) {
            // Only add views if not visible
            WaterflowCell *newView = [self.flowDataSource waterflowView:self cellAtIndex:i];
            newView.frame = CGRectFromString([self.indexToRectMap objectForKey:key]);
            [self addSubview:newView];
            
            // Setup gesture recognizer
            if ([newView.gestureRecognizers count] == 0) {
                UITapGestureRecognizer * tapGR = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectView:)] autorelease];
                tapGR.delegate = self;
                [newView addGestureRecognizer:tapGR];
                newView.userInteractionEnabled = YES;
            }
            
            [self.visibleViews setObject:newView forKey:key];
        }
    }
}

#pragma mark - Reusing Views

- (WaterflowCell *)dequeueReusableView {
    WaterflowCell *view = [self.reuseableViews anyObject];
    if (view) {
        // Found a reusable view, remove it from the set
        [view retain];
        [self.reuseableViews removeObject:view];
        [view autorelease];
    }
    
    return view;
}

- (void)enqueueReusableView:(WaterflowCell *)view {
    if ([view respondsToSelector:@selector(prepareForReuse)]) {
        [view performSelector:@selector(prepareForReuse)];
    }
    [self.reuseableViews addObject:view];
    [view removeFromSuperview];
}

#pragma mark - Gesture Recognizer

- (void)didSelectView:(UITapGestureRecognizer *)gestureRecognizer {    
    NSString *rectString = NSStringFromCGRect(gestureRecognizer.view.frame);
    NSArray *matchingKeys = [self.indexToRectMap allKeysForObject:rectString];
    NSString *key = [matchingKeys lastObject];
    if ([gestureRecognizer.view isMemberOfClass:[[self.visibleViews objectForKey:key] class]]) {
        if (self.flowDelegate && [self.flowDelegate respondsToSelector:@selector(waterflowView:didSelectCell:atIndex:)]) {
            NSInteger matchingIndex = PSCollectionIndexForKey([matchingKeys lastObject]);
            [self.flowDelegate waterflowView:self didSelectCell:(WaterflowCell *)gestureRecognizer.view atIndex:matchingIndex];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (![gestureRecognizer isMemberOfClass:[UITapGestureRecognizer class]]) return YES;
    
    NSString *rectString = NSStringFromCGRect(gestureRecognizer.view.frame);
    NSArray *matchingKeys = [self.indexToRectMap allKeysForObject:rectString];
    NSString *key = [matchingKeys lastObject];
    
    if ([touch.view isMemberOfClass:[[self.visibleViews objectForKey:key] class]]) {
        return YES;
    } else {
        return NO;
    }
}

@end
