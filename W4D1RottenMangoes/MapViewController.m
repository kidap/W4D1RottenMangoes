//
//  MapViewController.m
//  W4D1RottenMangoes
//
//  Created by Karlo Pagtakhan on 03/29/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import "MapViewController.h"
#import "MapKit/MapKit.h"
#import "CoreLocation/CLLocation.h"
#import "CoreLocation/CLGeocoder.h"
#import "Movie.h"
#import "Theatre.h"

@interface MapViewController()<CLLocationManagerDelegate,MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray<Theatre *> *theatresArray;
@property (nonatomic, assign) BOOL didZoom;
@end
@implementation MapViewController
-(void)viewDidLoad{
  NSLog(@"Movie: %@", self.movie.title);
  
  [self prepareView];
  [self prepareCoreLocation];
  [self prepareMapKit];
}
//MARK: Preparation
-(void)prepareView{
  self.theatresArray = [[NSMutableArray alloc] init];
}
-(void)prepareCoreLocation{
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;
  
  if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
    [self.locationManager requestWhenInUseAuthorization];
  }
  
  [self.locationManager startUpdatingLocation];
}
-(void)prepareMapKit{
  self.mapView.delegate = self;
  [self.mapView setShowsUserLocation:YES];
}
//MARK: MKMapViewDelegate
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
  CLLocation *currentLocation = userLocation.location;
  CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
  
  //Zoom in to the user location
  if (!self.didZoom){
    [self focusOnCoordinate:currentLocation.coordinate];
    self.didZoom = YES;
  }
  
  //Get location of user
  [reverseGeocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
    for (CLPlacemark *placemark in placemarks){
      NSLog(@"%@",placemark);
      NSString *postalCode = [placemark.postalCode stringByReplacingOccurrencesOfString:@" " withString:@""];
      
      //Get movies close to the user's location
      [self getTheatresInPostalCode:postalCode showingMovie:self.movie.title];
    }
  }];
}

//MARK: Helper methods
-(void)addTheatresAsAnnotation{
  for (Theatre *theatre in self.theatresArray){
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(theatre.lat, theatre.lng);
    
    annotation.coordinate = coordinate;
    annotation.title = theatre.name;
    annotation.subtitle = theatre.address;
    
    [self.mapView addAnnotation:annotation];
  }
}
-(void)focusOnCoordinate:(CLLocationCoordinate2D)coordinate{
  CLLocationCoordinate2D centerCoordinate = coordinate;
  MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
  MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
  [self.mapView setRegion:region animated:YES];
}
-(void)getTheatresInPostalCode:(NSString *)postalCode showingMovie:(NSString *)title{
  NSString *urlString = [NSString stringWithFormat:@"http://lighthouse-movie-showtimes.herokuapp.com/theatres.json?address=%@&movie=%@",postalCode, self.movie.title];
  urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@"%"];
  NSLog(@"%@",urlString);
  
  //Get theaters showing the movie based on the users' postal code
  NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    if (!error){
      NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
      
      NSArray *theatres = jsonObject[@"theatres"];
      for (NSDictionary *theatre in theatres){
        [self.theatresArray addObject:[[Theatre alloc] initWithDict:theatre]];
        NSLog(@"Theatres: %@",theatre);
      }
      //Use main thread to add annotations
      dispatch_async(dispatch_get_main_queue(), ^{
        [self addTheatresAsAnnotation];
      });
    }
  }];
  
  [task resume];
}
@end
