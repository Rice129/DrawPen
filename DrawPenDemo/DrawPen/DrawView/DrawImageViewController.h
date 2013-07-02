//
//  DrawImageViewController.h
//  DrawPen
//
//  Created by lingmin on 13-7-1.
//  Copyright (c) 2013年 lingmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaterflowView.h"
#import "DrawImageCell.h"

@interface DrawImageViewController : UIViewController<WaterflowViewDataSource,WaterflowViewDelegate,DrawImageCellDelegate>

@property (nonatomic, retain) NSArray                * imageArray;
@property (nonatomic, retain) UINavigationController * navigationController;

@end
