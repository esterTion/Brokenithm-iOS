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
    if (event.type == UIEventTypeTouches) {
        [(ViewController*)self.keyWindow.rootViewController updateTouches:event];
    }
    [super sendEvent:event];
}

@end
