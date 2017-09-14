//
//  TMCountryInput.m
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 1/20/16
//

#import "TMCountryInput.h"

@interface TMCountryInput ()

@property (nonatomic, strong) UIImageView * countryDisplay;
@property (nonatomic, strong) UIImageView * downArrow;
@property (nonatomic, strong) UIButton * countryButton;
@property (nonatomic, strong) UIView * countryPickerContainer;
@property (nonatomic, strong) CountryPicker * countryPicker;

@property (nonatomic, strong) UIButton * doneButton;
@end

@implementation TMCountryInput

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self awakeFromNib];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        [self awakeFromNib];
    }
    
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.pickerOpen = NO;
    
    self.countryPickerContainer = [[UIView alloc] initWithFrame:(CGRect){0, 0, 320, TMCOUNTRYINPUTHEIGHT}];
    
    self.countryPicker = [[CountryPicker alloc] initWithFrame:(CGRect){0, 44, 320, 180}];
    self.countryPicker.delegate = self;
    
    
    if (![self.countryPickerContainer.subviews containsObject:self.countryPicker]) {
        [self.countryPickerContainer addSubview:self.countryPicker];
    }
    
    self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.doneButton.frame = (CGRect){260, 4, 60, 40};
    self.doneButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [self.doneButton setTitle:@"DONE" forState:UIControlStateNormal];
    [self.doneButton addTarget:self action:@selector(doneTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.countryPickerContainer addSubview:self.doneButton];
    
    if (self.countryDisplay == nil) {
    
        CGFloat yPosition = 7.0;
        
        if IS_IPHONE_6P {
            yPosition = 20.0;
        }
        
        self.countryDisplay = [[UIImageView alloc] initWithFrame:(CGRect){0, yPosition, 23, 17}];
        [self addSubview:self.countryDisplay];
        
        self.downArrow = [[UIImageView alloc] initWithFrame:(CGRect){29, yPosition + 4, 10, 10}];
        self.downArrow.image = [UIImage imageNamed:@"down_arrow"];
        self.downArrow.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.downArrow];
        
        self.countryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.countryButton addTarget:self action:@selector(countryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.countryButton];
        
        [self setNeedsLayout];
        
        NSLocale * currentLocale = [NSLocale currentLocale];
        NSString * currentCountryCode = [currentLocale objectForKey:NSLocaleCountryCode];
        
        self.countryDisplay.image = [self imageForCountryCode:currentCountryCode];
        [self setSelectedCountryCode:currentCountryCode animated:NO];
    }
}

- (void) updateStyle:(BOOL)isLight {
    
    if (!isLight) {
        
        self.countryPickerContainer.backgroundColor = [UIColor TMBlackColor];
        self.countryPicker.backgroundColor = [UIColor TMBlackColor];
        [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
    }
    else {
        
        self.countryPickerContainer.backgroundColor = [UIColor TMGrayBackgroundColor];
        self.countryPicker.backgroundColor = [UIColor TMGrayBackgroundColor];
        [self.doneButton setTitleColor:[UIColor TMBlackColor] forState:UIControlStateNormal];
        self.countryPicker.lightStyle = YES;
    }
}


- (void) layoutSubviews
{
    CGRect frameOrigin = self.frame;
    frameOrigin.origin = (CGPoint){0, 0};
    
    self.countryButton.frame = frameOrigin;
}


#pragma mark - actions


- (void) countryButtonTapped:(id)sender
{
    if (!self.pickerOpen) {
        [self presentPicker];
    }
    else {
        [self dismissPicker:YES];
    }
}


- (void) doneTapped:(id)sender
{
    if (self.pickerOpen) {
        [self dismissPicker:YES];
    }
}


#pragma mark - animations


- (void) presentPicker
{
    if (self.viewForPicker) {
        self.pickerOpen = YES;
        
        CGRect startFrame = self.viewForPicker.frame;
        startFrame.origin.x = 0;
        startFrame.origin.y = startFrame.size.height;
        startFrame.size.height = TMCOUNTRYINPUTHEIGHT;
        
        CGRect endFrame = self.viewForPicker.frame;
        endFrame.origin.x = 0;
        endFrame.origin.y = endFrame.size.height - TMCOUNTRYINPUTHEIGHT;
        endFrame.size.height = TMCOUNTRYINPUTHEIGHT;
        
        CGRect pickerFrame = startFrame;
        pickerFrame.origin.y = 44;
        pickerFrame.size.height = 180;
        
        CGRect doneFrame = self.doneButton.frame;
        doneFrame.origin.x = startFrame.size.width - 60;
        
        self.countryPickerContainer.frame = startFrame;
        self.countryPicker.frame = pickerFrame;
        self.doneButton.frame = doneFrame;
        
        [self.viewForPicker addSubview:self.countryPickerContainer];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(countryInputWillShow:)]) {
            [self.delegate countryInputWillShow:self];
        }
        
        [self rotateArrow:180 animated:YES];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.countryPickerContainer.frame = endFrame;   
        } completion:^(BOOL finished) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(countryInputDidShow:)]) {
                [self.delegate countryInputDidShow:self];
            }
        }];
    }
}


- (void) dismissPicker:(BOOL)animated
{
    CGRect endFrame = self.viewForPicker.frame;
    endFrame.origin.x = 0;
    endFrame.origin.y = endFrame.size.height;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(countryInputWillHide:)]) {
        [self.delegate countryInputWillHide:self];
    }

    self.countryDisplay.image = [self imageForCountryCode:self.selectedCountryCode];
    
    [self rotateArrow:0 animated:animated];
    
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.countryPickerContainer.frame = endFrame;
        } completion:^(BOOL finished) {
            [self.countryPickerContainer removeFromSuperview];
            self.pickerOpen = NO;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(countryInputDidHide:)]) {
                [self.delegate countryInputDidHide:self];
            }
        }];
    }
    else {
        [self.countryPickerContainer removeFromSuperview];
        self.pickerOpen = NO;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(countryInputDidHide:)]) {
            [self.delegate countryInputDidHide:self];
        }
    }
}


- (void) setSelectedCountryCode:(NSString *)countryCode animated:(BOOL)animated
{
    self.countryDisplay.image = [self imageForCountryCode:countryCode];
    [self.countryPicker setSelectedCountryCode:countryCode animated:animated];
    self.selectedCountryCode = countryCode;
    self.selectedCountryName = self.countryPicker.selectedCountryName;
}


#pragma mark - CountryPickerDelegate

- (void)countryPicker:(CountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code
{
    self.selectedCountryCode = code;
    self.selectedCountryName = name;

    if (self.delegate && [self.delegate respondsToSelector:@selector(countryInputSelectionChanged:)]) {
        [self.delegate countryInputSelectionChanged:self];
    }
}


- (UIImage *) imageForCountryCode:(NSString *)countryCode
{
    NSString *imagePath = [NSString stringWithFormat:@"CountryPicker.bundle/%@", countryCode];
    return [UIImage imageNamed:imagePath];
}

- (void) rotateArrow:(NSInteger)degrees animated:(BOOL)animate
{
    CGFloat rot = (M_PI * degrees) / 180;
    
    if (animate) {
        [UIView animateWithDuration:0.28 animations:^{
            self.downArrow.transform = CGAffineTransformMakeRotation(rot);
        }];
    }
    else {
        self.downArrow.transform = CGAffineTransformMakeRotation(rot);
    }
}




@end
