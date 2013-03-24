//
//  SecondViewController.m
//  iosMobile
//
//  Created by Aaron Salo on 2/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SecondViewController.h"


@implementation SecondViewController
@synthesize mapView;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self mapView] setDelegate:self];
    //load the map with a pin at the church
    mapView.showsUserLocation = YES;
    CLLocationCoordinate2D thrive_location = CLLocationCoordinate2DMake(43.905004, -78.834118);//thrives location using longitude and latitude
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:thrive_location]; //set thrives location for the pin
    [annotation setTitle:@"Thrive Community Church"];   //set the name of tje pin
    [mapView setCenterCoordinate:thrive_location animated:true];    //center the map over thrive
    [mapView addAnnotation:annotation]; //drop the pin
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(thrive_location,600,600); 
    [mapView setRegion:region animated:true]; //set the map to be over thrive 
    
    [annotation release];
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
    self.mapView = nil;
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

-(IBAction) linkeToEmail:(id)sender
{
    NSString *emailString= [NSString stringWithFormat:@"mailto:?to=aaron.dune2000@gmail.com"];
    NSURL *emailURL = [[ NSURL alloc ] initWithString:emailString];
    [[UIApplication sharedApplication] openURL:emailURL];
}

@end
