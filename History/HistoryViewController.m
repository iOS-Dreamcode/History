//
//  HistoryViewController.m
//  History
//
//  Created by Srikanth Sombhatla on 21/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HistoryConstants.h"
#import "HistoryViewController.h"
#import "UIView+DCLayout.h"
#import "HistoryMediator.h"
#import <objc/runtime.h>

const int HISTORY_CONTENT_FONTSIZE = 15;

#define kTagActivityIndicator 101

@interface HistoryViewController ()

@property (retain, readwrite) NSDictionary* historyInfo;
- (NSDictionary*) formatInfo:(NSDictionary*)info;
- (void)favoritesButtonSelected;
- (UIActivityIndicatorView*) activityIndicator;
@end

@implementation HistoryViewController

@synthesize titleView;
@synthesize contentView;
@synthesize contentScrollView;
@synthesize historyInfo = _historyInfo;

// pimp

// TODO: Move this to utitlity method?
- (NSDictionary*) formatInfo:(NSDictionary*)info {
    NSString* desc = [info objectForKey:HISTORY_DESCRIPTION];
    desc = [desc stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
    desc = [desc stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
    NSDictionary* formatedInfo = [NSDictionary dictionaryWithObjectsAndKeys:[info objectForKey:HISTORY_TITLE],
                                  HISTORY_TITLE,desc,HISTORY_DESCRIPTION,nil];
    return formatedInfo;
}

- (void)favoritesButtonSelected {
    if(_historyInfo) {
        [[HistoryMediator sharedMediator] addAsFavorite:_historyInfo];
    }
}

- (UIActivityIndicatorView*) activityIndicator {
    UIActivityIndicatorView* spinWheel = (UIActivityIndicatorView*)[self.view viewWithTag:kTagActivityIndicator];
    if(!spinWheel) {
        spinWheel = [[[UIActivityIndicatorView alloc]
                      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
        spinWheel.tag = kTagActivityIndicator;
        spinWheel.center = self.view.center;
        spinWheel.hidesWhenStopped = YES;
    }
    return spinWheel;
}

// pimp

- (id) initWithHistoryInfo:(NSDictionary*)info nibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        _historyInfo = info;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        _historyInfo = nil;
    }
    return self;
}

- (NSString*) historyControllerId {
    return HISTORY_TODAY_VIEW;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setOpaque:YES];
    [self.view setBackgroundColor: [UIColor clearColor]];
    [[self navigationItem] setTitle:@"Today"];
    
    UIActivityIndicatorView* spinWheel = [self activityIndicator];
    [spinWheel startAnimating];
    [self.view addSubview:spinWheel];
}

- (void)viewDidUnload {
    [self setTitleView:nil];
    [self setContentView:nil];
    [self setContentScrollView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    self.titleView = nil;
    self.contentView = nil;
    [contentScrollView release];
    [super dealloc];
}

- (void)loadTodayInfo:(NSDictionary *)info {
    [[self activityIndicator] stopAnimating];
    self.historyInfo = [self formatInfo:info];
    titleView.text = [self.historyInfo objectForKey:HISTORY_TITLE];
    [titleView sizeToFit];
    contentView.text = [self.historyInfo objectForKey:HISTORY_DESCRIPTION];
    [contentView sizeToFit];
    
    [self.view dcPlaceThisView:self.contentView afterThisView:self.titleView withSpacing:10];
    [self.contentScrollView setScrollEnabled:YES];
    float h = [self.contentScrollView dcContentHeight];
    CGSize contentSize = CGSizeMake(self.view.frame.size.width, h);
    UIBarButtonItem* addToFavButton = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                       target:self
                                       action:@selector(favoritesButtonSelected)];
    [[self navigationItem] setRightBarButtonItem:addToFavButton];
    self.contentScrollView.contentSize = contentSize;
}

- (void)showError:(NSString*)error {
    [[self activityIndicator] stopAnimating];
    self.contentView.text = error;
}

@end
