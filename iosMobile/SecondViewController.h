//
//  SecondViewController.h
//  iosMobile
//
//  Created by Aaron Salo on 2/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface SecondViewController : UIViewController<MKMapViewDelegate> {
    //<MKMapViewDelegate>
    MKMapView *mapView;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

-(IBAction) linkToFacebook:(id)sender;
-(IBAction) linkToTwitter:(id)sender;
-(IBAction) linkeToEmail:(id)sender;

@end
