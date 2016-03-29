//
//  Theatre.h
//  W4D1RottenMangoes
//
//  Created by Karlo Pagtakhan on 03/29/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreLocation/CLLocation.h"

@interface Theatre : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, assign) CLLocationDegrees lat;
@property (nonatomic, assign) CLLocationDegrees lng;

-(instancetype)initWithDict:(NSDictionary *) dict;
-(instancetype)initWithName:(NSString *)name
                    address:(NSString *)address
                        lat:(CLLocationDegrees)lat
                        lng:(CLLocationDegrees)lng;
@end
