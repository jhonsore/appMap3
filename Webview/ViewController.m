//
//  ViewController.m
//  Webview
//
//  Created by iOS on 17/08/16.
//  Copyright © 2016 iOS. All rights reserved.

//for uiwebview/wkwebview implementation
//https://gowithfloat.com/2014/12/one-webview-to-rule-them-all/

//for js comunication
//http://ramkulkarni.com/blog/framework-for-interacting-with-embedded-webview-in-ios-application/

#import "ViewController.h"
// Required for calls to UIWebView and WKWebView to "see" our categories
#import "UIWebView+FLUIWebView.h"
#import "WKWebView+FLWKWebView.h"


@interface ViewController ()
{
    CLLocationManager *locationManager;
    UILabel *textLatitude;
    UILabel *textLongitude;
    int count;
    BOOL statusLoadWebview;
    INTULocationRequestID locationRequestID;
    NSTimer *timer;
    NSMutableDictionary *userPosition;
    INTULocationRequestID firstRequestIdUser;
}
@end

@implementation ViewController

/*
 * Called when the view has completed loading. Time to set up our WebView!
 */
- (void) viewDidLoad {
    [super viewDidLoad];
    
    firstRequestIdUser = NSNotFound;
    userPosition = nil;
    
    // Check if WKWebView is available
    // If it is present, create a WKWebView. If not, create a UIWebView.
    CGRect rect = CGRectMake(0,
                             0,
                             [[self view] bounds].size.width,
                             [[self view] bounds].size.height);

    //----------------------
    if (NSClassFromString(@"WKWebView")) {
        _webView = [[WKWebView alloc] initWithFrame:rect];
    } else {
        _webView = [[UIWebView alloc] initWithFrame: rect];
    }
    
    //prevents page from bounce when content is shorter than page screen
    [_webView preventFromBounce];
    
    // Add the webView to the current view.
    [[self view] addSubview: [self webView]];
    
    // Assign this view controller as the delegate view.
    // The delegate methods are below, and include methods for UIWebViewDelegate, WKNavigationDelegate, and WKUIDelegate
    [[self webView] setDelegateViews: self];
    
    // Ensure that everything will resize on device rotate.
    [[self webView] setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [[self view]    setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    
    // Just to show *something* on load, we go to our favorite site.
    //[[self webView] loadRequestFromString:@"http://www.google.com/"];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"webapp"]];
    [[self webView] loadRequest:[NSURLRequest requestWithURL:url]];
    
    //----------
    textLatitude = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 320, 30)];
    textLatitude.backgroundColor = [UIColor whiteColor];
    textLatitude.text = @"";
    [self.view addSubview:textLatitude];
    
    textLongitude = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 320, 30)];
    textLongitude.backgroundColor = [UIColor whiteColor];
    textLongitude.text = @"";
    [self.view addSubview:textLongitude];
    
    textLongitude.alpha = 0;
    textLatitude.alpha = 0;
    
    //[self setCorelocation];
    
}

- (void) startUpdateposUser{
    [self setCorelocation];
}

- (void) setCorelocation {

    //https://github.com/intuit/LocationManager
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];

    locationRequestID =
    [locMgr subscribeToLocationUpdatesWithDesiredAccuracy:INTULocationAccuracyHouse
        block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
            if (status == INTULocationStatusSuccess) {
                
                NSMutableDictionary *dic;
                
                NSString *latitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
                NSString *longitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
                
                NSLog(@"---------------");
                NSLog(@"user location");
                NSLog(@"%f",currentLocation.coordinate.latitude);
                NSLog(@"%f",currentLocation.coordinate.longitude);
                NSLog(@"---------------");
                
                dic = [NSMutableDictionary
                       dictionaryWithDictionary:@{
                                                  @"latitude" : latitude,
                                                  @"longitude" : longitude
                                                  }];
                
                [self callJSFunction:@"updatePosUser" withArgs:dic];
                
            }
            else {
                // An error occurred, more info is available by looking at the specific status returned. The subscription has been kept alive.
            }
        }];
}

- (void)cancelRequest:(id)sender
{
    
    [[INTULocationManager sharedInstance] cancelLocationRequest:locationRequestID];
    locationRequestID = NSNotFound;
    NSLog(@"INTULocationManager canceled");
    
}

- (id) getUserPosition{
    
    if(userPosition == nil){
        if(firstRequestIdUser == NSNotFound){
            
            NSLog(@"**********************");
            NSLog(@"calling it");
            NSLog(@"**********************");
            
            INTULocationManager *locMgr = [INTULocationManager sharedInstance];
            
            firstRequestIdUser = [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyRoom
                            timeout:1.0
               delayUntilAuthorized:YES  // This parameter is optional, defaults to NO if omitted
                              block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                  if (status == INTULocationStatusSuccess) {
                                      // Request succeeded, meaning achievedAccuracy is at least the requested accuracy, and
                                      // currentLocation contains the device's current location.
                                      
                                      userPosition = [NSMutableDictionary
                                                      dictionaryWithDictionary:@{
                                                                                 @"latitude" : [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude],
                                                                                 @"longitude" : [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude]
                                                                                 }];
                                      
                                      firstRequestIdUser = NSNotFound;
                                      
                                  }
                                  else if (status == INTULocationStatusTimedOut) {
                                      // Wasn't able to locate the user with the requested accuracy within the timeout interval.
                                      // However, currentLocation contains the best location available (if any) as of right now,
                                      // and achievedAccuracy has info on the accuracy/recency of the location in currentLocation.
                                      if(currentLocation.coordinate.latitude){
                                          userPosition = [NSMutableDictionary
                                                          dictionaryWithDictionary:@{
                                                                                     @"latitude" : [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude],
                                                                                     @"longitude" : [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude]
                                                                                     }];
                                      }else{
                                          userPosition = [NSMutableDictionary
                                                          dictionaryWithDictionary:@{
                                                                                     @"error" : [NSString stringWithFormat:@"Ocorreu um erro ao localizar o usuário (1004)"]
                                                                                     }];
                                      }
                                      
                                      firstRequestIdUser = NSNotFound;
                                      
                                  }
                                  else {
                                      // An error occurred, more info is available by looking at the specific status returned.
                                      userPosition = [NSMutableDictionary
                                                      dictionaryWithDictionary:@{
                                                                                 @"error" : [NSString stringWithFormat:@"Impossível localizar usuário (1003)"]
                                                                                 }];
                                      
                                      firstRequestIdUser = NSNotFound;
                                  }
                                  
                                  // Cancel the request (won't execute the block)
                                  [[INTULocationManager sharedInstance] cancelLocationRequest:firstRequestIdUser];
                                  
                              }];
        }
    }
    
    /*userPosition = [NSMutableDictionary
                    dictionaryWithDictionary:@{
                                               @"error" : [NSString stringWithFormat:@"Ocorreu um erro ao localizar o usuário (1004)"]
                                               }];*/
    
    NSMutableDictionary *userPositionTemp = userPosition;
    
    if(userPosition != nil){
        
        userPosition = nil;
        firstRequestIdUser = NSNotFound;
        
    }
    
    return userPositionTemp;
    
    /*INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    INTULocationRequestID requestID = [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyCity
                                       timeout:10.0
                          delayUntilAuthorized:YES  // This parameter is optional, defaults to NO if omitted
                                         block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                             if (status == INTULocationStatusSuccess) {
                                                 // Request succeeded, meaning achievedAccuracy is at least the requested accuracy, and
                                                 // currentLocation contains the device's current location.
                                                 
                                                 NSLog(@"---------------");
                                                 NSLog(@"user location");
                                                 NSLog(@"%f",currentLocation.coordinate.latitude);
                                                 NSLog(@"---------------");
                                                 
                                                 
                                             }
                                             else if (status == INTULocationStatusTimedOut) {
                                                 // Wasn't able to locate the user with the requested accuracy within the timeout interval.
                                                 // However, currentLocation contains the best location available (if any) as of right now,
                                                 // and achievedAccuracy has info on the accuracy/recency of the location in currentLocation.
                                             }
                                             else {
                                                 // An error occurred, more info is available by looking at the specific status returned.
                                             }
                                             
                                             // Cancel the request (won't execute the block)
                                             [[INTULocationManager sharedInstance] cancelLocationRequest:requestID];
                                             
                                         }];*/
    
    
    /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Init app"
     message:@"App iniciado"
     delegate:self
     cancelButtonTitle:@"OK"
     otherButtonTitles:nil];
     [alert show];*/
    /*NSMutableDictionary *dic = [NSMutableDictionary
     dictionaryWithDictionary:@{
     @"item" : @"value"
     }];
     
     [self callJSFunction:@"callJS" withArgs:dic];*/
}

/*
 * Enable rotating the view when the device rotates.
 */
- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
{
    return YES;
}

/*
 * This more or less ensures that the status bar is hidden for this view.
 * We also set UIStatusBarHidden to true in the Info.plist file.
 * We hide the status bar so we can use the full screen height without worrying about an offset for the status bar.
 */
- (BOOL) prefersStatusBarHidden
{
    return NO;
}

#pragma mark - js call

- (BOOL) processURL:(NSString *) url
{
    NSString *urlStr = [NSString stringWithString:url];
    
    NSString *protocolPrefix = @"js2ios://";
    if ([[urlStr lowercaseString] hasPrefix:protocolPrefix])
    {
        urlStr = [urlStr substringFromIndex:protocolPrefix.length];
        
        urlStr = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSError *jsonError;
        
        NSDictionary *callInfo = [NSJSONSerialization
                                  JSONObjectWithData:[urlStr dataUsingEncoding:NSUTF8StringEncoding]
                                  options:kNilOptions
                                  error:&jsonError];
        
        if (jsonError != nil)
        {
            //call error callback function here
            NSLog(@"Error parsing JSON for the url %@",url);
            return NO;
        }
        
        
        NSString *functionName = [callInfo objectForKey:@"functionname"];
        if (functionName == nil)
        {
            NSLog(@"Missing function name");
            return NO;
        }
        
        NSString *successCallback = [callInfo objectForKey:@"success"];
        NSString *errorCallback = [callInfo objectForKey:@"error"];
        NSArray *argsArray = [callInfo objectForKey:@"args"];
        
        
        [self callFunction:functionName withArgs:argsArray onSuccess:successCallback onError:errorCallback];
        
        return NO;
        
    }
    
    return YES;
}

- (void) callFunction:(NSString *) name withArgs:(NSArray *) args onSuccess:(NSString *) successCallback onError:(NSString *) errorCallback
{
    NSError *error;
    
    id retVal = [self processFunctionFromJS:name withArgs:args error:&error];
    
    if (error != nil)
    {
        NSString *resultStr = [NSString stringWithString:error.localizedDescription];
        [self callErrorCallback:errorCallback withMessage:resultStr];
        return;
    }
    
    [self callSuccessCallback:successCallback withRetValue:retVal forFunction:name];
    
}

-(void) callErrorCallback:(NSString *) name withMessage:(NSString *) msg
{
    if (name != nil)
    {
        //call error handler
        
        [[self webView] evaluateJavaScript:[NSString stringWithFormat:@"%@('%@');",name,msg] completionHandler:nil];
        
    }
    else
    {
        NSLog(@"%@",msg);
    }
    
}

-(void) callSuccessCallback:(NSString *) name withRetValue:(id) retValue forFunction:(NSString *) funcName
{
    if (name != nil)
    {
        retValue = (retValue) ? retValue : [NSMutableDictionary dictionary];
        
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
        [resultDict setObject:retValue forKey:@"result"];
        [self callJSFunction:name withArgs:resultDict];
        
    }
    else
    {
        NSLog(@"Result of function %@ = %@", funcName,retValue);
    }
    
}

-(void) callJSFunction:(NSString *) name withArgs:(NSMutableDictionary *) args
{
    NSError *jsonError;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:args options:0 error:&jsonError];
    
    if (jsonError != nil)
    {
        //call error callback function here
        NSLog(@"Error creating JSON from the response  : %@",[jsonError localizedDescription]);
        return;
    }
    
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    //NSLog(@"jsonStr = %@", jsonStr);
    
    if (jsonStr == nil)
    {
        NSLog(@"jsonStr is null. count = %lu", (unsigned long)[args count]);
    }
    
    [[self webView] evaluateJavaScript:[NSString stringWithFormat:@"%@('%@');",name,jsonStr] completionHandler:nil];
    
}

- (void) createError:(NSError**) error withMessage:(NSString *) msg
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:msg forKey:NSLocalizedDescriptionKey];
    
    *error = [NSError errorWithDomain:@"JSiOSBridgeError" code:-1 userInfo:dict];
    
}

-(void) createError:(NSError**) error withCode:(int) code withMessage:(NSString*) msg
{
    NSMutableDictionary *msgDict = [NSMutableDictionary dictionary];
    [msgDict setValue:[NSNumber numberWithInt:code] forKey:@"code"];
    [msgDict setValue:msg forKey:@"message"];
    
    NSError *jsonError;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:msgDict options:0 error:&jsonError];
    
    if (jsonError != nil)
    {
        //call error callback function here
        NSLog(@"Error creating JSON from error message  : %@",[jsonError localizedDescription]);
        return;
    }
    
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    [self createError:error withMessage:jsonStr];
}

- (id) processFunctionFromJS:(NSString *) name withArgs:(NSArray*) args error:(NSError **) error
{
    
    if ([name compare:@"getPositionUser" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        return [self getUserPosition];
    }
    
    if ([name compare:@"startUpdateposUser" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        [self startUpdateposUser];
    }
    
    return nil;
}

/*
- (BOOL) processURL:(NSString *) url
{
    NSString *urlStr = [NSString stringWithString:url];
    
    NSString *protocolPrefix = @"js2ios://";
    
    NSLog(@"processo url : %@",urlStr);
    
    //process only our custom protocol
    if ([[urlStr lowercaseString] hasPrefix:protocolPrefix])
    {
        //strip protocol from the URL. We will get input to call a native method
        urlStr = [urlStr substringFromIndex:protocolPrefix.length];
        
        //Decode the url string
        urlStr = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSError *jsonError;
        
        //parse JSON input in the URL
        NSDictionary *callInfo = [NSJSONSerialization
                                  JSONObjectWithData:[urlStr dataUsingEncoding:NSUTF8StringEncoding]
                                  options:kNilOptions
                                  error:&jsonError];
        
        //check if there was error in parsing JSON input
        if (jsonError != nil)
        {
            NSLog(@"Error parsing JSON for the url %@",url);
            return NO;
        }
        
        //Get function name. It is a required input
        NSString *functionName = [callInfo objectForKey:@"functionname"];
        if (functionName == nil)
        {
            NSLog(@"Missing function name");
            return NO;
        }
        
        NSString *successCallback = [callInfo objectForKey:@"success"];
        NSString *errorCallback = [callInfo objectForKey:@"error"];
        NSArray *argsArray = [callInfo objectForKey:@"args"];
        
        [self callNativeFunction:functionName withArgs:argsArray onSuccess:successCallback onError:errorCallback];
        
        //Do not load this url in the WebView
        return NO;
        
    }
    
    return YES;
}

- (void) callNativeFunction:(NSString *) name withArgs:(NSArray *) args onSuccess:(NSString *) successCallback onError:(NSString *) errorCallback
{
    
    //AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    
    //We only know how to process setDataUser
    if ([name compare:@"setDataUser" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        if (args.count > 0)
        {
            //NSString *resultStr = [NSString stringWithFormat:@"%@", [args objectAtIndex:0]];
             //NSData *objectData = [resultStr dataUsingEncoding:NSUTF8StringEncoding];
             //NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:objectData
             //options:kNilOptions
             //error:nil];
            
        }
        else
        {
            NSString *resultStr = [NSString stringWithFormat:@"Error calling function %@. Error : Missing argument", name];
            [self callErrorCallback:errorCallback withMessage:resultStr];
        }
    }
    else if ([name compare:@"getPositionUser" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        
        [self getUserPosition];
        
    }
    else
    {
        //Unknown function called from JavaScript
        NSString *resultStr = [NSString stringWithFormat:@"Cannot process function %@. Function not found", name];
        [self callErrorCallback:errorCallback withMessage:resultStr];
        
    }
}

-(void) callErrorCallback:(NSString *) name withMessage:(NSString *) msg
{
    if (name != nil)
    {
        //call error handler
        
        NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
        [resultDict setObject:msg forKey:@"error"];
        [self callJSFunction:name withArgs:resultDict];
    }
    else
    {
        NSLog(@"%@",msg);
    }
    
}

-(void) callSuccessCallback:(NSString *) name withRetValue:(id) retValue forFunction:(NSString *) funcName
{
    
    if (name != nil)
    {
        //call succes handler
        
        NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
        [resultDict setObject:retValue forKey:@"result"];
        
        NSLog(@"%@",[resultDict objectForKey:@"CPF"]);
        
    }
    else
    {
        NSLog(@"Result of function %@ = %@", funcName,retValue);
    }
    
}

-(void) callJSFunction:(NSString *) name withArgs:(NSMutableDictionary *) args
{
    NSError *jsonError;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:args options:0 error:&jsonError];
    
    if (jsonError != nil)
    {
        //call error callback function here
        NSLog(@"Error creating JSON from the response  : %@",[jsonError localizedDescription]);
        return;
    }
    
    //initWithBytes:length:encoding
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"jsonStr = %@", jsonStr);
    
    if (jsonStr == nil)
    {
        NSLog(@"jsonStr is null. count = %lu", (unsigned long)[args count]);
    }
    
    //[[self webView]  stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@('%@');",name,jsonStr]];
    [[self webView] evaluateJavaScript:[NSString stringWithFormat:@"%@('%@');",name,jsonStr] completionHandler:nil];
}*/

#pragma mark - UIWebView Delegate Methods

/*
 * Called on iOS devices that do not have WKWebView when the UIWebView requests to start loading a URL request.
 * Note that it just calls shouldStartDecidePolicy, which is a shared delegate method.
 * Returning YES here would allow the request to complete, returning NO would stop it.
 */
- (BOOL) webView: (UIWebView *) webView shouldStartLoadWithRequest: (NSURLRequest *) request navigationType: (UIWebViewNavigationType) navigationType
{
    return [self shouldStartDecidePolicy: request];
}

/*
 * Called on iOS devices that do not have WKWebView when the UIWebView starts loading a URL request.
 * Note that it just calls didStartNavigation, which is a shared delegate method.
 */
- (void) webViewDidStartLoad: (UIWebView *) webView
{
    [self didStartNavigation];
}

/*
 * Called on iOS devices that do not have WKWebView when a URL request load failed.
 * Note that it just calls failLoadOrNavigation, which is a shared delegate method.
 */
- (void) webView: (UIWebView *) webView didFailLoadWithError: (NSError *) error
{
    [self failLoadOrNavigation: [webView request] withError: error];
}

/*
 * Called on iOS devices that do not have WKWebView when the UIWebView finishes loading a URL request.
 * Note that it just calls finishLoadOrNavigation, which is a shared delegate method.
 */
- (void) webViewDidFinishLoad: (UIWebView *) webView
{
    [self finishLoadOrNavigation: [webView request]];
}

#pragma mark - WKWebView Delegate Methods

/*
 * Called on iOS devices that have WKWebView when the web view wants to start navigation.
 * Note that it calls shouldStartDecidePolicy, which is a shared delegate method,
 * but it's essentially passing the result of that method into decisionHandler, which is a block.
 */
- (void) webView: (WKWebView *) webView decidePolicyForNavigationAction: (WKNavigationAction *) navigationAction decisionHandler: (void (^)(WKNavigationActionPolicy)) decisionHandler
{
    decisionHandler([self shouldStartDecidePolicy: [navigationAction request]]);
}

/*
 * Called on iOS devices that have WKWebView when the web view starts loading a URL request.
 * Note that it just calls didStartNavigation, which is a shared delegate method.
 */
- (void) webView: (WKWebView *) webView didStartProvisionalNavigation: (WKNavigation *) navigation
{
    [self didStartNavigation];
}

/*
 * Called on iOS devices that have WKWebView when the web view fails to load a URL request.
 * Note that it just calls failLoadOrNavigation, which is a shared delegate method,
 * but it has to retrieve the active request from the web view as WKNavigation doesn't contain a reference to it.
 */
- (void) webView:(WKWebView *) webView didFailProvisionalNavigation: (WKNavigation *) navigation withError: (NSError *) error
{
    [self failLoadOrNavigation: [webView request] withError: error];
}

/*
 * Called on iOS devices that have WKWebView when the web view begins loading a URL request.
 * This could call some sort of shared delegate method, but is unused currently.
 */
- (void) webView: (WKWebView *) webView didCommitNavigation: (WKNavigation *) navigation
{
    // do nothing
}

/*
 * Called on iOS devices that have WKWebView when the web view fails to load a URL request.
 * Note that it just calls failLoadOrNavigation, which is a shared delegate method.
 */
- (void) webView: (WKWebView *) webView didFailNavigation: (WKNavigation *) navigation withError: (NSError *) error
{
    [self failLoadOrNavigation: [webView request] withError: error];
}

/*
 * Called on iOS devices that have WKWebView when the web view finishes loading a URL request.
 * Note that it just calls finishLoadOrNavigation, which is a shared delegate method.
 */
- (void) webView: (WKWebView *) webView didFinishNavigation: (WKNavigation *) navigation
{
    [self finishLoadOrNavigation: [webView request]];
}

#pragma mark - Shared Delegate Methods

/*
 * This is called whenever the web view wants to navigate.
 */
- (BOOL) shouldStartDecidePolicy: (NSURLRequest *) request
{
    // Determine whether or not navigation should be allowed.
    // Return YES if it should, NO if not.
    
    NSURL *url = [request URL];
    NSString *urlStr = url.absoluteString;
    
    return [self processURL:urlStr];
}

/*
 * This is called whenever the web view has started navigating.
 */
- (void) didStartNavigation
{
    // Update things like loading indicators here.
}

/*
 * This is called when navigation failed.
 */
- (void) failLoadOrNavigation: (NSURLRequest *) request withError: (NSError *) error
{
    // Notify the user that navigation failed, provide information on the error, and so on.
    NSLog(@"%@",error);
}

/*
 * This is called when navigation succeeds and is complete.
 */
- (void) finishLoadOrNavigation: (NSURLRequest *) request
{
    // Remove the loading indicator, maybe update the navigation bar's title if you have one.
}

@end

