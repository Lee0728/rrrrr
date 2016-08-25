/*
 App delegate
 
 Copyright 2013 Thinstuff Technologies GmbH, Author: Martin Fleisz
 
 This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
 If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

#import "AppDelegate.h"

#import "AboutController.h"
#import "BookmarkListController.h"
#import "AppSettingsController.h"
#import "MainTabBarController.h"
//#import "MessageViewController.h"
#import "MessageViewController.h"
#import "Utils.h"
#import "tcp.h"
#import "packect.h"
#import "GwtFunction.h"

//16.07.18
#import <sys/sysctl.h>

@implementation AppDelegate


@synthesize window = _window, tabBarController = _tabBarController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Set default values for most NSUserDefaults
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]]];
    SetSwapMouseButtonsFlag([[NSUserDefaults standardUserDefaults] boolForKey:@"ui.swap_mouse_buttons"]);
    SetInvertScrollingFlag([[NSUserDefaults standardUserDefaults] boolForKey:@"ui.invert_scrolling"]);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotateactive:) name:TSXrotateactive object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotatedeactive:) name:TSXrotatedeactive object:nil];
    NSString *error = nil;

    //[self httpGet];
    //[application setApplicationIconBadgeNumber:0];
    // init global settings
    first =3;
    //BOOL first =  [[NSUserDefaults standardUserDefaults] boolForKey:@"everLauched"];
    //char host[20];
    char port[10];
    //NSString * mystring;
    //strcpy(host,(char *)[@"192.168.2.108" UTF8String]);
    NSString *Virtualcmd = @"usr=usr00000001,root=11,priv=1,name=\"ios测试\\ios测试1\"";

    NSLog(@"the string is %@",Virtualcmd);
   // NSString *me = @"by";
    int num = [Virtualcmd length];
    NSLog(@"the num is %d",num);
    unichar *Cmdchar = (unichar *)malloc(num*sizeof(unichar));
    int i=0;
    for(i = 0 ; i < num ; i++)
    {
        *Cmdchar = [Virtualcmd characterAtIndex:i];
        printf("the cmdchar is %d \n",*Cmdchar);
        //Cmdchar++;
        Cmdchar++;
    }
    int length = 2*[Virtualcmd length]+10;
    [NSThread detachNewThreadSelector:@selector(Readmessage) toTarget:self withObject:nil];

    /*sendcmd(length,Cmdchar-num);
    int numread = readcmd();
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    unsigned short * unistr = readcmdstr(numread);
    //char * getstr = malloc(50);
     char *getstr = unicode_to_utf8(unistr,numread-10);

NSString *encrypted = [[NSString alloc] initWithCString:(const char*)getstr encoding:NSUTF8StringEncoding];*/
   /* NSString *documentDir = [[NSBundle mainBundle] pathForResource:@"IMG_0283_9990484" ofType:@"MOV"];
    NSLog(@"the dir is %@",documentDir);
    NSData* reader = [NSData dataWithContentsOfFile:documentDir];
    getreader = (unsigned char *)[reader bytes];
    int filelength = [reader length];
    NSLog(@"the length is %d",filelength);
    NSString *Uploadstr = @"usr=usr00000001,root=11,priv=1,name=\"IMG_0283_9990484.MOV\",size=38538403";
           //NSString *Uploadstr = @"usr=usr00000001,root=11,priv=1,name=\"ios测试\\ios测试1\"";
    int num1 = [Uploadstr length];
    NSLog(@"the num is %d",num1);
    unichar *Cmdchar1 = (unichar *)malloc(num1*sizeof(unichar));
    
    for(int i = 0 ; i < num1 ; i++)
    {
        *Cmdchar1 = [Uploadstr characterAtIndex:i];
        printf("the cmdchar is %d \n",*Cmdchar);
        //Cmdchar++;
        Cmdchar1++;
    }

    printf("the reader length is %d",[reader length]);
    unsigned char *senddata =malloc(4);
    senddata[0]=25;
    senddata[1]=100;
    senddata[2]=200;
    senddata[3]=300;
    int length1 = 2*[Uploadstr length]+10;
    printf("the uploadstr is %d",length1);
    //length1+= [reader length];
    Sendcmdupload(length1,Cmdchar1-num1,senddata,4);
    writefile(38538403,getreader);*/
    //readcmd();
    /*NSString *Downloadstr = @"usr=usr00000001,root=11,priv=1,name=\"IMG_0283_9990484.MOV\"";
    int num2 = [Downloadstr length];
    unichar *Cmdchar2 = (unichar *)malloc(num2*sizeof(unichar));
    
    for(int i = 0 ; i < num2 ; i++)
    {
        *Cmdchar2 = [Downloadstr characterAtIndex:i];
        printf("the cmdchar is %d \n",*Cmdchar2);
        //Cmdchar++;
        Cmdchar2++;
    }
    int length2 = 2*[Downloadstr length]+10;
    NSLog(@"the num2 is %d",num2);
    NSLog(@"the length2 is %d",length2);
    Sendcmddownload(length2,Cmdchar2-num2);
    readcmd(18);
    for(int i=0;i<(38538403/1024);i++)
    {
     if(i==100)
     {
         readcmdend(1024);
     }
    else
    {
    readcmd(1024);
    }
    }
    readcmdend(38538403%1024);*/
    
    //readcmd(1024);
    //readcmd(1024);
    //readcmd(396);
    //readcmd(1024);
    //readcmd(1024);
    //readcmd(1024);
    //NSLog(@"the str is %@",encrypted);

    // create bookmark view and navigation controller
    BookmarkListController* bookmarkListController = [[[BookmarkListController alloc] initWithNibName:@"BookmarkListView" bundle:nil] autorelease];
    //BookmarkListController.table
    UINavigationController* bookmarkNavigationController = [[[UINavigationController alloc] initWithRootViewController:bookmarkListController] autorelease];
    [messageViewController setDelegate:self];
    messageViewController =[[[MessageViewController alloc] initWithNibName:@"Messageview" bundle:nil delegate:self] autorelease];
    //[messageViewController setDelegate:self];
    UINavigationController* MessageViewNavigationController = [[[UINavigationController alloc] initWithRootViewController:messageViewController] autorelease];
    //messageViewController.edgesForExtendedLayout
    // create app settings view and navigation controller
    AppSettingsController* appSettingsController = [[[AppSettingsController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
    UINavigationController* appSettingsNavigationController = [[[UINavigationController alloc] initWithRootViewController:appSettingsController] autorelease];
    NSString *machinename = [self getMachine];
    NSLog(@"the machinename is %@",machinename);
    machinename=[machinename substringWithRange:NSMakeRange(0, 4)];
    if([machinename isEqualToString:@"iPad"])
    {
        helpViewController = [[[HelpController alloc] initWithNibName:@"View" bundle:nil] autorelease];
    }
    else
    {
        helpViewController = [[[HelpController alloc] initWithNibName:@"View" bundle:nil] autorelease];
    }
    // create help view controller
    
    [_tabBarController setrotateflag:0];
    // create about view controller
    AboutController* aboutViewController = [[[AboutController alloc] initWithNibName:@"AboutView" bundle:nil] autorelease];
    
    // add tab-bar controller to the main window and display everything
    NSArray* tabItems = [NSArray arrayWithObjects:bookmarkNavigationController,MessageViewNavigationController, helpViewController, aboutViewController, nil];
    [_tabBarController setViewControllers:tabItems];
    if ([_window respondsToSelector:@selector(setRootViewController:)])
        [_window setRootViewController:_tabBarController];
    else
        [_window addSubview:[_tabBarController view]];
    [_window makeKeyAndVisible];
    
    return YES;
}
- (void) Readmessage
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunched"])
    {//[[NSUserDefaults standardUserDefaults] setBool:YES
        //forKey:@"everLaunched"];
        //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
        //first = 2;
        //;
        [[NSUserDefaults standardUserDefaults] setBool:YES
                                                forKey:@"everLaunched"];
        [[NSUserDefaults standardUserDefaults]
         setBool:YES forKey:@"firstLaunch"];
        //[NSThread detachNewThreadSelector:@selector(httpGetmaxid) toTarget:self withObject:nil];
        
        midnum = [self httpGetmaxid];
        if(midnum!=nil)
        {
            maxmid = [midnum intValue];
            [self writefile:@"midnum.xml" writedata:midnum];
            
            NSString* mystring = [self readfile:@"midnum.xml"];
            NSLog(@"mystring=%@",mystring);
        }
        
        
    }
    else
    {
        [[NSUserDefaults
          standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
        
        [[NSUserDefaults
          standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
        id messageplist = [self applicationPlistFromFile:@"config.plist"];
        parserObjects = [[NSMutableArray alloc]init];
        //index.php?cmd=maxid
        if(messageplist != NULL)
        {
            messageconfig = [[NSMutableDictionary alloc] initWithDictionary:[self applicationPlistFromFile:@"config.plist"]];
            
            parserObjects = [messageconfig valueForKey:@"messageinfo"];
            if([parserObjects count]==0)
            {
                midnum = [self readfile:@"midnum.xml"];
                //midnum = [NSString stringWithFormat:@"%d",getmid];
            }
            else
            {
                MessageDic = [parserObjects objectAtIndex:([parserObjects count]-1)];
                midnum = [MessageDic valueForKey:@"MID"];
                midnum = [[parserObjects objectAtIndex:([parserObjects count]-1)] valueForKey:@"MID"];
            }
        }
        else
        {
            midnum = [self readfile:@"midnum.xml"];
            
        }
    }
    /* if (![fileManager fileExistsAtPath:path])
     {
     midnum = @"0";
     }
     else
     {
     //[self ParseMessageXml:path];
     int count = [parserObjects count];
     midnum =[[parserObjects objectAtIndex:count] valueForKey:@"MID"];
     
     }*/
    //midnum =@"6";
    if(midnum!=nil)
    {
    [self httpGet:midnum];
    }
    [self performSelectorOnMainThread:@selector(getParse) withObject:nil waitUntilDone:YES];

}
- (void)getParse
{
    [messageViewController getParse];
    [[messageViewController tableView] reloadData];
}
+ (NSString *)replaceUnicode:(NSString *)unicodeStr {
    
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2]stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                          mutabilityOption:NSPropertyListImmutable
                                                                    format:NULL
                                                          errorDescription:NULL];
    
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
    
}
- (void) writefile : (NSString*) filename writedata:(const void*)data length:(int)length
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *Paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [Paths objectAtIndex:0];
    NSData *getdata = [NSData dataWithBytes:data length:length];
    NSString *MessagePath = [documentDirectory stringByAppendingPathComponent:filename];
    [fileManager createFileAtPath:MessagePath contents:nil attributes:nil];
    [getdata writeToFile:MessagePath atomically:YES];
}
- (void) writefile : (NSString*) filename writedata:(NSString *)wdata
{
    NSData* Data = [wdata dataUsingEncoding:NSUTF8StringEncoding];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *Paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [Paths objectAtIndex:0];

    // DBNAME 是要查找的文件名字，文件全名
    
    NSString *MessagePath = [documentDirectory stringByAppendingPathComponent:filename];
    // NSString *NewMessagePath = [documentDirectory stringByAppendingPathComponent:@"NewMessage.xml"];
    
    [fileManager createFileAtPath:MessagePath contents:nil attributes:nil];
    [Data writeToFile:MessagePath atomically:YES];
}
- (NSString *)readfile:(NSString*)filename
{
    //NSData* Data = [wdata dataUsingEncoding:NSUTF8StringEncoding];
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *Paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [Paths objectAtIndex:0];
    
    // DBNAME 是要查找的文件名字，文件全名
    
    NSString *MessagePath = [documentDirectory stringByAppendingPathComponent:filename];
    NSString* myString = [NSString stringWithContentsOfFile:MessagePath usedEncoding:NULL error:NULL];
    NSLog(@"mystring=%@",myString);
    return myString;
}
- (id) applicationPlistFromFile:(NSString *)fileName
{
    NSData *retData;
    NSString *error = nil;
    id retPlist;
	NSPropertyListFormat format;
	
    retData = [self applicationDataFromFile:fileName];
    retPlist = [NSPropertyListSerialization propertyListFromData:retData  mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&error];
    if (!retPlist)
    {
        NSLog(@"Plist not returned, error: %@", error);
    }
    return retPlist;
}
- (void)Setbadge:count
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
}
- (NSData *)applicationDataFromFile:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSData *myData = [[[NSData alloc] initWithContentsOfFile:appFile] autorelease];
    return myData;
}
-(NSString *) httpGetmaxid
{
    NSString *url = @"http://125.76.226.161:9880/index.php?cmd=maxid";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    NSError *error = nil;
    //[NSThread detachNewThreadSelector:@selector(downloadfile) toTarget:self withObject:nil];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (data == nil) {
        NSLog(@"send request failed: %@", error);
        //desktopflag = 0;
        return nil;
    }
    //midnum = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSString *check = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"check=%@",check);
    return check;
    
}
- (BOOL)writeApplicationData:(NSData *)data toFile:(NSString *)fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	if (!documentsDirectory)
	{
		NSLog(@"Documents directory not found!");
		return NO;
	}
	NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"config.plist"];
	return ([data writeToFile:appFile atomically:YES]);
}
-(void) httpGet:(NSString *) num
{
    NSString *url = @"http://125.76.226.161:9880/index.php?cmd=getxml&MID=";//6&Platform=IOS";
    url = [url stringByAppendingString:num];
    url = [url stringByAppendingString:@"&Platform=IOS"];
    //url = [url stringByAddingPercentEscapesUsingEncoding:gbkEncoding];
    
    // NSURL *reURL = [[NSURL alloc] initWithString:url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (data == nil) {
        NSLog(@"send request failed: %@", error);
        //desktopflag = 0;
        return;
    }
    NSString *check = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"check=%@",check);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *Paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [Paths objectAtIndex:0];
    
    // DBNAME 是要查找的文件名字，文件全名
    
    NSString *MessagePath = [documentDirectory stringByAppendingPathComponent:@"Message.xml"];
    // NSString *NewMessagePath = [documentDirectory stringByAppendingPathComponent:@"NewMessage.xml"];
    
    [fileManager createFileAtPath:MessagePath contents:nil attributes:nil];
    [data writeToFile:MessagePath atomically:YES];
    //NSData* fileData = [NSData dataWithContentsOfFile:@"aaa.xml"];
    
    NSString* myString = [NSString stringWithContentsOfFile:MessagePath usedEncoding:NULL error:NULL];
    NSLog(@"mystring=%@",myString);
    // NSString* fileName = [[filePath objectAtIndex:0]stringByAppendingPathComponent:@"aaa.xml"];
    
    
    //NSMutableDictionary* dict = [[NSMutableDictionary alloc]initWithContentsOfFile:fileName];
    
}

//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
//{
//    /*if([[url scheme] isEqualToString:@"myapp"]){
//     [application setApplicationIconBadgeNumber:0];
//     return YES;
//     }
//     return NO;*/
//}

- (void)rotateactive:(NSNotification*)notification
{
    [_tabBarController setrotateflag:0];
}
- (void)rotatedeactive:(NSNotification*)notification
{
    [_tabBarController setrotateflag:1];
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    //    NSLog(@"%@",NSStringFromSelector(_cmd) );
    
    
}
- (void)ParseMessageXml:(NSString *)filename
{
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:filename];
    NSData *data = [file readDataToEndOfFile];
    [file closeFile];
    NSXMLParser *m_parser = [[NSXMLParser alloc] initWithData:data];
    //设置该类本身为代理类，即该类在声明时要实现NSXMLParserDelegate委托协议
    [m_parser setDelegate:self];  //设置代理为本地
    
    BOOL flag = [m_parser parse]; //开始解析
    
    if(flag) {
        NSLog(@"获取指定路径的xml文件成功");
    }else{
        NSLog(@"获取指定路径的xml文件失败");
    }
}
//step 2：准备解析节点
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    //    NSLog(@"%@",NSStringFromSelector(_cmd) );
    
    currentText = [[NSMutableString alloc]init];
    if ([elementName isEqualToString:@"element"]) {
        NSMutableDictionary *newNode = [[ NSMutableDictionary alloc ] initWithCapacity : 0 ];
        twitterDic = newNode;
        [parserObjects addObject :newNode];
        [newNode release];
    }
    else if(twitterDic) {
        NSMutableString *string = [[ NSMutableString alloc ] initWithCapacity : 0 ];
        [twitterDic setObject :string forKey :elementName];
        [string release ];
        currentElementName = elementName;
    }
    
    
}
//step 3:获取首尾节点间内容
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSLog(@"%@",NSStringFromSelector(_cmd) );
    NSLog(@"the string is %@",string);
    if ([string rangeOfString:@"\n"].location != NSNotFound)
    {
        return;
    }
    else
    {
        if(string != NULL)
        {
            [currentText appendString:string];
            NSLog(@"the string is %@",currentText);
            
        }
    }
}

//step 4 ：解析完当前节点
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"element"]) {
        twitterDic = nil;
    }
    if ([elementName isEqualToString:@"element"]) {
        twitterDic = nil;
    }else
        if ([elementName isEqualToString:currentElementName]) {
            
            
            [twitterDic setObject:currentText forKey:currentElementName];
            [currentText release];
            
        }
    
}

//step 5；解析结束
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    badgecount = [parserObjects count] -1;
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
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    // cancel disconnect timer
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

#pragma mark - 网页或其他应用中调用客户端并进入到虚拟应用
// test url:
// "ThinAPP://6e6f69446838624a7a4e4e6e4e446871616e496e4c69346b516b49544545314e5546414e445674786358417366324131626d46764f6b355255464e655855513d"

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (url == nil) {
        return NO;
    }
    NSString *strUrl = [url absoluteString];
    if (!strUrl || strUrl.length<=0) {
        return NO;
    }
    NSLog(@"\nstrUrl = %@\n", strUrl);
    
    if ([strUrl hasPrefix:@"GWTClient"]) {
        NSRange range = [strUrl rangeOfString:@"//"];
        if (range.location != NSNotFound) {
            strUrl = [strUrl substringFromIndex:range.location+range.length];
            NSLog(@"\nstrUrl = %@\n", strUrl);
        } else{
            return NO;
        }
    }else{
        return NO;
    }
    
    GwtFunction *gwt = [GwtFunction new];
    if (gwt) {
        NSString *strDecode = [gwt getDeCrityStrrap:strUrl];
        NSLog(@"\n\nstrDecode = %@\n", strDecode);
        [gwt release];
        
        NSArray *arrInfo = [strDecode componentsSeparatedByString:@","];
        if (arrInfo && [arrInfo  count]>0) {
            // ...
        }
    }
    
    return YES;
}

@end
