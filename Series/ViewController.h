//
//  ViewController.h
//  Series
//
//  Created by Mihir Garimella on 5/25/16.
//  Copyright © 2016 Mihir Garimella. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGLayoutView.h"
#import "MIHGradientView.h"
#import "SeriesButton.h"
#import "SeriesMathView.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "AFXMLResponseSerializer.h"

@interface ViewController : UIViewController <MGLayoutViewDelegate, MAWMathViewDelegate> {
    bool lastChangedInsideSigmaMathView;
    NSMutableArray *undoChain;
    AFHTTPRequestOperationManager *solveRequestManager;
    AFHTTPRequestOperationManager *imageRequestManager;
    int dismissCount;
    int dismissCountRequired;
    bool solveSuccessful;
    UIImageView *renderedImageView;
    UIImage *renderedLatex;
    SeriesButton *solve;
    UIView *resultView;
    bool converges;
    NSString *testName;
    UIImage *answerPrettyPrint;
    UIImage *conditionPrettyPrint;
    NSMutableCharacterSet *urlEscape;
    NSData *certificate;
    NSString *bundlePath;
    MIHGradientView *slate;
}

@property SeriesMathView *lowerBound;
@property SeriesMathView *insideSigma;
@property SeriesMathView *replacementLowerBound;

@end

