//
//  ContactViewController.m
//  iosMobile
//
//  Created by Aaron Salo on 3/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "ContactViewController.h"


@implementation ContactViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction) linkToFacebook:(id)sender
{
    NSString *facebookURLString= [NSString stringWithFormat:@"https://www.facebook.com/ithrivecc"];
    NSURL *facebookURL = [[ NSURL alloc ] initWithString:facebookURLString];
    [[UIApplication sharedApplication] openURL:facebookURL];
}

-(IBAction) linkToTwitter:(id)sender
{
    NSString *facebookURLString= [NSString stringWithFormat:@"https://twitter.com/ithrivecc/"];
    NSURL *facebookURL = [[ NSURL alloc ] initWithString:facebookURLString];
    [[UIApplication sharedApplication] openURL:facebookURL];
}

@end
