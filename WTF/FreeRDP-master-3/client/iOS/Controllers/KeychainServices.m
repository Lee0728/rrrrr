/*
 ------------------------------------------------------------------------
 Thinstuff iRdesktop
 A RDP client for the iPhone and iPod Touch, based off WinAdmin
 (an iPhone RDP client by Carter Harrison) which is based off CoRD 
 (a Mac OS X RDP client by Craig Dooley and Dorian Johnson) which is in 
 turn based off of the Unix program rdesktop by Matthew Chapman.
 ------------------------------------------------------------------------
 
 KeychainServices.m
 Copyright (C) Carter Harrison   2008-2009
 
 ------------------------------------------------------------------------
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License along
 with this program; if not, write to the Free Software Foundation, Inc.,
 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 ------------------------------------------------------------------------
 */


#import "KeychainServices.h"


@implementation KeychainServices

+(void)addGenericPasswordForConnectionSettings:(NSDictionary *)connectionSettings
{
	OSStatus err;	
    NSMutableDictionary *attrs = [KeychainServices secDictionaryForConnectionSettings:connectionSettings];
	err = SecItemAdd((CFDictionaryRef)attrs, NULL);		

	//The item already exists in the keychain.. Try to remove it and perform another add.
	if (err == -25299)
	{
		[KeychainServices removeGenericPasswordForConnectionSettings:connectionSettings];
		err = SecItemAdd((CFDictionaryRef)attrs, NULL);		
	}
}

+(void)updateGenericPasswordForConnectionSettings:(NSDictionary *)connectionSettings withNewConnectionSettings:(NSDictionary *)newSettings
{
	//This method actually removes the entry from the keychain and re-adds a new one.
	//We are doing this due to a bug we had encountered earlier in which the keychain seems to
	//have become corrupted.

	OSStatus err;
	NSMutableDictionary *attrs = [KeychainServices secDictionaryForConnectionSettings:connectionSettings];
	NSMutableDictionary *newAttrs = [KeychainServices secDictionaryForConnectionSettings:newSettings];
	
	err = SecItemDelete((CFDictionaryRef)attrs);

	err = SecItemAdd((CFDictionaryRef)newAttrs, NULL);

	//Check to see if for some reason this entry already exists when we
	//tried to add the new entry.  If so, then we will try to force it
	//out of the keychain by using a very generic query.
	if (err == -25299)
	{
		NSMutableDictionary *badAttrs = [newAttrs mutableCopy];
		[KeychainServices removeGenericPasswordForConnectionSettings:badAttrs];
		[KeychainServices addGenericPasswordForConnectionSettings:newAttrs];

		[badAttrs release];
	}	
}

+(NSString *)retrieveGenericPasswordForConnectionSettings:(NSDictionary *)connectionSettings
{
	NSMutableDictionary *attrs = [KeychainServices secDictionaryForConnectionSettings:connectionSettings];
	NSData *passwordData = NULL;
	NSString *password;
	[attrs setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
	//[attrs removeObjectForKey:(id)kSecValueData];	//Remove the password just in case one was passed in by accident.

	OSStatus err;
	err = SecItemCopyMatching((CFDictionaryRef)attrs, (CFTypeRef *)&passwordData);
	if (err == noErr)
    {
        password = [[[NSString alloc] initWithBytes:[passwordData bytes] length:[passwordData length] encoding:NSUTF8StringEncoding] autorelease];
        [passwordData autorelease];
        return password;
    }
	else
	{
		return @"";
	}
}

+(void)removeGenericPasswordForConnectionSettings:(NSDictionary *)connectionSettings
{
	OSStatus err;
	NSMutableDictionary *attrs = [KeychainServices secDictionaryForConnectionSettings:connectionSettings];
	//[attrs removeObjectForKey:(id)kSecValueData];
	err = SecItemDelete((CFDictionaryRef)attrs);
}

+(NSMutableDictionary *)secDictionaryForConnectionSettings:(NSDictionary *)connectionSettings
{
	NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithCapacity:4];
	[attrs setValue:(id)kSecClassInternetPassword forKey:(id)kSecClass];
	[attrs setValue:[connectionSettings valueForKey:@"title"] forKey:(id)kSecAttrLabel];
	[attrs setValue:[connectionSettings valueForKey:@"username"] forKey:(id)kSecAttrAccount];
	[attrs setValue:[connectionSettings valueForKey:@"hostname"] forKey:(id)kSecAttrServer];
	[attrs setValue:[connectionSettings valueForKey:@"password"] forKey:(id)kSecValueData];
//	if ([connectionSettings valueForKey:@"password"])
//	{
//		[attrs setObject:[[connectionSettings valueForKey:@"password"] dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecValueData];
//	}
	return attrs;
}

@end
