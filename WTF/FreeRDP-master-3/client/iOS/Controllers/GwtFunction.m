//
//  GwtFunction.m
//  GwtClient_IOS
//
//  Created by WuYonghua on 11-9-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "GwtFunction.h"
#define     LocalStr_None           @""

const int ConKey = 3562;
const int SeedA  = 5891;
const int SeedB  = 5920;
const char *B64Table ="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"; 

@implementation GwtFunction

-(NSData *)HexToBytes:(NSString *)hexstr
{
    int i=0;
    NSString *srcStr=[[[NSString alloc] initWithString:hexstr] autorelease];
    int size = [srcStr length] / 2;
    char *buff = malloc(size+1);
    memset(buff,0,size+1);
    int value=0;
    NSString *hex=[[[NSString alloc] initWithString:@""] autorelease];
    while (i < size){
        hex = @"0x";
        hex = [hex stringByAppendingString:[srcStr substringToIndex:2]];
        srcStr = [srcStr substringFromIndex:2];
        sscanf([hex cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
        buff[i] = value;
        i++;
    }
    printf("the buf is %s",buff);
    NSData *ret = [[[NSData alloc] initWithBytes:buff length:size] autorelease];
    free(buff);
    return ret;
}

-(int) poschar:(char)c at:(const char *)at
{
    int i;
    int len = strlen(at);
    for (i = 0; i < len; i ++) {
        if (at[i] == c) break;
    }
    if (i == len) return 0;
    return i;
}

-(NSString *)IntToHex:(int)Value len:(int)len
{
    char t[10];
    sprintf(t, "%%0%dx", len);
    sprintf(t, t, Value);
    NSString *s=[[[NSString alloc]initWithCString:t encoding:NSASCIIStringEncoding] autorelease];
    return s;
}

- (NSString *)txtFromBase64String:(NSString *)base64
{
    if (base64 && ![base64 isEqualToString:LocalStr_None]) {
        //取项目的bundleIdentifier作为KEY   改动了此处
        //NSString *key = [[NSBundle mainBundle] bundleIdentifier];
        NSData *data = [self dataWithBase64EncodedString:base64];
        //IOS 自带DES解密 Begin    改动了此处
        //data = [self DESDecrypt:data WithKey:key];
        //IOS 自带DES加密 End
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    else {
        return LocalStr_None;
    }
}

- (NSData *)dataWithBase64EncodedString:(NSString *)string
{
    if (string == nil)
        [NSException raise:NSInvalidArgumentException format:nil];
    if ([string length] == 0)
        return [NSData data];
    
    char *decodingTable = NULL;
    if (decodingTable == NULL)
    {
        decodingTable = malloc(256);
        if (decodingTable == NULL)
            return nil;
        memset(decodingTable, CHAR_MAX, 256);
        NSUInteger i;
        for (i = 0; i < 64; i++)
            decodingTable[(short)B64Table[i]] = i;
    }
    
    const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
    if (characters == NULL)     //  Not an ASCII string!
        return nil;
    char *bytes = malloc((([string length] + 3) / 4) * 3);
    if (bytes == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (YES)
    {
        char buffer[4];
        short bufferLength;
        for (bufferLength = 0; bufferLength < 4; i++)
        {
            if (characters[i] == '\0')
                break;
            if (isspace(characters[i]) || characters[i] == '=')
                continue;
            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
            {
                free(bytes);
                return nil;
            }
        }
        
        if (bufferLength == 0)
            break;
        if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
        {
            free(bytes);
            return nil;
        }
        
        //  Decode the characters in the buffer to bytes.
        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2)
            bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
        if (bufferLength > 3)
            bytes[length++] = (buffer[2] << 6) | buffer[3];
    }
    
    bytes = realloc(bytes, length);
    return [NSData dataWithBytesNoCopy:bytes length:length];
}
- (NSData *) B64Decode:(NSData *)data
{
    NSString *m = @"";
    const char *indata = [data bytes];

    int size = strlen(indata);//[data length];
    if (indata[size - 1] == '=') size--;
    if (indata[size - 1] == '=') size--;
    int len = size / 2;
    int t;
    char s1, s2;
    for (int i = 0; i < len; i++) {
        s1 = indata[i * 2];
        s2 = indata[i * 2 + 1];
        
        t = [self poschar:s1 at:B64Table] * 64 + [self poschar:s2 at:B64Table];
        m = [m stringByAppendingString:[self IntToHex:t len:3]];
    }
    if (size % 2 == 1){
        s1 = indata[size - 1];
        t = [self poschar:s1 at:B64Table] * 64;
        m = [m stringByAppendingString:[self IntToHex:t len:3]];
    }
    len = [m length] / 2;
    char s[5];
    s[0] = '0';
    s[1] = 'x';
    s[4] = 0;
    char *outs = malloc(len);

    for (int i = 0; i < len; i++) {
        s[2] = [m characterAtIndex:i*2];
        s[3] = [m characterAtIndex:i*2+1];
        sscanf(s, "%x", &outs[i]);
    }
    printf("the outs is %s",outs);
    NSData *d = [[[NSData alloc]initWithBytes:outs length:len] autorelease];
    free(outs);
    return d;
}

/*
- (NSData *) Crypt:(NSData *)data bEncrypt:(BOOL)bEncrypt
{
    UInt32 key = ConKey;
    const char *ps=[data bytes];
    int len=strlen(ps)+1;   //modify by wlp //int len = [data length]; for complex password
    char *pr=malloc(len);
    memset(pr, 0, len);
    for (int i = 0; i < len-1; i++) {
        pr[i] = ps[i] ^ (key >> 8);
        if (bEncrypt){
            key = ((unsigned char)pr[i] + key) * SeedA + SeedB;
        }
        else{
            key = ((unsigned char)ps[i] + key) * SeedA + SeedB;
        }
    }
    NSData *d=[NSData dataWithBytes:pr length:len];
    free(pr);
    return d;
}*/
- (NSData *) Acrypt:(NSData *)data
{
    int SeedA = 10;
    int SeedB = 17;
    int Key = 7402;
    Byte *p1 = (Byte *)[data bytes];
    
    int count = [data length];
    //count=count-2;
    char *pr=malloc(count);
    // byte[] b = Encoding.Default.GetBytes(Source);
    //int count = b.Length;
    for (int i = 0; i < count; i++)
    {
        pr[i] = (unsigned char)((int)p1[i] ^ Key);
        Key = Key + (SeedA - SeedB) * 2 + SeedB;
    }
    NSData *d=[NSData dataWithBytes:pr length:count];
    free(pr);
    return d;
    //return Encoding.Default.GetString(b);
}
- (NSData *) Crypt:(NSData *)data bEncrypt:(BOOL)bEncrypt
{
    UInt32 key = ConKey;
    int num = 0;
    int flag = 0;
    int length = 0;
    //NSString *encodedata = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    Byte *p1 = (Byte *)[data bytes];
    int len = [data length];
    for(int i=0;i<len;i++)
    {
        printf("testByte = %d\n",p1[i]);
        if(p1[i]==0)
        {
            num = i; 
        }
    }
    printf("byte\n");
    const char *p=[data bytes];
    /*int length = [data length];
    if(p[length-1]==0)
    {
        length = length-1;
    }*/
    if(num != 0)
    {
        for(int i=num;i<len;i++)
        {
            if(p1[i]!=0)
            {
                flag = 1;
            }
        }
        if(flag ==1)
        {
            length = len;
        }
        else{
            length = num;
        }
    }
    else 
    {
        length = len;
    }
    char *pr=malloc(length);
    memset(pr, 0, length);
    //}    
    //modify by wlp //int len = [data length]; for complex password
    
    for (int i = 0; i < length; i++) {
        pr[i] = p[i] ^ (key >> 8);
        if (bEncrypt){
            key = ((unsigned char)p[i] + key) * SeedA + SeedB;
        }
        else{
            key = ((unsigned char)p[i] + key) * SeedA + SeedB;
        }
    }
    NSData *d=[NSData dataWithBytes:pr length:length];
    printf("the pr is %s",pr);
    free(pr);
    return d;
}
- (NSString *) getDeCrityStrrap:(NSString *)srcStr
{
    //NSData *data=[[[NSData alloc]init] autorelease];
    NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *data = [self HexToBytes:srcStr];
    data = [self B64Decode:data];
    //data = [self Crypt:data bEncrypt:FALSE];
    data = [self Acrypt:data];
    NSString *dest = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
    //NSString *dest = [[[NSString alloc] initWithData:data encoding:gbkEncoding] autorelease];
    
    return dest;
}
- (NSString *) getDeCrityStr:(NSString *)srcStr
{
    //NSData *data=[[[NSData alloc]init] autorelease];
            NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *data = [self HexToBytes:srcStr];
    data = [self B64Decode:data];
    data = [self Crypt:data bEncrypt:FALSE];
    //data = [self Acrypt:data];
    NSString *dest = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
   // NSString *dest = [[[NSString alloc] initWithData:data encoding:gbkEncoding] autorelease];

    return dest;
}
     
@end
