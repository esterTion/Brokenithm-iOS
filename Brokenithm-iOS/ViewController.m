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
    //self.airIOView.backgroundColor = [UIColor blueColor];
    //self.sliderIOView.backgroundColor = [UIColor redColor];
    self.ledBackground = [CAGradientLayer layer];
    self.ledBackground.frame = CGRectMake(0, 0, screenWidth, sliderHeight);
    [self.sliderIOView.layer addSublayer:self.ledBackground];
    self.ledBackground.startPoint = CGPointMake(1,0);
    self.ledBackground.endPoint = CGPointMake(0,0);
    {
        float pointOffset = 0;
        NSMutableArray *locations = [NSMutableArray arrayWithCapacity:33];
        for (int i=0; i<33; i++) {
            NSNumber *loc = [NSNumber numberWithFloat:pointOffset];
            locations[i] = loc;
            pointOffset += 1.0/32;
        }
        self.ledBackground.locations = locations;
    }
    
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
    
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        char ledDataChar[32*3] = {0,254,254,0,254,254,0,254,254,0,0,0,254,254,254,254,254,254,254,254,254,0,0,0,10,10,10,10,10,10,10,10,10,0,0,0,0,254,128,0,254,128,0,254,128,0,254,128,0,254,128,0,254,128,0,254,128,0,0,0,0,0,254,0,0,254,0,0,254,0,0,254,0,0,254,0,0,0,0,0,254,0,0,254,0,0,254,0,0,254,0,0,254,0,0,0};
        NSData *ledData = [NSData dataWithBytes:ledDataChar length:32*3];
        [self updateLed:ledData];
    });
}

-(void)updateLed:(NSData*)rgbData {
    if (rgbData.length != 32*3) return;
    NSMutableArray *colorArr = [NSMutableArray arrayWithCapacity:33];
    colorArr[0] = (__bridge id)([UIColor colorWithWhite:0 alpha:0].CGColor);
    uint8_t *rgb = (uint8_t*)rgbData.bytes;
    for (int i=0; i<32; i++) {
        float r = rgb[i*3+1], g = rgb[i*3+2], b = rgb[i*3];
        r /= 255.0;
        g /= 255.0;
        b /= 255.0;
        UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1];
        colorArr[i+1] = (__bridge id)color.CGColor;
    }
    self.ledBackground.colors = colorArr;
    [self.ledBackground setNeedsDisplay];
}

-(BOOL)prefersStatusBarHidden { return kCFCoreFoundationVersionNumber < 1443.00; }
-(UIRectEdge)preferredScreenEdgesDeferringSystemGestures { return UIRectEdgeAll; }
-(BOOL)prefersHomeIndicatorAutoHidden { return YES; }
-(UIStatusBarStyle) preferredStatusBarStyle { return UIStatusBarStyleLightContent;}

@end
