//
//
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/2/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

@class THContactTextField;

@protocol THContactTextFieldDelegate <UITextFieldDelegate>

@optional
- (void)textFieldDidChange:(THContactTextField *)textField;
- (void)textFieldDidHitBackspaceWithEmptyText:(THContactTextField *)textField;
- (void)textFieldDidBeginEditing:(THContactTextField *)textField;

@end

@interface THContactTextField : UITextField

@property (nonatomic, assign) id <THContactTextFieldDelegate>delegate;

@end
