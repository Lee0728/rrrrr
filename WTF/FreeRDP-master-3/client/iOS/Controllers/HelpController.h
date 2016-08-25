/*
 Application help controller
 
 Copyright 2013 Thinstuff Technologies GmbH, Author: Martin Fleisz
 
 This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
 If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

/*#import <UIKit/UIKit.h>

@interface HelpController : UIViewController <UIWebViewDelegate>
{
	IBOutlet UIScrollView* help_scrollview;
    IBOutlet UIView* help_view;
}
@end*/
#import <UIKit/UIKit.h>

@interface HelpController : UITableViewController
{
    IBOutlet UIScrollView* help_scrollview;
    NSString *machinename;
    id delegate;
    UIButton *backbutton;
    //UITableViewController
    //UITableViewCell *HelpCell;
    IBOutlet UITableViewCell *HelpCell;
}
- (void)setDelegate:(id)object;
- (id)delegate;
- (void)back:(id) sender;
//@property (nonatomic, retain)
@end
@protocol HelpControllerDelegate
-(void) SetBackSessionflag;
@end