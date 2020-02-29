//
//  ViewController.m
//  Brokenithm-iOS
//
//  Created by ester on 2020/2/28.
//  Copyright © 2020 esterTion. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property UIView *airIOView;
@property UIView *sliderIOView;
@property CAGradientLayer *ledBackground;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGRect screenSize = [UIScreen mainScreen].bounds;
    float screenWidth = screenSize.size.width;
    float screenHeight = screenSize.size.height;
    float offsetY = 0, sliderHeight = screenHeight*0.6;
    self.airIOView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, screenWidth, screenHeight*0.4)];
    offsetY += screenHeight*0.4;
    self.sliderIOView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, screenWidth, sliderHeight)];
    [self.view addSubview:self.airIOView];
    [self.view addSubview:self.sliderIOView];
    self.airIOView.backgroundColor = [UIColor blueColor];
    self.sliderIOView.backgroundColor = [UIColor redColor];
    
    struct CGColor *whiteColor = [UIColor whiteColor].CGColor;
    float airOffset=0, airHeight = screenHeight*0.4/6;
    for (int i=0;i<6;i++) {
        UIView *airInput = [[UIView alloc] initWithFrame:CGRectMake(0, airOffset, screenWidth, airHeight)];
        airInput.layer.borderWidth = 1.0f;
        airInput.layer.borderColor = whiteColor;
        airOffset += airHeight;
        [self.airIOView addSubview:airInput];
    }
    
    float sliderWidth = screenWidth / 16, sliderOffset = 0;
    for (int i=0;i<16;i++) {
        UIView *sliderInput = [[UIView alloc] initWithFrame:CGRectMake(sliderOffset, 0, sliderWidth, sliderHeight)];
        sliderInput.layer.borderWidth = 1.0f;
        sliderInput.layer.borderColor = whiteColor;
        sliderOffset += sliderWidth;
        [self.sliderIOView addSubview:sliderInput];
    }
}

-(BOOL)prefersStatusBarHidden { return kCFCoreFoundationVersionNumber < 1443.00; }
-(UIRectEdge)preferredScreenEdgesDeferringSystemGestures { return UIRectEdgeAll; }
-(BOOL)prefersHomeIndicatorAutoHidden { return YES; }
-(UIStatusBarStyle) preferredStatusBarStyle { return UIStatusBarStyleLightContent;}

@end
