//
//  ViewController.h
//  Brokenithm-iOS
//
//  Created by ester on 2020/2/28.
//  Copyright © 2020 esterTion. All rights reserved.
//

#pragma once

@class SocketDelegate;

#import <UIKit/UIKit.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import "SocketDelegate.h"

@interface ViewController : UIViewController {
    SocketDelegate *server;
}
@property UIView *airIOView;
@property UIView *sliderIOView;
@property CAGradientLayer *ledBackground;

-(void)updateLed:(NSData*)rgbData;

@end
