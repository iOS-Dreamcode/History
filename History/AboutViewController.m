//
//  AboutViewController.m
//  History
//
//  Created by Srikanth Sombhatla on 07/09/12.
//
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)loadView {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSArray* arr = [[NSBundle mainBundle] loadNibNamed:@"AboutView_iPhone" owner:self options:nil];
    self.view = [arr objectAtIndex:0];
}

- (void)viewDidLoad {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [super viewDidLoad];
    [self.view setOpaque:YES];
    [self.view setBackgroundColor: [UIColor clearColor]];
    self.navigationItem.title = @"About";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
