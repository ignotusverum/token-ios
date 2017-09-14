//
//  TMCountryInput.h
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 1/20/16
//

#import <UIKit/UIKit.h>

#import "CountryPicker.h"

@class TMCountryInput;

// picker height 180 + "Done" toolbar 44 = 224
#define TMCOUNTRYINPUTHEIGHT 224.0


@protocol TMCountryInputDelegate <NSObject>

@optional
- (void) countryInputWillShow:(TMCountryInput *)picker;
- (void) countryInputDidShow:(TMCountryInput *)picker;
- (void) countryInputWillHide:(TMCountryInput *)picker;
- (void) countryInputDidHide:(TMCountryInput *)picker;
- (void) countryInputSelectionChanged:(TMCountryInput *)picker;

@end


@interface TMCountryInput : UIView <CountryPickerDelegate>

- (void) presentPicker;
- (void) updateStyle:(BOOL)isLight;
- (void) dismissPicker:(BOOL)animated;
- (void) setSelectedCountryCode:(NSString *)countryCode animated:(BOOL)animated;
- (UIImage *) imageForCountryCode:(NSString *)countryCode;

@property BOOL pickerOpen;
@property (nonatomic, strong) NSString * selectedCountryCode;
@property (nonatomic, strong) NSString * selectedCountryName;
@property (nonatomic, strong) IBOutlet UIView * viewForPicker;
@property (nonatomic, strong) IBOutlet id<TMCountryInputDelegate> delegate;

@end
