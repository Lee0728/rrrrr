/*
 App delegate
 
 Copyright 2013 Thinstuff Technologies GmbH, Author: Martin Fleisz
 
 This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
 If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

#import <UIKit/UIKit.h>
#import "HelpController.h"
#import "MessageViewController.h"
#import <stdio.h>
@class MainTabBarController;

@interface AppDelegate : NSObject <UIApplicationDelegate,MessgeViewControllerDelegate> {
    
    MainTabBarController* _tabBarController;
    HelpController* helpViewController;
    int first;
    NSMutableDictionary *midconfig;
    int maxmid;
    NSMutableDictionary *getmidconfig;
    NSString *midnum;
    NSXMLParser *parser;
    NSMutableArray *parserObjects;
    NSMutableString *currentText;
    NSMutableDictionary *twitterDic;
    NSString *currentElementName;
    NSMutableDictionary *messageconfig;
    NSMutableDictionary* configdata;
    MessageViewController* messageViewController;
    NSMutableDictionary *MessageDic;
    int badgecount;
    int geti;
    unsigned char *getreader;
}
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MainTabBarController* tabBarController;
//- (void)Rdpviewconnetrotate;
- (void)Setbadge:count;
@end
