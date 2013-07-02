//
//  ImageViewController.h
//  DrawPen
//
//  Created by damin ding on 13-7-2.
//  Copyright (c) 2013年 lingmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController<UIAlertViewDelegate>

@property (nonatomic, retain) UIImageView * imageView;
@property (nonatomic, retain) NSArray * array;
@property (nonatomic, retain) UIImage * drawImage;
@property (nonatomic, assign) NSInteger index;

@end
