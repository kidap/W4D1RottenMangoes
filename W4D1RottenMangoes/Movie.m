//
//  Movie.m
//  W4D1RottenMangoes
//
//  Created by Karlo Pagtakhan on 03/28/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import "Movie.h"

@implementation Movie

-(instancetype) initWithTitle:(NSString *)title
                      movieID:(NSString *)movieID
                         year:(NSString *)year
                       rating:(NSString *)rating
            originalPosterURL:(NSString *)originalPosterURL{
  if (self = [super init]) {
    _movieID = movieID;
    _title = title;
    _year = year;
    _rating = rating;
    _originalPosterURL = originalPosterURL;
  }
  return self;
}
@end
