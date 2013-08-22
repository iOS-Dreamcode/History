//
//  FavoritesViewController.m
//  History
//
//  Created by Srikanth Sombhatla on 25/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FavoritesViewController.h"
#import "HistoryViewController.h"
#import "HistoryMediator.h"
#import "HistoryConstants.h"

#define kTagDeleteFavorite 10
#define kTagDeleteAllFavs 11

@interface FavoritesViewController () {
    HistoryEngine* _engine; // non owning
}

- (void)updateEditButtons;
- (void)setEditButtonIfRequired;
- (void)removeAllFavorites;
@end

@implementation FavoritesViewController

- (void)updateEditButtons {
    if(![_engine favoritesCount]) {
        [self setEditing:FALSE animated:YES];
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    }
}

- (void)setEditButtonIfRequired {
    if([_engine favoritesCount]) {
        [self.navigationItem setLeftBarButtonItem:self.editButtonItem animated:YES];
    } else {
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Favorites";
    [self.navigationItem setLeftBarButtonItem:self.editButtonItem animated:YES];
    [self.view setOpaque:NO];
    [self.view setBackgroundColor:[UIColor clearColor]];
    _engine = [HistoryEngine sharedEngine];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setEditButtonIfRequired];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    return [_engine favoritesCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        UILabel* l = [cell textLabel];
        [l setNumberOfLines:0];
        [l setLineBreakMode:UILineBreakModeWordWrap];
        [l setTextColor:[UIColor colorWithRed:0.297 green:0.216 blue:0.080 alpha:1.000]];
        UIFont* f = [UIFont fontWithName:HISTORY_FONT_FOR_TITLE size:[UIFont labelFontSize]];
        [l setFont:f];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    NSString* title = [[_engine favoriteTitles] objectAtIndex:indexPath.row];
    [[cell textLabel] setText:title];
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_engine removeFavoriteAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [[HistoryMediator sharedMediator] favoritesEdited];
        [self performSelector:@selector(updateEditButtons) withObject:self afterDelay:1];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animate {
    [super setEditing:editing animated:animate];
    if(editing) {
        UIBarButtonItem* removeAllFavsButton = [[[UIBarButtonItem alloc]
                                                 initWithTitle:@"Remove all"
                                                 style:UIBarButtonItemStylePlain
                                                 target:self
                                                 action:@selector(removeAllFavorites)] autorelease];
        [[self navigationItem] setRightBarButtonItem:removeAllFavsButton animated:YES];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[HistoryMediator sharedMediator] showFavoriteAtIndex:indexPath.row];
}

- (void)removeFavoriteAtIndex:(NSInteger)index {
    // Data source is updated by this call.
    NSArray* deleteIndexPath = [NSArray arrayWithObjects:
                                [NSIndexPath indexPathForRow:index inSection:0],
                                nil];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:deleteIndexPath withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    [self updateEditButtons];
}

- (void)removeAllFavorites {
    UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"History" message:@"Delete all your favorites?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete",nil] autorelease];
    alert.tag = kTagDeleteAllFavs;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%d tag %d",buttonIndex,alertView.tag);
    if(alertView.tag == kTagDeleteAllFavs) {
        [[HistoryMediator sharedMediator] removeAllFavorites];
        [self updateEditButtons];
        [self.tableView reloadData];
    } else {
        NSLog(@"%s aleretview with %d tag is not handled.",__PRETTY_FUNCTION__,alertView.tag);
    }
}

@end
