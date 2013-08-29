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

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    //mapView.showsUserLocation = YES;
    CLLocationCoordinate2D thrive_location = CLLocationCoordinate2DMake(43.905004, -78.834118);//thrives location using longitude and latitude
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(thrive_location,600,600);
    [self.mapView setRegion:region animated:true]; //set the map to be over thrive
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = thrive_location;
    annotation.title=@"Thrive Community Church";
    [self.mapView addAnnotation:annotation];
}

- (void)viewDidLoad
{
    //self.mapView = nil;
    [super viewDidLoad];
    self.mapView.delegate = self;
}


-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.title=@"Map";
    //[annotation release];
    
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
