//
//  MapViewController.h
//  Thrive
//
//  Created by Aaron Salo on 4/9/13.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController<MKMapViewDelegate>
{
    MKMapView *mapView;
}
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@end
