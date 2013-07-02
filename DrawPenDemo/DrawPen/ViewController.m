//
//  ViewController.m
//  DrawPen
//
//  Created by lingmin on 13-6-29.
//  Copyright (c) 2013年 lingmin. All rights reserved.
//

#import "ViewController.h"
#import "DrawView.h"
#import "DrawImageViewController.h"

@interface ViewController ()

@property (nonatomic, retain) DrawView       * drawView;
@property (nonatomic, assign) CGFloat          alpha;
@property (nonatomic, retain) UIView         * funView;
@property (nonatomic, retain) UIColor        * color;
@property (nonatomic, retain) UIView         * imageView;
@property (nonatomic, retain) NSArray        * imageNamesArray;
@property (nonatomic, retain) NSMutableArray * imageNameArray;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.drawView = [[DrawView alloc]initWithFrame:CGRectMake(0, 0, 320, 460)];
    [self.drawView setBackgroundColor:[UIColor darkGrayColor]];
    [self.view addSubview:self.drawView];
    
    UIButton * previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    previousButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 430, 70, 20)];
    [previousButton setBackgroundColor:[UIColor redColor]];
    [previousButton setTitle:@"上一步" forState:UIControlStateNormal];
    [previousButton addTarget:self action:@selector(previousBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:previousButton];
    
    UIButton * clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    clearButton = [[UIButton alloc]initWithFrame:CGRectMake(90, 430, 70, 20)];
    [clearButton setBackgroundColor:[UIColor greenColor]];
    [clearButton setTitle:@"清空" forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(clearBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearButton];
    
    UIButton * lineColorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    lineColorBtn = [[UIButton alloc]initWithFrame:CGRectMake(175, 430, 70, 20)];
    [lineColorBtn setBackgroundColor:[UIColor purpleColor]];
    [lineColorBtn setTitle:@"颜色" forState:UIControlStateNormal];
    [lineColorBtn addTarget:self action:@selector(chageLineColor:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lineColorBtn];
    
    UIButton * saveImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveImageBtn = [[UIButton alloc]initWithFrame:CGRectMake(250, 430, 70, 20)];
    [saveImageBtn setBackgroundColor:[UIColor orangeColor]];
    [saveImageBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveImageBtn addTarget:self action:@selector(saveImageToLocation:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveImageBtn];
  
    UIButton * layoutBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [layoutBtn setFrame:CGRectMake(300, 5, 20, 20)];
    [layoutBtn addTarget:self action:@selector(showImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:layoutBtn];
    
    self.imageNameArray = [[NSMutableArray alloc]init];
    
    [self functionView];
}

- (void)functionView
{
    self.funView = [[UIView alloc]initWithFrame:CGRectMake(0, 460, 320, 100)];
    [self.funView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.funView];
    [self.funView setHidden:YES];
    
    NSArray * array = [[NSArray alloc]initWithObjects:@"黑",@"白",@"赤",@"橙",@"黄",@"绿",@"青",@"蓝",@"紫", nil];
    UISegmentedControl * segment = [[UISegmentedControl alloc]initWithItems:array];
    [segment setFrame:CGRectMake(5, 5, 250, 30)];
    [segment setSegmentedControlStyle:UISegmentedControlStyleBar];
    [segment addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [segment setSelectedSegmentIndex:0];
    [self.funView addSubview:segment];
    
    UISlider * alphaSlider = [[UISlider alloc]initWithFrame:CGRectMake(5, 40, 200, 10)];
    [alphaSlider addTarget:self action:@selector(alphaValueChange:) forControlEvents:UIControlEventValueChanged];
    [alphaSlider setMaximumValue:1.0];
    [alphaSlider setMinimumValue:0.0];
    [alphaSlider setValue:1.0];
    self.alpha = alphaSlider.value;
    [self.funView addSubview:alphaSlider];
    
    UILabel * alphaLable = [[UILabel alloc]initWithFrame:CGRectMake(210, 40, 60, 20)];
    [alphaLable setText:@"透明度"];
    [alphaLable setBackgroundColor:[UIColor clearColor]];
    [self.funView addSubview:alphaLable];
    
    UISlider * widthSlider = [[UISlider alloc]initWithFrame:CGRectMake(5, 70, 200, 10)];
    [widthSlider addTarget:self action:@selector(widthValueChange:) forControlEvents:UIControlEventValueChanged];
    [widthSlider setMaximumValue:10.0];
    [widthSlider setMinimumValue:0.0];
    [widthSlider setValue:1.0];
    self.alpha = widthSlider.value;
    [self.funView addSubview:widthSlider];
    
    UILabel * widthLable = [[UILabel alloc]initWithFrame:CGRectMake(210, 70, 50, 20)];
    [widthLable setText:@"宽度"];
    [widthLable setBackgroundColor:[UIColor clearColor]];
    [self.funView addSubview:widthLable];
    
    UIButton * doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setFrame:CGRectMake(270, 2, 50, 30)];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.funView addSubview:doneButton];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ButtonAction

- (IBAction)showImage:(id)sender{
    DrawImageViewController * drawImageViewController = [[DrawImageViewController alloc]init];
    drawImageViewController.navigationController = self.navigationController;
    [self.navigationController pushViewController:drawImageViewController animated:YES];
}

- (IBAction)backToMain:(id)sender{
    [UIView animateWithDuration:0.35 animations:^{
        [_imageView setFrame:CGRectMake(320, 0, 320, 460)];
    }];
}

- (IBAction)doneAction:(id)sender
{
    [UIView animateWithDuration:0.35 animations:^{
        self.funView.frame = CGRectMake(0, 460, 320, 100);
    } completion:^(BOOL finish){
        [self.funView setHidden:NO];
    }];
}

- (void)alphaValueChange:(id)sender{
    UISlider * slider = (UISlider*)sender;
    self.alpha = slider.value;
    CGFloat R; CGFloat G; CGFloat B; CGFloat alpha;
    [self.color getRed:&R  green:&G blue:&B alpha:&alpha];
    [self.drawView LineColor:R G:G B:B Alpha:self.alpha];
}

- (void)widthValueChange:(id)sender{
    UISlider * slider = (UISlider*)sender;
    [self.drawView LineWidth:slider.value];
}

- (void)segmentAction:(UISegmentedControl *)segment
{
    switch (segment.selectedSegmentIndex) {
        case 0:{
            self.color = [UIColor blackColor];
            break;
        }
        case 1:{
            self.color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
            break;
        }
        case 2:{
            self.color = [UIColor redColor];
            break;
        }
        case 3:{
            self.color = [UIColor orangeColor];
            break;
        }
        case 4:{
            self.color = [UIColor yellowColor];
            break;
        }
        case 5:{
            self.color = [UIColor greenColor];
            break;
        }
        case 6:{
            self.color = [UIColor cyanColor];
            break;
        }
        case 7:{
            self.color = [UIColor blueColor];
            break;
        }
        case 8:{
            self.color = [UIColor purpleColor];
            break;
        }            
        default:
            break;
    }
    CGFloat R; CGFloat G; CGFloat B; CGFloat alpha;
    [self.color getRed:&R  green:&G blue:&B alpha:&alpha];
    [self.drawView LineColor:R G:G B:B Alpha:self.alpha];
}

- (IBAction)previousBtn:(id)sender{
    [self.drawView backToLastStep];
}

- (IBAction)clearBtn:(id)sender{
    [self.drawView clearUp];
}

- (IBAction)chageLineColor:(id)sender{
    [UIView animateWithDuration:0.35 animations:^{
        [self.funView setHidden:NO];
        self.funView.frame = CGRectMake(0, 360, 320, 100);
    }];
}
- (IBAction)saveImageToLocation:(id)sender{
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"保存图片"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"不保存" otherButtonTitles:@"保存",nil];
    [alertView show];
}
#pragma mark - function

- (void)saveImage{
    UIImage * saveImage = [self convertViewToImage:self.drawView];
    NSUserDefaults * userDesaults = [NSUserDefaults standardUserDefaults];
    NSInteger index = [userDesaults integerForKey:ImageIndex];
    NSString * imageIndex = [NSString stringWithFormat:@"%d.png",index+1];
    NSArray * array = [userDesaults objectForKey:ImageArray];
    [_imageNameArray addObjectsFromArray:array];
    
    NSString * path = [[PathManager sharePathManager] namePath:imageIndex];
    [[PathManager sharePathManager] buildPathForFile:path];
    [UIImageJPEGRepresentation(saveImage, 1.0) writeToFile:path atomically:YES];
    
    [userDesaults setInteger:index+1 forKey:ImageIndex];
    [_imageNameArray addObject:imageIndex];
    [userDesaults setObject:(NSArray *)_imageNameArray forKey:ImageArray];
    [_imageNameArray removeAllObjects];
    [userDesaults synchronize];
}

-(UIImage*)convertViewToImage:(UIView*)v{
    UIGraphicsBeginImageContext(v.bounds.size);    
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();    
    return image;
    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self saveImage];
    }
}

@end
