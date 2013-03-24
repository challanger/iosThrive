//
//  FirstViewController.m
//  iosMobile
//
//  Created by Aaron Salo on 2/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"
#import "News.h"


@implementation FirstViewController
@synthesize imageView = mImageView;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    NSLog(@"view did load");
    [super viewDidLoad];
    //load a default image into the News viewere just incase nothing else loads 
    NSAssert(self.imageView, @"self.imageView is nil. Check your IBOutlet connections");
    self.imageView.backgroundColor = [UIColor blackColor];
    self.imageView.clipsToBounds = YES;
    self.imageView.image = [UIImage imageNamed:@"thrive"];
    //load the rest of the news items 
    [self loadData];
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
    self.imageView = nil;
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(BOOL) loadData
{    
    //pull the images to display on the News page 
    NSMutableArray *news_images=[News load_current_items_db];
    
    //place the news images in the image viewer
    self.imageView.animationImages = news_images;
    self.imageView.animationDuration= 10;
    [self.imageView startAnimating];
    
    //[news_images release];
    return false;
}


- (void)dealloc
{
    //[mImageView release];
    [super dealloc];
}

@end
