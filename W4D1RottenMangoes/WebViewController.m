//
//  WebViewController.m
//  W4D1RottenMangoes
//
//  Created by Karlo Pagtakhan on 03/28/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import "WebViewController.h"
#import "Movie.h"
#import "MapViewController.h"

@interface WebViewController()<UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end
@implementation WebViewController
-(void)viewDidLoad{
  [self addUIElements];
  [self prepareWebView];
}
-(void)addUIElements{
  UIBarButtonItem *showTheatersNearby = [[UIBarButtonItem alloc] initWithTitle:@"Show Theatre Map"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(showTheatersNearby:)];
  self.navigationItem.rightBarButtonItem = showTheatersNearby;
}
-(void)prepareWebView{
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.movie.alternateLink]];
  [self.webView loadRequest:request];
  self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  [self.activityIndicator startAnimating];
  self.activityIndicator.center = self.view.center;
  [self.webView addSubview:self.activityIndicator];
}
//MARK: WebView delegate
-(void)webViewDidFinishLoad:(UIWebView *)webView{
  [self.activityIndicator stopAnimating];
}

//MARK: Action
-(void)showTheatersNearby:(id)sender{
  //Trigger segue
  [self performSegueWithIdentifier:@"showTheatresNearby" sender:self];
}
//MARK: Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  if ([segue.identifier isEqualToString:@"showTheatresNearby"]){
    MapViewController *destinationVC = segue.destinationViewController;
    destinationVC.movie = self.movie;
  }
}
@end
