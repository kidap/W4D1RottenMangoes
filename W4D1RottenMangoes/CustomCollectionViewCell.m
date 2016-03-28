//
//  CustomCollectionViewCell.m
//  W4D1RottenMangoes
//
//  Created by Karlo Pagtakhan on 03/28/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import "CustomCollectionViewCell.h"

@implementation CustomCollectionViewCell

-(void)prepareForReuse{
  [self.dataTask cancel];
  //Images can also be cleared here
  [self.imageView setImage:nil];
}


@end
