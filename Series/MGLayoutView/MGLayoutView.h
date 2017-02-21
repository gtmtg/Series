//
//  MGLayoutView.h
//

#import <UIKit/UIKit.h>

@class MGLayoutView;

@protocol MGLayoutViewDelegate <NSObject>

- (void)layoutSubviews:(MGLayoutView *)view;

@end

@interface MGLayoutView : UIView

@property id<MGLayoutViewDelegate> delegate;

@end
