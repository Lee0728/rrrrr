//
//  MessageViewController.m
//  FreeRDP
//
//  Created by 吴 永华 on 14-3-12.
//
//

#import "MessageViewController.h"
//16.07.18
#import <sys/sysctl.h>
@interface MessageViewController ()

@end

@implementation MessageViewController
@synthesize tableView = _tableView,mstablecell = _msTableCell;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id)getdelegate{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    fontsizeflag = 0;
    NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"7.0" options: NSNumericSearch];
   /* if (order == NSOrderedSame || order == NSOrderedDescending)
    {
        // OS version >= 7.0
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.
    }*/
    /*[self setTitle:@"消息"];
    UIImage* tabBarIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tabbar_message" ofType:@"png"]];
    
    [self setTabBarItem:[[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"message", @"Tabbar item message") image:tabBarIcon tag:0] autorelease]];
    self.tabBarItem.badgeValue = @"5";*/
    UIImage* tabBarIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tabbar_message" ofType:@"png"]];
    [self setTabBarItem:[[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"message", @"Tabbar item message") image:tabBarIcon tag:0] autorelease]];
    delegate = getdelegate;
    NSString *sysversion = [[UIDevice currentDevice] systemVersion];
    NSLog(@"the sysversion is %@",sysversion);
    NSString *sysversion1=[sysversion substringWithRange:NSMakeRange(0, 1)];
    NSLog(@"the sysversion is %@",sysversion1);
    [self setTitle:@"消息"];
    if([sysversion1 isEqualToString:@"7"])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    if (_refreshTableView == nil) {
        //初始化下拉刷新控件
        EGORefreshTableHeaderView *refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 0.0)];
        //refreshView.delegate = self;
        [refreshView setDelegate:self];
        //将下拉刷新控件作为子控件添加到UITableView中
        [self.tableView addSubview:refreshView];
        _refreshTableView = refreshView;
    }
    //[this getprase];
    [self getParse];
    /*
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *Paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    id messageplist = [self applicationPlistFromFile:@"config.plist"];
    delegate =getdelegate;
    parserObjects = [[NSMutableArray alloc]init];
    if(messageplist != NULL)
    {
    messageconfig = [[NSMutableDictionary alloc] initWithDictionary:[self applicationPlistFromFile:@"config.plist"]];
    
    parserObjects = [messageconfig valueForKey:@"messageinfo"];
    }
    id badgeplist = [self applicationPlistFromFile:@"badgeconfig.plist"];
    if(badgeplist != NULL)
    {
    badgeconfig = [[NSMutableDictionary alloc] initWithDictionary:[self applicationPlistFromFile:@"badgeconfig.plist"]];
        badgecount = [badgeconfig valueForKey:@"badgevalue"];
    }
    else
    {
        badgecount = 0;
    }
    Messagecount = [parserObjects count];
    NSString *documentDirectory = [Paths objectAtIndex:0];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"Message.xml"];
    //NSString *newpath = [documentDirectory stringByAppendingPathComponent:@"NewMessage.xml"];
    [self ParseMessageXml:path];*/
    //oldcount = [parserObjects count];

    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;//隐藏为YES，显示为NO
}

- (void)getParse
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *Paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    id messageplist = [self applicationPlistFromFile:@"config.plist"];
    //delegate =getdelegate;
    parserObjects = [[NSMutableArray alloc]init];
    if(messageplist != NULL)
    {
        messageconfig = [[NSMutableDictionary alloc] initWithDictionary:[self applicationPlistFromFile:@"config.plist"]];
        
        parserObjects = [messageconfig valueForKey:@"messageinfo"];
    }
    id badgeplist = [self applicationPlistFromFile:@"badgeconfig.plist"];
    if(badgeplist != NULL)
    {
        badgeconfig = [[NSMutableDictionary alloc] initWithDictionary:[self applicationPlistFromFile:@"badgeconfig.plist"]];
        badgecount = [badgeconfig valueForKey:@"badgevalue"];
    }
    else
    {
        badgecount = 0;
    }
    Messagecount = [parserObjects count];
    NSString *documentDirectory = [Paths objectAtIndex:0];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"Message.xml"];
    //NSString *newpath = [documentDirectory stringByAppendingPathComponent:@"NewMessage.xml"];
    [self ParseMessageXml:path];
    //oldcount = [parserObjects count];
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

- (NSData *)applicationDataFromFile:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSData *myData = [[[NSData alloc] initWithContentsOfFile:appFile] autorelease];
    return myData;
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
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.editButtonItem.title = @"删除";
     [[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
   // self.edgesForExtendedLayout = UIRectEdgeNone;
    //self.navigationController.navigationBar.barTintColor = [UIColor grayColor];
    //self.edgesForExtendedLayout
	// Do any additional setup after loading the view.
}
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    if (self.editing) {
        self.editButtonItem.title = @"完成";
    } else {
        self.editButtonItem.title = @"删除";
    }
    
    [[self tableView] setEditing:editing animated:animated];
}
- (void)datatofile
{
    NSString *error = nil;
    NSData *pData = [NSPropertyListSerialization dataFromPropertyList:messageconfig format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    if (!pData)
    {
        NSLog(@"Save Error: %@", error);
        NSLog(@"%@", messageconfig);
        //return NO;
    }
    [self writeApplicationData:pData toFile:@"config.plist"];
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
- (messagetablecell*)MessagecellForBookmark
{
    static NSString *MessagecellIdentifier = @"MessageCell";
    messagetablecell *cell = (messagetablecell*)[[self tableView] dequeueReusableCellWithIdentifier:MessagecellIdentifier];
    //[cell mytitle];
    if(cell == nil)
    {
        [[NSBundle mainBundle] loadNibNamed:@"messagecell" owner:self options:nil];
        //[_bmTableCell setAccessoryView:[self disclosureButtonWithImage:_star_on_img]];
        cell = _msTableCell;
        _msTableCell = nil;
    }
    
    return cell;
}
- (UITableViewCell*)GetMessagecell:(int) position
{
    //UITableViewCell *cell =
    int line;
    NSString *CellTableIdentifier = @"CellTableIdentifier";
   // UITableViewCell *cell = [table]
   UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellTableIdentifier];
    cell.backgroundColor = [UIColor whiteColor];
    NSString *machinename = [self getMachine];
    NSLog(@"the machinename is %@",machinename);
    machinename=[machinename substringWithRange:NSMakeRange(0, 4)];
    CGRect TitleLabelRect;
    CGRect ContentLabelRect;
    UILabel *ContentLabel;
    UILabel *TitleLabel;
    NSString *ContentText = [[parserObjects objectAtIndex:([parserObjects count]-position-1)] valueForKey:@"MContent"];
    int length = [ContentText length];
    if(length<50)
    {
        fontsizeflag = 1;
    }
    if(length<=100)
    {
        line = 0;
    }
    else if((length>100)&&(length<150))
    {
        line = 1;
    }
    else
    {
        line = 2;
    }
	//cell.selectedTextColor = [UIColor blackColor];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if([machinename isEqualToString:@"iPad"])
    {

       TitleLabelRect = CGRectMake(40,5,600,15);
       TitleLabel = [[UILabel alloc] initWithFrame:TitleLabelRect];
          TitleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    }
    else
    {
        TitleLabelRect = CGRectMake(40,5,250,15);
        TitleLabel = [[UILabel alloc] initWithFrame:TitleLabelRect];
    TitleLabel.font = [UIFont fontWithName:@"Helvetica" size:8];
    }
 
    //TitleLabel = [[UILabel alloc] initWithFrame:TitleLabelRect];
    TitleLabel.textAlignment = UITextAlignmentLeft;
    TitleLabel.numberOfLines = 0;
    TitleLabel.backgroundColor = [UIColor whiteColor];
    //TitleLabel.
    //[[cell getlabeltitle] setText:[[parserObjects objectAtIndex:([parserObjects count]-[indexPath row]-1)] valueForKey:@"MTitle"]];
    //[[cell getlabelcontent] setText:[[parserObjects objectAtIndex:([parserObjects count]-[indexPath row]-1)] valueForKey:@"MContent"]];
    TitleLabel.text = [[parserObjects objectAtIndex:([parserObjects count]-position-1)] valueForKey:@"MTitle"];//@"Name";
    
    [cell.contentView addSubview:TitleLabel];
    
    if([machinename isEqualToString:@"iPad"])
    {
        ContentLabelRect = CGRectMake(40,30,600,40+line*40);
        ContentLabel = [[UILabel alloc] initWithFrame:ContentLabelRect];
        ContentLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
               // ContentLabel.font = [UIFont fontWithName:@"STHeiti-Medium.ttc" size:16];
    }
    else
    {
        ContentLabelRect = CGRectMake(40,20,250,40+line*60);
        ContentLabel = [[UILabel alloc] initWithFrame:ContentLabelRect];
        ContentLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        //ContentLabel.f
        
    }
    ContentLabel.lineBreakMode = UILineBreakModeWordWrap;
    
    ContentLabel.textAlignment = UITextAlignmentLeft;
    ContentLabel.backgroundColor = [UIColor whiteColor];
    ContentLabel.numberOfLines = 0;
    //[[cell getlabeltitle] setText:[[parserObjects objectAtIndex:([parserObjects count]-[indexPath row]-1)] valueForKey:@"MTitle"]];
    //[[cell getlabelcontent] setText:[[parserObjects objectAtIndex:([parserObjects count]-[indexPath row]-1)] valueForKey:@"MContent"]];
    ContentLabel.text = [[parserObjects objectAtIndex:([parserObjects count]-position-1)] valueForKey:@"MContent"];//@"Name";
    [cell.contentView addSubview:ContentLabel];
	//Build and configure a new accessory view containing a red Abort UIButton and a UIActivityIndicatorView
 UIImage *mouseImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"message" ofType:@"png"]];
UIImageView *myimageView = [[UIImageView alloc]initWithImage:mouseImage];
    [myimageView setFrame:CGRectMake(0,0,32,32)];
    [cell.contentView addSubview:myimageView];
     return cell;
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



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    //    NSLog(@"%@",NSStringFromSelector(_cmd) );
    
    
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
    messageconfig = [[NSMutableDictionary alloc] init];
        [messageconfig setValue:parserObjects forKey:@"messageinfo"];
    NSString *error = nil;
    NSData *pData = [NSPropertyListSerialization dataFromPropertyList:messageconfig format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    [messageconfig release];
    [self setTitle:@"消息"];
    UIImage* tabBarIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tabbar_message" ofType:@"png"]];
    [self setTabBarItem:[[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"message", @"Tabbar item message") image:tabBarIcon tag:0] autorelease]];
    Newmessagecount = [parserObjects count];
    badgecount+=Newmessagecount - Messagecount;

    if (!pData)
    {
        NSLog(@"Save Error: %@", error);
        //NSLog(@"%@", settingsRoot);
        //return NO;
    }
    [self writeApplicationData:pData toFile:@"config.plist"];
    [badgeconfig setValue:badgecount forKey:@"badgevalue"];
    pData = [NSPropertyListSerialization dataFromPropertyList:badgeconfig format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    [self writeApplicationData:pData toFile:@"badgeconfig.plist"];
    NSString *value = [NSString stringWithFormat:@"%d",badgecount];
    if(badgecount == 0)
    {
        self.tabBarItem.badgeValue = nil;
        [delegate Setbadge:badgecount];
    }
    else
    {
    self.tabBarItem.badgeValue = value;
        [delegate Setbadge:badgecount];
    }
    [pData release];
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
-(NSString *) httpGetmaxid
{
    NSString *url = @"http://125.76.226.161:9880/index.php?cmd=maxid";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (data == nil) {
        NSLog(@"send request failed: %@", error);
        //desktopflag = 0;
        return nil;
    }
    NSString *check = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"check=%@",check);
    return check;
    
}
#pragma mark -
#pragma mark Table view data source
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//更改删除按钮
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath

{
     if (editingStyle == UITableViewCellEditingStyleDelete)
     {
         NSString *error = nil;
         [parserObjects removeObject:[parserObjects objectAtIndex:[parserObjects count]-[indexPath row]-1]];
         if([parserObjects count]==0)
         {
             maxmid = [self httpGetmaxid];
             [self writefile:@"midnum.xml" writedata:maxmid];
             NSString *error = nil;
             [badgeconfig setValue:0 forKey:@"badgevalue"];
             NSData* pData = [NSPropertyListSerialization dataFromPropertyList:badgeconfig format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
             [self writeApplicationData:pData toFile:@"badgeconfig.plist"];
             self.tabBarItem.badgeValue = nil;
             [delegate Setbadge:0];
         }
         messageconfig = [[NSMutableDictionary alloc] init];
         [messageconfig setValue:parserObjects forKey:@"messageinfo"];
         NSData *pData = [NSPropertyListSerialization dataFromPropertyList:messageconfig format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
         [messageconfig release];
         //[pData release];
         //[_history_search_result removeObjectAtIndex:[self historyIndexFromIndexPath:indexPath]];
         //[tableView reloadSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationNone];
         [tableView reloadData];
         [self writeApplicationData:pData toFile:@"config.plist"];

           //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
     }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *ContentText = [[parserObjects objectAtIndex:([parserObjects count]-[indexPath row]-1)] valueForKey:@"MContent"];
    int length = [ContentText length];
    if(length<=100)
    {
        return 80;
    }
    else if((length>100)&&(length<200))
    {
        return 120;
    }
    else
    {
        return 160;
    }
    //return 80;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	//[parserObjects

    return 1;
}

/*- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 10.0;
    } else {
        return 20;
    }
}*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    
	return [parserObjects count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //messagetablecell* cell = [self MessagecellForBookmark];
    UITableViewCell *cell = [self GetMessagecell:[indexPath row]];
    //[[cell getlabeltitle] setText:[[parserObjects objectAtIndex:([parserObjects count]-[indexPath row]-1)] valueForKey:@"MTitle"]];
    //[[cell getlabelcontent] setText:[[parserObjects objectAtIndex:([parserObjects count]-[indexPath row]-1)] valueForKey:@"MContent"]];
    //[[cell getlabelcontent] setText:@"123?345"];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *error = nil;
    [badgeconfig setValue:0 forKey:@"badgevalue"];
    NSData* pData = [NSPropertyListSerialization dataFromPropertyList:badgeconfig format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    [self writeApplicationData:pData toFile:@"badgeconfig.plist"];
    self.tabBarItem.badgeValue = nil;
    [delegate Setbadge:0];
    NSString * weburl =[[parserObjects objectAtIndex:([parserObjects count]-[indexPath row]-1)] valueForKey:@"MUrl"];
    //[check length]
    //BOOL web = [weburl isEqualToString:@""];
    if([weburl length]>0)
    {
    Messagewebview = [[MessageWebview alloc] initWithNibName:nil bundle:nil url:weburl];
    if (!MessageViewNavController)
    {
        MessageViewNavController = [[UINavigationController alloc] initWithRootViewController:Messagewebview];
        //[MessageViewNavController setDelegate:Messagewebview];
        MessageViewNavController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        //applistNavController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        MessageViewNavController.navigationBar.barStyle = UIBarStyleDefault;
    }
    //[self.view addSubview:applistNavController.view];
    [self.navigationController pushViewController:Messagewebview animated:YES];
    }
}
#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
//开始重新加载时调用的方法
- (void)reloadTableViewDataSource{
	//_reloading = YES;
    //开始刷新后执行后台线程，在此之前可以开启HUD或其他对UI进行阻塞
    [NSThread detachNewThreadSelector:@selector(doInBackground) toTarget:self withObject:nil];
}

//完成加载时调用的方法
- (void)doneLoadingTableViewData{
    NSLog(@"doneLoadingTableViewData");
    
	//_reloading = NO;
	//[_refreshTableView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    //刷新表格内容
    [_refreshTableView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    [self.tableView reloadData];
}
-(void)doInBackground
{
    NSLog(@"doInBackground");
    
    //NSArray *dataArray2 = [NSArray arrayWithObjects:@"Ryan2",@"Vivi2", nil];
    //self.array = dataArray2;
    //[NSThread sleepForTimeInterval:3];
    //[self ]
    if([parserObjects count]==0)
    {

        midnum = [self readfile:@"midnum.xml"];
    }
    else
    {
    NSMutableDictionary *MessageDic = [parserObjects objectAtIndex:([parserObjects count]-1)];
    midnum = [MessageDic valueForKey:@"MID"];
    }
     [self httpGet:midnum];
    [self getParse];
    //后台操作线程执行完后，到主线程更新UI
    [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:YES];
}
#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
//下拉被触发调用的委托方法
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self reloadTableViewDataSource];
}

//返回当前是刷新还是无刷新状态
-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    //return _reloading;
}

//返回刷新时间的回调方法
-(NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshTableView egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshTableView egoRefreshScrollViewDidEndDragging:scrollView];
}
/*applistController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
[applistController setDelegate:self];
appbookmark = [_manual_bookmarks objectAtIndex:bookmarkrow];
[applistController setAppdata:appdata];
[applistController setdesktopflag:desktopflag];
if(desktopflag == 0)
{
    self.tabBarItem.title = @"应用列表";
}
else
{
    self.tabBarItem.title = @"桌面列表";
}
[applistController setDelegate:self];
[applistController setAgentpage:AgentPage];
if (!applistNavController)
{
    applistNavController = [[UINavigationController alloc] initWithRootViewController:applistController];
    [applistNavController setDelegate:applistController];
    applistNavController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    applistNavController.navigationBar.barStyle = UIBarStyleDefault;
}
[self.navigationController pushViewController:applistController animated:YES];
}
/*- (UITableViewCell*)cellForGenericListEntry
{
    static NSString *CellIdentifier = @"BookmarkListCell";
    UITableViewCell *cell = [[self tableView] dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        //[cell setAccessoryView:[self disclosureButtonWithImage:_star_off_img]];
    }
    
    return cell;
}*/

/*
// prevent that an item is moved befoer the Add Bookmark item
-(NSIndexPath*)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{

}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	// dont allow to reorder Add Bookmark item

}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{

	return nil;
}

- (NSString*)tableView:(UITableView*)tableView titleForFooterInSection:(NSInteger)section
{
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark -
#pragma mark Table view delegate

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{

}

- (void)accessoryButtonTapped:(UIControl*)button withEvent:(UIEvent*)event
{

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

	
}

- (void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath
{

}*/

@end
