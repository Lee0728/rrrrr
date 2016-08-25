/*
 Application info controller
 
 Copyright 2013 Thinstuff Technologies GmbH, Author: Martin Fleisz
 
 This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
 If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

#import "AboutController.h"
#import "Utils.h"
#import "BlockAlertView.h"

@implementation AboutController

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    [self setTitle:NSLocalizedString(@"About", @"About Controller title")];
    UIImage* tabBarIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tabbar_icon_about" ofType:@"png"]];
    [self setTabBarItem:[[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"About", @"Tabbar item about") image:tabBarIcon tag:0] autorelease]];
    return self;
}

- (void)dealloc
{
    [super dealloc];
}


@end
