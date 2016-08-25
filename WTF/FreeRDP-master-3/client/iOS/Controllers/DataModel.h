//
//  DataModel.h
//  GwtClient_IOS
//
//  Created by WuYonghua on 11-9-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DataModel : NSObject {
    NSString *appId;
    NSString *appName;
    NSData   *icoData;
    NSString *serverid;
    NSString *desktoptype;
    NSString *rap;
}
//- (id)initWithTitle:(NSString *)appId 
//          appName:(NSNumber *)pappName;

@property(nonatomic, copy) NSString *appId;
@property(nonatomic, copy) NSString *appName;
@property(nonatomic, copy) NSData *icoData;
@property(nonatomic, copy) NSString *serverid;
@property(nonatomic, copy) NSString *desktoptype;
@property(nonatomic, copy) NSString *rap;
@end
