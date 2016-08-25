#include <stdio.h>
#include <string.h>

#include <iconv.h>
#import "ini.h"
//#import "utils.h"

@implementation INIParser (Parsing)

- (int)parse: (char *)filename
{
	int err;
	char buf [1024];
	char * lb;
	FILE * file;
	
	file = fopen (filename, "r");
	if (file == NULL)
		return INIP_ERROR_FOPEN_FAILED;

	while (1) {
		if (fgets (buf, 1023, file) == NULL)
			break;

		lb = [self trim: buf];
		if (*lb == 0)
			break;

		err = [self parseLine: lb];
		if (err != INIP_ERROR_NONE) {
			fclose (file);
			return err;
		}
	}
	
	fclose (file);
	return INIP_ERROR_NONE;
}

int code_convert(char *from_charset, char *to_charset, char *inbuf, size_t inlen, char *outbuf, size_t outlen) {
    iconv_t cd = NULL;
    cd = iconv_open(to_charset, from_charset);
    if(!cd)
        return -1;
    memset(outbuf, 0, outlen);
    if(iconv(cd, &inbuf, &inlen, &outbuf, &outlen) == -1) {
        return -1;
    }
    iconv_close(cd);
    return 0;
}
- (NSString*) getANSIString:(char*)ansiString {
    NSString *string = nil;
    //char *ansiString = (char*)[ansiData bytes];
    int ansiLen = strlen(ansiString);//[ansiData length];
    int utf8Len = ansiLen*2;
    char *utf8String = (char*)malloc(utf8Len);
    memset(utf8String, 0, utf8Len);
    int result = code_convert("gb2312", "utf8", ansiString, ansiLen, utf8String, utf8Len);
    if (result == -1) {        
    }
    else {
        string = [[NSString alloc] initWithUTF8String:utf8String];
    }
    free(utf8String);
    return string;
}

//parse data
- (int)parsedata: (NSData *)appdata
{
    char *lb;
    char buf[1024*200];
    int err = 0;
    int i = 0;
    int j = 0;
    int count = [appdata length];
    char *data = (char*)[appdata bytes];
    printf("the data is %s",data);
    //char *data= (char*)malloc(count * 2);
    //memset(data, 0, count * 2);
    //code_convert("gb2312", "utf8", ansiString, count, data, count*2);
    while(i < count){
        j = 0;
        while (data[i] != '\n' && data[i] != '\r' && i < count){
            buf[j] = data[i];
            j++;
            i++;
        }
        buf[j] = 0;
        lb = [self trim:buf];
        if (*lb != 0){
            err = [self parseLine: lb];
            if (err != INIP_ERROR_NONE) break;
        }
        i++;
    }
    return err;
}

- (int)parseLine: (char *) line
{
	int err;

	if (*line == '[') 
        err = [self parseSection: line];
	else		  
        err = [self parseAssignment: line];
	
	return err;
}

- (int)parseSection: (char *)line
{
	INISection * section;
	NSString * name;
	char *l,*str;
	
	l = strchr (line, ']');
	if (l == NULL)
		return INIP_ERROR_INVALID_SECTION;
	
	*l = 0;
//	name = [NSString stringWithCString: line +1];
    
    //中文文件夹 －wlp
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    str = line+1;
    NSData *d = [[NSData alloc] initWithBytes:str length:strlen(str)];
    name = [[[NSString alloc]initWithData:d encoding:enc] autorelease];
    
	section = [[[INISection alloc] initWithName: name] autorelease];
	[sections setObject: section forKey: name];
	csection = section;
    [d release];
	return INIP_ERROR_NONE;
}

- (int)parseAssignment: (char *)line
{
	char * name, * value;
	NSString * n, * v;
	
	if (csection == nil)
		return INIP_ERROR_NO_SECTION;

	name = line;
	value = strchr (name, '=');
	if (value == NULL)
		return INIP_ERROR_INVALID_ASSIGNMENT;
	
	*value++ = 0;
    name = [self trim:name];
    value = [self trim:value];
    //中文
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
	n = [NSString stringWithCString: name encoding:NSASCIIStringEncoding];
	v = [NSString stringWithCString: value encoding:NSASCIIStringEncoding];
    NSData *data = [[[NSData alloc] initWithBytes:value length:strlen(value)] autorelease];
    //v = [[NSString alloc]initWithBytes:value length:strlen(value) encoding:enc];
    v = [[[NSString alloc]initWithData:data encoding:enc] autorelease];
    //NSLog(@"%@=%@", n, v);
    //if (n==@"name") 
    //    v = [self getANSIString:value];
    //else
    //    v = [NSString stringWithCString: value];
	[csection insert: n value: v];
	return INIP_ERROR_NONE;
}

@end
