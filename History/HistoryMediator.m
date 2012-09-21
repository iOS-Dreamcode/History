//
//  HistoryMediator.m
//  History
//
//  Created by Srikanth Sombhatla on 07/09/12.
//
//

#import "HistoryMediator.h"
#import "HistoryEngine.h"
#import "HistoryConstants.h"
#import "HistoryViewController.h"
#import "FavoritesViewController.h"
#import "FavoriteViewController.h"
#import "AboutViewController.h"

@interface HistoryMediator ()
- (void)todayInfoAvailable:(NSNotification*)notif;
- (void)updateFavsBadge;

@property (nonatomic,readwrite,assign) UITabBarController* mainTabBarController;
@property (nonatomic,readwrite,assign) UIViewController<HistoryTodayView>* todayViewController;
@property (nonatomic,readwrite,assign) UINavigationController* favNavController;
@property (nonatomic,readwrite,assign) UITableViewController<HistoryFavoritesListView>* favoritesViewController;
@property (nonatomic,readwrite,assign) UIViewController<HistoryFavoriteView>* favoriteViewController;
@property (nonatomic,readwrite,assign) UIViewController* aboutViewController;
@property (assign,nonatomic,readwrite) HistoryEngine* engine;
@property (retain,nonatomic,readwrite) NSDictionary* currentInfo;

@end

@implementation HistoryMediator
@synthesize engine = _engine;

- (void)todayInfoAvailable:(NSNotification*)notif {
    if([notif.name isEqualToString:HistoryEngineUpdateAvailableNotification]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSDictionary* userInfo = notif.userInfo;
        if([userInfo objectForKey:HISTORY_ERRORSTRING]) {
            NSAssert([self.todayViewController respondsToSelector:@selector(showError:)], @"todayViewController does not responds to required protocol method showError:");
            self.todayViewController.tabBarItem.badgeValue = @"!";
            [self.todayViewController showError:[userInfo objectForKey:HISTORY_ERRORSTRING]];
        } else {
            NSAssert([self.todayViewController respondsToSelector:@selector(loadTodayInfo:)], @"todayViewController does not responds to required protocol method loadTodayInfo:");
            if(self.todayViewController && [notif.userInfo count]) {
                self.currentInfo = notif.userInfo;
                [self.todayViewController loadTodayInfo:self.currentInfo];
                }
            }
        }
}

- (void)favoritesEdited {
    [self updateFavsBadge];
}

- (void)updateFavsBadge {
    NSString* badge;
    if(self.engine.favoritesCount)
        badge = [NSString stringWithFormat:@"%d",self.engine.favoritesCount];
     else
        badge = nil;
    self.favNavController.tabBarItem.badgeValue = badge;
}

+ (id)sharedMediator {
    static HistoryMediator *m = nil;
    @synchronized(self) {
        if (m == nil)
            m = [[HistoryMediator alloc] init];
    }
    return m;
}

- (id)init {
    self = [super init];
    if(self) {
        self.engine =  [HistoryEngine sharedEngine];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(todayInfoAvailable:) name:HistoryEngineUpdateAvailableNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    self.engine = nil;
    self.currentInfo = nil;
    self.favoriteViewController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)prepareControllers {
    /*
     History has 2 main features which are laid out as tabs
     1. Today.
     2. Favorites.
     Inside Favorites, UI is drilled down which is navigation controller navigating list items.
     */
    
    // Create all participating view controllers
    self.todayViewController = [[HistoryViewController alloc]
                                initWithNibName:@"HistoryInfoView_iPhone" bundle:nil];
    UITabBarItem* todayTabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Today"
                                                                   image:[UIImage imageNamed:@"todayicon_retina.png"]
                                                                     tag:HISTORY_TAB_TODAY] autorelease];
    UINavigationController* todayNavContoller = [[[UINavigationController alloc] initWithRootViewController:self.todayViewController] autorelease];
    todayNavContoller.tabBarItem = todayTabBarItem;
    
    self.favoritesViewController = [[FavoritesViewController alloc]
                                    initWithNibName:@"FavoritesView_iPhone" bundle:nil];
    self.favNavController = [[UINavigationController alloc]
                             initWithRootViewController:self.favoritesViewController];
    
    UITabBarItem* favTabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Favorites"
                                                                 image:[UIImage imageNamed:@"favsicon_retina.png"]
                                                                   tag:HISTORY_TAB_FAVLIST] autorelease];
    self.favNavController.tabBarItem = favTabBarItem;
    [self updateFavsBadge];
    
    // This is how we can programatically create view controller without Control+dragdrop in interface builder.
    self.aboutViewController = [[AboutViewController alloc] init];
    UITabBarItem* aboutTabBarItem = [[[UITabBarItem alloc] initWithTitle:@"About"
                                                                   image:[UIImage imageNamed:@"abouticon_retina.png"]
                                                                     tag:HISTORY_TAB_FAV] autorelease];
    self.aboutViewController.tabBarItem = aboutTabBarItem;
    // Accessing view property triggers view loading lifecycle.
    (void)self.aboutViewController.view;
    
    UINavigationController* aboutNavController = [[[UINavigationController alloc] initWithRootViewController:self.aboutViewController] autorelease];
    
    // Create main tab bar which holds these view controllers.
    self.mainTabBarController = [[UITabBarController alloc] init];
    
    self.mainTabBarController.delegate = self;
    NSArray* controllers = [NSArray arrayWithObjects:todayNavContoller,
                            self.favNavController,
                            aboutNavController,
                            nil];
    [self.mainTabBarController setViewControllers:controllers animated:YES];
    self.mainTabBarController.selectedViewController = todayNavContoller;
    self.mainTabBarController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:HISTORY_BKG_MAIN]];
}

- (void)fetchTodayUpdate {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.engine fetchTodayInfo];
}

- (void)showFavorites {
    [self.mainTabBarController setSelectedIndex:HISTORY_TAB_FAVLIST];
}

- (BOOL)addAsFavorite:(NSDictionary*)info {
    if([self.engine saveAsFavorite:info]) {
        [self.favoritesViewController.tableView reloadData];
        [self favoritesEdited];
        return YES;
    } else {
        return NO;
    }
}

- (void)showFavoriteAtIndex:(NSInteger)index {
    NSDictionary* info = [self.engine favoriteAtIndex:index];
    if(info) {
        FavoriteViewController* fav = [[[FavoriteViewController alloc] initWithNibName:@"HistoryInfoView_iPhone"
                                                                                bundle:nil] autorelease];
        [self.favNavController pushViewController:fav animated:YES];
        [fav loadFavoriteInfo:info withIndex:index];
    }
}

- (BOOL)removeFavoriteAtIndex:(NSInteger)index {
    if([self.engine removeFavoriteAtIndex:index]) {
        [self.favNavController popViewControllerAnimated:YES];
        [self.favoritesViewController removeFavoriteAtIndex:index];
        [self favoritesEdited];
        return YES;
    } else {
        return NO;
    }
    
}

- (BOOL)removeAllFavorites {
    if([_engine removeAllFavorites]) {
        [self favoritesEdited];
        return YES;
    } else {
        return NO;
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    NSLog(@"%s %@",__PRETTY_FUNCTION__,viewController.tabBarItem.title);
}


@end
