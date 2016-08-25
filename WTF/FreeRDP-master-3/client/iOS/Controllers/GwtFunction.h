//
//  GwtFunction.h
//  GwtClient_IOS
//
//  Created by WuYonghua on 11-9-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GwtFunction : NSObject {

}
- (NSData *) HexToBytes:(NSString *)hexstr;
- (NSData *) B64Decode:(NSData *)data;
- (NSData *) Crypt:(NSData *)data bEncrypt:(BOOL)bEncrypt;
- (NSString *) getDeCrityStr:(NSString *)srcStr;
- (NSString *) getDeCrityStrrap:(NSString *)srcStr;
- (NSData *)dataWithBase64EncodedString:(NSString *)string;
- (NSString *)txtFromBase64String:(NSString *)base64;
//- char *decodingTable = NULL;
@end
