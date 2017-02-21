//
//  MGLayoutView.m
//

#import "MGLayoutView.h"

@implementation MGLayoutView

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_delegate layoutSubviews:self];
}

@end
