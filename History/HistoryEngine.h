//
//  HistoryEngine.h
//  History
//
//  Created by Srikanth Sombhatla on 22/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

NSString* const HistoryEngineUpdateAvailableNotification;

@interface HistoryEngine : NSObject

+ (id) sharedEngine;
- (void)fetchTodayInfo;
- (BOOL)saveAsFavorite:(NSDictionary*)info;
- (NSArray*)favorites;
- (NSArray*)favoriteTitles;
- (NSInteger)favoritesCount;
- (NSDictionary*)favoriteAtIndex:(NSInteger)index;
- (BOOL)removeFavoriteAtIndex:(NSInteger)index;
- (BOOL)removeAllFavorites;
@end
