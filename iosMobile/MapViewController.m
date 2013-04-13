//
//  MapViewController.m
//  Thrive
//
//  Created by Aaron Salo on 4/9/13.
//
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController
@synthesize mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.mapView = nil;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    NSLog(@"viewWillApppear2");
    [annotation release];
}


-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
    NSLog(@"viewWillApppear");
    
}

-(void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
