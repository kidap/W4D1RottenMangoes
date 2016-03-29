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

@interface MapViewController()<CLLocationManagerDelegate,MKMapViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray<Theatre *> *theatresArray;
@property (copy, nonatomic) CLPlacemark *lastPlacemark;
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
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Change Location" style:UIBarButtonItemStylePlain target:self action:@selector(changePostalCode:)];
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
    CLPlacemark *currentPlacemark;
    for (CLPlacemark *placemark in placemarks){
      currentPlacemark = placemark;
      NSString *postalCode = [placemark.postalCode stringByReplacingOccurrencesOfString:@" " withString:@""];
      
      //Get the movie theatres only when the postal code changes
      if(![self.lastPlacemark.postalCode isEqualToString:placemark.postalCode]){
        //Get movies close to the user's location
        NSLog(@"Get Theatres nearby");
        [self getTheatresInPostalCode:postalCode showingMovie:self.movie.title placemark:placemark];
      }
    }
    self.lastPlacemark = currentPlacemark;
  }];
  
  
}

//MARK: Table view delegate and datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  return self.theatresArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TheatreCell" forIndexPath:indexPath];
  cell.textLabel.text = self.theatresArray[indexPath.row].name;
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f kms",self.theatresArray[indexPath.row].distanceFromUser];
  return cell;
}

//MARK: Action
-(void)changePostalCode:(id)sender{
  
  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Change postal code" message:@"Enter postal code" preferredStyle:UIAlertControllerStyleAlert];
  
  [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    textField.placeholder = @"postal code";
  }];
  
  [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    NSLog(@"Ok pressed");
    UITextField *textfield = [alertController.textFields firstObject];
    NSLog(@"text entered:%@",textfield.text);
    
    //Get movies close to the user's location
    NSLog(@"Get Theatres nearby");
    [self getTheatresInPostalCode:textfield.text showingMovie:self.movie.title];
  }]];
  
  [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    NSLog(@"Cancel pressed");
  }]];
  
  [self presentViewController:alertController animated:YES completion:nil];
  
}
//MARK: Helper methods
-(void)focusOnCoordinate:(CLLocationCoordinate2D)coordinate{
  CLLocationCoordinate2D centerCoordinate = coordinate;
  MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
  MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
  [self.mapView setRegion:region animated:YES];
}
-(void)getTheatresInPostalCode:(NSString *)postalCode showingMovie:(NSString *)title{
  [self getTheatresInPostalCode:postalCode showingMovie:self.movie.title placemark:nil];
}
-(void)getTheatresInPostalCode:(NSString *)postalCode showingMovie:(NSString *)title placemark:(CLPlacemark *)placemark{
  NSString *urlString = [NSString stringWithFormat:@"http://lighthouse-movie-showtimes.herokuapp.com/theatres.json?address=%@&movie=%@",postalCode, self.movie.title];
  urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
  NSLog(@"%@",urlString);
  
  //Clear annotations and tables
  [self.theatresArray removeAllObjects];
  [self.mapView removeAnnotations:self.mapView.annotations];
  
  //Get location of the postal code if placemark was not provided
  if (!placemark){
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:postalCode inRegion:nil completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
      self.lastPlacemark = [[CLPlacemark alloc] initWithPlacemark:[placemarks firstObject]];
      [self getTheatresUsingURLString:urlString];
    }];
  } else {
    self.lastPlacemark = placemark;
    [self getTheatresUsingURLString:urlString];
  }
  
}
-(void)getTheatresUsingURLString:(NSString *)urlString{
  
  //Get theaters showing the movie based on the users' postal code
  NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    if (!error){
      //Convert data to JSON
      NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
      
      //Loop at all the theatres
      NSArray *theatres = jsonObject[@"theatres"];
      for (NSDictionary *theatre in theatres){
        
        //Creat theatre instance
        Theatre *newTheatre = [[Theatre alloc] initWithDict:theatre];
        
        //Calculate distance
        CLLocation *destination = [[CLLocation alloc] initWithLatitude:newTheatre.coordinate.latitude longitude:newTheatre.coordinate.longitude];
        CLLocation *initial = self.lastPlacemark.location;
        CLLocationDistance distance = [ initial distanceFromLocation:destination];
        distance /= 1000;
        
        //Add distance to object
        newTheatre.distanceFromUser = distance;
        
        //Add theater to array
        [self.theatresArray addObject:newTheatre];
        
        NSLog(@"Theatres: %@",theatre);
      }
      
      //Use main thread to add annotations
      dispatch_async(dispatch_get_main_queue(), ^{
        [self sortTableView];
        [self addTheatresAsAnnotation];
        [self.tableView reloadData];
        [self focusOnCoordinate:self.lastPlacemark.location.coordinate];
      });
    }
  }];
  
  [task resume];
}
-(void)addTheatresAsAnnotation{
  for (Theatre *theatre in self.theatresArray){
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(theatre.coordinate.latitude, theatre.coordinate.longitude);
    
    annotation.coordinate = coordinate;
    annotation.title = theatre.name;
    annotation.subtitle = theatre.address;
    [self.mapView addAnnotation:annotation];
  }
}
-(void)sortTableView{
  NSSortDescriptor *tableSorter = [NSSortDescriptor sortDescriptorWithKey:@"distanceFromUser" ascending:YES];
  
  [self.theatresArray sortUsingDescriptors:@[tableSorter]];
}
@end
