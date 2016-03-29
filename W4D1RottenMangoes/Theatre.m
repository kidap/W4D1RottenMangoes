
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

  return [self initWithName:dict[@"name"]
                    address:dict[@"address"]
                        lat:[lat doubleValue]
                        lng:[lng doubleValue]];
}
-(instancetype)initWithName:(NSString *)name
                    address:(NSString *)address
                        lat:(CLLocationDegrees)lat
                        lng:(CLLocationDegrees)lng{
  if (self = [super init]){
    _name = name;
    _address = address;
    _lat = lat;
    _lng = lng;
  }
  return self;
}
@end
