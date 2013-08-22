//
//  AppDelegate.m
//  History
//
//  Created by Srikanth Sombhatla on 21/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "HistoryMediator.h"
#import "HistoryConstants.h"

@interface AppDelegate() {
}

- (void) saveAsFavorite;

@property (retain,nonatomic) HistoryMediator* mediator;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize mediator = _mediator;


// pimpl
- (void) saveAsFavorite {
    NSLog(@"%s",__PRETTY_FUNCTION__);
}
// pimpl

- (void)dealloc {
    [_window release];
    self.mediator = nil;
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    // TODO: Move appearance customization to a seperate method.
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor], UITextAttributeTextColor,
      [UIColor clearColor], UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
      [UIFont fontWithName:HISTORY_FONT_FOR_NAVBAR size:HISTORY_FONTSIZE_FOR_NAVBAR], UITextAttributeFont,
      nil]];
    
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // All app navigation is handled by this class
    self.mediator = [HistoryMediator sharedMediator];
    [self.mediator prepareControllers];
    self.window.rootViewController = self.mediator.mainTabBarController;
    [self.window makeKeyAndVisible];
    [self.mediator fetchTodayUpdate];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

//UIImage* navBarBkgImg = [UIImage imageNamed:@"navwrinklewhitepaper_retina.png"];
// Customize nav bar
// [[UINavigationBar appearance] setBackgroundImage:navBarBkgImg forBarMetrics:UIBarMetricsDefault];

//        [[UINavigationBar appearance] setTitleTextAttributes:
//         [NSDictionary dictionaryWithObjectsAndKeys:
//          [UIColor whiteColor], UITextAttributeTextColor, 
//          [UIColor clearColor], UITextAttributeTextShadowColor, 
//          [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset, 
//          [UIFont fontWithName:HISTORY_FONT_FOR_TITLE size:16], UITextAttributeFont, 
//          nil]];


//        
//        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:navBarBkgImg forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//        [[[_mainNavController navigationItem] backBarButtonItem] setTitle:@"Go Back"];


// Add a tabbar as a user controlled navigation
//[[UITabBar appearance] setBackgroundImage:navBarBkgImg];
//        UITabBar* tabBar = [[UITabBar alloc] init];
//        [tabBar setTag:HISTORY_TAG_TABBAR];
//        
//        UITabBarItem* favsTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Favorites" image:nil tag:HISTORY_TAG_FAVORITES];
//        NSArray* tabBarItems = [NSArray arrayWithObjects:favsTabBarItem, nil];
//        [tabBar setItems:tabBarItems animated:YES];
//        [tabBar setDelegate:self];    
//        
//        CGSize appSize = [_mainNavController.view frame].size;
//        CGRect f = CGRectMake(0,appSize.height-HISTORY_UI_TABBAR_HEIGHT,appSize.width,HISTORY_UI_TABBAR_HEIGHT);
//        tabBar.frame = f;
//        [_mainNavController.view addSubview:tabBar];
//        [tabBar release];


// Override point for customization after application launch.
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        _tabBarController = [[UITabBarController alloc] init];
//        // TODO: Cleanup
//        
//        // Create today view
//        _todayViewController = [[HistoryViewController alloc] initWithNibName:@"HistoryView_iPhone" bundle:nil];
//        UITabBarItem* tabItem = [[UITabBarItem alloc] initWithTitle:@"Today" image:nil tag:1];
//        [_todayViewController setTabBarItem:tabItem];
//        [tabItem release];
//
//        // Create favs view
//        FavoritesViewController* favsViewController = [[FavoritesViewController alloc] initWithNibName:@"FavoritesView_iPhone" bundle:nil];
//        UINavigationController* favsNavController = [[UINavigationController alloc] initWithRootViewController:favsViewController];
//        
//        [[favsNavController navigationBar] setHidden:YES];
//        UITabBarItem* tabItem2 = [[UITabBarItem alloc] initWithTitle:@"Favorites" image:nil tag:2];
//        [favsNavController setTabBarItem:tabItem2];
//        
//        // Add to tabbar
//        NSArray* controllers = [NSArray arrayWithObjects:
//                                    _todayViewController,
//                                    favsNavController,
//                                    nil];
//        
//        [_tabBarController setViewControllers:controllers animated:true];
//        [_tabBarController setSelectedViewController:_todayViewController];
//        self.window.rootViewController = _tabBarController;
//        
//        [[_tabBarController tabBar] setAlpha:0.3];
//        //[[_tabBarController tabBar] setHidden:true];
//
//         UIImage* img = [UIImage imageNamed:@"navbarcloth.png"];
////        CGSize s = img.size;
//        [[UITabBar appearance] setBackgroundImage:img];
//
//        
//        [[UINavigationBar appearance] setTitleTextAttributes:
//         [NSDictionary dictionaryWithObjectsAndKeys:
//          [UIColor whiteColor], UITextAttributeTextColor, 
//          [UIColor redColor], UITextAttributeTextShadowColor, 
//          [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset, 
//          [UIFont fontWithName:@"Chalkduster" size:16], UITextAttributeFont, 
//          nil]];
//        
//        [[UINavigationBar appearance] setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
//    } else {
//        NSLog(@"************** iPad Not implemented");
//    }

