//
//  SecondViewController.m
//  iosMobile
//
//  Created by Aaron Salo on 2/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SecondViewController.h"

#import "MapViewController.h"


@implementation SecondViewController



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
    
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [super dealloc];
}

-(IBAction) linkToFacebook:(id)sender
{
    NSString *facebookURLString= [NSString stringWithFormat:@"https://www.facebook.com/318011664926017"];
    NSURL *facebookURL = [[ NSURL alloc ] initWithString:facebookURLString];
    [[UIApplication sharedApplication] openURL:facebookURL];
}

-(IBAction) linkToTwitter:(id)sender
{
    NSLog(@"twitter press");
    NSString *facebookURLString= [NSString stringWithFormat:@"https://twitter.com/ithrivecc"];
    NSURL *facebookURL = [[ NSURL alloc ] initWithString:facebookURLString];
    [[UIApplication sharedApplication] openURL:facebookURL];
}

-(IBAction) linkeToEmail:(id)sender
{
    NSString *emailString= [NSString stringWithFormat:@"mailto:?to=info@ithrive.ca"];
    NSURL *emailURL = [[ NSURL alloc ] initWithString:emailString];
    [[UIApplication sharedApplication] openURL:emailURL];
}

-(IBAction) linkeToMap:(id)sender
{
    //UIButton *button = (UIButton *)sender;
    NSLog(@"map press");
    
    MapViewController *mapViewC = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    //messageView.modalTransitionStyle
    //[self.parentViewController.parentViewController.navigationController pushViewController:mapViewC animated:YES];
    [self.navigationController pushViewController:mapViewC animated:YES];
}

@end
