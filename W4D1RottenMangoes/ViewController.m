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
#import "WebViewController.h"
static NSInteger movieCountPerPage = 50;

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray<Movie *> *moviesArray;
@property (nonatomic,assign) NSInteger lastPageDownloaded;
@property (nonatomic,strong) NSMutableArray *indexPathArrayToBeAdded;
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic,assign) bool isTaskCompleted;
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
  self.lastPageDownloaded = 1;
  self.isTaskCompleted = YES;
  [self getMovieWithPage:self.lastPageDownloaded];
  
}
-(void)prepareCollectionView{
  self.collectionView.delegate = self;
  self.collectionView.dataSource = self;
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
  cell.rating.text = [NSString stringWithFormat:@"Critics score: %@", movie.rating ];
  
  //Get image online
  NSLog(@"%@",movie.originalPosterURL);
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
  [cell.dataTask resume];
  
  NSLog(@"Displaying movie: %@", movie.title);
  return cell;
  
}

//MARK: Scrolling
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
  //NSLog(@"Scrolling");
  NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:self.moviesArray.count -1 inSection:0];
  if([self.collectionView.indexPathsForVisibleItems containsObject:lastIndexPath]){
    NSLog(@"END of the list");
    
    self.lastPageDownloaded++;
    [self getMovieWithPage:self.lastPageDownloaded];
  }
}

//MARK: Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  if ([segue.identifier isEqualToString:@"showAlternateLink"]){
    WebViewController *destination = segue.destinationViewController;
    NSInteger selectedIndex = self.collectionView.indexPathsForSelectedItems[0].row;
//    destination.urlString = self.moviesArray[selectedIndex].alternateLink;
    destination.movie = self.moviesArray[selectedIndex];
  }
}

//MARK: Helper
-(void)getMovieWithPage:(NSInteger)pageNumber{
  
  //Check if the task is already running
  if (self.isTaskCompleted){
    //Refresh array
    self.indexPathArrayToBeAdded = [NSMutableArray array];
    
    //Display activity indicator
    dispatch_async(dispatch_get_main_queue(), ^{
      [self displayActivityIndicator];
    });
    
    //Build URL
    NSString *urlString = [NSString stringWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?apikey=h8ym7ry7kkur36j7ku482y9z&page=%ld&page_limit=%ld",self.lastPageDownloaded,movieCountPerPage];
    
    //Get JSON data
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      if (!error){
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:1 error:nil];
        if (!jsonData[@"error"]){
          NSArray *movieList = jsonData[@"movies"];
          for (NSDictionary *movie in movieList){
//            NSLog(@"%@",movie);
            //Add movie to array that will be displayed
            [self.moviesArray addObject:[[Movie alloc] initWithDictionary:movie]];
            
            //Store indexPath that will be inserted
            NSInteger itemNo = (NSInteger)self.moviesArray.count - 1;
            [self.indexPathArrayToBeAdded addObject:[NSIndexPath indexPathForItem:itemNo inSection:0]];
          }
          //Reload Collection View
          dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%lu",(unsigned long)self.moviesArray.count);
            [self.collectionView insertItemsAtIndexPaths:self.indexPathArrayToBeAdded];
            self.isTaskCompleted = YES;
            [self.activityIndicator stopAnimating];
          });
        } else{
          [self displayAlertWithMessage:jsonData[@"error"]];
        }
      } else{
        [self displayAlertWithMessage:error.localizedDescription];
        NSLog(@"Error:%@",error);
      }
    }];
    
    [task resume];
    self.isTaskCompleted = NO;
  }
}
-(void)displayActivityIndicator{
  self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  [self.activityIndicator setCenter:self.view.center];
  [self.activityIndicator setHidesWhenStopped:YES];
  
  [self.collectionView addSubview:self.activityIndicator];
  [self.activityIndicator startAnimating];
}
-(void)displayAlertWithMessage:(NSString *)error{
  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    [self dismissViewControllerAnimated:YES completion:nil];
  }];
  [alertController addAction:okAction];
  
  [self presentViewController:alertController animated:YES completion:nil];
}


//No need to use this. task can be started in the cellForItemAtIndexPath
//-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(CustomCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
//  [cell.dataTask resume];
//}
//-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(CustomCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
//  [cell.dataTask suspend];
//}
@end
