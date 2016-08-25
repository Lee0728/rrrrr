/*
 bookmarks and active session view controller
 
 Copyright 2013 Thinstuff Technologies GmbH, Author: Martin Fleisz
 
 This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
 If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

#import "BookmarkListController.h"
#import "Utils.h"
#import "BookmarkEditorController.h"
#import "Toast+UIView.h"
#import "Reachability.h"
#import "GlobalDefaults.h"
#import "BlockAlertView.h"

//#define SECTION_SESSIONS    0
#define SECTION_BOOKMARKS   0
#define NUM_SECTIONS        1

@interface BookmarkListController (Private)
#pragma mark misc functions
- (UIButton*)disclosureButtonWithImage:(UIImage*)image;
- (void)performSearch:(NSString*)searchText;
#pragma mark Persisting bookmarks
- (void)scheduleWriteBookmarksToDataStore;
- (void)writeBookmarksToDataStore;
- (void)scheduleWriteManualBookmarksToDataStore;
- (void)writeManualBookmarksToDataStore;
- (void)readManualBookmarksFromDataStore;
- (void)writeArray:(NSArray*)bookmarks toDataStoreURL:(NSURL*)url;
- (NSMutableArray*)arrayFromDataStoreURL:(NSURL*)url;
- (NSURL*)manualBookmarksDataStoreURL;
- (NSURL*)connectionHistoryDataStoreURL;
@end


@implementation BookmarkListController

@synthesize searchBar = _searchBar, tableView = _tableView, bmTableCell = _bmTableCell, sessTableCell = _sessTableCell;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        // load bookmarks
        [self readManualBookmarksFromDataStore];
        
        // load connection history
        [self readConnectionHistoryFromDataStore];
        
        // init search result array
        _manual_search_result = nil;
        
        // register for session notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDisconnected:) name:TSXSessionDidDisconnectNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionFailedToConnect:) name:TSXSessionDidFailToConnectNotification object:nil];
        
        // set title and tabbar controller image
        //[self setTitle:NSLocalizedString(@"Connections", @"'集群列表': bookmark controller title")];
        UIImage* tabBarIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tabbar_bookmark" ofType:@"png"]];
        [self setTabBarItem:[[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Bookmark", @"Tabbar item bookmark") image:tabBarIcon tag:0] autorelease]];
        //[self setTabBarItem:[[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:0] autorelease]];
        [[self tabBarItem] setTitle:@"集群列表"];//NSLocalizedString(@"jiqun", @"'jiqun': jiqun list title")];
        self.tabBarItem.title = @"集群列表";
        self.tabBarItem.badgeValue = nil;
        //self.tabBarItem.badgeValue = @"5";
        // load images
        _star_on_img = [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_accessory_star_on" ofType:@"png"]] retain];
        _star_off_img = [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_accessory_star_off" ofType:@"png"]] retain];
        
        // init reachability detection
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        appdata = [[NSMutableData alloc] init];
        // init other properties
        _active_sessions = [[NSMutableArray alloc] init];
        _temporary_bookmark = nil;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
}

- (void)renametablebartitle;
{
    [[self tabBarItem] setTitle:@"集群列表"];//NSLocalizedString(@"jiqun", @"'jiqun': jiqun list title")];
    self.tabBarItem.title = @"集群列表";
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem* newButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"New", @"New Button title") style:UIBarButtonItemStyleDone target:self action:@selector(newBookmark:)] autorelease];
    // set edit button to allow bookmark list editing
    self.editButtonItem.title = @"编辑";
    [[self navigationItem] setLeftBarButtonItem:newButton];
    [[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
    
    /*
     if (![[InAppPurchaseManager sharedInAppPurchaseManager] isProVersion])
     [[self navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Go Pro" style:UIBarButtonItemStyleDone target:self action:@selector(goProButtonPressed:)]];
     */
}

- (IBAction)newBookmark:(id)sender
{
    ComputerBookmark *bookmark = [[[ComputerBookmark alloc] initWithBaseDefaultParameters] autorelease];
    BookmarkEditorController* bookmarkEditorController = [[[BookmarkEditorController alloc] initWithBookmark:bookmark] autorelease];
    [bookmarkEditorController setTitle:NSLocalizedString(@"Add Connection", @"Add Connection title")];
    [bookmarkEditorController setDelegate:self];
    [bookmarkEditorController setHidesBottomBarWhenPushed:YES];
    [[self navigationController] pushViewController:bookmarkEditorController animated:YES];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // in case we had a search - search again cause the bookmark searchable items could have changed
    if ([[_searchBar text] length] > 0)
        [self performSearch:[_searchBar text]];
    
    // to reflect any bookmark changes - reload table
    [_tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // clear any search
    [_searchBar setText:@""];
    [_searchBar resignFirstResponder];
    [self performSearch:@""];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return NO;
}
- (BOOL)shouldAutorotate
{
    return NO;
}
-(NSUInteger)supportedInterfaceOrientations
{ return UIInterfaceOrientationMaskPortrait;//只支持这一个方向(正常的方向)
    //return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [_tsxconnect_reachability stopNotifier];
    [_tsxconnect_reachability release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_temporary_bookmark release];
    [_connection_history release];
    [_active_sessions release];
    [_tsxconnect_search_result release];
    [_manual_search_result release];
    [_manual_bookmarks release];
    [_tsxconnect_bookmarks release];
    
    [_star_on_img release];
    [_star_off_img release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch(section)
    {
            
        case SECTION_BOOKMARKS:
        {
            // (+1 for Add Bookmark entry)
            /*if(_manual_search_result != nil)
             return ([_manual_search_result count] + [_history_search_result count] + 1);*/
            return ([_manual_bookmarks count]);
        }
            break;
            
        default:
            break;
    }
    return 0;
}

- (UITableViewCell*)cellForGenericListEntry
{
    static NSString *CellIdentifier = @"BookmarkListCell";
    UITableViewCell *cell = [[self tableView] dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setAccessoryView:[self disclosureButtonWithImage:_star_off_img]];
    }
    
    return cell;
}

- (BookmarkTableCell*)cellForBookmark
{
    static NSString *BookmarkCellIdentifier = @"BookmarkCell";
    BookmarkTableCell *cell = (BookmarkTableCell*)[[self tableView] dequeueReusableCellWithIdentifier:BookmarkCellIdentifier];
    if(cell == nil)
    {
        [[NSBundle mainBundle] loadNibNamed:@"BookmarkTableViewCell" owner:self options:nil];
        //[_bmTableCell setAccessoryView:[self disclosureButtonWithImage:_star_on_img]];
        cell = _bmTableCell;
        _bmTableCell = nil;
    }
    
    return cell;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    switch ([indexPath section])
    {
            /*case SECTION_SESSIONS:
             {
             // get custom session cell
             static NSString *SessionCellIdentifier = @"SessionCell";
             SessionTableCell *cell = (SessionTableCell*)[tableView dequeueReusableCellWithIdentifier:SessionCellIdentifier];
             if(cell == nil)
             {
             [[NSBundle mainBundle] loadNibNamed:@"SessionTableViewCell" owner:self options:nil];
             cell = _sessTableCell;
             _sessTableCell = nil;
             }
             
             // set cell data
             RDPSession* session = [_active_sessions objectAtIndex:[indexPath row]];
             [[cell title] setText:[session sessionName]];
             [[cell server] setText:[[session params] StringForKey:@"hostname"]];
             if([[[cell server] text] length] == 0)
             [[cell server] setText:@"TSX Connect"];
             [[cell username] setText:[[session params] StringForKey:@"username"]];
             [[cell screenshot] setImage:[session getScreenshotWithSize:[[cell screenshot] bounds].size]];
             [[cell disconnectButton] setTag:[indexPath row]];
             return cell;
             }*/
            
        case SECTION_BOOKMARKS:
        {
            // special handling for first cell - quick connect/quick create Bookmark cell
            /*if([indexPath row] == 0)
             {
             // if a search text is entered the cell becomes a quick connect/quick create bookmark cell - otherwise it's just an add bookmark cell
             UITableViewCell* cell = [self cellForGenericListEntry];
             if ([[_searchBar text] length] == 0)
             {
             [[cell textLabel] setText:[@"  " stringByAppendingString:NSLocalizedString(@"Add Connection", @"'Add Connection': button label")]];
             [((UIButton*)[cell accessoryView]) setHidden:YES];
             }
             else
             {
             [[cell textLabel] setText:[@"  " stringByAppendingString:[_searchBar text]]];
             [((UIButton*)[cell accessoryView]) setHidden:NO];
             }
             
             return cell;
             return;
             }
             else
             {*/
            // do we have a history cell or bookmark cell?
            if ([self isIndexPathToHistoryItem:indexPath])
            {
                UITableViewCell* cell = [self cellForGenericListEntry];
                [[cell textLabel] setText:[@"  " stringByAppendingString:[_history_search_result objectAtIndex:[self historyIndexFromIndexPath:indexPath]]]];
                [((UIButton*)[cell accessoryView]) setHidden:NO];
                return cell;
            }
            else
            {
                // set cell properties
                ComputerBookmark* entry;
                BookmarkTableCell* cell = [self cellForBookmark];
                if(_manual_search_result == nil)
                    entry = [_manual_bookmarks objectAtIndex:[self bookmarkIndexFromIndexPath:indexPath]];
                else
                    entry = [[_manual_search_result objectAtIndex:[self bookmarkIndexFromIndexPath:indexPath]] valueForKey:@"bookmark"];
                [[cell title] setText:[entry label]];
                //[[cell title] setText:@"11"];
                [[cell subTitle] setText:[[entry params] StringForKey:@"hostname"]];
                return cell;
            }
            // }
        }
            
        default:
            break;
    }
    
    NSAssert(0, @"Failed to create cell");
    return nil;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // dont allow to edit Add Bookmark item
    /*if([indexPath section] == SECTION_SESSIONS)
     return NO;*/
    /*if([indexPath section] == SECTION_BOOKMARKS && [indexPath row] == 0)
     return NO;*/
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source
        switch([indexPath section])
        {
            case SECTION_BOOKMARKS:
            {
                if (_manual_search_result == nil)
                    [_manual_bookmarks removeObjectAtIndex:[self bookmarkIndexFromIndexPath:indexPath]];
                else
                {
                    // history item or bookmark?
                    if ([self isIndexPathToHistoryItem:indexPath])
                    {
                        [_connection_history removeObject:[_history_search_result objectAtIndex:[self historyIndexFromIndexPath:indexPath]]];
                        [_history_search_result removeObjectAtIndex:[self historyIndexFromIndexPath:indexPath]];
                    }
                    else
                    {
                        [_manual_bookmarks removeObject:[[_manual_search_result objectAtIndex:[self bookmarkIndexFromIndexPath:indexPath]] valueForKey:@"bookmark"]];
                        [_manual_search_result removeObjectAtIndex:[self bookmarkIndexFromIndexPath:indexPath]];
                    }
                }
                [self scheduleWriteManualBookmarksToDataStore];
                break;
            }
        }
        
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationNone];
    }
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if([fromIndexPath compare:toIndexPath] != NSOrderedSame)
    {
        switch([fromIndexPath section])
        {
            case SECTION_BOOKMARKS:
            {
                int fromIdx = [self bookmarkIndexFromIndexPath:fromIndexPath];
                int toIdx = [self bookmarkIndexFromIndexPath:toIndexPath];
                ComputerBookmark* temp_bookmark = [[_manual_bookmarks objectAtIndex:fromIdx] retain];
                [_manual_bookmarks removeObjectAtIndex:fromIdx];
                if (toIdx >= [_manual_bookmarks count])
                    [_manual_bookmarks addObject:temp_bookmark];
                else
                    [_manual_bookmarks insertObject:temp_bookmark atIndex:toIdx];
                [temp_bookmark release];
                
                [self scheduleWriteManualBookmarksToDataStore];
                break;
            }
        }
    }
}


// prevent that an item is moved befoer the Add Bookmark item
-(NSIndexPath*)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    // don't allow to move:
    //  - items between sections
    //  - the quick connect/quick create bookmark cell
    //  - any item while a search is applied
    if([proposedDestinationIndexPath row] == 0 || ([sourceIndexPath section] != [proposedDestinationIndexPath section]) ||
       _manual_search_result != nil || _tsxconnect_search_result != nil)
    {
        return sourceIndexPath;
    }
    else
    {
        return proposedDestinationIndexPath;
    }
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // dont allow to reorder Add Bookmark item
    if([indexPath section] == SECTION_BOOKMARKS && [indexPath row] == 0)
        return NO;
    return YES;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    /*if(section == SECTION_SESSIONS && [_active_sessions count] > 0)
     return NSLocalizedString(@"My Sessions", @"'My Session': section sessions header");
     /*if(section == SECTION_BOOKMARKS)
     return NSLocalizedString(@"Manual Connections", @"'Manual Connections': section manual bookmarks header");*/
    return nil;
}

- (NSString*)tableView:(UITableView*)tableView titleForFooterInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*if([indexPath section] == SECTION_SESSIONS)
     return 72;*/
    return [tableView rowHeight];
}

#pragma mark -
#pragma mark Table view delegate

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    if (self.editing) {
        self.editButtonItem.title = @"完成";
    } else {
        self.editButtonItem.title = @"编辑";
    }
    
    [[self tableView] setEditing:editing animated:animated];
}

- (void)accessoryButtonTapped:(UIControl*)button withEvent:(UIEvent*)event
{
    // forward a tap on our custom accessory button to the real accessory button handler
    NSIndexPath* indexPath = [[self tableView] indexPathForRowAtPoint:[[[event touchesForView:button] anyObject] locationInView:[self tableView]]];
    if (indexPath == nil)
        return;
    
    [[[self tableView] delegate] tableView:[self tableView] accessoryButtonTappedForRowWithIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* if([indexPath section] == SECTION_SESSIONS)
     {
     // resume session
     RDPSession* session = [_active_sessions objectAtIndex:[indexPath row]];
     UIViewController* ctrl = [[[RDPSessionViewController alloc] initWithNibName:@"RDPSessionView" bundle:nil session:session] autorelease];
     [ctrl setHidesBottomBarWhenPushed:YES];
     [[self navigationController] pushViewController:ctrl animated:YES];
     }
     else
     {*/
    ComputerBookmark* bookmark = nil;
    if([indexPath section] == SECTION_BOOKMARKS)
    {
        // first row has either quick connect or add bookmark item
        /*if([indexPath row] == 0)
         {
         if ([[_searchBar text] length] == 0)
         {
         // show add bookmark controller
         ComputerBookmark *bookmark = [[[ComputerBookmark alloc] initWithBaseDefaultParameters] autorelease];
         BookmarkEditorController* bookmarkEditorController = [[[BookmarkEditorController alloc] initWithBookmark:bookmark] autorelease];
         [bookmarkEditorController setTitle:NSLocalizedString(@"Add Connection", @"Add Connection title")];
         [bookmarkEditorController setDelegate:self];
         [bookmarkEditorController setHidesBottomBarWhenPushed:YES];
         [[self navigationController] pushViewController:bookmarkEditorController animated:YES];
         }
         else
         {
         // create a quick connect bookmark and add an entry to the quick connect history (if not already in the history)
         bookmark = [self bookmarkForQuickConnectTo:[_searchBar text]];
         if (![_connection_history containsObject:[_searchBar text]])
         {
         [_connection_history addObject:[_searchBar text]];
         [self scheduleWriteConnectionHistoryToDataStore];
         }
         }
         }
         else
         {*/
        if(_manual_search_result != nil)
        {
            if ([self isIndexPathToHistoryItem:indexPath])
            {
                // create a quick connect bookmark for a history item
                NSString* item = [_history_search_result objectAtIndex:[self historyIndexFromIndexPath:indexPath]];
                bookmark = [self bookmarkForQuickConnectTo:item];
            }
            else
                bookmark = [[_manual_search_result objectAtIndex:[self bookmarkIndexFromIndexPath:indexPath]] valueForKey:@"bookmark"];
        }
        else
        {
            bookmark = [_manual_bookmarks objectAtIndex:[self bookmarkIndexFromIndexPath:indexPath]];
            bookmarkrow = [self bookmarkIndexFromIndexPath:indexPath];
            NSString *host = [[[bookmark params] copy] StringForKey:@"hostname"];
            int intport = [[[bookmark params] copy] intForKey:@"port"];
            NSString *port = [NSString stringWithFormat:@"%d",intport];
            NSString *username = [[[bookmark params] copy] StringForKey:@"username"];
            NSString *pwd = [[[bookmark params] copy] StringForKey:@"password"];
            //NSString *pwd = [[[bookmark params] copy] intForKey:@"password"];
            NSString *domain = [[[bookmark params] copy] StringForKey:@"domain"];
            logmode = [[[bookmark params] copy] intForKey:@"logmode"];
            printf("the logmode is %d",logmode);
            //domain = @"ry.com";
            [self httpGettype:host port:port];
            NSLog(@"agentpage=%@",AgentPage);
            vernum = [self httpGetver:host port:port];
            
            if(desktopflag == 1)
            {
                [self httpGetDesktop:host port:port userName:username pwd:pwd domain:domain];
            }
            else if(desktopflag == 0)
            {
                //pwd = [self getMD5PWD:pwd];
                if(logmode == 1)
                {
                    NSData *testData = [pwd dataUsingEncoding: NSUTF8StringEncoding];
                    Byte *testByte = (Byte *)[testData bytes];
                    printf("test byte is");
                    pwdstring=[[NSString alloc] init];
                    for(int i=0;i<[testData length];i++)
                    {
                        NSString *stringHex = [NSString stringWithFormat:@"%x",testByte[i]];
                        NSLog(@"the stringHex is %@",stringHex);
                        pwdstring = [pwdstring stringByAppendingString:stringHex];
                        NSLog(@"the pwdstring is %@",pwdstring);
                        //printf("%d",testByte[i]);
                    }
                    
                }
                else
                {
                    pwd = [self getMD5PWD:pwd];
                }
                [self httpGet:host port:port userName:username pwd:pwd];
                
            }
        }
    }
    
    // set reachability status
    /* WakeUpWWAN();
     [bookmark setConntectedViaWLAN:[[Reachability reachabilityWithHostName:[[bookmark params] StringForKey:@"hostname"]] currentReachabilityStatus] == ReachableViaWiFi];*/
    //}
    
    /*if(bookmark != nil)
     {
     // create rdp session
     RDPSession* session = [[[RDPSession alloc] initWithBookmark:bookmark] autorelease];
     UIViewController* ctrl = [[[RDPSessionViewController alloc] initWithNibName:@"RDPSessionView" bundle:nil session:session] autorelease];
     [ctrl setHidesBottomBarWhenPushed:YES];
     [[self navigationController] pushViewController:ctrl animated:YES];
     [_active_sessions addObject:session];
     }*/
    
}

- (NSString *)getMD5PWD:(NSString *)pwdSrc
{
    NSString *string = @"";
    if(pwdSrc != nil)  string = pwdSrc;
    unsigned char *inStrg = (unsigned char*)[[string dataUsingEncoding:NSASCIIStringEncoding] bytes];
    unsigned long lngth = [string length];
    unsigned char result[MD5_DIGEST_LENGTH];
    NSMutableString *pwd = [NSMutableString string];
    MD5(inStrg, lngth, result);
    unsigned int i;
    for (i = 0; i < MD5_DIGEST_LENGTH; i++)
    {
        [pwd appendFormat:@"%02x", result[i]];
    }
    return pwd;
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [appdata appendData:data];
    /*INIParser *parser = [[[INIParser alloc] init] autorelease];
     int err = [parser parsedata: appdata];
     if (err != INIP_ERROR_NONE)
     {
     //[parser release];
     return;
     }
     NSString *result = [parser get:@"VirtulType" section:@"info"];
     AgentPage = [parser get:@"AgentPage" section:@"info"];
     if([result isEqualToString:@""])
     {
     
     }
     if([result isEqualToString:@"Desktop"])
     {
     desktopflag=1;
     //NSLog(@"pwd=%@", pwd);
     //pwd = [self getMD5PWD:pwd];
     [self httpGetDesktop:host port:port userName:userName pwd:pwd];
     }
     else
     {
     [self httpGet:host port:port userName:userName pwd:pwd];
     }*/
    /*
     if (appdata)
     {
     const char *old=[appdata bytes];
     const char *new=[data bytes];
     int oldlen=[appdata length];
     int newlen=[data length];
     char *rec=malloc(oldlen + newlen);
     memcpy(rec, old, oldlen);
     memcpy(&rec[oldlen], new, newlen);
     [appdata release];
     appdata = [[NSData alloc]initWithBytes:rec length:(oldlen +newlen)];
     free(rec);
     }
     else
     {
     appdata = data;
     [appdata retain];
     }
     */
}
- (void)pagetoRdpSessionView:(NSString *)hostname port:(NSString *)port username:(NSString *)username password:(NSString *)password rapshell:(NSString *)rapshell safegateway:(int)safegateway Sessionid:(NSString *)Sessionid appid:(NSString *)appid
{
    /* if (safegateway == 1)
     {
     safemode = TRUE;
     }
     else
     {
     safemode = FALSE;
     }*/
    //[applistNavController.view removeFromSuperview];
    NSLog(@"the username is %@",username);
    printf("the safegateway is %d",safegateway);
    //[applistController release];
    NSLog(@"appbookmark:%@", appbookmark);
    NSLog(@"\nhostNname:%@, port:%@, username:%@, password:%@, rapshell:%@, safegateway:%d, Sessionid:%@, appid:%@\n", hostname, port, username, password, rapshell, safegateway, Sessionid, appid);
    RDPSession* session = [[RDPSession alloc] initWithBookmark:appbookmark hostname:hostname port:port username:username password:password rapshell:rapshell safegateway:safegateway Sessionid:Sessionid appid:appid];
    //    RDPSession* session = [[[RDPSession alloc] initWithBookmark:appbookmark hostname:hostname port:@"3389" username:@"administrator" password:@"realor#123" rapshell:@"" safegateway:safegateway Sessionid:Sessionid appid:appid] autorelease];
    [session Setvernum:vernum];
    ctrl = [[[RDPSessionViewController alloc] initWithNibName:@"RDPSessionView" bundle:nil session:session desktopflag:desktopflag] autorelease];
    [ctrl setDelegate:self];
    [ctrl setHidesBottomBarWhenPushed:YES];
    if((desktopflag == 0)&&(vernum>=6))
    {
        [ctrl sessionSetVirtualdata:applistController.vd Userid:applistController.Userid vdsp:applistController.vdsp];
    }
    [[self navigationController] pushViewController:ctrl animated:YES];
    //[self.view addSubview:ctrl.view];
}
- (void)ApplistAppstart
{
    [[self navigationController] pushViewController:ctrl animated:YES];
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    /*[self connectionRequestDidSucceed];
     [self ErrorMessageBox:[[NSBundle mainBundle] localizedStringForKey:@"AlertTitle" value:@"Error Infomation" table:nil]
     messageStr:[[NSBundle mainBundle] localizedStringForKey:@"FavMessage" value:@"Can not connect server!" table:nil]
     btnTitleStr:[[NSBundle mainBundle] localizedStringForKey:@"OkBtnCaption" value:@"OK" table:nil]
     tag:0];*/
    NSLog(@"\nerror: %@\n", error);
}

#pragma mark - NSURLConnectionDataDelegate
-(void) connectionDidFinishLoading:(NSURLConnection *)connection{
    // [self connectionRequestDidSucceed];
    
    NSString *check = [[[NSString alloc] initWithData:appdata encoding:NSASCIIStringEncoding] autorelease];
    //NSString *check = [[[NSString alloc] initWithData:appdata encoding:gbkEncoding] autorelease];
    ComputerBookmark* bookmark = nil;
    NSLog(@"check=%@",check);
    if ((check != NULL) &&[check length]>8)
        check = [check substringToIndex:8];
    else
        check = @"";
    if ([check isEqualToString:@"[result]"]){
        /*int index = [selectedCellIndexPath indexAtPosition:([selectedCellIndexPath length] - 1)];
         NSDictionary *connectionSettings = [bookmarkedServers objectAtIndex:index];
         NSLog(@"agentpage=%@",AgentPage);
         NSLog(@"host=%@",host);
         [delegate pageToApplistView:appdata connectionsSettings:connectionSettings desktop:desktopflag agentpage:AgentPage];*/
        if (applistController)
        {
            [applistController release];
            
        }
        appbookmark = [[[ComputerBookmark alloc] initWithBaseDefaultParameters] autorelease];
        appbookmark = [_manual_bookmarks objectAtIndex:bookmarkrow];
        
        applistController = [[AppListViewController alloc] initWithNibName:@"AppListViewController" bundle:[NSBundle mainBundle] isdesktop:desktopflag bookmark:appbookmark];
        
        applistController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        [applistController setDelegate:self];
        appbookmark = [_manual_bookmarks objectAtIndex:bookmarkrow];
        //[applistController setConnectionsSettings:connectionsSettings];
        [applistController setdesktopflag:desktopflag];
        [applistController setversion:vernum];
        [applistController setAppdata:appdata];
        // isdesktop = desktopflag;
        //[applistController.Setdele]
        if(desktopflag == 0)
        {
            self.tabBarItem.title = @"应用列表";
        }
        else
        {
            self.tabBarItem.title = @"桌面列表";
        }
        //        [applistController setDelegate:self];
        [applistController setAgentpage:AgentPage];
        if (!applistNavController)
        {
            applistNavController = [[UINavigationController alloc] initWithRootViewController:applistController];
            [applistNavController setDelegate:applistController];
            applistNavController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
            //applistNavController.navigationBar.barStyle = UIBarStyleBlackOpaque;
            applistNavController.navigationBar.barStyle = UIBarStyleDefault;
        }
        //[self.view addSubview:applistNavController.view];
        [self.navigationController pushViewController:applistController animated:YES];
        //[applistController setHidesBottomBarWhenPushed:YES];
    }
    else
    {
        /*[self ErrorMessageBox:[[NSBundle mainBundle] localizedStringForKey:@"AlertTitle" value:@"Error Infomation" table:nil]
         messageStr:[[NSBundle mainBundle] localizedStringForKey:@"FavMessage" value:@"Can not connect server!" table:nil]
         btnTitleStr:[[NSBundle mainBundle] localizedStringForKey:@"OkBtnCaption" value:@"OK" table:nil]
         tag:0];*/
    }
    [appdata setData:nil];
    //    if (appdata != nil)
    //    {
    //        [appdata release];
    //        appdata = nil;
    //    }
}
-(void) httpGettype:(NSString *)host port:(NSString *)port
{
    //配置登录Web服务器信息，并获取Rap配置文件
    
    
    NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    //char namecstring[10];
    //NSData *data = [userName dataUsingEncoding:gbkEncoding];
    //NSData *data=[userName dataUsingEncoding:gbkEncoding];
    //NSString *thename = [[NSString alloc] initWithData:data encoding:gbkEncoding];
    NSString *url = @"http://";
    url = [url stringByAppendingString:host];
    url = [url stringByAppendingString:@":"];
    url = [url stringByAppendingString:port];
    url = [url stringByAppendingString:@"/config.txt"];
    //    [appdata release];
    //    appdata = nil;
    //start reading file data
    //url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    url = [url stringByAddingPercentEscapesUsingEncoding:gbkEncoding];
    
    // NSURL *reURL = [[NSURL alloc] initWithString:url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (data == nil) {
        NSLog(@"send request failed: %@", error);
        desktopflag = 0;
        return;
    }
    [appdata appendData:data];
    INIParser *parser = [[[INIParser alloc] init] autorelease];
    int err = [parser parsedata: appdata];
    if (err != INIP_ERROR_NONE)
    {
        //[parser release];
        [appdata setData:nil];
        return;
    }
    NSString *result = [parser get:@"VirtulType" section:@"info"];
    //NSString *Agent = [parser get:@"VirtulType" section:@"info"];
    //AgentPage = [parser get:@"AgentPage" section:@"info"];
    NSString *Agent = [parser get:@"AgentPage" section:@"info"];
//    NSString *Agent1 = [parser get:@"VirtulType" section:@"info"];
    AgentPage = Agent;
    //AgentPage = [[NSString alloc] initWithString:[parser get:@"AgentPage" section:@"info"]];
    NSLog(@"\nresult = %@\n", result);
    if([result isEqualToString:@"Desktop"])
    {
        NSLog(@"\nresult2 = %@\n", result);
        desktopflag=1;
        // NSString *agentpage = Agent;
        //NSLog(@"pwd=%@", pwd);
        //pwd = [self getMD5PWD:pwd];
        //[self httpGetDesktop:host port:port userName:userName pwd:pwd];
    }
    else
    {
        //[self httpGet:host port:port userName:userName pwd:pwd];
        desktopflag = 0;
    }
    [appdata setData:nil];
    /* NSURLRequest *request = [[NSURLRequest alloc] initWithURL:reURL];
     NSLog(url);
     //[urlconn release];
     urlconn = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
     [reURL release];
     [request release]; */
}
-(void) httpGetDesktop:(NSString *)host port:(NSString *)port userName:(NSString *)userName pwd:(NSString *)pwd domain:(NSString *)domain
{
    //配置登录Web服务器信息，并获取Rap配置文件
    [appdata setData:nil];
    NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    //char namecstring[10];
    //NSData *data = [userName dataUsingEncoding:gbkEncoding];
    //NSData *data=[userName dataUsingEncoding:gbkEncoding];
    //NSString *thename = [[NSString alloc] initWithData:data encoding:gbkEncoding];
    
    NSString *url = @"http://";
    url = [url stringByAppendingString:host];
    url = [url stringByAppendingString:@":"];
    url = [url stringByAppendingString:port];
    url = [url stringByAppendingString:@"/"];
    url = [url stringByAppendingString:AgentPage];
    url = [url stringByAppendingString:@"?CMD=GETAppList&Language=ZH-CN&User="];
    url = [url stringByAppendingString:userName];
    url = [url stringByAppendingString:@"&PWD="];
    url = [url stringByAppendingString:pwd];
    url = [url stringByAppendingString:@"&Domain="];
    if (domain) {
        url = [url stringByAppendingString:domain];
    }
    url = [url stringByAppendingString:@"&AuthFlag=&AuthType="];
    url = [url stringByAppendingString:@"0"];
    url = [url stringByAppendingString:@"&Policy=6,n,y,n,n"];
    url = [url stringByAppendingString:@"&OS=iOS"];
    //    [appdata release];
    //    appdata = nil;
    //start reading file data
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //url = [url stringByAddingPercentEscapesUsingEncoding:gbkEncoding];
    NSLog(@"the url is %@",url);
    //NSLog(url);
    url = [url stringByAddingPercentEscapesUsingEncoding:gbkEncoding];
    NSURL *reURL = [[NSURL alloc] initWithString:url];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:reURL];
    //[urlconn release];
    urlconn = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    [reURL release];
    [request release];
}
-(int) httpGetver:(NSString *)host port:(NSString *)port
{
    NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *url=@"http://";
    NSString *urlver=@"http://";
    //NSString *url=@"http://";
    urlver = [urlver stringByAppendingString:host];
    urlver = [urlver stringByAppendingString:@":"];
    urlver = [urlver stringByAppendingString:port];
    urlver = [urlver stringByAppendingString:@"/RAPAGENT.xgi?CMD=GetClientExever&Language=ZH-CN"];
    urlver = [urlver stringByAddingPercentEscapesUsingEncoding:gbkEncoding];
    NSLog(@"the urlver is %@",urlver);
    NSURL *Getverurl = [NSURL URLWithString:urlver];
    NSURLRequest *Verrequest = [NSURLRequest requestWithURL:Getverurl];
    NSData *VerdataOfUrl = [NSURLConnection sendSynchronousRequest:Verrequest returningResponse:nil error:nil];
    INIParser *verparser = [[[INIParser alloc] init] autorelease];
    int err = [verparser parsedata: VerdataOfUrl];
    if (err != INIP_ERROR_NONE)
    {
        return 0;
    }
    NSString *ver = [verparser get:@"Version" section:@"result"];
    if([ver isEqualToString:@""])
    {
        
    }
    
    ver = [ver substringToIndex:1];
    vernum = [ver intValue];
    return vernum;
}
-(void) httpGet:(NSString *)host port:(NSString *)port userName:(NSString *)userName pwd:(NSString *)pwd
{
    //配置登录Web服务器信息，并获取Rap配置文件
    NSLog(@"the http pwd is %@",pwd);
    NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    //char namecstring[10];
    //NSData *data = [userName dataUsingEncoding:gbkEncoding];
    //NSData *data=[userName dataUsingEncoding:gbkEncoding];
    //NSString *thename = [[NSString alloc] initWithData:data encoding:gbkEncoding];
    NSString *url = @"http://";
    url = [url stringByAppendingString:host];
    url = [url stringByAppendingString:@":"];
    url = [url stringByAppendingString:port];
    url = [url stringByAppendingString:@"/RAPAGENT.xgi?CMD=GETAppList&Language=ZH-CN&User="];
    url = [url stringByAppendingString:userName];
    url = [url stringByAppendingString:@"&PWD="];
    if(logmode==1)
    {
        url = [url stringByAppendingString:pwdstring];
    }
    else
    {
        url = [url stringByAppendingString:pwd];
    }
    url = [url stringByAppendingString:@"&AuthFlag=&AuthType="];
    if(logmode == 0)
    {
        url = [url stringByAppendingString:@"0"];
    }
    else
    {
        url = [url stringByAppendingString:@"5"];
    }
    url = [url stringByAppendingString:@"&Policy=6,n,y,n,n"];
    url = [url stringByAppendingString:@"&OS=iOS"];
    //    [appdata release];
    //    appdata = nil;
    //start reading file data
    //url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"the url is %@",url);
    NSString *stringInt = [NSString stringWithFormat:@"%x",43];
    NSLog(@"the stringInt is %@",stringInt);
    url = [url stringByAddingPercentEscapesUsingEncoding:gbkEncoding];
    NSURL *reURL = [[NSURL alloc] initWithString:url];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:reURL];
    NSLog(@"%@", url);
    //[urlconn release];
    urlconn = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    [reURL release];
    [request release];
}


- (void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath
{
    // get the bookmark
    NSString* bookmark_editor_title = NSLocalizedString(@"Edit Connection", @"Edit Connection title");
    ComputerBookmark* bookmark = nil;
    if ([indexPath section] == SECTION_BOOKMARKS)
    {
        /*if ([indexPath row] == 0)
         {
         // create a new bookmark and init hostname and label
         bookmark = [self bookmarkForQuickConnectTo:[_searchBar text]];
         bookmark_editor_title = NSLocalizedString(@"Add Connection", @"Add Connection title");
         }
         else
         {*/
        if (_manual_search_result != nil)
        {
            if ([self isIndexPathToHistoryItem:indexPath])
            {
                // create a new bookmark and init hostname and label
                NSString* item = [_history_search_result objectAtIndex:[self historyIndexFromIndexPath:indexPath]];
                bookmark = [self bookmarkForQuickConnectTo:item];
                bookmark_editor_title = NSLocalizedString(@"Add Connection", @"Add Connection title");
            }
            else
                bookmark = [[_manual_search_result objectAtIndex:[self bookmarkIndexFromIndexPath:indexPath]] valueForKey:@"bookmark"];
        }
        else
            bookmark = [_manual_bookmarks objectAtIndex:[self bookmarkIndexFromIndexPath:indexPath]];	// -1 because of ADD BOOKMARK entry
        //}
    }
    
    // bookmark found? - start the editor
    if (bookmark != nil)
    {
        BookmarkEditorController* editBookmarkController = [[[BookmarkEditorController alloc] initWithBookmark:bookmark] autorelease];
        [editBookmarkController setHidesBottomBarWhenPushed:YES];
        [editBookmarkController setTitle:bookmark_editor_title];
        [editBookmarkController setDelegate:self];
        [[self navigationController] pushViewController:editBookmarkController animated:YES];
    }
}

#pragma mark -
#pragma mark Search Bar Delegates

- (BOOL)searchBarShouldBeginEditing:(UISearchBar*)searchBar
{
    // show cancel button
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // clear search result
    [_tsxconnect_search_result release];
    _tsxconnect_search_result = nil;
    [_manual_search_result release];
    _manual_search_result = nil;
    
    // clear text and remove cancel button
    [searchBar setText:@""];
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar*)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    
    // re-enable table selection
    [_tableView setAllowsSelection:YES];
    
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)searchText
{
    [self performSearch:searchText];
    [_tableView reloadData];
}

#pragma mark - Session handling

// session was added
- (void)sessionDisconnected:(NSNotification*)notification
{
    // remove session from active sessions
    RDPSession* session = (RDPSession*)[notification object];
    [_active_sessions removeObject:session];
    [applistController enableInterface];
    // if this view is currently active refresh tsxconnect entries
    if([[self navigationController] visibleViewController] == self)
        //[_tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_SESSIONS] withRowAnimation:UITableViewRowAnimationNone];
        
        // if session's bookmark is not in the bookmark list ask the user if he wants to add it
        // (this happens if the session is created using the quick connect feature)
        if (![[session bookmark] isKindOfClass:NSClassFromString(@"TSXConnectComputerBookmark")] &&
            ![_manual_bookmarks containsObject:[session bookmark]])
        {
            // retain the bookmark in case we want to save it later
            _temporary_bookmark = [[session bookmark] retain];
            
            // ask the user if he wants to save the bookmark
            NSString* title = NSLocalizedString(@"Save Connection Settings?", @"Save connection settings title");
            NSString* message = NSLocalizedString(@"Your Connection Settings have not been saved. Do you want to save them?", @"Save connection settings message");
            BlockAlertView* alert = [BlockAlertView alertWithTitle:title message:message];
            [alert setCancelButtonWithTitle:NSLocalizedString(@"No", @"No Button") block:nil];
            [alert addButtonWithTitle:NSLocalizedString(@"Yes", @"Yes Button") block:^{
                if (_temporary_bookmark)
                {
                    [_manual_bookmarks addObject:_temporary_bookmark];
                    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_BOOKMARKS] withRowAnimation:UITableViewRowAnimationNone];
                    [_temporary_bookmark autorelease];
                    _temporary_bookmark = nil;
                }
            }];
            [alert show];
        }
    //[self goapplist];
}

- (void)sessionFailedToConnect:(NSNotification*)notification
{
    // remove session from active sessions
    RDPSession* session = (RDPSession*)[notification object];
    [_active_sessions removeObject:session];
    
    // display error toast
    [[self view] makeToast:NSLocalizedString(@"Failed to connect to session!", @"Failed to connect error message") duration:ToastDurationNormal position:@"center"];
}

#pragma mark - Reachability notification
- (void)reachabilityChanged:(NSNotification*)notification
{
    // no matter how the network changed - we will disconnect
    // disconnect session (if there is any)
    if ([_active_sessions count] > 0)
    {
        RDPSession* session = [_active_sessions objectAtIndex:0];
        [session disconnect];
    }
}

#pragma mark - BookmarkEditorController delegate

- (void)commitBookmark:(ComputerBookmark *)bookmark
{
    // if we got a manual bookmark that is not in the list yet - add it otherwise replace it
    BOOL found = NO;
    for (int idx = 0; idx < [_manual_bookmarks count]; ++idx)
    {
        if ([[bookmark uuid] isEqualToString:[[_manual_bookmarks objectAtIndex:idx] uuid]])
        {
            [_manual_bookmarks replaceObjectAtIndex:idx withObject:bookmark];
            found = YES;
            break;
        }
    }
    if (!found)
        [_manual_bookmarks addObject:bookmark];
    
    // remove any quick connect history entry with the same hostname
    NSString* hostname = [[bookmark params] StringForKey:@"hostname"];
    if ([_connection_history containsObject:hostname])
    {
        [_connection_history removeObject:hostname];
        [self scheduleWriteConnectionHistoryToDataStore];
    }
    
    [self scheduleWriteManualBookmarksToDataStore];
}

- (IBAction)disconnectButtonPressed:(id)sender
{
    // disconnect session and refresh table view
    RDPSession* session = [_active_sessions objectAtIndex:[sender tag]];
    [session disconnect];
}

#pragma mark - Misc functions

- (BOOL)hasNoBookmarks
{
    return ([_manual_bookmarks count] == 0 && [_tsxconnect_bookmarks count] == 0);
}

- (UIButton*)disclosureButtonWithImage:(UIImage*)image
{
    // we make the button a little bit bigger (image widht * 2, height + 10) so that the user doesn't accidentally connect to the bookmark ...
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, [image size].width * 2, [image size].height + 10)];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(accessoryButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [button setUserInteractionEnabled:YES];
    return button;
}

- (void)performSearch:(NSString*)searchText
{
    [_manual_search_result autorelease];
    [_tsxconnect_search_result autorelease];
    
    if([searchText length] > 0)
    {
        _manual_search_result = [FilterBookmarks(_manual_bookmarks, [searchText componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]) retain];
        _tsxconnect_search_result = [FilterBookmarks(_tsxconnect_bookmarks, [searchText componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]) retain];
        _history_search_result = [FilterHistory(_connection_history, searchText) retain];
    }
    else
    {
        _history_search_result = nil;
        _tsxconnect_search_result = nil;
        _manual_search_result = nil;
    }
}

- (int)bookmarkIndexFromIndexPath:(NSIndexPath*)indexPath
{
    return [indexPath row];
}

- (int)historyIndexFromIndexPath:(NSIndexPath*)indexPath
{
    return [indexPath row] - 1;
}

- (BOOL)isIndexPathToHistoryItem:(NSIndexPath*)indexPath
{
    return (([indexPath row] - 1) < [_history_search_result count]);
}

- (ComputerBookmark*)bookmarkForQuickConnectTo:(NSString*)host
{
    ComputerBookmark* bookmark = [[[ComputerBookmark alloc] initWithBaseDefaultParameters] autorelease];
    [bookmark setLabel:host];
    [[bookmark params] setValue:host forKey:@"hostname"];
    return bookmark;
}

#pragma mark - Persisting bookmarks

- (void)scheduleWriteBookmarksToDataStore
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self writeBookmarksToDataStore];
    }];
}

- (void)writeBookmarksToDataStore
{
    [self writeManualBookmarksToDataStore];
}

- (void)scheduleWriteManualBookmarksToDataStore
{
    [[NSOperationQueue mainQueue] addOperation:[[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(writeManualBookmarksToDataStore) object:nil] autorelease]];
}

- (void)writeManualBookmarksToDataStore
{
    [self writeArray:_manual_bookmarks toDataStoreURL:[self manualBookmarksDataStoreURL]];
}

- (void)scheduleWriteConnectionHistoryToDataStore
{
    [[NSOperationQueue mainQueue] addOperation:[[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(writeConnectionHistoryToDataStore) object:nil] autorelease]];
}

- (void)writeConnectionHistoryToDataStore
{
    [self writeArray:_connection_history toDataStoreURL:[self connectionHistoryDataStoreURL]];
}

- (void)writeArray:(NSArray*)bookmarks toDataStoreURL:(NSURL*)url
{
    NSData* archived_data = [NSKeyedArchiver archivedDataWithRootObject:bookmarks];
    [archived_data writeToURL:url atomically:YES];
}

- (void)readManualBookmarksFromDataStore
{
    [_manual_bookmarks autorelease];
    _manual_bookmarks = [self arrayFromDataStoreURL:[self manualBookmarksDataStoreURL]];
    
    if(_manual_bookmarks == nil)
    {
        _manual_bookmarks = [[NSMutableArray alloc] init];
        [_manual_bookmarks addObject:[[[GlobalDefaults sharedGlobalDefaults] newTestServerBookmark] autorelease]];
    }
}

- (void)readConnectionHistoryFromDataStore
{
    [_connection_history autorelease];
    _connection_history = [self arrayFromDataStoreURL:[self connectionHistoryDataStoreURL]];
    
    if(_connection_history == nil)
        _connection_history = [[NSMutableArray alloc] init];
}

- (NSMutableArray*)arrayFromDataStoreURL:(NSURL*)url
{
    NSData* archived_data = [NSData dataWithContentsOfURL:url];
    
    if (!archived_data)
        return nil;
    
    return [[NSKeyedUnarchiver unarchiveObjectWithData:archived_data] retain];
}

- (NSURL*)manualBookmarksDataStoreURL
{
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], @"com.thinstuff.tsx-rdc-ios.bookmarks.plist"]];
}

- (NSURL*)connectionHistoryDataStoreURL
{
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], @"com.thinstuff.tsx-rdc-ios.connection_history.plist"]];
}

@end

