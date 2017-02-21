//
//  SeriesButton.m
//  Series
//
//  Created by Mihir Garimella on 5/25/16.
//  Copyright © 2016 Mihir Garimella. All rights reserved.
//

#import "SeriesButton.h"

@implementation SeriesButton

- (id)initWithFrame:(CGRect)frame text:(NSString *)text color:(UIColor *)color onLeft:(bool)left
{
    if (self = [super init]) {
        _color = color;
        
        self.frame = frame;
        self.layer.cornerRadius = 15;
        self.layer.borderColor = _color.CGColor;
        self.layer.borderWidth = 2;
        self.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | (left ? UIViewAutoresizingFlexibleRightMargin : UIViewAutoresizingFlexibleLeftMargin));
        
        [self setTitle:text forState:UIControlStateNormal];
        [self setTitleColor:color forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        self.titleLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:15];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.backgroundColor = highlighted ? _color : [UIColor clearColor];
}

@end
