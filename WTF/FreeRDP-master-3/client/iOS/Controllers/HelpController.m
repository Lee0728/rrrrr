/*
 Application help controller
 
 Copyright 2013 Thinstuff Technologies GmbH, Author: Martin Fleisz
 
 This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
 If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

/*#import "HelpController.h"
#import "Utils.h"

@implementation HelpController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    UIImage* tabBarIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tabbar_icon_help" ofType:@"png"]];
    [self setTabBarItem:[[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Help", @"Tabbar item help") image:tabBarIcon tag:0] autorelease]];
    return self;
}

- (void)loadView
{
	// load default view and set background color and resizing mask
    //[self view]
	[super loadView];

    
}
- (void)buildscrollview
{

//help_scrollview.minimumZoomScale = help_scrollview.frame.size.height / [rd view].frame.size.height;
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    help_scrollview.contentSize=CGSizeMake(400, 2000);
}
- (void)dealloc {
    [super dealloc];
}



@end*/
/*
 Application help controller
 
 Copyright 2013 Thinstuff Technologies GmbH, Author: Martin Fleisz
 
 This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
 If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

#import "HelpController.h"
#import "Utils.h"

//16.07.18
#import <sys/sysctl.h>

@implementation HelpController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    UIImage* tabBarIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tabbar_icon_help" ofType:@"png"]];
    [self setTabBarItem:[[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Help", @"Tabbar item help") image:tabBarIcon tag:0] autorelease]];
    NSString *machinename1 = [self getMachine];
    NSLog(@"the machinename is %@",machinename);
    NSString *machinename2=[machinename1 substringWithRange:NSMakeRange(0, 4)];
    NSLog(@"the machinename is %@",machinename1);
    machinename = [machinename2 copy];
    NSLog(@"the machinename is %@",machinename);
    /*UIImage* tabBarIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tabbar_icon_help" ofType:@"png"]];
     [self setTabBarItem:[[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Help", @"Tabbar item help") image:tabBarIcon tag:0] autorelease]];*/
    return self;
}

- (void)loadView
{
    // load default view and set background color and resizing mask
    //[self view]
    [super loadView];
    
    
}
- (void)buildscrollview
{
    
    //help_scrollview.minimumZoomScale = help_scrollview.frame.size.height / [rd view].frame.size.height;
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    /*help_scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - 44)];
     help_scrollview.backgroundColor = [UIColor blackColor];
     help_scrollview.bounces = NO;
     help_scrollview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
     //help_scrollview.contentSize = CGSizeMake([[connectionSettings valueForKey:@"screenwidth"] intValue], [[connectionSettings valueForKey:@"screenheight"] intValue]);
     help_scrollview.maximumZoomScale = 3.0;
     [help_scrollview addSubview:help_view];
     [[self view] addSubview:help_scrollview];*/
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
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    footerView.backgroundColor = [UIColor clearColor];
    if([machinename isEqualToString:@"iPad"])
    {
        backbutton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-75, 20, 150, 45)];
    }
    else
    {
        backbutton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-50, 10, 100, 30)];
    }
    //[backbutton setBackgroundColor:[UIColor blueColor]];
    UIImage *backimage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"yuanguangchange" ofType:@"png"]];
    [backbutton setBackgroundImage:backimage forState:0];
    [backbutton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchDown];
    [backbutton setTitle:@"返回" forState:0];
    [footerView addSubview:backbutton];
    self.tableView.tableFooterView = footerView;
    
    //help_scrollview.contentSize=CGSizeMake(400, 2000);
}
- (void)back:(id) sender
{
    [delegate SetBackSessionflag];
    [self.view removeFromSuperview];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    /*if(helpflag == TRUE)
     {
     return NO;
     }
     else
     {
     return YES;
     }*/
    return NO;
}
- (void)dealloc {
    [super dealloc];
}
- (NSInteger)numberOfSections;
{
    return 1;
}
- (void)setDelegate:(id)object
{
    if (delegate)
    {
        [delegate release];
    }
    delegate = object;
    [object retain];
}

- (id)delegate
{
    return delegate;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (indexPath.row == 5)
    {
        if([machinename isEqualToString:@"iPad"])
        {
            return 200.0;
        }
        else
        {
            return 130.0;
        }
    }
    else
    {
        if([machinename isEqualToString:@"iPad"])
        {
            NSLog(@"ipad");
            return 100;
        }
        else
        {
            return 50.0;
        }
    }
    //return tableView.rowHeight;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 6;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *CellIdentifier = @"HelpCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        [[NSBundle mainBundle] loadNibNamed:@"helpcell" owner:self options:NULL];
        cell = HelpCell;
        //[cell setFrame:CGRectMake(32, 40, 7680.0, 180.0)];
        //[cell.contentView setFrame:CGRectMake(32, 40, 7680.0, 180.0)];
        switch (indexPath.row) {
            case 0:
            {
                
                UIImageView *helpimg = (UIImageView *)[cell viewWithTag:0];
                if([machinename isEqualToString:@"iPad"])
                {
                    UIImage *getimg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toolbar_icon_disconnect_ipad" ofType:@"png"]];
                    helpimg.image = getimg;
                }
                else
                {
                    [helpimg setFrame:CGRectMake(34, 60, 40.0, 40.0)];
                    UIImage *getimg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toolbar_icon_disconnect" ofType:@"png"]];
                    helpimg.image = getimg;
                }
                //[helpimg setFrame:CGRectMake(32, 40, 120.0, 180.0)];
                
                UILabel *appName = (UILabel *)[cell viewWithTag:1];
                if([machinename isEqualToString:@"iPad"])
                {
                    appName.font = [UIFont fontWithName:@"Arial" size:20];
                }
                else
                {
                    [appName setFrame:CGRectMake(60, 0, 250.0, 50.0)];
                    appName.font = [UIFont fontWithName:@"Arial" size:12];
                }
                appName.text = @"退出界面开关，选中后退出应用返回应用列表界面";
                break;
            }
            case 1:
            {
                
                UIImageView *helpimg = (UIImageView *)[cell viewWithTag:0];
                if([machinename isEqualToString:@"iPad"])
                {
                    UIImage *getimg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toolbar_icon_keyboard_ipad" ofType:@"png"]];
                    helpimg.image = getimg;
                }
                else
                {
                    [helpimg setFrame:CGRectMake(34, 60, 40.0, 40.0)];
                    UIImage *getimg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toolbar_icon_keyboard" ofType:@"png"]];
                    helpimg.image = getimg;
                }
                //[helpimg setFrame:CGRectMake(32, 40, 120.0, 180.0)];
                
                UILabel *appName = (UILabel *)[cell viewWithTag:1];
                if([machinename isEqualToString:@"iPad"])
                {
                    appName.font = [UIFont fontWithName:@"Arial" size:20];
                }
                else
                {
                    [appName setFrame:CGRectMake(60, 0, 250.0, 50.0)];
                    appName.font = [UIFont fontWithName:@"Arial" size:12];
                }
                appName.text = @"键盘开关，选中后打开键盘界面，再次选中关闭该键盘界面";
                break;
            }
            case 2:
            {
                
                UIImageView *helpimg = (UIImageView *)[cell viewWithTag:0];
                if([machinename isEqualToString:@"iPad"])
                {
                    UIImage *getimg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toolbar_icon_extkeyboad_ipad" ofType:@"png"]];
                    helpimg.image = getimg;
                }
                else
                {
                    [helpimg setFrame:CGRectMake(34, 60, 40.0, 40.0)];
                    UIImage *getimg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toolbar_icon_extkeyboad" ofType:@"png"]];
                    helpimg.image = getimg;
                }
                //[helpimg setFrame:CGRectMake(32, 40, 120.0, 180.0)];
                
                UILabel *appName = (UILabel *)[cell viewWithTag:1];
                if([machinename isEqualToString:@"iPad"])
                {
                    appName.font = [UIFont fontWithName:@"Arial" size:20];
                }
                else
                {
                    [appName setFrame:CGRectMake(60, 0, 250.0, 50.0)];
                    appName.font = [UIFont fontWithName:@"Arial" size:12];
                }
                //[helpimg setFrame:CGRectMake(32, 40, 120.0, 120.0)];
                
                //UILabel *appName = (UILabel *)[cell viewWithTag:1];
                //appName.font = [UIFont fontWithName:@"Arial" size:20];
                appName.text = @"增强键盘开关，选中后打开增强键盘界面，包括常用的windows功能键，再次选中关闭该增强键盘界面";
                break;
            }
            case 3:
            {
                
                UIImageView *helpimg = (UIImageView *)[cell viewWithTag:0];
                //[helpimg setFrame:CGRectMake(32, 40, 120.0, 120.0)];
                if([machinename isEqualToString:@"iPad"])
                {
                    UIImage *getimg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toolbar_icon_touchpointer_ipad" ofType:@"png"]];
                    helpimg.image = getimg;
                }
                else
                {
                    [helpimg setFrame:CGRectMake(34, 60, 40.0, 40.0)];
                    UIImage *getimg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toolbar_icon_touchpointer" ofType:@"png"]];
                    helpimg.image = getimg;
                }
                //[helpimg setFrame:CGRectMake(32, 40, 120.0, 180.0)];
                
                UILabel *appName = (UILabel *)[cell viewWithTag:1];
                if([machinename isEqualToString:@"iPad"])
                {
                    appName.font = [UIFont fontWithName:@"Arial" size:20];
                }
                else
                {
                    [appName setFrame:CGRectMake(60, 0, 250.0, 50.0)];
                    appName.font = [UIFont fontWithName:@"Arial" size:12];
                }
                //UILabel *appName = (UILabel *)[cell viewWithTag:1];
                //appName.font = [UIFont fontWithName:@"Arial" size:20];
                appName.text = @"触摸指针开关，选中后打开触摸指针界面，再次选中关闭触摸指针界面";
                break;
            }
            case 4:
            {
                
                UIImageView *helpimg = (UIImageView *)[cell viewWithTag:0];
                UIImage *getimg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"catalog" ofType:@"png"]];
                helpimg.image = getimg;
                if([machinename isEqualToString:@"iPad"])
                {
                    UIImage *getimg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"catalog_ipad" ofType:@"png"]];
                    helpimg.image = getimg;
                }
                else
                {
                    [helpimg setFrame:CGRectMake(34, 60, 40.0, 40.0)];
                    UIImage *getimg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"catalog" ofType:@"png"]];
                    helpimg.image = getimg;
                }
                //[helpimg setFrame:CGRectMake(32, 40, 120.0, 180.0)];
                
                UILabel *appName = (UILabel *)[cell viewWithTag:1];
                if([machinename isEqualToString:@"iPad"])
                {
                    appName.font = [UIFont fontWithName:@"Arial" size:20];
                }
                else
                {
                    [appName setFrame:CGRectMake(60, 0, 250.0, 50.0)];
                    appName.font = [UIFont fontWithName:@"Arial" size:12];
                }
                //[helpimg setFrame:CGRectMake(32, 40, 120.0, 120.0)];
                // UILabel *appName = (UILabel *)[cell viewWithTag:1];
                //[appName setFrame:CGRectMake(148, 0, 242.0, 240.0)];
                //appName.font = [UIFont fontWithName:@"Arial" size:12];
                //appName.font = [UIFont fontWithName:@"Arial" size:12];
                appName.text = @"文件映射开关，选中后打开文件映射界面，选中关闭按钮后该页面关闭";
                break;
            }
            case 5:
            {
                
                UIImageView *helpimg = (UIImageView *)[cell viewWithTag:0];
                [helpimg setFrame:CGRectMake(34, 60, 300.0, 300.0)];
                UIImage *getimg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"touch_pointer_active" ofType:@"png"]];
                helpimg.image = getimg;
                if([machinename isEqualToString:@"iPad"])
                {
                    [helpimg setFrame:CGRectMake(34, 60, 300.0, 300.0)];
                    UIImage *getimg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"touch_pointer_active_ipad" ofType:@"png"]];
                    helpimg.image = getimg;
                }
                else
                {
                    [helpimg setFrame:CGRectMake(34, 40, 200.0, 200.0)];
                    UIImage *getimg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"touch_pointer_active_iphone" ofType:@"png"]];
                    helpimg.image = getimg;
                }
                //[helpimg setFrame:CGRectMake(32, 40, 120.0, 180.0)];
                UILabel *appName = (UILabel *)[cell viewWithTag:1];
                
                if([machinename isEqualToString:@"iPad"])
                {
                    [appName setFrame:CGRectMake(248, -60, 500.0, 342.0)];
                    appName.font = [UIFont fontWithName:@"Arial" size:20];
                }
                else
                {
                    [appName setFrame:CGRectMake(148, -60, 160.0, 242.0)];
                    appName.font = [UIFont fontWithName:@"Arial" size:12];
                }
                //UILabel *appName = (UILabel *)[cell viewWithTag:1];
                
                //appName.font = [UIFont fontWithName:@"Arial" size:12];
                
                appName.text = @"触摸指针：左上角箭头指向鼠标坐标位置，右上角鼠标表示右键，中间鼠标表示鼠标左键，右侧中间双向箭头表示上下拖动滚动条，左下方的按钮表示返回原始尺寸，下方中间键盘表示系统键盘，右下方键盘表示增强功能键盘";
                break;
            }
                //default:
                //break;
        }
    }
    return cell;
}

@end
