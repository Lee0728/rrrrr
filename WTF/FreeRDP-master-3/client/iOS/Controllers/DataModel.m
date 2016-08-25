//
//  DataModel.m
//  GwtClient_IOS
//
//  Created by WuYonghua on 11-9-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "DataModel.h"


@implementation DataModel

@synthesize appId;
@synthesize appName;
@synthesize icoData;
@synthesize serverid;
//- (id)initWithTitle:(NSString *)pappId 
//          appName:(NSString *)pappName{
//    self = [super init]; 
//    if(nil != self) {
//        self.appId = pappId;
//        self.appName = pappName;
//    }
//    return self;
//}

- (void) dealloc { 
    if (appId != nil) [appId release];
    if (appName != nil) [appName release];
    if (icoData != nil) [icoData release];
    [super dealloc];
}

@end
