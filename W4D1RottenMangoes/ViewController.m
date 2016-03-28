//
//  ViewController.m
//  W4D1RottenMangoes
//
//  Created by Karlo Pagtakhan on 03/28/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import "ViewController.h"
#import "Movie.h"
#import "CustomCollectionViewCell.h"

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray<Movie *> *moviesArray;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  
  [self prepareData];
  [self prepareCollectionView];
}
-(void)prepareData{
  self.moviesArray = [[NSMutableArray alloc] init];
  
  NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?apikey=h8ym7ry7kkur36j7ku482y9z&page_limit=10"]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (!error){
      NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:1 error:nil];
      NSArray *movieList = jsonData[@"movies"];
      for (NSDictionary *movie in movieList){
//        NSLog(@"%@",movie);
        
        NSDictionary *ratings = movie[@"ratings"];
        NSDictionary *posters = movie[@"posters"];
        NSNumber *rating = ratings[@"critics_score"];
        NSNumber *year = movie[@"year"];
        
        [self.moviesArray addObject:[[Movie alloc] initWithTitle:movie[@"title"]
                                                         movieID:movie[@"id"]
                                                            year:[year stringValue]
                                                          rating:[rating stringValue]
                                               originalPosterURL:posters[@"original"]]];
      }
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
      });
    } else{
      NSLog(@"Error:%@",error);
    }
  }];
  
  [task resume];
  
}
-(void)prepareCollectionView{
  self.collectionView.delegate = self;
  self.collectionView.dataSource = self;
  self.collectionView.backgroundColor = [UIColor lightGrayColor];
}
//MARK: UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  NSLog(@"Total number of items: %lu", self.moviesArray.count);
  return self.moviesArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"movieCell" forIndexPath:indexPath];
  
  Movie *movie = self.moviesArray[indexPath.row];
  cell.movieTitle.text = movie.title;
  cell.movieYear.text = movie.year;
  cell.rating.text = [NSString stringWithFormat:@"Rating: %@", movie.rating ];
  
  //Get image online
  NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:movie.originalPosterURL]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (!error){
      UIImage *posterImage = [UIImage imageWithData:data];
      dispatch_async(dispatch_get_main_queue(), ^{
        [cell.imageView setImage:posterImage];
      });
    } else{
      NSLog(@"Error:%@",error);
    }
  }];
  
  cell.dataTask = task;

  
  NSLog(@"Displaying movie: %@", movie.title);
  return cell;

}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(CustomCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
  [cell.dataTask resume];
}
-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(CustomCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
  [cell.dataTask suspend];
}
@end
