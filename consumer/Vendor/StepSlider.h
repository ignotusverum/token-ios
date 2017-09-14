//
//
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/2/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StepSliderDelegate <NSObject>

- (void) stepSliderDidScrolToIndex:(NSInteger)index;

@end

@interface StepSlider : UIControl

@property (nonatomic, strong) id <StepSliderDelegate> delegate;

@property (nonatomic) IBInspectable NSUInteger maxCount;
@property (nonatomic) IBInspectable NSUInteger index;

@property (nonatomic) IBInspectable CGFloat trackHeight;
@property (nonatomic) IBInspectable CGFloat trackCircleRadius;
@property (nonatomic) IBInspectable CGFloat sliderCircleRadius;

@property (nonatomic, strong) IBInspectable UIColor * firstGradientColor;
@property (nonatomic, strong) IBInspectable UIColor * secondGradientColor;

@property (nonatomic, strong) IBInspectable UIColor * trackColor;
@property (nonatomic, strong) IBInspectable UIColor * sliderCircleColor;

@property (nonatomic, strong) NSMutableArray * arrayOfLabelNames;

@end
