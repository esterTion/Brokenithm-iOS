//
//  FunctionButton.m
//  Brokenithm-iOS
//
//  Created by ester on 2020/3/4.
//  Copyright © 2020 esterTion. All rights reserved.
//

#import "FunctionButton.h"

@implementation FunctionButton

-(id)initAtY:(CGFloat)y {
    self = [super initWithFrame:CGRectMake(0, y, 200, 60)];
    self.textAlignment = NSTextAlignmentCenter;
    self.textColor = [UIColor whiteColor];
    self.numberOfLines = 1;
    self.backgroundColor = [UIColor blackColor];
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 1.0;
    return self;
}

@end
