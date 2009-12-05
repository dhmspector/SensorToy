//
//  MainViewController.h
//  CoreLocationTest
//
//  Created by David HM Spector on 12/3/09.
//  Copyright Zeitgeist Information Systems 2009. All rights reserved.
//

#import "FlipsideViewController.h"
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import <MapKit/MKReverseGeocoder.h>
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"                // Apple's "reachability code"

#define kOne32ndCompassDivision  11.25

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, MKReverseGeocoderDelegate, MKMapViewDelegate, UIAccelerometerDelegate, CLLocationManagerDelegate> {
  // the MapKit parts
  IBOutlet UILabel    *currentLocation;
  IBOutlet UILabel    *currentElevation;
  IBOutlet UILabel    *currentHeading;
  IBOutlet UILabel    *currentSpeed;
  IBOutlet UISwitch   *coreLocationSwitch;
  IBOutlet UILabel    *lastUpdateTime;
  IBOutlet UILabel    *whichNetwork;
  IBOutlet UIButton   *showInfo;
  IBOutlet MKMapView  *mapView;
  
  // The Accelerometers Parts
  IBOutlet  UILabel   *xLabel;
  IBOutlet  UILabel   *yLabel;
  IBOutlet  UILabel   *zLabel;
  IBOutlet  UIProgressView  *xBar;
  IBOutlet  UIProgressView  *yBar;
  IBOutlet  UIProgressView  *zBar;
    
  NetworkStatus remoteHostStatus;
	NetworkStatus internetConnectionStatus;
	NetworkStatus localWiFiConnectionStatus;
  
  
  MKPlacemark         *mPlacemark;
  MKReverseGeocoder   *geoCoder;  
  UIAccelerometer     *accelerometer;
  CLLocationManager   *locationManager;
  NSDateFormatter     *dateFormatter;
  
  BOOL loc_service_active;

}

/* 
@property (nonatomic, retain) UILabel *currentLocation;
@property (nonatomic, retain) UILabel *currentElevation;
 @property (nonatomic, retain) UILabel *currentHeading;
 @property (nonatomic, retain) UILabel *currentSpeed;
 @property (nonatomic, retain) UILabel *lastUpdateTime;
@property (nonatomic, retain) UISwitch *coreLocationSwitch;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) MKPlacemark *mPlacemark;
@property (nonatomic, retain) MKReverseGeocoder *geoCoder;
*/

- (IBAction)toggleCoreLocation;
- (IBAction) showUserLocation;
- (IBAction) toggleMapType;
- (IBAction)showInfo;

@end
