//
//  parse.h
//  ini
//
//  Created by Moelli on 04.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


@interface INIParser (Parsing)

- (int)parse: (char *)filename;
- (int)parsedata: (NSData *)data;
- (int)parseLine: (char *) line;
- (int)parseSection: (char *) line;
- (int)parseAssignment: (char *) line;
- (NSString*) getANSIString:(char*)ansiString;
@end