//
//  ViewController.m
//  Series
//
//  Created by Mihir Garimella on 5/25/16.
//  Copyright © 2016 Mihir Garimella. All rights reserved.
//

#import "MyCertificate.h"
#import "ViewController.h"

#define UIColorFromHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

const NSString *wolframAlphaAppId = @"[API KEY HERE]";

@implementation ViewController

- (id)init
{
    if (self = [super init]) {
        MGLayoutView *view = [[MGLayoutView alloc] initWithFrame:self.view.frame];
        view.delegate = self;
        view.backgroundColor = [UIColor whiteColor];
        self.view = view;
        
        UIView *statusBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
        statusBarBackground.backgroundColor = [UIColor blackColor];
        statusBarBackground.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin);
        [self.view addSubview:statusBarBackground];
        
        slate = [[MIHGradientView alloc] initWithColor:[UIColor whiteColor] to:UIColorFromHex(0xE7E7EB)];
        slate.frame = CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height - 200);
        slate.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        [self.view addSubview:slate];
        
        UIImageView *instructions = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"instructions.png"]];
        instructions.frame = CGRectMake((self.view.bounds.size.width / 2) - 275, 20, 550, 122);
        instructions.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
        [slate addSubview:instructions];
        
        _lowerBound = [[SeriesMathView alloc] initWithFrame:CGRectMake(0, 0, 63, 63)];
        _lowerBound.inkThickness = 1.15;
        _lowerBound.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
        [slate addSubview:_lowerBound];
        
        UIImageView *instructions2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"instructions2.png"]];
        instructions2.frame = CGRectMake(40, self.view.bounds.size.height - 312, 293, 20);
        instructions2.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin);
        [slate addSubview:instructions2];
        
        _insideSigma = [[SeriesMathView alloc] initWithFrame:CGRectMake(20, 163, self.view.bounds.size.width - 40, self.view.bounds.size.height - 490)];
        _insideSigma.inkThickness = 1.4;
        _insideSigma.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [slate addSubview:_insideSigma];
        
        certificate = [NSData dataWithBytes:myCertificate.bytes length:myCertificate.length];
        bundlePath = [[[NSBundle mainBundle] pathForResource:@"resources" ofType:@"bundle"] stringByAppendingPathComponent:@"conf"];
        
        if ([_lowerBound registerCertificate:certificate]) {
            _lowerBound.delegate = self;
            [_lowerBound addSearchDir:bundlePath];
            [_lowerBound configureWithBundle:@"math" andConfig:@"standard"];
        }
        
        if ([_insideSigma registerCertificate:certificate]) {
            _insideSigma.delegate = self;
            [_insideSigma addSearchDir:bundlePath];
            [_insideSigma configureWithBundle:@"math" andConfig:@"standard"];
        }
        
        SeriesButton *clear = [[SeriesButton alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height - 256, 67, 36) text:@"Clear" color:UIColorFromHex(0xCE2D38) onLeft:YES];
        [clear addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
        [slate addSubview:clear];
        
        SeriesButton *undo = [[SeriesButton alloc] initWithFrame:CGRectMake(102, self.view.bounds.size.height - 256, 67, 36) text:@"Undo" color:UIColorFromHex(0x0365C0) onLeft:YES];
        [undo addTarget:self action:@selector(undo) forControlEvents:UIControlEventTouchUpInside];
        [slate addSubview:undo];

        solve = [[SeriesButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 87, self.view.bounds.size.height - 256, 67, 36) text:@"Solve" color:UIColorFromHex(0x00882B) onLeft:NO];
        [solve addTarget:self action:@selector(solve:) forControlEvents:UIControlEventTouchUpInside];
        [slate addSubview:solve];
        
        UIImageView *shadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow.png"]];
        shadow.frame = CGRectMake(0, self.view.bounds.size.height - 180, self.view.bounds.size.width, 18);
        shadow.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
        [self.view addSubview:shadow];
        
        UIImageView *credits = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"credits.png"]];
        credits.frame = CGRectMake(self.view.bounds.size.width - 258, self.view.bounds.size.height - 70, 238, 50);
        credits.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin);
        [self.view addSubview:credits];
        
        imageRequestManager = [AFHTTPRequestOperationManager manager];
        imageRequestManager.responseSerializer = [AFImageResponseSerializer serializer];
        
        solveRequestManager = [AFHTTPRequestOperationManager manager];
        solveRequestManager.responseSerializer = [AFXMLResponseSerializer new];
        
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        
        dismissCount = 0;
        undoChain = [NSMutableArray array];
        
        renderedImageView = [[UIImageView alloc] init];
        renderedImageView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin);
        renderedImageView.hidden = YES;
        [self.view addSubview:renderedImageView];
        
        resultView = [[UIView alloc] init];
        resultView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
        resultView.hidden = YES;
        resultView.clipsToBounds = YES;
        [self.view addSubview:resultView];
    }
    
    return self;
}

// Delegate Methods -- View Controller

- (void)layoutSubviews:(MGLayoutView *)view
{
    _lowerBound.frame = CGRectMake((self.view.bounds.size.width / 2) + 10, 33, 63, 63);
}

// Delegate Methods -- Math View

- (void)mathViewDidEndWriting:(SeriesMathView *)mathView
{
    [undoChain addObject:@(mathView == _insideSigma)];
}

// Actions

- (void)solve:(UIButton *)sender
{
    if (![_lowerBound.resultAsText isEqualToString:@""] && ![_insideSigma.resultAsText isEqualToString:@""]) {
        [SVProgressHUD show];
        
        solveSuccessful = YES;
        dismissCountRequired = 2;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            while (_lowerBound.isBusy || _insideSigma.isBusy) { }

            NSString *lowerBound = [self fixLaTeX:_lowerBound.resultAsLaTeX];
            NSString *insideSigma = [self fixLaTeX:_insideSigma.resultAsLaTeX];
            NSString *query = [NSString stringWithFormat:@"\\sum_{n=%@}^{\\infty} %@", lowerBound, insideSigma];
            NSString *codeCogsURL = [@"http://latex.codecogs.com/png.latex?%5Cdpi%7B300%7D%20" stringByAppendingString:[self urlEncode:query]];
            NSString *wolframURL = [self urlWithBase:@"http://api.wolframalpha.com/v2/query" andParameters:@{@"input": query, @"appid": wolframAlphaAppId }];
            
            NSLog(@"%@\n", query);
            
            [imageRequestManager GET:codeCogsURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                renderedLatex = responseObject;
                [self halfDismiss:YES];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Image error: %@", error);
                [self halfDismiss:NO];
            }];
            
            [solveRequestManager GET:wolframURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                bool error = YES;
                conditionPrettyPrint = [[UIImage alloc] init];
                answerPrettyPrint = [[UIImage alloc] init];
                testName = @"";
                
                @try {
                    for (NSDictionary *pod in responseObject[@"pod"]) {
                        NSString *id = pod[@"_id"];
                        
                        if ([id isEqualToString:@"Result"]) {
                            NSString *result = pod[@"subpod"][0][@"plaintext"][0];
                            
                            if ([result rangeOfString:@"does not converge"].location != NSNotFound) {
                                converges = NO;
                                error = NO;
                            } else if ([result rangeOfString:@"converges"].location != NSNotFound) {
                                converges = YES;
                                error = NO;
                            }
                            
                            NSUInteger conditionIndex = [result rangeOfString:@" when "].location;
                            if (conditionIndex != NSNotFound) {
                                dismissCountRequired++;
                                NSString *condition = [result componentsSeparatedByString:@" when "][1];
                                [self wolframPrettyPrint:condition forCondition:YES];
                            }
                            
                            NSArray *equalParts = [(conditionIndex == NSNotFound ? result : [result substringWithRange:NSMakeRange(0, conditionIndex)]) componentsSeparatedByString:@"="];
                            if (equalParts.count >= 3) {
                                dismissCountRequired++;
                                NSString *convergesTo = [equalParts lastObject];
                                [self wolframPrettyPrint:convergesTo forCondition:NO];
                            }
                            
                            // to what?
                                // can we parse the answer in a nicer way?
                            // conditional on anything
                                // conditional on what?
                                // can we parse the condition in a nicer way?
                        } else if ([id isEqualToString:@"ConvergenceTests"]) {
                            for (int n = 0; ; n++) {
                                NSString *convergence = pod[@"subpod"][n][@"plaintext"][0];
                                
                                bool converges_ = [convergence rangeOfString:@"converges"].location != NSNotFound;
                                
                                if (converges_ || [convergence rangeOfString:@"diverges"].location != NSNotFound) {
                                    NSArray *convergenceParts = [convergence componentsSeparatedByString:@", "];
                                    
                                    NSArray *testParts = [convergenceParts[0] componentsSeparatedByString:@" "];
                                    testName = [[testParts subarrayWithRange:NSMakeRange(2, testParts.count - 3)] componentsJoinedByString:@" "].capitalizedString;
                                    
                                    converges = converges_;
                                    
                                    // by what test?
                                        // if conditional, we only care about the test
                                    
                                    error = NO;
                                    break;
                                }
                            }
                        }
                    }
                } @catch (NSException *exception) {
                    NSLog(@"Parse error: %@", exception);
                } @finally {
                    [self halfDismiss:!error];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Solver error: %@", error);
                [self halfDismiss:NO];
            }];
        });
    } else {
        [self shake:sender];
    }
}

- (void)clear
{
    [_lowerBound removeFromSuperview];
    _lowerBound = [[SeriesMathView alloc] initWithFrame:CGRectMake(0, 0, 63, 63)];
    _lowerBound.inkThickness = 1.15;
    _lowerBound.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
    [slate addSubview:_lowerBound];
    
    if ([_lowerBound registerCertificate:certificate]) {
        _lowerBound.delegate = self;
        [_lowerBound addSearchDir:bundlePath];
        [_lowerBound configureWithBundle:@"math" andConfig:@"standard"];
    }
    
    [_insideSigma removeFromSuperview];
    _insideSigma = [[SeriesMathView alloc] initWithFrame:CGRectMake(20, 163, self.view.bounds.size.width - 40, self.view.bounds.size.height - 490)];
    _insideSigma.inkThickness = 1.4;
    _insideSigma.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [slate addSubview:_insideSigma];
    
    if ([_insideSigma registerCertificate:certificate]) {
        _insideSigma.delegate = self;
        [_insideSigma addSearchDir:bundlePath];
        [_insideSigma configureWithBundle:@"math" andConfig:@"standard"];
    }
    
    [self.view setNeedsLayout];
    
    [undoChain removeAllObjects];
    renderedImageView.hidden = YES;
    resultView.hidden = YES;
}

- (void)undo
{
    if (undoChain.count > 0) {
        [([[undoChain lastObject] boolValue] ? _insideSigma : _lowerBound) undo];
        [undoChain removeLastObject];
    }
}

- (void)halfDismiss:(BOOL)success
{
    if (!success) {
        solveSuccessful = NO;
    }
    
    if (++dismissCount == dismissCountRequired) {
        dismissCount = 0;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (solveSuccessful) {
                renderedImageView.hidden = NO;
                renderedImageView.image = renderedLatex;
                CGFloat width = 60 / renderedLatex.size.height * renderedLatex.size.width;
                renderedImageView.frame = CGRectMake(20, self.view.bounds.size.height - 116, width, 60);
                
                [resultView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                
                bool conditional = conditionPrettyPrint.size.width != 0;
                bool answer = answerPrettyPrint.size.width != 0;
                
                UILabel *convergesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, resultView.bounds.size.width, 20)];
                if ([testName isEqualToString:@""]) {
                    convergesLabel.text = (converges || conditional) ? @"Converges" : @"Diverges";
                } else {
                    convergesLabel.text = [NSString stringWithFormat:@"%@ (%@)", ((converges || conditional) ? @"Converges" : @"Diverges"), testName];
                }
                convergesLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:17];
                convergesLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin);
                [resultView addSubview:convergesLabel];
                
                CGFloat heightSoFar = 32;
                if (conditional) {
                    CGFloat conditionHeight = conditionPrettyPrint.size.height / 1.9;
                    bool imageBiggerThanLabel = YES;
                    CGFloat paddingToAlign;
                    if (conditionHeight < 17) {
                        imageBiggerThanLabel = NO;
                        paddingToAlign = (17 - conditionHeight) / 2;
                        conditionHeight = 17;
                    } else {
                        paddingToAlign = (conditionHeight - 17) / 2;
                    }
                    
                    UIView *conditionView = [[UIView alloc] initWithFrame:CGRectMake(0, heightSoFar, resultView.bounds.size.width, conditionHeight)];
                    conditionView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin);
                    heightSoFar += conditionHeight + 9;
                    [resultView addSubview:conditionView];
                    
                    UILabel *conditionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imageBiggerThanLabel ? paddingToAlign : 0, 79, 17)];
                    conditionLabel.text = @"Condition:";
                    conditionLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:15];
                    [conditionView addSubview:conditionLabel];
                    
                    UIImageView *conditionImageView = [[UIImageView alloc] initWithImage:conditionPrettyPrint];
                    conditionImageView.frame = CGRectMake(79, imageBiggerThanLabel ? -1 : (paddingToAlign - 1), conditionPrettyPrint.size.width / 1.9, conditionPrettyPrint.size.height / 1.9);
                    [conditionView addSubview:conditionImageView];
                }
                
                if (answer) {
                    CGFloat answerHeight = answerPrettyPrint.size.height / 1.9;
                    bool imageBiggerThanLabel = YES;
                    CGFloat paddingToAlign;
                    if (answerHeight < 17) {
                        imageBiggerThanLabel = NO;
                        paddingToAlign = (17 - answerHeight) / 2;
                        answerHeight = 17;
                    } else {
                        paddingToAlign = (answerHeight - 17) / 2;
                    }
                    
                    UIView *answerView = [[UIView alloc] initWithFrame:CGRectMake(0, heightSoFar, resultView.bounds.size.width, answerHeight)];
                    answerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin);
                    heightSoFar += answerHeight;
                    [resultView addSubview:answerView];
                    
                    UILabel *answerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imageBiggerThanLabel ? paddingToAlign : 0, 50, 17)];
                    answerLabel.text = @"Result:";
                    answerLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:15];
                    [answerView addSubview:answerLabel];
                    
                    UIImageView *answerImageView = [[UIImageView alloc] initWithImage:answerPrettyPrint];
                    answerImageView.frame = CGRectMake(50, imageBiggerThanLabel ? 0 : paddingToAlign, answerPrettyPrint.size.width / 1.9, answerPrettyPrint.size.height / 1.9);
                    [answerView addSubview:answerImageView];
                }
                
                resultView.frame = CGRectMake(width + 50, self.view.bounds.size.height - 86 - (heightSoFar / 2), self.view.bounds.size.width - width - 328, heightSoFar);
                resultView.hidden = NO;
            } else {
                [self shake:solve];
            }
            
            [SVProgressHUD dismiss];
        });
    }
}

- (void)shake:(UIButton *)button
{
    button.transform = CGAffineTransformMakeTranslation(16, 0);
    [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.2 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        button.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (NSString *)fixLaTeX:(NSString *)input
{
    NSUInteger length = input.length;
    unichar input_[length + 1];
    [input getCharacters:input_ range:NSMakeRange(0, length)];
    
    NSMutableString *output = [NSMutableString string];
    
    for(int i = 0; i < length; i++) {
        unichar this = input_[i];
        
        if (this != ' ') {
            [output appendFormat:@"%C", this];
        } else if (i != length - 1) {
            unichar next = input_[i + 1];
            if ((next >= 'a' && next <= 'z') ||
                (next >= 'A' && next <= 'Z') ||
                (next >= '0' && next <= '9')) {
                [output appendString:@" "];
            }
        }
        if (this == '}' && i != length - 1 && input_[i + 1] != '{') {
            [output appendString:@" "];
        }
    }
    
    return (NSString *)(output);
}

- (void)wolframPrettyPrint:(NSString *)input forCondition:(BOOL)forCondition
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSString *regularImageURL;
        __block bool regularWorked = NO;
        dispatch_semaphore_t regularSemaphore = dispatch_semaphore_create(0);
        
        __block NSString *solvedImageURL;
        __block bool solveWorked = NO;
        __block bool noSolutions = NO;
        dispatch_semaphore_t solveSemaphore = dispatch_semaphore_create(0);
        
        NSString *regularRequestURL = [self urlWithBase:@"http://api.wolframalpha.com/v2/query" andParameters:@{@"input": input, @"appid": @"Q927KA-Y4W5V3H4E4", @"mag": @"2"}];
        AFHTTPRequestOperation *regularOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:regularRequestURL]]];
        regularOperation.responseSerializer = [AFXMLResponseSerializer new];
        [regularOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            @try {
                for (NSDictionary *pod in responseObject[@"pod"]) {
                    if ([pod[@"_id"] isEqualToString:@"Input"]) {
                        regularImageURL = pod[@"subpod"][0][@"img"][0][@"_src"];
                        regularWorked = YES;
                        break;
                    }
                }
            } @catch (NSException *exception) {

            } @finally {
                dispatch_semaphore_signal(regularSemaphore);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Pretty print (regular) error: %@", error);
            dispatch_semaphore_signal(regularSemaphore);
        }];
        
        [regularOperation start];
        
        if (forCondition) {
            NSString *solveRequestURL = [self urlWithBase:@"http://api.wolframalpha.com/v2/query" andParameters:@{@"input": [@"solve" stringByAppendingString:input], @"appid": @"Q927KA-Y4W5V3H4E4", @"mag": @"2"}];
            AFHTTPRequestOperation *solveOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:solveRequestURL]]];
            solveOperation.responseSerializer = [AFXMLResponseSerializer new];
            [solveOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                @try {
                    for (NSDictionary *pod in responseObject[@"pod"]) {
                        NSString *title = pod[@"_title"];
                        if ([title isEqualToString:@"Solution over the reals"]) {
                            NSString *plaintext = pod[@"subpod"][0][@"plaintext"][0];
                            if ([plaintext rangeOfString:@"n element Z"].location == NSNotFound) {
                                solvedImageURL = pod[@"subpod"][0][@"img"][0][@"_src"];
                                solveWorked = YES;
                            }
                        } else if ([title isEqualToString:@"Result"]) {
                            NSString *plaintext = pod[@"subpod"][0][@"plaintext"][0];
                            if ([plaintext isEqualToString:@"(no solutions exist)"]) {
                                noSolutions = YES;
                                break;
                            }
                        }
                    }
                } @catch (NSException *exception) {
                    
                } @finally {
                    dispatch_semaphore_signal(solveSemaphore);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Pretty print (solve) error: %@", error);
                dispatch_semaphore_signal(solveSemaphore);
            }];
            
            [solveOperation start];
            dispatch_semaphore_wait(solveSemaphore, DISPATCH_TIME_FOREVER);
        }
        
        dispatch_semaphore_wait(regularSemaphore, DISPATCH_TIME_FOREVER);
        
        UIImage *output;
        if (noSolutions) {
            output = [[UIImage alloc] init];
        } else if (solveWorked) {
            output = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:solvedImageURL]]];
        } else if (regularWorked) {
            output = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:regularImageURL]]];
        } else {
            output = [[UIImage alloc] init];
        }
        if (forCondition) {
            conditionPrettyPrint = output;
        } else {
            answerPrettyPrint = output;
        }
        [self halfDismiss:YES];
    });
}

- (NSString *)urlWithBase:(NSString *)base andParameters:(NSDictionary *)parameters
{
    NSMutableArray *parameterPairs = [NSMutableArray array];
    for (NSString *key in parameters) {
        [parameterPairs addObject:[NSString stringWithFormat:@"%@=%@", key, [self urlEncode:parameters[key]]]];
    }
    return [NSString stringWithFormat:@"%@?%@", base, [parameterPairs componentsJoinedByString:@"&"]];
}

- (NSString *)urlEncode:(NSString *)input
{
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)(input.UTF8String);
    size_t sourceLen = strlen((const char *)(source));
    for (size_t i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"%20"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return (NSString *)(output);
}

@end
