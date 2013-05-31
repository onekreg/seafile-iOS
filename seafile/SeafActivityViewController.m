//
//  SeafActivityViewController.m
//  seafilePro
//
//  Created by Wang Wei on 5/18/13.
//  Copyright (c) 2013 tsinghua. All rights reserved.
//

#import "SeafActivityViewController.h"
#import "SeafAppDelegate.h"
#import "SVProgressHUD.h"
#import "Debug.h"

enum {
    ACTIVITY_INIT = 0,
    ACTIVITY_START,
    ACTIVITY_END,
};

@interface SeafActivityViewController ()
@property int state;
@property (readonly) UIWebView *webview;
@end

@implementation SeafActivityViewController
@synthesize connection = _connection;
@synthesize state;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
    
}

- (void)refresh:(id)sender
{
    [self start];
}

- (UIWebView *)webview
{
    return (UIWebView *)self.view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Activities";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    self.webview.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setConnection:(SeafConnection *)connection
{
    self.state = ACTIVITY_INIT;
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"]] cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 1];
    [self.webview loadRequest: request];
    _connection = connection;
}

- (NSString *)urlStr
{
    return [_connection.address stringByAppendingString:API_URL"/activity/"];
}

- (void)start
{
    [SVProgressHUD showWithStatus:@"Loading ..."];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[self urlStr]] cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 1];
    [request setHTTPMethod:@"GET"];
    [request setValue:[NSString stringWithFormat:@"Token %@", _connection.token] forHTTPHeaderField:@"Authorization"];
    [self.webview loadRequest: request];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.state == ACTIVITY_START)
        [self start];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
    [super viewWillDisappear:animated];
}


# pragma - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (self.state == ACTIVITY_INIT) {
        self.state = ACTIVITY_START;
        if (self.isViewLoaded && self.view.window)
            [self start];
    } else {
        [SVProgressHUD dismiss];
        self.state = ACTIVITY_END;
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SVProgressHUD showErrorWithStatus:@"Failed to load activities"];
    self.state = ACTIVITY_END;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    Debug("Request %@\n", request.URL);
    NSString *urlStr = request.URL.absoluteString;
    if ([urlStr hasPrefix:@"file://"] || [urlStr hasPrefix:[_connection.address stringByAppendingString:API_URL]])
        return YES;
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (!IsIpad()) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    return YES;
}

@end