//
//  AppDelegate.m
//  Series
//
//  Created by Mihir Garimella on 5/25/16.
//  Copyright © 2016 Mihir Garimella. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    ViewController *viewController = [[ViewController alloc] init];
    self.window.rootViewController = viewController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
