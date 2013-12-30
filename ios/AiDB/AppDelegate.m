/**
 *
 * This file is part of the APP(ideas) database abstraction project (AiDb).
 * Copyright 2013, APPideas
 *
 * AiDb is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * AiDb is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with AiDb (in the 'resources' directory). If not, see
 * <http://www.gnu.org/licenses/>.
 * http://appideas.com/abstract-your-database-introduction
 *
 */

#import "AppDelegate.h"
#import "AiDatabase.h"
#import "MainViewController.h"

@implementation AppDelegate

// Application delegate method. Finished launching
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    /*
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    */
    [AiDatabase createDatabase];
    AiDatabase *db = [[AiDatabase alloc] init];
    [db doUpgrade];
    /*
    MainViewController *vc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    self.window.rootViewController = vc;
    
    [self.window makeKeyAndVisible];
     */
    
    return YES;
}

// Application delegate method. Will enter the background
- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

// Application delegate method. Has entered the background
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

// Application delegate method. Will enter the foreground
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

// Application delegate method. Did resume from the background
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}

// Application delegate method. Application is about to terminate
- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

@end
