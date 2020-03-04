//
//  MainApp.m
//  Brokenithm-iOS
//
//  Created by ester on 2020/3/2.
//  Copyright © 2020 esterTion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainApp.h"

@interface MainApp ()
@end

@implementation MainApp

-(void)sendEvent:(UIEvent *)event {
    [super sendEvent:event];
    if (event.type == UIEventTypeTouches) {
        [(ViewController*)self.keyWindow.rootViewController updateTouches:event];
    }
}

@end
