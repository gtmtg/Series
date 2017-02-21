//
//  SeriesMathView.m
//  Series
//
//  Created by Mihir Garimella on 5/27/16.
//  Copyright © 2016 Mihir Garimella. All rights reserved.
//

#import "SeriesMathView.h"

@implementation SeriesMathView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 15;
        
        self.baselineColor = [UIColor clearColor];
        self.beautificationOption = MAWBeautifyDisabled;
        self.gesturesEnabled = MAWGesturesOverwrite;
        self.inkColor = [UIColor colorWithWhite:0.25 alpha:1.0];
        
        _border = [CAShapeLayer layer];
        _border.strokeColor = [UIColor colorWithWhite:0.66 alpha:1.0].CGColor;
        _border.fillColor = nil;
        _border.lineDashPattern = @[@6, @5];
        _border.lineWidth = 4;
        [self.layer addSublayer:_border];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _border.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:15].CGPath;
    _border.frame = self.bounds;
}

@end
