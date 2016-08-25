//
//  MessageWebview.m
//  FreeRDP
//
//  Created by 吴 永华 on 14-3-14.
//
//

#import "MessageWebview.h"
//16.07.18
#import <sys/sysctl.h>
@interface MessageWebview ()

@end

@implementation MessageWebview

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSString *)Weburl
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
     //[self setTitle:NSLocalizedString(@"message", @"'集群列表': bookmark controller title")];
    self.navigationItem.title = @"消息";
    NSString *machinename = [self getMachine];
    NSLog(@"the machinename is %@",machinename);
    machinename=[machinename substringWithRange:NSMakeRange(0, 4)];
    if([machinename isEqualToString:@"iPad"])
    {
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
    }
    else
    {
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    }
    
    request =[NSURLRequest requestWithURL:[NSURL URLWithString:Weburl]];
    [self.view addSubview: webView];
    [webView loadRequest:request];
    if (self) {
        // Custom initialization
    }

    return self;
}
- (NSString*)getMachine{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *name = malloc(size);
    sysctlbyname("hw.machine", name, &size, NULL, 0);
    
    NSString *machine = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
    NSLog(@"the machinename is %@",machine);
    free(name);
    
    if( [machine isEqualToString:@"i386"] || [machine isEqualToString:@"x86_64"] ) machine = @"ios_Simulator";
    else if( [machine isEqualToString:@"iPhone1,1"] ) machine = @"iPhone_1G";
    else if( [machine isEqualToString:@"iPhone1,2"] ) machine = @"iPhone_3G";
    else if( [machine isEqualToString:@"iPhone2,1"] ) machine = @"iPhone_3GS";
    else if( [machine isEqualToString:@"iPhone3,1"] ) machine = @"iPhone_4";
    else if( [machine isEqualToString:@"iPod1,1"] ) machine = @"iPod_Touch_1G";
    else if( [machine isEqualToString:@"iPod2,1"] ) machine = @"iPod_Touch_2G";
    else if( [machine isEqualToString:@"iPod3,1"] ) machine = @"iPod_Touch_3G";
    else if( [machine isEqualToString:@"iPod4,1"] ) machine = @"iPod_Touch_4G";
    else if( [machine isEqualToString:@"iPad1,1"] ) machine = @"iPad_1";
    else if( [machine isEqualToString:@"iPad2,1"] ) machine = @"iPad_2";
    
    return machine;
}
- (void)viewDidLoad
{
    //[super viewDidLoad];
    [super viewDidLoad];
    

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) webViewDidStartLoad:(UIWebView *)webView
{
    //创建UIActivityIndicatorView背底半透明View
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [view setTag:108];
    [view setBackgroundColor:[UIColor blackColor]];
    [view setAlpha:0.5];
    [self.view addSubview:view];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [activityIndicator setCenter:view.center];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [view addSubview:activityIndicator];
    
    [activityIndicator startAnimating];
}
@end
