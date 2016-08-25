/*
 bookmarks and active session view controller
 
 Copyright 2013 Thinstuff Technologies GmbH, Author: Martin Fleisz
 
 This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
 If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

#import <UIKit/UIKit.h>
#import "Bookmark.h"
#import "BookmarkTableCell.h"
#import "SessionTableCell.h"
#import "BookmarkEditorController.h"
#import "Reachability.h"
#import "ini.h"
#import "RDPSessionViewController.h"
#import "AppListViewController.h"
#import "openssl/md5.h"
@interface BookmarkListController : UIViewController <AppListViewControllerDelegate,UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, BookmarkEditorDelegate>
{
    NSMutableData *appdata;
    int desktopflag;
    int bookmarkrow;
    BOOL safemode;
    int vernum;
    int logmode;
    NSString *pwdstring;
    RDPSessionViewController* ctrl;
    ComputerBookmark* appbookmark;
    NSURLConnection *urlconn;
    UINavigationController *applistNavController;
    AppListViewController *applistController;
	// custom bookmark and session table cells
	BookmarkTableCell* _bmTableCell;
    SessionTableCell* _sessTableCell;

	// child views
	UISearchBar* _searchBar;
	UITableView* _tableView;
   
	// array with search results (or nil if no search active)
	NSMutableArray* _manual_search_result;
	NSMutableArray* _tsxconnect_search_result;   
    NSMutableArray* _history_search_result;

    // bookmark arrays
    NSMutableArray* _manual_bookmarks;
    NSMutableArray* _tsxconnect_bookmarks;
    
    // bookmark star images
    UIImage* _star_on_img;
    UIImage* _star_off_img;
    NSString *AgentPage;
    // array with active sessions
    NSMutableArray* _active_sessions;
    
    // array with connection history entries
    NSMutableArray* _connection_history;
    
    // temporary bookmark when asking if the user wants to store a bookmark for a session initiated by a quick connect
    ComputerBookmark* _temporary_bookmark;
    
    // reachability notification helper for tsx connect
    Reachability* _tsxconnect_reachability;
}

@property (nonatomic, retain) IBOutlet UISearchBar* searchBar;
@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet BookmarkTableCell* bmTableCell;
@property (nonatomic, retain) IBOutlet SessionTableCell* sessTableCell;

- (IBAction)newBookmark:(id)sender;
- (void)renametablebartitle;
-(int) httpGetver:(NSString *)host port:(NSString *)port;
@end
