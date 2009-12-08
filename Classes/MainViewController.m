//
//  MainViewController.m
//  CoreLocationTest
//
//  Created by David HM Spector on 12/3/09.
//  Copyright Zeitgeist Information Systems 2009. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"


@implementation MainViewController
//@synthesize currentLocation, currentElevation, currentHeading, coreLocationSwitch, mapView, mPlacemark, geoCoder;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    // Custom initialization
  }
  return self;
}


- (void)viewDidLoad 
{
  [super viewDidLoad];
  // First, determine what we can about network reacability  
  [[Reachability sharedReachability] setHostName:@"www.apple.com"];	
  remoteHostStatus          = [[Reachability sharedReachability] remoteHostStatus];
  internetConnectionStatus	= [[Reachability sharedReachability] internetConnectionStatus];
  localWiFiConnectionStatus	= [[Reachability sharedReachability] localWiFiConnectionStatus];
  switch (internetConnectionStatus) {
    case ReachableViaCarrierDataNetwork:
      whichNetwork.text = @"Cellular";
      break;
    case ReachableViaWiFiNetwork:
      whichNetwork.text = @"WiFi";
      break;
    case NotReachable:
    default:
      whichNetwork.text = @"None";
      break;
  }
  
  // The sensors
  accelerometer = [UIAccelerometer sharedAccelerometer];
	accelerometer.updateInterval = 0.1;
	accelerometer.delegate = self;	
  
  // Core Location
  locationManager = [[CLLocationManager alloc] init];
  locationManager.delegate = self;
  locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; 
  [locationManager startUpdatingLocation];
  loc_service_active = YES;
  
  if ([locationManager headingAvailable])
    [locationManager startUpdatingHeading];
  else 
    currentHeading.text = @"N/A";
  
  // The map
  mapView.delegate = self;
  mapView.zoomEnabled = YES;
  mapView.scrollEnabled = YES;
  mapView.showsUserLocation = YES;
  mapView.mapType = MKMapTypeHybrid;
  mapStatusText.text = @"Not following user";
  
  
  
  /*Region and Zoom */
  MKCoordinateRegion region;
  MKCoordinateSpan span;
  span.latitudeDelta = 0.2;
  span.longitudeDelta = 0.2;
  
  CLLocationCoordinate2D location = mapView.userLocation.coordinate;
  
  location.latitude =  40.814849;
  location.longitude = -73.622732;
  region.span = span;
  region.center = location;
  
  [mapView setRegion:region animated:YES];
  [mapView regionThatFits:region];
  
  /*Geocoder Stuff*/
  //  geoCoder=[[MKReverseGeocoder alloc] initWithCoordinate:location];
  //  geoCoder.delegate = self;
  //  [geoCoder start];
  
  
  dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
  [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
  
}




- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {  
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)showInfo {    
	
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}




- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
  // release all our UI bits  
  [currentLocation release];
  [currentElevation release];
  [currentHeading release];
  [coreLocationSwitch release];
  [mapView release];
  
  [xLabel release];
  [yLabel release];
  [zLabel release];
  
  [xBar release];
  [yBar release];
  [zBar release];
  
  
  // deactivate and release the sensors, map and geocoder
  accelerometer.delegate = nil;
  [accelerometer release];  
  
  mapView.delegate = nil;
  [mapView release];
  
  //  geoCoder.delegate = nil;
  //  [geoCoder release];
  
  locationManager.delegate = nil;
  [locationManager release];
  
  [dateFormatter release];
  
  //...and finally:
  [super dealloc];
}

#pragma mark MapKit Delegate Methods

// this causes the map to track the user... this *will* interfere with the 
// user's pinch/zoom control of the map.  You have been warned.
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)Oobject
                         change:(NSDictionary *)change
                        context:(void *)context
{
  mapView.centerCoordinate = mapView.userLocation.location.coordinate;
}



- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder 
       didFailWithError:(NSError *)error
{
  NSLog(@"Reverse Geocoder Errored");  
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
  NSLog(@"Reverse Geocoder completed");
  mPlacemark = placemark;
  [mapView addAnnotation:placemark];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
  MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
  annView.animatesDrop = TRUE;
  return annView;
}


#pragma mark UIAccelerometer Delegate Methods

- (void)accelerometer:(UIAccelerometer *)meter didAccelerate:(UIAcceleration *)acceleration {
  xLabel.text = [NSString stringWithFormat:@"%.5f", acceleration.x];
  xBar.progress = ABS(acceleration.x);
  
  yLabel.text = [NSString stringWithFormat:@"%.5f", acceleration.y];
  yBar.progress = ABS(acceleration.y);
  
  zLabel.text = [NSString stringWithFormat:@"%.5f", acceleration.z];
  zBar.progress = ABS(acceleration.z);
  
}


#pragma mark ---- Location Manager Delegate Methods ----
- (void) locationManager:(CLLocationManager *)manager
     didUpdateToLocation:(CLLocation *)newLocation
            fromLocation:(CLLocation *)oldLocation 
{  
  NSLog(@"Location: %@", [newLocation description]);
  currentLocation.text  = [NSString stringWithFormat:@"%3.2f, %3.2f", newLocation.coordinate.latitude, newLocation.coordinate.longitude];
  currentElevation.text = [NSString stringWithFormat:@"%3.2f", newLocation.altitude];
  currentSpeed.text = newLocation.speed < 0 ?  @" - " : [NSString stringWithFormat:@"@%3.2f m/s", newLocation.speed];
  lastUpdateTime.text =  [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:newLocation.timestamp]];
}


- (void)locationManager:(CLLocationManager *)manager 
       didFailWithError:(NSError *)error
{
  NSLog(@"Error: %@", [error description]);
}

- (void)locationManager:(CLLocationManager *)manager 
       didUpdateHeading:(CLHeading *)newHeading
{
  
  float heading = [newHeading trueHeading];
  NSString *ordinalPoint = nil;
  
  // we're going to use/show the 16 common cardinal and intercadinal compass points; the idea is we 
  // split the difference between intercardinal points.  For example between north and east is northeast.  
  // Between North and NorthEast and NorthEast and East are two more divisions, NorthNorthEast and EastNorthEast.
  // North -> East = 90 deg; North -> NorthEast and NorthEast -> East = 45deg, North -> NorthNorthEast -- 22.5deg.  
  //
  // In order to have a smooth transition between the intercardinal points, you need to plit the distance yet again, 
  // making an 11.25 degree split.  In essesnce you are declaring north to be 11.5 deg to the left or right of true north; 
  // ditto to the other 3 cardinal points;  To be able to get all of the 16 common compass points to display you need to 
  // do the same for each of N, NNE, NE, ENE, E ESE, SE SSE, S, SSW, SW, WSW W, WNW, NW NNW.
  
  //N.B.: North is a special case since the way we're normalizing it, it lies left of 359.99deg as well as < 11.25deg
  
  if (heading > 337.5 + kOne32ndCompassDivision && heading < 359.99 || heading > 0.00 && heading < kOne32ndCompassDivision)   
    ordinalPoint = @"(N)";
  else if (heading > kOne32ndCompassDivision && heading < (22.5 - kOne32ndCompassDivision))
    ordinalPoint = @"(NNE)";
  else if (heading > (22.5 - kOne32ndCompassDivision) && heading < (45 + kOne32ndCompassDivision))
    ordinalPoint = @"(NE)";
  else if (heading > (45.0 - kOne32ndCompassDivision) && heading < (67.5 + kOne32ndCompassDivision))
    ordinalPoint = @"(ENE)";  
  
  else if (heading > (90.0 - kOne32ndCompassDivision) && heading < (90.0 + kOne32ndCompassDivision))
    ordinalPoint = @"(E)";
  else if (heading > (112.5 - kOne32ndCompassDivision) && heading < (112.5 + kOne32ndCompassDivision))
    ordinalPoint = @"(ESE)";
  else if (heading > (135.0 - kOne32ndCompassDivision) && heading < (135.0 + kOne32ndCompassDivision))
    ordinalPoint = @"(SSE)";
  else if (heading > (157.5 - kOne32ndCompassDivision) && heading < (157.5 + kOne32ndCompassDivision))
    ordinalPoint = @"(SSE)";
  
  else if (heading > (180.0 - kOne32ndCompassDivision) && heading < (180.0 + kOne32ndCompassDivision))
    ordinalPoint = @"(S)";
  else if (heading > (202.6 - kOne32ndCompassDivision) && heading < (202.5 + kOne32ndCompassDivision))
    ordinalPoint = @"(SSW)";
  else if (heading > (202.5 - kOne32ndCompassDivision) && heading < (225.0 + kOne32ndCompassDivision))
    ordinalPoint = @"(SE)";
  else if (heading > (202.5 - kOne32ndCompassDivision) && heading < (247.7 + kOne32ndCompassDivision))
    ordinalPoint = @"(WSW)";
  
  else if (heading > (270.0 - kOne32ndCompassDivision) && heading < (270.0 + kOne32ndCompassDivision))
    ordinalPoint = @"(W)";
  else if (heading > (292/5 - kOne32ndCompassDivision) && heading < (292.5 + kOne32ndCompassDivision))
    ordinalPoint = @"(NWN)";
  else if (heading > (315.0 - kOne32ndCompassDivision) && heading < (315.0 + kOne32ndCompassDivision))
    ordinalPoint = @"(NW)";
  else if (heading > (337.5 - kOne32ndCompassDivision) && heading < (337.5 + kOne32ndCompassDivision))
    ordinalPoint = @"(NNW)";
  
  
  //  NSLog(@"Heading: %f", [newHeading magneticHeading]);
  
  currentHeading.text = heading < 0 ?  @" - " : [NSString stringWithFormat:@"%3.1fº %@", heading, ordinalPoint];  
  
  // This will rotate the map as the compass heading changes. We need to put the map inside another view for
  // and deal with clipping regions I think for it to work sensibly.  Right now it spins the mapview on top 
  // of the main view which is both wrong and really ugly.
  if (rotateMap)
    [mapView setTransform:CGAffineTransformMakeRotation(-1 * newHeading.magneticHeading * 3.14159 / 180)];    
}



#pragma mark Action Methods
- (IBAction)toggleCoreLocation
{
  if (loc_service_active)
  {
    if ([locationManager headingAvailable])
      [locationManager stopUpdatingHeading];
    
    [locationManager stopUpdatingLocation];
    [currentLocation setTextColor:[UIColor redColor]];
    [currentElevation setTextColor:[UIColor redColor]];
    [currentSpeed setTextColor:[UIColor redColor]];
    [currentHeading setTextColor:[UIColor redColor]];
    loc_service_active = NO;
    NSLog(@"Stop updating Location");
    
  }
  else 
  {
    if ([locationManager headingAvailable])
      [locationManager startUpdatingHeading];
    
    [locationManager startUpdatingLocation];
    [currentLocation setTextColor:[UIColor whiteColor]];
    [currentElevation setTextColor:[UIColor whiteColor]];
    [currentSpeed setTextColor:[UIColor whiteColor]];
    [currentHeading setTextColor:[UIColor whiteColor]];
    loc_service_active = YES;
    NSLog(@"Start updating Location");    
  }
}


- (IBAction) showUserLocation
{
  MKUserLocation *annotation = mapView.userLocation;
  CLLocation *location = annotation.location;
  if (nil == location)
    return;
  
  CLLocationDistance distance = MAX(4 * location.horizontalAccuracy, 500); // meters
  MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, distance, distance);
  
  [mapView setRegion:region animated:YES];    
  [locationManager startUpdatingLocation];
}

- (IBAction) toggleMapType
{
  if (mapView.mapType == MKMapTypeHybrid)
    mapView.mapType = MKMapTypeStandard;
  else
    mapView.mapType = MKMapTypeHybrid;
}


- (IBAction)toggleMapRotation 
{
  if (rotateMap){
    [mapView setTransform:CGAffineTransformMakeRotation(0)];    
    rotateMap = NO;

  }
  else 
    rotateMap = YES;
  NSLog(@"Changed rotateMap to %@", rotateMap ? @"YES" : @"NO");  
  
}


- (IBAction)toggleMapFollowsUser
{
  // this causes the map to follow the user around - This needs to be a toggle;
  // if it's on, the map will literally follow the user undoing any moves/drags/zooms
  // the user does.
  
  mapFollowsUser = !mapFollowsUser;
  
  if (mapFollowsUser) {    
    [mapView.userLocation addObserver:self forKeyPath:@"location" options:0 context:NULL];
    mapStatusText.text = @"Following user";
  }
  else {
    [mapView.userLocation removeObserver:self forKeyPath:@"location"];
    mapStatusText.text = @"Not following user";      
  }
  
  NSLog(@"Changed mapFollowsUser to %@", mapFollowsUser ? @"YES" : @"NO");
}

@end
