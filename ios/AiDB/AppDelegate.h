/**
 * Application delegate
 */
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

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    
}

/**
 * The main window
 */
@property (strong, nonatomic) UIWindow *window;

/**
 * Application delegate method. Finished launching
 *
 * @returns		Whether or not the launch succeeded
 * @since		20131221
 * @author		costmo
 * @param       application         A reference to the application
 * @param       launchOptions       Application launch options
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

/**
 * Application delegate method. Will enter the background
 *
 * @since		20131221
 * @author		costmo
 * @param       application         A reference to the application
 */
- (void)applicationWillResignActive:(UIApplication *)application;

/**
 * Application delegate method. Has entered the background
 *
 * @since		20131221
 * @author		costmo
 * @param       application         A reference to the application
 */
- (void)applicationDidEnterBackground:(UIApplication *)application;

/**
 * Application delegate method. Will enter the foreground
 *
 * @since		20131221
 * @author		costmo
 * @param       application         A reference to the application
 */
- (void)applicationWillEnterForeground:(UIApplication *)application;

/**
 * Application delegate method. Did resume from the background
 *
 * @since		20131221
 * @author		costmo
 * @param       application         A reference to the application
 */
- (void)applicationDidBecomeActive:(UIApplication *)application;

/**
 * Application delegate method. Application is about to terminate
 *
 * @since		20131221
 * @author		costmo
 * @param       application         A reference to the application
 */
- (void)applicationWillTerminate:(UIApplication *)application;



@end
