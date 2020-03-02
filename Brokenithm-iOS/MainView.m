//
//  MainView.m
//  Brokenithm-iOS
//
//  Created by ester on 2020/3/2.
//  Copyright © 2020 esterTion. All rights reserved.
//

#import "MainView.h"


@implementation MainView

-(id)init{
    id val = [super init];
    self.multipleTouchEnabled = YES;
    return val;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { NSLog(@"began"); [self updateTouches:event]; }
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { NSLog(@"ended"); [self updateTouches:event]; }
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { NSLog(@"moved"); [self updateTouches:event]; }
-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { NSLog(@"cancel"); [self updateTouches:event]; }

-(void)updateTouches:(UIEvent *)event {
    [self.parent updateTouches:event];
}

@end
