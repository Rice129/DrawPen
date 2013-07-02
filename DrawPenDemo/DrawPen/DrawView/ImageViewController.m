//
//  ImageViewController.m
//  DrawPen
//
//  Created by damin ding on 13-7-2.
//  Copyright (c) 2013年 lingmin. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

#pragma mark - LifeCycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(isDeleteImage)];
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.imageView setImage:_drawImage];
    [self.view setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:self.imageView];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PrivateMethod

- (void)isDeleteImage
{
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"是否删除"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"否"
                                              otherButtonTitles:@"删除", nil];
    [alertView show];
}

- (void)deleteImage
{
    NSUserDefaults * userDesaults = [NSUserDefaults standardUserDefaults];
    NSArray * array = [userDesaults objectForKey:ImageArray];
    NSMutableArray * mutableArray = [NSMutableArray arrayWithArray:array];
    if ([mutableArray count]) {
        NSString * imageName = [mutableArray objectAtIndex:_index];
        NSString * imagePath = [[PathManager sharePathManager] namePath:imageName];
        [[PathManager sharePathManager] deleteBuildPath:imagePath];
        [mutableArray removeObjectAtIndex:_index];
        [userDesaults setObject:mutableArray forKey:ImageArray];
        [userDesaults synchronize];
    }
    if ([mutableArray count] > 0) {
        if (_index < mutableArray.count - 1) {
            NSString * imagePath = [mutableArray objectAtIndex:_index+1];
            UIImage * layoutImage = [UIImage imageWithContentsOfFile:[[PathManager sharePathManager] namePath:imagePath]];
            _index = _index+1;
            [_imageView setImage:layoutImage];
        } else {
            NSString * imagePath = [mutableArray objectAtIndex:0];
            UIImage * layoutImage = [UIImage imageWithContentsOfFile:[[PathManager sharePathManager] namePath:imagePath]];
            _index = 0;
            [_imageView setImage:layoutImage];
        }
    } else {
        [_imageView setImage:nil];
    }

}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self deleteImage];
    }
}

@end
