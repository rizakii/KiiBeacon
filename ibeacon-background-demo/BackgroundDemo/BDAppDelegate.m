//
//  BDAppDelegate.m
//  BackgroundDemo
//
//  Created by David G. Young on 11/6/13.
//  Copyright (c) 2013 RadiusNetworks. All rights reserved.
//

#import "BDAppDelegate.h"
#import <KiiSDK/Kii.h>

@implementation BDAppDelegate
{
    CLLocationManager *_locationManager;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"applicationDidFinishLaunching");

    // Override point for customization after application launch.
    // Initialize the Kii SDK!
    [Kii beginWithID:@"sandbox"
              andKey:@"dummy" andCustomURL:@"https://dev-jp.internal.kii.com/api"];
    [Kii setLogLevel:3];
    NSError *error = nil;
    [KiiUser authenticateSynchronous:@"sampleApp" withPassword:@"123123" andError:&error];

    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    CLBeaconRegion *region;

    region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"] major: 1 minor: 1 identifier: @"region1"];
    region.notifyEntryStateOnDisplay = YES;
    [_locationManager startMonitoringForRegion:region];
    [_locationManager stopRangingBeaconsInRegion:region];
    //[_locationManager startRangingBeaconsInRegion:region];

    region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"] major: 1 minor: 2 identifier: @"region2"];
    region.notifyEntryStateOnDisplay = YES;
    [_locationManager startMonitoringForRegion:region];
    [_locationManager stopRangingBeaconsInRegion:region];
    //[_locationManager startRangingBeaconsInRegion:region];
    
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    KiiBucket *bucket = [Kii bucketWithName:@"inStore"];
    KiiObject *inObject = [bucket createObject];
    if(state == CLRegionStateInside) {
        NSLog(@"locationManager didDetermineState INSIDE for %@", region.identifier);
        NSError* error = nil;
        [inObject saveSynchronous:&error];
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
        localNotification.alertBody = @"Your have entered the region";
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    else if(state == CLRegionStateOutside) {
        NSLog(@"locationManager didDetermineState OUTSIDE for %@", region.identifier);
    }
    else {
        NSLog(@"locationManager didDetermineState OTHER for %@", region.identifier);
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    // I commented out the line below because otherwise you see this every second in the logs
    // NSLog(@"locationManager didRangeBeacons");
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"applicationWillTerminate");
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder"
                                                        message:notification.alertBody
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    // Request to reload table view data
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
    
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
}
@end

