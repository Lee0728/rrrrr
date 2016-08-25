//
//  MessageViewController.h
//  FreeRDP
//
//  Created by 吴 永华 on 14-3-12.
//
//

#import <UIKit/UIKit.h>
#import "messagetablecell.h"
#import "EGORefreshTableHeaderView.h"
#import "MessageWebview.h"
@interface MessageViewController : UIViewController <NSXMLParserDelegate,EGORefreshTableHeaderDelegate>
{
    UITableView* _tableView;
    messagetablecell* _msTableCell;
    MessageWebview* Messagewebview;
    int oldcount;
    int newcount;
    int badgecount;
    id delegate;
    int Messagecount;
    int Newmessagecount;
    int fontsizeflag;
    NSString *midnum;
    NSString *maxmid;
    NSMutableDictionary *getmidconfig;
    EGORefreshTableHeaderView *_refreshTableView;
    UINavigationController* MessageViewNavController;
    NSMutableDictionary *messageconfig;
    NSMutableDictionary *badgeconfig;
    NSXMLParser *parser;
    NSMutableArray *parserObjects;
    NSMutableString *currentText;
    NSMutableDictionary *twitterDic;
    NSString *currentElementName;
    int fontflag;
}
- (void)getParse;
- (void)setDelegate:(id)object;
- (void) writefile : (NSString*) filename writedata:(NSString *)wdata;
- (id)applicationPlistFromFile:(NSString *)fileName;
- (NSString *)readfile:(NSString*)filename;
 @property (nonatomic, retain) IBOutlet UITableView* tableView;

 @property (nonatomic, retain) IBOutlet messagetablecell* mstablecell;
@end
@protocol MessgeViewControllerDelegate
//- (void)pageToApplistView:(NSData *)data;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id)getdelegate;
- (void)Setbadge:(int) count;
- (void)pagetozbarviewcontroller ;
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view;
-(NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view;
-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view;
@end