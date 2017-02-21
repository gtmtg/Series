//
//  SeriesButton.h
//  Series
//
//  Created by Mihir Garimella on 5/25/16.
//  Copyright © 2016 Mihir Garimella. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SeriesButton : UIButton {
    UIColor *_color;
}

- (id)initWithFrame:(CGRect)frame text:(NSString *)text color:(UIColor *)color onLeft:(bool)left;

@end
