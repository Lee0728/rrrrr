/*
 main tabbar controller
 
 Copyright 2013 Thinstuff Technologies GmbH, Author: Martin Fleisz
 
 This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
 If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

#import "MainTabBarController.h"


@implementation MainTabBarController

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if(tabrotateflag == 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    return YES;
}
- (BOOL)shouldAutorotate
{
    if(tabrotateflag == 0)
    {
        return YES;
    }
    else
   {
    return NO;
    }
    return YES;
}
- (void)setrotateflag:(int)rotateflag
{
    tabrotateflag = rotateflag;
}
/*-(NSUInteger)supportedInterfaceOrientations
{ return UIInterfaceOrientationMaskPortrait;//只支持这一个方向(正常的方向)
    //return UIInterfaceOrientationMaskLandscape;
}*/
@end
