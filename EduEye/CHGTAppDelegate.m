//
//  CHGTAppDelegate.m
//  EduEye
//
//  Created by Einari Kurvinen on 16/03/14.
//  Copyright (c) 2014 chgt. All rights reserved.
//

#import "CHGTAppDelegate.h"

@implementation CHGTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Prevent display from sleeping
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    CHGTViewController *vc = [[CHGTViewController alloc] init];
    [vc stopServer];
    [vc stopImageStreaming];

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    CHGTViewController *vc = [[CHGTViewController alloc] init];
    [vc stopServer];
    [vc stopImageStreaming];

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    CHGTViewController *vc = [[CHGTViewController alloc] init];
    //NSLog(@"Delegate speaking");
   [vc startServer];
    //[vc startImageStreaming];

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    CHGTViewController *vc = [[CHGTViewController alloc] init];
    [vc stopServer];
    [vc stopImageStreaming];
}

@end
