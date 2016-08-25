//
//  AppListViewController.h
//  iRdesktop
//
//  Created by WuYonghua on 11-9-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AdSupport/AdSupport.h>
//#import <ini/ini.h>
#import "RDPSessionViewController.h"
#import "Bookmark.h"
#import "ini.h"
#import "DataModel.h"
#import "openssl/md5.h"
#import "KeychainServices.h"
//#import "PageViewController.h"

@interface AppListViewController : UITableViewController<UINavigationControllerDelegate> {
    id delegate;
    UITableViewCell *AppCell;
    NSMutableArray *Applist,*DirList;
    NSIndexPath *SelectedIndex;
    ComputerBookmark* appbookmark;
    int safegateway;
    int version;
    BOOL safemode;
    NSString *pwdstring;
    int powerflag;
    int timerflag;
    BOOL CanSelectApp;
    BOOL Directlogin;
    int logmode;
    //BOOL safegateway;
    NSMutableDictionary *Application;
    NSData *appdata;
    NSDictionary *connectionsSettings;
    NSString *curAppID,*curIP;
    Boolean showTip;
    int appRootCount;
    int vernum;
    int appdesktop;
    int powercmd;
    NSString * powerstate;
    UIView *statuView;
    NSString * appagentpage;
    NSString * powerurl;
    NSString * pwd;
    NSTimer *connectionTimer;
    NSTimer *directlogin;
    NSTimer *directesc;
    NSURLConnection *urlconn;
    NSMutableData *appdata1;
    NSString *vd;
   NSString *Userid;
    NSString *vdsp;
    NSData *dataOfUrl;
    int startupflag;
}

@property (nonatomic, retain) IBOutlet UITableViewCell *AppCell;
@property (nonatomic,copy) NSString *vd;
@property (nonatomic,copy) NSString *Userid;
@property (nonatomic,copy) NSString *vdsp;

- (NSString *)GetFinger;
- (void) timerFired:(NSTimer *)timer;
- (void)appListMain;
- (void)loadDataToCell:(BOOL)isRoot parentDir:(NSString *)parentDir;
- (void)setDelegate:(id)object;
- (id)delegate;
- (void)setAppdata:(NSData *)data;
- (void)setConnectionsSettings:(NSDictionary *)value;
- (void)setdesktopflag:(int)desktopflag;
- (void)setAgentpage:(NSString *)agentpage;
- (NSString *) getDeCrityStrrap:(NSString *)srcStr;
- (IBAction)backFavorite:(id)sender;
- (void)disableInterface;
- (void)enableInterface;
- (void) startup;
- (void) powerdown;
- (void) powerup;
//from PageViewController' Event
- (void)EventDisconnect;
- (void)EventConnected;
- (void)EventConnectFail;
- (void)EventConnectStatus:(int)status;
- (void)EventRapShellOK;
- (void)EventRunTip:(NSString *)msg;
- (void)EventRunError:(NSString *)msg;
- (void) DidRunApp;
- (void)timertablepress: (NSTimer *) timer;
- (void)setversion:(int)ver;
//////////////////////////////////////////////
/// UINavigationControllerDelegate Methods ///
//////////////////////////////////////////////
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end

@protocol AppListViewControllerDelegate
- (void)connectToServerWithConnectionSettings:(NSDictionary *)connectionSettings withCellIndex:(NSIndexPath *)index ver:(int) vernum;
- (void)cancelLastConnectRequest;
- (UIToolbar *)appMainToolbar;
- (void)backFavoriteChooser;
- (void)SetDirectLogin;
- (void)pagetoRdpSessionview;
- (void)RunAppID:(NSString *)appid ver:(int)vernum;
- (void)pagetoRdpSessionView:(NSString *)hostname port:(NSString *)port username:(NSString *)username password:(NSString *)password rapshell:(NSString *)rapshell safegateway:(int)safegateway Sessionid:(NSString *)Sessionid appid:(NSString *)appid;
- (void)renametablebartitle;
@end
