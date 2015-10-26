//
//  MMPostcodeTextFieldFormatter.m
//  UK Postcode TextField Delegate
//
//  Created by Cornelis van der Bent on 26/10/15.
//  Copyright © 2015 meaning-matters. All rights reserved.
//
//  Resource used: http://www.doogal.co.uk/PostcodeDistricts.php

#import "MMPostcodeTextFieldFormatter.h"
#import "UIView+MM.h"


typedef NS_ENUM(NSInteger, MMPostcodeToken)
{
    MMPostcodeTokenSpace  = ' ',
    MMPostcodeTokenLetter = '@',
    MMPostcodeTokenDigit  = '#',
};


@interface MMPostcodeTextFieldFormatter ()

@property (nonatomic, strong) UITextField*           textField;
@property (nonatomic, strong) NSDictionary*          outwardCodes;
@property (nonatomic, strong) NSArray*               formats;
@property (nonatomic, assign) BOOL                   deleted; // Indicates that a character was deleted.
@property (nonatomic, strong) NSMutableCharacterSet* specialCharactersSet;

@end


@implementation MMPostcodeTextFieldFormatter

#pragma mark - Life Cycle

- (instancetype)initWithTextField:(UITextField*)textField;
{
    if (self = [super init])
    {
        self.textField = textField;
        
        self.formats = @[@"@# #@@", @"@## #@@", @"@@# #@@", @"@@## #@@", @"@#@ #@@", @"@@#@ #@@"];
        
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        self.textField.autocorrectionType     = UITextAutocorrectionTypeNo;
        self.textField.keyboardType           = UIKeyboardTypeDefault;
        
        [self initOutwardCodes];
        [self initSpecialCharactersSet];
        [self startObservingTextChanges];
    }
    
    return self;
}


- (instancetype)initWithSearchBar:(UISearchBar*)searchBar
{
    UITextField* textField = [searchBar findViewOfClass:[UITextField class] inView:searchBar];
    if (textField != nil)
    {
        return [self initWithTextField:textField];
    }
    else
    {
        return nil;
    }
}


- (void)dealloc
{
    [self.textField removeTarget:self action:@selector(textDidChange) forControlEvents:UIControlEventEditingChanged];
}


#pragma mark - Public API

- (BOOL)shouldChangeText:(NSString*)text inRange:(NSRange)range
{
    text = [text uppercaseString];
    
    self.deleted = (text.length == 0);
    
    // Ignore double spaces.
    if (!self.deleted && [self.textField.text characterAtIndex:(self.textField.text.length - 1)] == ' ' && [text isEqualToString:@" "])
    {
        return NO;
    }
    
    // Ignore leading spaces.
    if (!self.deleted && (self.textField.text.length == 0) && [text isEqualToString:@" "])
    {
        return NO;
    }
    
    // Ignore special characters.
    if (!self.deleted && [self.specialCharactersSet characterIsMember:[text characterAtIndex:0]])
    {
        return NO;
    }
    
    // Ignore edit done halfway the text.
    if (self.textField.text.length > (range.location + 1))
    {
        return YES;
    }
    
    // Set the current keyboardType according to the typed character.  The user may
    // have switched from letters to digits, and that switch is leading.  If we don't
    // take this into acccount, the keyboardType may change unexpectedly for some postcode
    // formats.  An example is W11 where the keyboard type stays at letters after the W, so
    // the following 1 is type by switching the keyboard manually to digits.  Without this
    // extra logic, the prediction would be letters which would cause the keyboard to switch,
    // and that looks as if the app made a mistake that now has to be corrected; not good!
    if (text.length == 1)
    {
        MMPostcodeToken token = [self postcodeTokenForCharacter:[text characterAtIndex:0]];
        self.textField.keyboardType = [self keyboardTypeForPostcodeToken:token];
    }
    
    NSString*      code         = [self.textField.text stringByReplacingCharactersInRange:range withString:text];
    UIKeyboardType keyboardType = [self predictKeyboardTypeWithCode:code];
    
    [self setKeyboardType:keyboardType];
    
    return YES;
}


- (void)setKeyboardType:(UIKeyboardType)keyboardType
{
    if (keyboardType == UIKeyboardTypeDefault)
    {
        [self.textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
        [self.textField reloadInputViews];
        
        [self.textField setKeyboardType:UIKeyboardTypeDefault];
        [self.textField reloadInputViews];
    }
    else
    {
        [self.textField setKeyboardType:UIKeyboardTypeDefault];
        [self.textField reloadInputViews];
        
        [self.textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
        [self.textField reloadInputViews];
    }
}


- (BOOL)isValid
{
    NSRange range;
    
    range = [self.textField.text rangeOfString:@"^(GIR ?0AA|[A-PR-UWYZ]([0-9]{1,2}|([A-HK-Y][0-9]([0-9ABEHMNPRV-Y])?)|"
                                                "[0-9][A-HJKPS-UW]) ?[0-9][ABD-HJLNP-UW-Z]{2})$"
                                       options:NSRegularExpressionSearch];
    
    return (range.length > 0);
}


#pragma mark - Helpers

- (void)textDidChange
{
    self.textField.text = [self.textField.text uppercaseString];
    
    if (self.textField.text.length == 0)
    {
        [self setKeyboardType:UIKeyboardTypeDefault];
    }
    
    if (self.textField.text.length <= 4)
    {
        if (self.outwardCodes[self.textField.text] != nil)
        {
            if (self.deleted)
            {
                self.textField.text = [self.textField.text substringToIndex:self.textField.text.length - 1];
            }
            else
            {
                self.textField.text = [self.textField.text stringByAppendingString:@" "];
            }
        }
    }
    
    self.textField.textColor = [self isValid] ? [UIColor blackColor] : [UIColor redColor];
}


- (void)initOutwardCodes
{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"OutwardCodes" ofType:@"json"];
    NSData*   data     = [NSData dataWithContentsOfFile:filePath];
    
    self.outwardCodes  = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}


- (void)initSpecialCharactersSet
{
    self.specialCharactersSet = [NSMutableCharacterSet new];
    
    [self.specialCharactersSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
    [self.specialCharactersSet formUnionWithCharacterSet:[NSCharacterSet symbolCharacterSet]];
    [self.specialCharactersSet removeCharactersInString:@"-"];
}


- (void)startObservingTextChanges
{
    [self.textField addTarget:self action:@selector(textDidChange) forControlEvents:UIControlEventEditingChanged];
}


- (UIKeyboardType)predictKeyboardTypeWithCode:(NSString*)code
{
    MMPostcodeToken token;
    UIKeyboardType  keyboardType;
    
    NSString* format = [self formatForCode:code];
    
    // We only want to change the keyboard if there's no other option. But when a character
    // was deleted, we want to go back to the previous keyboard if it was correct, because the
    // user is probably making a correction.
    if (self.deleted)
    {
        token = [self postcodeTokenForCharacter:[self.textField.text characterAtIndex:(self.textField.text.length - 1)]];
        if (token == MMPostcodeTokenSpace)
        {
            token = [format characterAtIndex:format.length - 1];
        }
        
        keyboardType = [self keyboardTypeForPostcodeToken:token];
    }
    else
    {
        // Quick & dirty optimization for London.
        if (code.length == 3 && [code hasPrefix:@"EC"])
        {
            return UIKeyboardTypeDefault;
        }
        
        // Determine what the keyboard type of last character is.
        if (format.length == 0)
        {
            keyboardType = UIKeyboardTypeDefault;
        }
        else
        {
            keyboardType = [self keyboardTypeForPostcodeToken:[format characterAtIndex:(format.length - 1)]];
        }
        
        for (NSString *possibleFormat in self.formats)
        {
            if ([possibleFormat hasPrefix:format])
            {
                if (possibleFormat.length > format.length)
                {
                    token        = [possibleFormat characterAtIndex:format.length];
                    keyboardType = [self keyboardTypeForPostcodeToken:token];
                    
                    if (keyboardType == self.textField.keyboardType)
                    {
                        // The current keyboard is a possible one, so we don't need to
                        // check other, because we're keeping the current one.
                        break;
                    }
                }
            }
        }
    }
    
    return keyboardType;
}


- (MMPostcodeToken)postcodeTokenForCharacter:(unichar)character
{
    MMPostcodeToken postcodeToken;
    
    if (character == ' ')
    {
        postcodeToken = MMPostcodeTokenSpace;
    }
    else if ([[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"] characterIsMember:character])
    {
        postcodeToken = MMPostcodeTokenLetter;
    }
    else if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:character])
    {
        postcodeToken = MMPostcodeTokenDigit;
    }
    else
    {
        postcodeToken = MMPostcodeTokenLetter;
    }
    
    return postcodeToken;
}


- (NSString *)formatForCode:(NSString*)code
{
    NSMutableString *format = [NSMutableString string];
    
    for (NSUInteger index = 0; index < code.length; index++)
    {
        unichar character = [code characterAtIndex:index];
        [format appendFormat:@"%c", (char)[self postcodeTokenForCharacter:character]];
    }
    
    return [NSString stringWithString:format];
}


- (UIKeyboardType)keyboardTypeForPostcodeToken:(MMPostcodeToken)token
{
    switch (token)
    {
        case MMPostcodeTokenSpace:  return UIKeyboardTypeNumbersAndPunctuation;
        case MMPostcodeTokenLetter: return UIKeyboardTypeDefault;
        case MMPostcodeTokenDigit:  return UIKeyboardTypeNumbersAndPunctuation;
    }
}

@end
