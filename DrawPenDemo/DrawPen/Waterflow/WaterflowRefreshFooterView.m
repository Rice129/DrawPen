//
//  WaterflowRefreshFooterView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "WaterflowRefreshFooterView.h"

#define TEXT_COLOR	 [UIColor lightGrayColor]
#define FLIP_ANIMATION_DURATION 0.18f


@interface WaterflowRefreshFooterView()

- (void)setState:(WFPullRefreshState)aState;

@end

@implementation WaterflowRefreshFooterView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, self.frame.size.height/2.0-20, 150, 20.0f)];
		_statusLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		_statusLabel.font = [UIFont boldSystemFontOfSize:13.0f];
		_statusLabel.textColor = TEXT_COLOR;
		_statusLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_statusLabel];
        
		_lastUpdatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, self.frame.size.height/2.0, 150, 20.0f)];
		_lastUpdatedLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		_lastUpdatedLabel.font = [UIFont systemFontOfSize:12.0f];
		_lastUpdatedLabel.textColor = TEXT_COLOR;
		_lastUpdatedLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_lastUpdatedLabel];
		
		CALayer *layer = [CALayer layer];
		layer.frame = CGRectMake(0, (self.frame.size.height-45)/2.0, 17.0f, 45.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:@"blackArrowDown.png"].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:layer];
		_arrowImage=layer;
		
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		view.frame = CGRectMake(8.0f, (self.frame.size.height-20)/2.0, 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;
		[view release];
		
		[self setState:WFPullRefreshNormal];
		
    }
	
    return self;
}


#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate {
    
	if ([_delegate respondsToSelector:@selector(waterfolwRefreshTableFooterDataSourceLastUpdated:)]) {
		
		NSDate *date = [_delegate waterfolwRefreshTableFooterDataSourceLastUpdated:self];
		
        NSString *dateString = @"从未";
        if (date != nil) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            dateString = [formatter stringFromDate:date];
            [formatter release];
        }
		_lastUpdatedLabel.text = [NSString stringWithFormat:@"上次更新: %@", dateString];
		[[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
	} else {
		_lastUpdatedLabel.text = nil;
	}
}

- (void)setState:(WFPullRefreshState)aState{
	
	switch (aState) {
		case WFPullRefreshPulling:
			
			_statusLabel.text = @"松开刷新...";
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, .0f, .0f, 1.0f);
			[CATransaction commit];
			
			break;
		case WFPullRefreshNormal:
			
			if (_state == WFPullRefreshPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			
			_statusLabel.text = @"上拉刷新...";
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			[self refreshLastUpdatedDate];
			
			break;
		case WFPullRefreshLoading:
			
			_statusLabel.text = @"正在更新...";
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			_arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
	_state = aState;
}


#pragma mark -
#pragma mark ScrollView Methods

- (void)waterflowRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
	
	if (_state == WFPullRefreshLoading) {
		
		CGFloat offset = MAX(scrollView.contentOffset.y , 0);
		offset = MIN(offset, 88);
		scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, offset, 0.0f);
		
	} else {
		
		BOOL _loading = NO;
        if ([_delegate respondsToSelector:@selector(waterflowRefreshTableFooterDataSourceIsLoading:)]) {
            _loading = [_delegate waterflowRefreshTableFooterDataSourceIsLoading:self];
        }
        
        CGFloat offset = scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height;
		if (_state == WFPullRefreshPulling && offset < 65.0f && !_loading) {
			[self setState:WFPullRefreshNormal];
		} else if (_state == WFPullRefreshNormal && offset > 65.0f && !_loading) {
			[self setState:WFPullRefreshPulling];
		}
		
		if (scrollView.contentInset.top != 0) {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
	}
}

- (BOOL)waterflowRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	BOOL _loading = NO;
    if ([_delegate respondsToSelector:@selector(waterflowRefreshTableFooterDataSourceIsLoading:)]) {
        _loading = [_delegate waterflowRefreshTableFooterDataSourceIsLoading:self];
    }
	
    CGFloat offset = scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height;
	if (offset >= 65.0f && !_loading) {
        if ([_delegate respondsToSelector:@selector(waterfolwRefreshTableFooterDidTriggerRefresh:)]) {
            [_delegate waterfolwRefreshTableFooterDidTriggerRefresh:self];
        }
		[self setState:WFPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 60.0f, 0.0f);
		[UIView commitAnimations];
		return NO;
	}
	
    return YES;
}

- (void)waterflowRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[self setState:WFPullRefreshNormal];
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	
	_delegate=nil;
	_activityView = nil;
	_statusLabel = nil;
	_arrowImage = nil;
	_lastUpdatedLabel = nil;
    [super dealloc];
}


@end
