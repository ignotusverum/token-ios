//
//
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/2/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

#import "THContactViewStyle.h"

@implementation THContactViewStyle

- (id)initWithTextColor:(UIColor *)textColor
            gradientTop:(UIColor *)gradientTop
         gradientBottom:(UIColor *)gradientBottom
            borderColor:(UIColor *)borderColor
            borderWidth:(CGFloat)borderWidth
     cornerRadiusFactor:(CGFloat)cornerRadiusFactor {
    
    if (self = [super init]) {
        self.textColor = textColor;
        self.gradientTop = gradientTop;
        self.gradientBottom = gradientBottom;
        self.borderColor = borderColor;
        self.borderWidth = borderWidth;
        self.cornerRadiusFactor = cornerRadiusFactor;
    }
    return self;
}

@end
