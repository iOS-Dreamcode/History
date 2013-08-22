//
//  HistoryViewController.h
//  History
//
//  Created by Srikanth Sombhatla on 21/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "History.h"

@interface HistoryViewController : UIViewController<HistoryTodayView>

@property (retain, readonly) NSDictionary* historyInfo;
@property (retain, nonatomic) IBOutlet UILabel *titleView;
@property (retain, nonatomic) IBOutlet UILabel *contentView;
@property (retain, nonatomic) IBOutlet UIScrollView *contentScrollView;


- (id) initWithHistoryInfo:(NSDictionary*)info nibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil;
- (NSString*) historyControllerId;

@end
