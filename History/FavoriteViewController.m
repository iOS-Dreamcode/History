//
//  FavoriteViewController.m
//  History
//
//  Created by Srikanth Sombhatla on 10/09/12.
//
//

#import "FavoriteViewController.h"
#import "HistoryMediator.h"
#import "HistoryConstants.h"

@interface FavoriteViewController ()

- (void)removeThisFavorite;
@property (nonatomic,readwrite) NSInteger currentFavIndex;
@property (nonatomic,readwrite,retain) NSDictionary* favInfo;
@end

@implementation FavoriteViewController

- (void)removeThisFavorite {
    UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:HISTORY_PROD_NAME
                                                     message:NSLocalizedString(@"Do you want to delete this favorite?",nil)
                                                                               delegate:self
                                                                               cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                           otherButtonTitles:NSLocalizedString(@"Delete", nil), nil] autorelease];
    [alert show];
}
    
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Favorite"];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadFavoriteInfo:(NSDictionary*)info withIndex:(NSInteger)favIndex {
    self.currentFavIndex = favIndex;
    [self loadTodayInfo:info];
    self.navigationItem.title= @"Favorite";
    UIBarButtonItem* removeFavButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeThisFavorite)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:removeFavButton,nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex)
        [[HistoryMediator sharedMediator] removeFavoriteAtIndex:self.currentFavIndex];
}

@end
