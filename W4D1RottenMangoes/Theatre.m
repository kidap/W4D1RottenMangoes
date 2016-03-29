
//
//  Theatre.m
//  W4D1RottenMangoes
//
//  Created by Karlo Pagtakhan on 03/29/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import "Theatre.h"


@implementation Theatre
-(instancetype)initWithDict:(NSDictionary *) dict{
  NSNumber *lat = dict[@"lat"];
  NSNumber *lng = dict[@"lng"];
  CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);

  return [self initWithName:dict[@"name"]
                    address:dict[@"address"]
                        coordinate:coordinate];
}
-(instancetype)initWithName:(NSString *)name
                    address:(NSString *)address
                 coordinate:(CLLocationCoordinate2D)coordinate{
  if (self = [super init]){
    _name = name;
    _address = address;
    _coordinate = coordinate;
    _distanceFromUser = 0;
  }
  return self;
}
@end
