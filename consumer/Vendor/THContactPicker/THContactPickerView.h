//
//
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/2/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THContactView.h"

@class THContactPickerView;

@protocol THContactPickerDelegate <NSObject>

@optional

- (void)contactPickerTextViewDidChange:(NSString *)textViewText;
- (void)contactPickerDidRemoveContact:(id)contact;
- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView;
- (BOOL)contactPickerTextFieldShouldReturn:(UITextField *)textField;
- (void)contactPickerTextDidBeginEditing:(UITextField *)textField;
- (BOOL)contactPickerTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

@end

@interface THContactPickerView : UIView <UITextViewDelegate, THContactViewDelegate, UIScrollViewDelegate, UITextInputTraits>

@property (nonatomic, strong) THContactView *selectedContactView;
@property (nonatomic, assign) IBOutlet id <THContactPickerDelegate>delegate;

@property (nonatomic, assign) BOOL limitToOne;				// only allow the ContactPicker to add one contact
@property (nonatomic, assign) CGFloat verticalPadding;		// amount of padding above and below each contact view
@property (nonatomic, assign) NSInteger maxNumberOfLines;	// maximum number of lines the view will display before scrolling
@property (nonatomic, strong) UIFont *font;

@property (nonatomic, strong) THContactTextField *textField;

- (void)addContact:(id)contact withName:(NSString *)name;
- (void)removeContact:(id)contact;
- (void)removeAllContacts;
- (BOOL)resignFirstResponder;

// View Customization
- (void)setContactViewStyle:(THContactViewStyle *)color selectedStyle:(THContactViewStyle *)selectedColor;
- (void)setPlaceholderLabelText:(NSString *)text;
- (void)setPlaceholderLabelTextColor:(UIColor *)color;
- (void)setPromptLabelText:(NSString *)text;
- (void)setPromptLabelAttributedText:(NSAttributedString *)attributedText;
- (void)setPromptLabelTextColor:(UIColor *)color;
- (void)setFont:(UIFont *)font;

- (void)updateKeyboardType:(UIKeyboardType)type;
- (void)textFieldBecomeFirstResponderWithKeyboardType:(UIKeyboardType)type;
- (void)setTextFieldInputAccessoryView:(UIView *)view;
- (void)removeLastEnteredTextFieldText;

@end
