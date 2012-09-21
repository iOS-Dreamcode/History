//
//  HistoryMediator.h
//  History
//
//  Created by Srikanth Sombhatla on 07/09/12.
//
//

#import <UIKit/UIKit.h>
#import "History.h"
#import "HistoryEngine.h"

@interface HistoryMediator : NSObject <UITabBarControllerDelegate>

+ (id)sharedMediator;
- (void)prepareControllers;
- (void)fetchTodayUpdate;
- (void)showFavorites;
- (BOOL)addAsFavorite:(NSDictionary*)info;
- (void)showFavoriteAtIndex:(NSInteger)index;
- (BOOL)removeFavoriteAtIndex:(NSInteger)index;
- (BOOL)removeAllFavorites;
- (void)favoritesEdited;

@property (nonatomic,readonly) UITabBarController* mainTabBarController;
//@property (nonatomic,readonly) UIViewController<HistoryTodayView>* todayViewController;
@property (nonatomic,readonly) UINavigationController* favNavController;
@property (nonatomic,readonly) UITableViewController<HistoryFavoritesListView>* favoritesViewController;
@property (nonatomic,readonly) UIViewController<HistoryFavoriteView>* favoriteViewController;
@property (nonatomic,readonly) UIViewController* aboutViewController;
@property (readonly,nonatomic) HistoryEngine* engine;

@end
