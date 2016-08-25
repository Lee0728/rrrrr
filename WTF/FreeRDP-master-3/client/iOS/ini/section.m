#import "section.h"

@implementation INISection

- initWithName: (NSString *)name {

	self = [super init];
	assignments = [[NSMutableDictionary alloc] init];
	sname = name;
	return self;
}

- (void)dealloc {

	[assignments release];
	//[sname release];
	return [super dealloc];
}

- (void)insert: (NSString *)name value: (NSString *)value {

	//NSCharacterSet *whitespce = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    //value = [value stringByTrimmingCharactersInSet:whitespce];
    //name = [name stringByTrimmingCharactersInSet:whitespce];
    [assignments setObject: value forKey: name];
	return;
}

- (NSString *)retrieve: (NSString *)name {
	NSString * ret;

	ret = [assignments objectForKey: name];
	return ret;
}

@end
