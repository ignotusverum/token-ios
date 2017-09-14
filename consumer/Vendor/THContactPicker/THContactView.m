//
//
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/2/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

#import "THContactView.h"
#import "THContactTextField.h"

@interface THContactView () <THContactTextFieldDelegate>

@end

@implementation THContactView

#define kHorizontalPadding 5

#define k7DefaultBorderWidth 0
#define k7DefaultCornerRadiusFactor 7

#define k7ColorText [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]
#define k7ColorGradientTop  nil
#define k7ColorGradientBottom  nil
#define k7ColorBorder nil

#define k7ColorSelectedText [UIColor whiteColor]
#define k7ColorSelectedGradientTop [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]
#define k7ColorSelectedGradientBottom [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]
#define k7ColorSelectedBorder nil

NSInteger const kCircleHeight = 30;

- (id)initWithName:(NSString *)name
{
    return [self initWithName:name style:nil selectedStyle:nil];
}

- (id)initWithName:(NSString *)name style:(THContactViewStyle *)style selectedStyle:(THContactViewStyle *)selectedStyle
{
    return [self initWithName:name style:style selectedStyle:selectedStyle showComma:NO];
}

- (id)initWithName:(NSString *)name style:(THContactViewStyle *)style selectedStyle:(THContactViewStyle *)selectedStyle showComma:(BOOL)showComma
{
    self = [super init];
    if (self) {
        self.name = name;
        self.isSelected = NO;
        self.showComma = NO; // showComma;
        
        // default styles
        if (style == nil) {
            style = [[THContactViewStyle alloc] initWithTextColor:k7ColorText
                                                 gradientTop:k7ColorGradientTop
                                              gradientBottom:k7ColorGradientBottom
                                                 borderColor:k7ColorBorder
                                                 borderWidth:k7DefaultBorderWidth
                                          cornerRadiusFactor:k7DefaultCornerRadiusFactor];
        }
        if (selectedStyle == nil) {
            selectedStyle = [[THContactViewStyle alloc] initWithTextColor:k7ColorSelectedText
                                                         gradientTop:k7ColorSelectedGradientTop
                                                      gradientBottom:k7ColorSelectedGradientBottom
                                                         borderColor:k7ColorSelectedBorder
                                                        borderWidth:k7DefaultBorderWidth
                                                  cornerRadiusFactor:k7DefaultCornerRadiusFactor];
        }
        
        self.style = style;
        self.selectedStyle = selectedStyle;
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    self.label = [[UILabel alloc] init];
    self.label.backgroundColor = [UIColor clearColor];
    self.label.text = self.name;
    self.label.clipsToBounds = YES;
    self.label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.label];
    
    self.textField = [[THContactTextField alloc] init];
	self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.delegate = self;
    self.textField.hidden = YES;
    [self addSubview:self.textField];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapGesture];
    
    [self adjustSize];
    
    [self unSelect];
}

- (void)adjustSize
{
    self.label.layer.cornerRadius = kCircleHeight / 2;
    self.label.backgroundColor = self.style.gradientTop;
    
    if (self.name.length > 2) {
        
        NSMutableDictionary * dict = [NSMutableDictionary new];
        [dict setObject:[UIFont fontWithName:self.label.font.fontName size:self.label.font.pointSize] forKey:NSFontAttributeName];
        CGRect labelHeight = [self.name boundingRectWithSize:CGSizeMake(120, kCircleHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
        
        CGFloat width = labelHeight.size.width;
        
        self.label.frame = CGRectMake(0, 0, width + 8, kCircleHeight);
        self.bounds = CGRectMake(0, 0, width + 8 + kHorizontalPadding, kCircleHeight);
    }
    else {
        self.label.frame = CGRectMake(0, 0, kCircleHeight, kCircleHeight);
        self.bounds = CGRectMake(0, 0, kCircleHeight + kHorizontalPadding, kCircleHeight);
    }
}

- (void)setFont:(UIFont *)font
{
    self.label.font = font;

    [self adjustSize];
}

- (void)select
{
    if ([self.delegate respondsToSelector:@selector(contactViewWasSelected:)]){
        [self.delegate contactViewWasSelected:self];
    }
    
    self.label.textColor = self.selectedStyle.textColor;
    self.label.layer.borderWidth = self.selectedStyle.borderWidth;
    self.label.backgroundColor = self.selectedStyle.gradientTop;
    
    self.isSelected = YES;

    [self.textField becomeFirstResponder];
}

- (void)unSelect
{
    if ([self.delegate respondsToSelector:@selector(contactViewWasUnSelected:)]){
        [self.delegate contactViewWasUnSelected:self];
    }
    
    self.label.textColor = self.style.textColor;
    self.label.layer.borderWidth = self.style.borderWidth;
    self.label.backgroundColor = self.style.gradientTop;
    
    [self setNeedsDisplay];
    
    self.isSelected = NO;

    [self.textField resignFirstResponder];
}

- (void)handleTapGesture
{
    // do nothing when bubble is tapped
}

#pragma mark - UITextViewDelegate

- (void)textFieldDidHitBackspaceWithEmptyText:(THContactTextField *)textView
{
    self.textField.hidden = NO;
    
    // Capture "delete" key press when cell is empty
    if ([self.delegate respondsToSelector:@selector(contactViewShouldBeRemoved:)]){
        [self.delegate contactViewShouldBeRemoved:self];
    }
}

- (void)textFieldDidChange:(THContactTextField *)textField
{
    [self unSelect];
    
    if ([self.delegate respondsToSelector:@selector(contactViewWasUnSelected:)]){
        [self.delegate contactViewWasUnSelected:self];
    }
    
	self.textField.text = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextInputTraits

- (void)setKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance
{
    self.textField.keyboardAppearance = keyboardAppearance;
}

- (UIKeyboardAppearance)keyboardAppearance
{
    return self.textField.keyboardAppearance;
}

- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType
{
    self.textField.returnKeyType = returnKeyType;
}

- (UIReturnKeyType)returnKeyType
{
    return self.textField.returnKeyType;
}

@end
