//
//  Movie.m
//  W4D1RottenMangoes
//
//  Created by Karlo Pagtakhan on 03/28/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import "Movie.h"

@implementation Movie

-(instancetype) initWithDictionary:(NSDictionary *)movieDetails{
  if (self = [super init]) {
    NSDictionary *ratings = movieDetails[@"ratings"];
    NSDictionary *posters = movieDetails[@"posters"];
    NSDictionary *links = movieDetails[@"links"];
    NSNumber *rating = ratings[@"critics_score"];
    NSNumber *year = movieDetails[@"year"];

    self = [self initWithTitle:movieDetails[@"title"]
                       movieID:movieDetails[@"id"]
                          year:[year stringValue]
                        rating:[rating stringValue]
                          link:links[@"alternate"]
             originalPosterURL:posters[@"original"]];
  }
  return self;
}
-(instancetype) initWithTitle:(NSString *)title
                      movieID:(NSString *)movieID
                         year:(NSString *)year
                       rating:(NSString *)rating
                         link:(NSString *)alternateLink
            originalPosterURL:(NSString *)originalPosterURL{
  if (self = [super init]) {
    _movieID = movieID;
    _title = title;
    _year = year;
    _rating = rating;
    _alternateLink = alternateLink;
    _originalPosterURL = originalPosterURL;
  }
  return self;
}
@end
