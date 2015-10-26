//
//  MMPostcodeTextFieldFormatter.h
//  UK Postcode TextField Delegate
//
//  Created by Cornelis van der Bent on 26/10/15.
//  Copyright © 2015 meaning-matters. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 *  This class' main purpose is to limit the number of keyboard switches,
 *  between letters and digits (using the [123] and [ABC] keys), the user
 *  has to make when typing a UK postcode.
 *
 *  Additionally it automatically places the space between the outward and
 *  inward code.
 *
 *  On a backspace, the keyboard type is set to what it was when the user
 *  typed the just deleted character.  This is by far the best guess because
 *  the chance of mistakingly typing the character type is very low.  In other
 *  words, it's almost 100% certain that when the user goes back, he wants
 *  a different letter or a different digit than the one that was typed in error.
 *
 *  Here's the complete list of valid UK postcode formats:
 *
 *      Format      Example     Example Place
 *      --------    --------    ------------------------------------------------
 *      @# #@@      B1 1AA      Royal Mail Central Birmingham Delivery Office
 *      @## #@@     M60 2LA     Manchester City Council
 *      @@# #@@     SA6 7JL     Driver and Vehicle Licensing Authority, Swansea
 *      @@## #@@    SO17 1BJ    University of Southampton
 *      @#@ #@@     W1D 1AN     Tottenham Court Road Tube Station, London
 *      @@#@ #@@    EC2R 8AH	Bank of England, London
 *
 *  In the format, @ represents a letter, and # a digit.
 *
 *  For each character typed it goes through the list of possible letter/digit
 *  UK postcode formats.  If there's a match, it determines what the keyboard
 *  type of the next character is.  If one of the matches requires the current
 *  keyboard type, the keyboard type will not be changed, even if other matches
 *  do require a keyboard switch.  We don't want to user to undo an automatic
 *  switch because it looks as if the app just made a mistake which the user
 *  than feels has to undo, and that's a bad thing.
 *
 *  Only the characers A..Z, 0..9 and a space are accepted, all other input
 *  is ignored.  Double spaces are also ignored.  However, this class purposely
 *  allows the user to type any combination of this allowed set of characters;
 *  We never want to forcefully limit the characters that can be typed.  Because
 *  this is very annoying for a person, even if a typo is made.  And, this would
 *  be very dangerous, because it could limit the use of the app in case
 *  the algorithm has bugs or is not up to date with UK postcodes changes.
 *
 *  When the user copy-pastes a string, no changes are made to it.  Of course,
 *  when that string does not match any of UK postcode formats, the keyboard
 *  type is simply left alone.
 *
 *  When editing the postcode with the cursor before the end of the typed text,
 *  no keyboard switching is done.  This also applies to cutting more than one
 *  character.
 */
@interface MMPostcodeTextFieldFormatter : NSObject

/**
 *  Creates an initialized `MMPostcodeTextFieldFormatter` object.
 *
 *  @param textField    The `UITextField` it will format it's text of.
 */
- (instancetype)initWithTextField:(UITextField*)textField;

/**
 *  Creates an initialized `MMPostcodeTextFieldFormatter` object.
 *
 *  The searchBar's enclosed `UITextField` is found, after which `initWithTextField`
 *  is called.
 *
 *  @param searchBar    The `UISearchBar` whose text field will be used.
 */
- (instancetype)initWithSearchBar:(UISearchBar*)searchBar;

/**
 *  This method must be called from the the text field's or search bar's
 *  `shouldChangeCharactersInRange` delegate method.  It implements the
 *  regular text editing logic normally found in this method.
 */
- (BOOL)shouldChangeText:(NSString*)text inRange:(NSRange)range;

@end
