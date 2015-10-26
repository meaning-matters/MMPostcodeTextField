//
//  ViewController.m
//  MMPostcodeTextField
//
//  Created by Cornelis van der Bent on 26/10/15.
//  Copyright © 2015 meaning-matters. All rights reserved.
//

#import "ViewController.h"
#import "MMPostcodeTextFieldFormatter.h"


@interface ViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField*           textField;
@property (nonatomic, strong) MMPostcodeTextFieldFormatter* textFieldFormatter;

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textFieldFormatter = [[MMPostcodeTextFieldFormatter alloc] initWithTextField:self.textField];
}


#pragma mark - TextField Delegate

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    return [self.textFieldFormatter shouldChangeText:string inRange:range];
}

@end
