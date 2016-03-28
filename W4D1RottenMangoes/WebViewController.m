//
//  WebViewController.m
//  W4D1RottenMangoes
//
//  Created by Karlo Pagtakhan on 03/28/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController()
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end
@implementation WebViewController
-(void)viewDidLoad{
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
  [self.webView loadRequest:request];
//  [self.webView loadHTMLString: baseURL:nil];
}
@end
