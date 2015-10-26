//
//  UIView+MM.m
//  UK Postcode TextField Delegate
//
//  Created by Cornelis van der Bent on 26/10/15.
//  Copyright © 2015 meaning-matters. All rights reserved.
//

#import "UIView+MM.h"


@implementation UIView (MM)

- (id)findViewOfClass:(Class)class inView:(UIView*)view
{
    UIView* foundView;
    
    if ([view isKindOfClass:class])
    {
        foundView = view;
    }
    else
    {
        for (UIView* subview in view.subviews)
        {
            foundView = [self findViewOfClass:class inView:subview];
            
            if (foundView != nil)
            {
                break;
            }
        }
        
        foundView = nil;
    }
    
    return foundView;
}

@end
