//
//  UIView+MM.h
//  UK Postcode TextField Delegate
//
//  Created by Cornelis van der Bent on 26/10/15.
//  Copyright © 2015 meaning-matters. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (MM)

/**
 *  Finds the first subview of given class by recursively walking down view's subview tree.
 */
- (id)findViewOfClass:(Class)class inView:(UIView*)view;

@end
