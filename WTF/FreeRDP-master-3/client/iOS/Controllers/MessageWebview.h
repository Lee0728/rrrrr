//
//  MessageWebview.h
//  FreeRDP
//
//  Created by 吴 永华 on 14-3-14.
//
//

#import <UIKit/UIKit.h>

@interface MessageWebview : UIViewController <UIWebViewDelegate>
{
    UIWebView *webView;
    NSURLRequest *request;
    UINavigationController *MessageViewNavController;
    UIActivityIndicatorView *activityIndicator;

}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSString *)Weburl;
- (void)didReceiveMemoryWarning;
- (void)viewDidLoad;
- (void) webViewDidStartLoad:(UIWebView *)webView;
- (void)ParseMessageXml:(NSString *)filename;
@end
