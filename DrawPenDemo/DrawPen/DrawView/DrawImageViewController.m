//
//  DrawImageViewController.m
//  DrawPen
//
//  Created by lingmin on 13-7-1.
//  Copyright (c) 2013年 lingmin. All rights reserved.
//

#import "DrawImageViewController.h"
#import "WaterflowCell.h"
#import "ImageViewController.h"

@interface DrawImageViewController ()

@property (nonatomic, retain) WaterflowView * drawImageFlowView;

@end

@implementation DrawImageViewController

#pragma mark - LiftCycle

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
	// Do any additional setup after loading the view.
    [self.navigationController.navigationBar setHidden:NO];
    self.drawImageFlowView = [[WaterflowView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.drawImageFlowView setBackgroundColor:[UIColor grayColor]];
    [self.drawImageFlowView setNumOfColInPortrait:4];
    [self.drawImageFlowView setFlowDataSource:self];
    [self.drawImageFlowView setFlowDelegate:self];
    [self.drawImageFlowView setShouldDragUpdate:NO];
    [self.view addSubview:self.drawImageFlowView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    NSUserDefaults * userDesaults = [NSUserDefaults standardUserDefaults];
    NSArray * array = [userDesaults objectForKey:ImageArray];
    NSMutableArray * mutableArray = [[NSMutableArray alloc]init];
    if ([array count]) {
        for (NSString * imagePath in array) {
            UIImage * layoutImage = [UIImage imageWithContentsOfFile:[[PathManager sharePathManager] namePath:imagePath]];
            [mutableArray addObject:layoutImage];
        }
        _imageArray = (NSArray *)mutableArray;
    } else {
        _imageArray = nil;
    }
    [self.drawImageFlowView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - WaterflowViewDelegate

- (NSInteger)numberOfViewsPerPage:(WaterflowView *)flowView{
    return 20;
}

- (NSInteger)numberOfViewsInWaterflowView:(WaterflowView *)flowView{
    if ([_imageArray count]) {
        return [_imageArray count];
    }
    return 0;
}

- (WaterflowCell *)waterflowView:(WaterflowView *)flowView cellAtIndex:(NSInteger)index{
    WaterflowCell * cell = (WaterflowCell *)[flowView dequeueReusableView];
    if (!cell) {
        cell = [[WaterflowCell alloc] initWithFrame:CGRectMake(0, 0, 64, 92)] ;
    }
    [cell setFrame:CGRectMake(0, 0, 64, 92)];
    
    DrawImageCell * drawImageCell = [[[NSBundle mainBundle] loadNibNamed:@"DrawImageCell" owner:self options:nil] objectAtIndex:0];
    [drawImageCell setIndex:index];
    [drawImageCell setImage:[_imageArray objectAtIndex:index]];
    [drawImageCell setDelegate:self];
    [drawImageCell setFrame:cell.bounds];
    [cell addSubview:drawImageCell];
    return cell;
}

- (CGFloat)heightForCellAtIndex:(NSInteger)index{
    return 92;
}

#pragma mark - DrawImageCellDelegate

- (void)selectDrawCellDelegate:(NSInteger)index
{
    ImageViewController * imageViewController = [[ImageViewController alloc]init];
    imageViewController.drawImage = [_imageArray objectAtIndex:index];
    imageViewController.array = _imageArray;
    imageViewController.index = index;
    [self.navigationController pushViewController:imageViewController animated:YES];
}

@end
