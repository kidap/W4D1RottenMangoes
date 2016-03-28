//
//  Movie.h
//  W4D1RottenMangoes
//
//  Created by Karlo Pagtakhan on 03/28/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Movie : NSObject
@property (nonatomic, copy) NSString *movieID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *year;
@property (nonatomic, copy) NSString *rating;
@property (nonatomic, copy) NSString *originalPosterURL;

-(instancetype) initWithTitle:(NSString *)title
                      movieID:(NSString *)movieID
                         year:(NSString *)year
                       rating:(NSString *)rating
            originalPosterURL:(NSString *)originalPosterURL;
@end
