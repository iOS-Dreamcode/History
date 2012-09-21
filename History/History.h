//
//  History.h
//  History
//
//  Created by Srikanth Sombhatla on 07/09/12.
//
//

#import <Foundation/Foundation.h>

@protocol HistoryTodayView <NSObject>
@required
- (void)loadTodayInfo:(NSDictionary*)info;
- (void)showError:(NSString*)error;
@end

@protocol HistoryFavoritesListView <NSObject>
@required
- (void)removeFavoriteAtIndex:(NSInteger)index;
@end

@protocol HistoryFavoriteView <NSObject>
@required
- (void)loadFavoriteInfo:(NSDictionary*)info withIndex:(NSInteger)favIndex;
@end