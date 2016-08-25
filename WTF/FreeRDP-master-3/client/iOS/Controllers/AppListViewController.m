//
//  AppListViewController.m
//  iRdesktop
//
//  Created by WuYonghua on 11-9-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "AppListViewController.h"
#import "GwtFunction.h"
#import "Misc.h"
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
@implementation AppListViewController

@synthesize AppCell;
@synthesize Userid = _Userid, vd=_vd, vdsp=_vdsp;
#pragma mark MAC
// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to mlamb.
- (NSString *) macaddress
{
    int mib[6];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    // NSString *outstring = [NSString stringWithFormat:@"x:x:x:x:x:x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    NSString *outstring = [NSString stringWithFormat:@"%x%x%x%x%x%x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    return [outstring uppercaseString];
}
/*- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
 {
 [appdata1 appendData:data];
 
 }
 
 - (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
 {
 //[self connectionRequestDidSucceed];
 [self ErrorMessageBox:[[NSBundle mainBundle] localizedStringForKey:@"AlertTitle" value:@"Error Infomation" table:nil]
 messageStr:[[NSBundle mainBundle] localizedStringForKey:@"FavMessage" value:@"Can not connect server!" table:nil]
 btnTitleStr:[[NSBundle mainBundle] localizedStringForKey:@"OkBtnCaption" value:@"OK" table:nil]
 tag:0];
 }
 
 -(void) connectionDidFinishLoading:(NSURLConnection *)connection{
 
 NSString *check = [[[NSString alloc] initWithData:appdata1 encoding:NSASCIIStringEncoding] autorelease];
 }*/
-(NSData *)HexToBytes:(NSString *)hexstr
{
    int i=0;
    NSString *srcStr=[[[NSString alloc] initWithString:hexstr] autorelease];
    int size = [srcStr length] / 2;
    char *buff = malloc(size);
    int value=0;
    NSString *hex;//=[[NSString alloc] initWithString:@""];
    while (i < size){
        hex = @"0x";
        hex = [hex stringByAppendingString:[srcStr substringToIndex:2]];
        srcStr = [srcStr substringFromIndex:2];
        sscanf([hex cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
        buff[i] = value;
        i++;
    }
    //[hex release];
    NSData *ret = [[[NSData alloc] initWithBytes:buff length:size] autorelease];
    free(buff);
    return ret;
}

- (NSString *)getMD5PWD:(NSString *)pwdSrc
{
    NSString *string = @"";
    if(pwdSrc != nil)  string = pwdSrc;
    unsigned char *inStrg = (unsigned char*)[[string dataUsingEncoding:NSASCIIStringEncoding] bytes];
    unsigned long lngth = [string length];
    unsigned char result[MD5_DIGEST_LENGTH];
    NSMutableString *pwd = [NSMutableString string];
    MD5(inStrg, lngth, result);
    unsigned int i;
    for (i = 0; i < MD5_DIGEST_LENGTH; i++)
    {
        [pwd appendFormat:@"%02x", result[i]];
    }
    return pwd;
}
- (void)ErrorMessageBox:(NSString *)titleStr messageStr:(NSString *)messageStr btnTitleStr:(NSString *)btnTitleStr tag:(NSInteger)tag
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleStr
                                                    message:messageStr
                                                   delegate:self
                                          cancelButtonTitle:btnTitleStr
                                          otherButtonTitles:nil];
    [alert setTag:tag];
    [alert show];
    [alert release];
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 1:
            //[delegate backFavoriteChooser];
            [[self navigationController] popViewControllerAnimated:YES];
            break;
        case 2:
            break;
        default:
            break;
    }
}
//获取根目录列表
- (void)getRootDirList: (INIParser *)parser parentName:(NSString *)parentName
{
    NSString *key,*appid,*appname;
    int i = 0;
    while (1) {
        
        key = [parser get:[NSString stringWithFormat:@"DIR%d",i] section:parentName];
        if (key == nil) break;
        if ([key isEqualToString:@"DIR_Null"])
        {
            i++;
            continue;
        }
        appid   = [parser get:@"id" section:key];
        appname = [parser get:@"name" section:key];
        DataModel *AppInfo = [[DataModel alloc] init];
        AppInfo.appId = appid;
        AppInfo.appName = appname;
        AppInfo.icoData = nil;
        [DirList addObject:AppInfo];
        [AppInfo release];
        i++;
    }
}
//获取根目录应用程序列表
- (void)getRootAppList:(INIParser *)parser parentName:(NSString *)parentName
{
    NSString *key,*appid,*appname,*appico,*serverid,*rap,*desktoptype;
    int checkAppType;
    int i = 0;
    NSData *icodata;
    if((appdesktop == 0)&&(version>=6))
    {
        _vd = [[NSString alloc] initWithString:[parser get:@"vd" section:@"VirtualDisk"]];
        _Userid = [[NSString alloc] initWithString:[parser get:@"UsrID" section:@"VirtualDisk"]];
        _vdsp =  [[NSString alloc] initWithString:[parser get:@"vdsp" section: @"VirtualDisk"]];
        NSLog(@"the vd is %@,Userid is %@,vdsp is %@",_vd,_Userid,_vdsp);
    }
    while(1){
        //key = [NSString stringWithFormat:@"APP%i",i];
        key = @"";
        NSData *data;
        data = [parentName dataUsingEncoding:NSUTF8StringEncoding];
        //parentName = [[NSString alloc]initWithData:data encoding:];
        
        //NSLog(@"parentName=%@",parentName);
        key = [parser getstring:[NSString stringWithFormat:@"APP%i",i] section:parentName];
        if (key == nil) break;
        
        checkAppType = [parser getInt:@"app_type_mode" section:key];  //排除 内容类型 app_type_mode = 2 //add wlp
        
        if (checkAppType != 2){
            appid =   [parser get:@"app_id" section:key];
            appname = [parser get:@"name" section:key];
            appico =  [parser get:@"ico" section: key];
            serverid = [parser get:@"ServerId" section:key];
            powerstate = [parser get:@"desktop_power_statue" section:key];
            desktoptype = [parser get:@"desktop_type" section:key];
            rap = [parser get:@"URL" section:key];
            rap = [rap substringFromIndex:6];
            NSLog(@"the URL is %@",rap);
            id gwt = [GwtFunction new];
            rap = [gwt getDeCrityStrrap:rap];
            NSLog(@"the URL is %@",rap);
            NSString *string2 = @"AppID";
            NSRange range = [rap rangeOfString:string2];
            int location = range.location;
            int leight = range.length;
            NSLog(@"the location is %d",location);
            NSLog(@"the location is %d",leight);
            location = location + leight+12;
            rap = [rap substringToIndex:location];
            NSLog(@"the URL is %@",rap);
            NSLog(@"the serverid is%@",serverid);
            NSLog(@"the key is%@",key);
            icodata = [self HexToBytes:appico];
            DataModel *AppInfo = [[DataModel alloc] init];
            AppInfo.appId = appid;
            AppInfo.appName = appname;
            AppInfo.icoData = icodata;
            AppInfo.serverid = serverid;
            AppInfo.rap = rap;
            AppInfo.desktoptype =desktoptype;
            [Applist addObject:AppInfo];
            [AppInfo release];
        }
        
        i++;
    }
    appRootCount = [Applist count];
}
-(void) loadDataToCellPower:(BOOL)isRoot parentDir:(NSString *)parentDir {
    //    if (Applist != nil) [Applist release];
    //    if (DirList != nil) [DirList release];
    //NSString *dirname = [[NSString alloc] init];
    //dirname = [dirname stringByAppendingString:parentDir];
    NSString *dirname = [[NSString alloc] init];
    dirname = [dirname stringByAppendingString:parentDir];
    [Applist removeAllObjects];
    [DirList removeAllObjects];
    //dirname = [[NSString alloc] initWithString:parentDir];
    INIParser *parser = [[[INIParser alloc] init] autorelease];
    int err = [parser parsedata: appdata];
    if (err != INIP_ERROR_NONE)
    {
        //[parser release];
        return;
    }
    //判断ini文件结构是否正确
    int result=[parser getInt:@"result" section:@"result"];
    if (result != 0)
    {
        [self ErrorMessageBox:[[NSBundle mainBundle] localizedStringForKey:@"AlertTitle" value:@"Error Informaion" table:nil]
                   messageStr:[parser get:@"MsgDesc" section:@"result"]
                  btnTitleStr:[[NSBundle mainBundle] localizedStringForKey:@"OkbtnCaption" value:@"OK" table:nil]
                          tag:1];
        return;
    }
    //判断版本级是否对应
    result = [parser getInt:@"iOS" section:@"MutiClient"];
    if (result != 1){
        [self ErrorMessageBox:[[NSBundle mainBundle] localizedStringForKey:@"AlertTitle" value:@"Error Informaion" table:nil]
                   messageStr:[[NSBundle mainBundle] localizedStringForKey:@"PlatformErr" value:@"Server not support,Please downLoad laster Server." table:nil]
                  btnTitleStr:[[NSBundle mainBundle] localizedStringForKey:@"OkbtnCaption" value:@"OK" table:nil]
                          tag:1];
        return;
    }
    //    Applist = [[NSMutableArray alloc] init];
    //    DirList = [[NSMutableArray alloc] init];
    if (isRoot)
    {
        [self getRootDirList:parser parentName:@"DirList"];
        [self getRootAppList:parser parentName:parentDir];
    }
    else
    {
        NSString *tmp = @"AppList_";
        //NSString *tmp1 = parentDir;
        //NSString *string = [string stringByAppendingFormat:@"%@,%@",tmp, parentDir];        //NSString *tmp1 = parentDir;
        tmp = [tmp stringByAppendingString:dirname];
        [self getRootDirList:parser parentName:@"DirListEmpty"];
        [self getRootAppList:parser parentName:tmp];
    }
    
}
-(void) loadDataToCell:(BOOL)isRoot parentDir:(NSString *)parentDir {
    //    if (Applist != nil) [Applist release];
    //    if (DirList != nil) [DirList release];
    //NSString *dirname = [[NSString alloc] init];
    //dirname = [dirname stringByAppendingString:parentDir];
    NSString *dirname = [[NSString alloc] init];
    dirname = [dirname stringByAppendingString:parentDir];
    [Applist removeAllObjects];
    [DirList removeAllObjects];
    //dirname = [[NSString alloc] initWithString:parentDir];
    INIParser *parser = [[[INIParser alloc] init] autorelease];
    int err = [parser parsedata: appdata];
    if (err != INIP_ERROR_NONE)
    {
        //[parser release];
        return;
    }
    //判断ini文件结构是否正确
    int result=[parser getInt:@"result" section:@"result"];
    if (result != 0)
    {
        [self ErrorMessageBox:[[NSBundle mainBundle] localizedStringForKey:@"AlertTitle" value:@"Error Informaion" table:nil]
                   messageStr:[parser get:@"MsgDesc" section:@"result"]
                  btnTitleStr:[[NSBundle mainBundle] localizedStringForKey:@"OkbtnCaption" value:@"OK" table:nil]
                          tag:1];
        return;
    }
    //判断版本级是否对应
    result = [parser getInt:@"iOS" section:@"MutiClient"];
    if (result != 1){
        [self ErrorMessageBox:[[NSBundle mainBundle] localizedStringForKey:@"AlertTitle" value:@"Error Informaion" table:nil]
                   messageStr:[[NSBundle mainBundle] localizedStringForKey:@"PlatformErr" value:@"Server not support,Please downLoad laster Server." table:nil]
                  btnTitleStr:[[NSBundle mainBundle] localizedStringForKey:@"OkbtnCaption" value:@"OK" table:nil]
                          tag:1];
        return;
    }
    //    Applist = [[NSMutableArray alloc] init];
    //    DirList = [[NSMutableArray alloc] init];
    if (isRoot)
    {
        [self getRootDirList:parser parentName:@"DirList"];
        [self getRootAppList:parser parentName:parentDir];
    }
    else
    {
        NSString *tmp = @"AppList_";
        //NSString *tmp1 = parentDir;
        //NSString *string = [string stringByAppendingFormat:@"%@,%@",tmp, parentDir];        //NSString *tmp1 = parentDir;
        tmp = [tmp stringByAppendingString:dirname];
        [self getRootDirList:parser parentName:@"DirListEmpty"];
        [self getRootAppList:parser parentName:tmp];
    }
    
}
/********************End********************/
////////////////////////////////////////配置当前将要运行应用程序的参数/////////////////////////////////////////////
- (void)configSelectedApp:(NSData *)srcStr
{
    NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    INIParser *parser = [[[INIParser alloc] init] autorelease];
    NSString *RapShell;
    
    int err = [parser parsedata: srcStr];
    
    if (err != INIP_ERROR_NONE) return;
    
    //NSLog(@"%@",[parser get:@"MsgDesc" section:@"result"]);
    
    int result=[parser getInt:@"result" section:@"result"];
    if (result != 0){
        [self ErrorMessageBox:[[NSBundle mainBundle] localizedStringForKey:@"AlertTitle" value:@"Error Informaion" table:nil]
                   messageStr:[parser get:@"MsgDesc" section:@"result"]
                  btnTitleStr:[[NSBundle mainBundle] localizedStringForKey:@"OkbtnCaption" value:@"OK" table:nil]
                          tag:2];
        return;
    }
    
    id gwt = [GwtFunction new];
    NSString *hostname=[parser get:@"Server_address" section:@"Server"];
    NSRange range=[hostname rangeOfString:@":"];
    NSString *hostport=[hostname substringFromIndex:range.location + range.length];
    hostname = [hostname substringToIndex:range.location];
    NSString *username=[parser get:@"Login_user" section:@"Server"];
    username = [gwt getDeCrityStr:username];
    
    //    16.07.12
    NSString *domain = [parser get:@"Login_domain" section:@"Server"];
    if (![domain isEqualToString:@""]) {
        domain = [gwt getDeCrityStr:domain];
        username = [NSString stringWithFormat:@"%@\\%@", domain, username];
    }
    NSLog(@"the username is %@",username);
    
    
    NSString *password=[parser get:@"Login_password" section:@"Server"];
    NSLog(@"the password is %@",password);
    password = [gwt getDeCrityStr:password];
    if(appdesktop==1)
    {
        //pwd=[[[appbookmark params] copy] StringForKey:@"password"];
        //password=@"realor#123";
    }
    NSString *s = [parser get:@"RapShellPath" section:@"Server"];
    NSLog(@"the s is %@",s);
    NSString *WebSessionID = [parser get:@"SessionID" section:@"Farm"];
    NSLog(@"the WebSessionID is %@",WebSessionID);
    NSString *ServerIPType = [parser get:@"ServerIPType" section: @"Server"];
    NSLog(@"the ServerIPType is %@",ServerIPType);
    //if (!ServerIPType) ServerIPType = @"0";
    //safegateway = 0;
    if([ServerIPType isEqualToString:@"2"])
    {
        safegateway = 1;
    }
    else
    {
        safegateway = 0;
    }
    
    if([s isEqualToString:@""])
    {
        RapShell = @"";
    }
    else
    {
        NSLog(@"the s is %@",s);
        NSData *shell = [s dataUsingEncoding:NSUTF8StringEncoding];  //modefy by //wlp
        
        
        shell = [gwt B64Decode:shell];
        shell = [gwt Crypt:shell bEncrypt:FALSE];
        const char *getbyte = [shell bytes];
        printf("the getbyte is %s",getbyte);
        char *serch = strstr(getbyte,"exe");
        int num = serch - getbyte;
        printf("the num is %d",num);
        char *c = malloc(num+4);
        memset(c,0,num+4);
        memcpy(c,getbyte,num+3);
        printf("the c is %s",c);
        NSString *ss = [NSString stringWithCString:c encoding:NSUTF8StringEncoding];
        //NSString *ss = [[NSString alloc] initWithUTF8String:c];
        NSLog(@"the ss is %@",ss);
        //[[[NSString alloc] initWithCString:c encoding:NSUTF8StringEncoding] autorelease];
        //"\"C:\\Program Files\\RealFriend\\Rap Server\\Bin\\rapshell.exe\" /N:APP00000001 /U:admin /P:c4ca4238a0b923820dcc509a6f75849b /T:31333037343138323632 /S:0 /Ds:C1D1E1F1H2 /M:A3EA40239 /H: /I:0 /E:",
        
        //支持安全连接网关，if serveriptype=2 socket连接后需发送"AGS:" + WebSessionID + 0
        
        
        RapShell = @"\"";
        RapShell = [RapShell stringByAppendingString:ss];
        RapShell = [RapShell stringByAppendingString:@"\""];
        RapShell = [RapShell stringByAppendingString:@" /N:"];
        RapShell = [RapShell stringByAppendingString:curAppID];
        NSLog(@"the curAppID is %@",curAppID);
        
        //RapShell = [RapShell stringByAppendingString:@" /N:APP00000000"];
        
        RapShell = [RapShell stringByAppendingString:@" /U:"];
        // NSString *userName = [connectionsSettings valueForKey:@"username"];
        NSString *username = [[[appbookmark params] copy] StringForKey:@"username"];
        //NSString *userName = @"瑞友";
        RapShell = [RapShell stringByAppendingString:username];
        RapShell = [RapShell stringByAppendingString:@" /P:"];
        NSString *pwd = [[[appbookmark params] copy] StringForKey:@"password"];
        //NSString *pwd = [connectionsSettings valueForKey:@"password"];
        pwd = [self getMD5PWD:pwd];
        NSLog(@"the pwd is %@",pwd);
        RapShell = [RapShell stringByAppendingString:pwd];
        RapShell = [RapShell stringByAppendingString:@" /T:31333037343138323632"];
        RapShell = [RapShell stringByAppendingString:@" /S:1"];  //session type
        RapShell = [RapShell stringByAppendingString:@" /D:C1D1E1F1H2"]; //MacID
        RapShell = [RapShell stringByAppendingString:@" /M:"];
        NSString *Finger = [self GetFinger];
        //NSString *adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        RapShell = [RapShell stringByAppendingString:Finger];
        //RapShell = [RapShell stringByAppendingString:@"AB1234567"];
        RapShell = [RapShell stringByAppendingString:@" /H:0"];
        RapShell = [RapShell stringByAppendingString:@" /I:0"];
        RapShell = [RapShell stringByAppendingString:@" /E:"];
        RapShell = [RapShell stringByAppendingString:WebSessionID];
        //RapShell = [RapShell stringByAddingPercentEscapesUsingEncoding:gbkEncoding];
    }
    NSString *sessionid=@"AGS:";
    WebSessionID = [sessionid stringByAppendingString:WebSessionID];
    //BOOL safemode = safegateway;
    NSLog(@"\nthe Rapshelll is %@\n",RapShell);
    NSLog(@"the username is %@\n",username);
    NSLog(@"the password is %@\n",password);
    
    NSLog(@"the safegateway is %d\n",safegateway);
    NSLog(@"the WebSessionID is %@\n",WebSessionID);
    NSLog(@"the curAppID is %@\n",curAppID);
    [delegate pagetoRdpSessionView:hostname port:hostport username:username password:password rapshell:RapShell safegateway:safegateway Sessionid:WebSessionID appid:curAppID];
    /* RDPSession* session = [[[RDPSession alloc] initWithBookmark:appbookmark hostname:hostname port:hostport username:username password:password rapshell:RapShell safegateway:safegateway Sessionid:WebSessionID appid:curAppID] autorelease];
     UIViewController* ctrl = [[[RDPSessionViewController alloc] initWithNibName:@"RDPSessionView" bundle:nil session:session desktopflag:0] autorelease];
     // [ctrl setHidesBottomBarWhenPushed:YES];
     [[self navigationController] pushViewController:ctrl animated:YES];*/
    
    /* int colordepthV   = [[connectionsSettings valueForKey:@"colordepth"] intValue];
     int screenWidthV  = [[connectionsSettings valueForKey:@"screenwidth"] intValue];
     int screenHeightV = [[connectionsSettings valueForKey:@"screenheight"] intValue];
     NSString *colordepth   = [[NSString stringWithFormat:@"%d",colordepthV] copy];
     NSString *screenWidth  = [[NSString stringWithFormat:@"%d",screenWidthV] copy];
     NSString *screenHeight = [[NSString stringWithFormat:@"%d",screenHeightV] copy];
     NSString *domain1 = [connectionsSettings valueForKey:@"domain"];
     if(appdesktop==0)
     {
     domain1=@"";
     }
     //    NSString *srvsound = @"";
     //    if ([[connectionsSettings valueForKey:@"srvsound"] boolValue]) {
     //        srvsound = @"true";
     //    }else{
     //        srvsound = @"false";
     //    }
     [Application removeAllObjects];
     NSArray *vkeys = [NSArray arrayWithObjects:@"hostname", @"port", @"domain", @"username", @"password", @"rapshell", @"screenwidth", @"screenheight", @"console", @"srvsound", @"colordepth", @"WebSessionID", @"ServerIPType", nil];
     NSArray *values = [NSArray arrayWithObjects:hostname, hostport, domain1, username, password, RapShell, screenWidth, screenHeight, @"false", @"false", colordepth, WebSessionID, ServerIPType, nil];
     NSDictionary *apps = [NSDictionary dictionaryWithObjects:values forKeys:vkeys];
     [Application setValuesForKeysWithDictionary:apps];
     //    Application = [[NSDictionary alloc]initWithObjects:values forKeys:vkeys];
     [delegate connectToServerWithConnectionSettings:Application withCellIndex:SelectedIndex ver:vernum];*/
    //[RapShell release];
    
    [gwt release];
}

- (void)setversion:(int)ver
{
    version = ver;
}
- (void)sessionWillConnect:(RDPSession*)session
{
    
}
- (NSString *)GetFinger
{
    NSString *string = [self macaddress];
    //NSString *string = @"IABCDERGH";
    NSLog(@"the string is %@",string);
    string = [self getMD5PWD:string];
    NSLog(@"the string is %@",string);
    string = [string substringToIndex:8];
    //string = [[@"I" stringByAppendingString:string] uppercaseString];
    string = [@"I" stringByAppendingString:string];
    NSLog(@"the string is %@",string);
    return string;
}
- (NSString *)GetComputer
{
    return curIP;
    
}
- (bool)GetApplication
{
    NSData *dataOfUrl;
    NSString *m=appagentpage;
    if(appdesktop==0)
    {
        NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *apphost = [[[appbookmark params] copy] StringForKey:@"hostname"];
        int intport = [[[appbookmark params] copy] intForKey:@"port"];
        NSString *port = [NSString stringWithFormat:@"%d",intport];
        NSString *username = [[[appbookmark params] copy] StringForKey:@"username"];
        NSString *myuser= [[[appbookmark params] copy] intForKey:@"hostname"];
        logmode = [[[appbookmark params] copy] intForKey:@"logmode"];
        if(logmode == 0)
        {
            pwdstring = [[[appbookmark params] copy] StringForKey:@"password"];
        }
        else
        {
            pwdstring = [[[appbookmark params] copy] StringForKey:@"password"];
            NSData *testData = [pwdstring dataUsingEncoding: NSUTF8StringEncoding];
            Byte *testByte = (Byte *)[testData bytes];
            printf("test byte is");
            [pwdstring release];
            pwdstring=[[NSString alloc] init];
            for(int i=0;i<[testData length];i++)
            {
                NSString *stringHex = [NSString stringWithFormat:@"%x",testByte[i]];
                NSLog(@"the stringHex is %@",stringHex);
                pwdstring = [pwdstring stringByAppendingString:stringHex];
                NSLog(@"the pwdstring is %@",pwdstring);
//                printf("%d",testByte[i]);
            }
        }
        NSString *domain = [[[appbookmark params] copy] StringForKey:@"domain"];
        NSString *url=@"http://";
        NSString *urlver=@"http://";
        urlver = [urlver stringByAppendingString:apphost];
        urlver = [urlver stringByAppendingString:@":"];
        urlver = [urlver stringByAppendingString:port];
        urlver = [urlver stringByAppendingString:@"/RAPAGENT.xgi?CMD=GetClientExever&Language=ZH-CN"];
        urlver = [urlver stringByAddingPercentEscapesUsingEncoding:gbkEncoding];
        NSURL *Getverurl = [NSURL URLWithString:urlver];
        NSURLRequest *Verrequest = [NSURLRequest requestWithURL:Getverurl];
        NSData *VerdataOfUrl = [NSURLConnection sendSynchronousRequest:Verrequest returningResponse:nil error:nil];
        INIParser *verparser = [[[INIParser alloc] init] autorelease];
        int err = [verparser parsedata: VerdataOfUrl];
        if (err != INIP_ERROR_NONE) return false;
        NSString *ver = [verparser get:@"Version" section:@"result"];
        ver = [ver substringToIndex:1];
        vernum = [ver intValue];
        url = [url stringByAppendingString:apphost];
        url = [url stringByAppendingString:@":"];
        url = [url stringByAppendingString:port];
        //url = [url stringByAppendingString:@"/RAPAGENT.xgi?CMD=GETApplication&Language=ZH-CN&User="];
        url = [url stringByAppendingString:@"/RAPAGENT.xgi?CMD=GETApplication&Language=ZH-CN&User="];
        url = [url stringByAppendingString:username];
        url = [url stringByAppendingString:@"&PWD="];
        if(logmode==0)
        {
            url = [url stringByAppendingString:[self getMD5PWD:pwdstring]];
        }
        else
        {
            url=[url stringByAppendingString:pwdstring];
        }
        //url = [url stringByAppendingString:pwd];
        //url = [url stringByAppendingString:@"&Domain=ry"];
        if(logmode==0)
        {
            url = [url stringByAppendingString:@"&Auth_Flag=&AuthType=0"];
        }
        else
        {
            url = [url stringByAppendingString:@"&Auth_Flag=&AuthType=5"];
        }
        url = [url stringByAppendingString:@"&AppID="];
        url = [url stringByAppendingString:curAppID];
        url = [url stringByAppendingString:@"&Computer="];
//        url = [url stringByAppendingString:curIP];  //modify wlp [self GetComputer]
        url = [url stringByAppendingString:@"IOS"];
        url = [url stringByAppendingString:@"&Finger="];
        url = [url stringByAppendingString:[self GetFinger]];
        NSLog(@"GetApplication:%@", url);
        //url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        url = [url stringByAddingPercentEscapesUsingEncoding:gbkEncoding];
        
        //NSURL *reURL = [[NSURL alloc] initWithString:url];
        //NSData *dataOfUrl = [[NSData alloc] initWithContentsOfURL:reURL];
        NSLog(@"the url is %@",url);
        NSURL *reURL = [NSURL URLWithString:url];
        NSURLRequest *request = [NSURLRequest requestWithURL:reURL];
        dataOfUrl = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
    }
    else if(appdesktop==1)
    {
        NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *url1=@"http://";
        NSString *urlver1=@"http://";
        /*NSString *host1     = [connectionsSettings valueForKey:@"hostname"];
         NSString *userName1 = [connectionsSettings valueForKey:@"username"];
         NSString *pwd1      = [connectionsSettings valueForKey:@"password"];
         //NSString *pwd      = [KeychainServices retrieveGenericPasswordForConnectionSettings:connectionsSettings];
         NSString *port1     = [connectionsSettings valueForKey:@"port"];
         NSString *domain1   = [connectionsSettings valueForKey:@"domain"];
         */
        NSString *host1 = [[[appbookmark params] copy] StringForKey:@"hostname"];
        int intport = [[[appbookmark params] copy] intForKey:@"port"];
        NSString *port1 = [NSString stringWithFormat:@"%d",intport];
        NSString *userName1 = [[[appbookmark params] copy] StringForKey:@"username"];
        NSString *myuser= [[[appbookmark params] copy] intForKey:@"hostname"];
        NSString *pwd1 = [[[appbookmark params] copy] StringForKey:@"password"];
        //NSString *pwd = [[[bookmark params] copy] intForKey:@"password"];
        NSString *domain1 = [[[appbookmark params] copy] StringForKey:@"domain"];
        domain1 = @"ry.com";
        vernum = 6;
        //NSString *url=@"http://";
        url1 = [url1 stringByAppendingString:host1];
        url1 = [url1 stringByAppendingString:@":"];
        url1 = [url1 stringByAppendingString:port1];
        //url = [url stringByAppendingString:@"/RAPAGENT.xgi?CMD=GETApplication&Language=ZH-CN&User="];
        //url1 = [url1 stringByAppendingString:@"/"];
        //url1 = [url1 stringByAppendingString:appagentpage];
        url1 = [url1 stringByAppendingString:@"/AgentPage.aspx?CMD=GETApplication&Language=ZH-CN&User="];
        url1 = [url1 stringByAppendingString:userName1];
        url1 = [url1 stringByAppendingString:@"&PWD="];
        url1 = [url1 stringByAppendingString:pwd1];
        url1 = [url1 stringByAppendingString:@"&Domain="];
        url1 = [url1 stringByAppendingString:domain1];
        //url = [url stringByAppendingString:pwd];
        //url = [url stringByAppendingString:@"&Domain=ry"];
        url1 = [url1 stringByAppendingString:@"&Auth_Flag=&AuthType=0"];
        url1 = [url1 stringByAppendingString:@"&AppID="];
        url1 = [url1 stringByAppendingString:curAppID];
        int index = [SelectedIndex indexAtPosition:([SelectedIndex length] - 1)];
        DataModel *app = [Applist objectAtIndex:index];
        url1 = @"http://";
        url1 = [url1 stringByAppendingString:app.rap];
        url1 = [url1 stringByAppendingString:@"&Computer="];
        //url = [url stringByAppendingString:curIP];  //modify wlp [self GetComputer]
        url1 = [url1 stringByAppendingString:@"IOS"];
        url1 = [url1 stringByAppendingString:@"&Finger="];
        url1 = [url1 stringByAppendingString:[self GetFinger]];
        
        //url1 = [
        //url1 = [url1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        url1 = [url1 stringByAddingPercentEscapesUsingEncoding:gbkEncoding];
        
        //NSURL *reURL = [[NSURL alloc] initWithString:url];
        //NSData *dataOfUrl = [[NSData alloc] initWithContentsOfURL:reURL];
        NSURL *reURL1 = [NSURL URLWithString:url1];
        NSURLRequest *request = [NSURLRequest requestWithURL:reURL1];
        dataOfUrl = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    }
    
    if (dataOfUrl == nil){
        //[dataOfUrl release];
        //[reURL release];
        return false;
    }
    else
    {
        [self configSelectedApp:dataOfUrl];
        
        //[reURL release];
        //[dataOfUrl release];
        //        return true;
    }
    return true;
}
/////////////////////////////////////////////////////End////////////////////////////////////////////////////////////////

- (void)setAppdata:(NSData *)data
{
    //[appdata autorelease];
    //appdata = [data retain];
    appdata = [[NSData alloc] initWithData:data];
    [self appListMain];
}
- (void)appListMain
{
    [self loadDataToCell:YES parentDir:@"AppList_NULL"];
    showTip=NO;
    [[self tableView] reloadData];
}
- (void)setConnectionsSettings:(NSDictionary *)value
{
    [connectionsSettings autorelease];
    connectionsSettings = [value retain];
}

- (void)setdesktopflag:(int)desktopflag
{
    appdesktop = desktopflag;
}
- (void)setAgentpage:(NSString *)agentpage
{
    appagentpage = agentpage;
}


#pragma mark - AppListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isdesktop:(int)desktop bookmark:(ComputerBookmark*)bookmark
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    //safegateway = FALSE;
    appdata1 = [[NSMutableData alloc] init];
    if (self) {
        CanSelectApp = TRUE;
        appbookmark = [[[ComputerBookmark alloc] initWithBaseDefaultParameters] autorelease];
        appbookmark = bookmark;
        showTip = NO;
        Applist = [[NSMutableArray alloc] initWithCapacity:0];
        DirList = [[NSMutableArray alloc] initWithCapacity:0];
        Application = [[NSMutableDictionary alloc] initWithCapacity:0];
        appdesktop = 0;
    }
    //Setup the navigation item
    if(desktop==0)
    {
        self.navigationItem.title = [[NSBundle mainBundle] localizedStringForKey:@"applistTitle" value:@"Applications List" table:@"Localizable"];
    }
    else{
        self.navigationItem.title = [[NSBundle mainBundle] localizedStringForKey:@"desktopTitle" value:@"Applications List" table:@"Localizable"];
    }
    
    UIBarButtonItem *backBtn = [[[UIBarButtonItem alloc] initWithTitle:[[NSBundle mainBundle] localizedStringForKey:@"backFavorite" value:@"Back Favorite" table:nil] style:UIBarButtonItemStylePlain target:self action:@selector(backFavorite:)] autorelease];
    self.navigationItem.leftBarButtonItem = backBtn;
    
    NSURL *ipUrl = [[NSURL alloc] initWithString:@"http://automation.whatismyip.com/n09230945.asp"];
    curIP = [[NSString alloc] initWithContentsOfURL:ipUrl];
    if (!curIP)
    {
        curIP = @"";
    }
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
    [ipUrl release];
    
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;//隐藏为YES，显示为NO
}
- (void)dealloc
{
    [curIP release];
    //if (appdata) [appdata release];
    if (appdata1) [appdata1 release];
    if (connectionsSettings) [connectionsSettings release];
    [Applist release];
    [DirList release];
    [Application release];
    [SelectedIndex autorelease];
    //    if (Applist != nil) [Applist release];
    //    if (DirList != nil) [DirList release];
    //    if (Application != nil) [Application release];
    //return [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
//view entry point
- (void)viewDidLoad
{
    [super viewDidLoad];
    powerflag = 0;
    timerflag = 0;
    //    if(appdesktop==0)
    //     {
    //     self.navigationItem.title = [[NSBundle mainBundle] localizedStringForKey:@"applistTitle" value:@"Applications List" table:@"Localizable"];
    //     }
    //     else{
    //     self.navigationItem.title = [[NSBundle mainBundle] localizedStringForKey:@"desktopTitle" value:@"Applications List" table:@"Localizable"];
    //     }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount;
    if (DirList == nil)
        rowCount = 0;
    else
        rowCount = [DirList count];
    
    if (Applist == nil)
        rowCount += 0;
    else
        rowCount += [Applist count];
    NSLog(@"\nrowCount = %d\n", rowCount);
    return  rowCount;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //[appdata appendData:data];
    //NSData *appdata1;
    //NSMutableData *appdata1;
    [appdata1 appendData:data];
    
    /*INIParser *parser = [[[INIParser alloc] init] autorelease];
     int err = [parser parsedata: appdata];
     if (err != INIP_ERROR_NONE)
     {
     //[parser release];
     return;
     }
     NSString *result = [parser get:@"VirtulType" section:@"info"];
     AgentPage = [parser get:@"AgentPage" section:@"info"];
     if([result isEqualToString:@""])
     {
     
     }
     if([result isEqualToString:@"Desktop"])
     {
     desktopflag=1;
     //NSLog(@"pwd=%@", pwd);
     //pwd = [self getMD5PWD:pwd];
     [self httpGetDesktop:host port:port userName:userName pwd:pwd];
     }
     else
     {
     [self httpGet:host port:port userName:userName pwd:pwd];
     }*/
    /*
     if (appdata)
     {
     const char *old=[appdata bytes];
     const char *new=[data bytes];
     int oldlen=[appdata length];
     int newlen=[data length];
     char *rec=malloc(oldlen + newlen);
     memcpy(rec, old, oldlen);
     memcpy(&rec[oldlen], new, newlen);
     [appdata release];
     appdata = [[NSData alloc]initWithBytes:rec length:(oldlen +newlen)];
     free(rec);
     }
     else
     {
     appdata = data;
     [appdata retain];
     }
     */
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //     //[self connectionRequestDidSucceed];
    //     [self ErrorMessageBox:[[NSBundle mainBundle] localizedStringForKey:@"AlertTitle" value:@"Error Infomation" table:nil]
    //     messageStr:[[NSBundle mainBundle] localizedStringForKey:@"FavMessage" value:@"Can not connect server!" table:nil]
    //     btnTitleStr:[[NSBundle mainBundle] localizedStringForKey:@"OkBtnCaption" value:@"OK" table:nil]
    //     tag:0];
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection{
    //[self connectionRequestDidSucceed];
    //[self configSelectedApp:check];
    INIParser *parser = [[[INIParser alloc] init] autorelease];
    if(powerflag == 1)
    {
        NSString *check = [[[NSString alloc] initWithData:appdata1 encoding:NSASCIIStringEncoding] autorelease];
        //NSString *check = [[[NSString alloc] initWithData:appdata encoding:gbkEncoding] autorelease];
        
        NSLog(@"check=%@",check);
        
        if(powercmd == 2)
        {
            startupflag = 1;
            //[NSThread detachNewThreadSelector:@selector(getappdata) toTarget:self withObject:nil];}
            [self getappdata];
        }
        else
        {
            connectionTimer=[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
            powerflag = 0;
        }
    }
    
    //    if (appdata != nil)
    //    {
    //        [appdata release];
    //        appdata = nil;
    //    }
}

- (void) startup
{
    NSData *dataOfUrl;
    powerflag = 1;
    powercmd = 2;
    DataModel *appInfo = [Applist objectAtIndex:SelectedIndex.row];
    //int serverid = [appInfo.serverid intValue];
    showTip = YES;
    [self.tableView reloadData];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:SelectedIndex];
    
    UIImageView *icoView = (UIImageView *)[cell viewWithTag:2];
    
    //给当前所选的Table Cell添加显示状态信息层；
    statuView = [[[UIView alloc] initWithFrame:CGRectMake(icoView.frame.origin.x, icoView.frame.size.height+5, cell.frame.size.width, 44)] autorelease];
    UIActivityIndicatorView *gear = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    gear.frame = CGRectMake(0, 11, 22.0, 22.0);
    [gear startAnimating];
    [statuView addSubview:gear];
    
    UILabel *statuLabel = [[[UILabel alloc] initWithFrame:CGRectMake(25, 11, statuView.frame.size.width - 40, 22)] autorelease];
    [statuLabel setTag:4];
    statuLabel.text = [[NSBundle mainBundle] localizedStringForKey:@"startup" value:@"正在重启请稍候" table:nil];
    [statuLabel setFont:[UIFont systemFontOfSize:14]];
    statuLabel.backgroundColor = [UIColor clearColor];
    [statuView addSubview:statuLabel];
    [statuView removeFromSuperview];
    [cell.contentView addSubview:statuView];
    int index = [SelectedIndex indexAtPosition:([SelectedIndex length] - 1)];
    DataModel *app = [Applist objectAtIndex:index];
    curAppID = app.appId;
    //[self disableInterface];
    NSString *desktopid=[appInfo.appId substringFromIndex:3];
    NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *url1=@"http://";
    //NSString *urlver1=@"http://";
    NSString *host1     = [[[appbookmark params] copy] StringForKey:@"hostname"];
    NSString *userName1 = [[[appbookmark params] copy] StringForKey:@"username"];
    NSString *pwd1      = [[[appbookmark params] copy] StringForKey:@"password"];
    //NSString *pwd      = [KeychainServices retrieveGenericPasswordForConnectionSettings:connectionsSettings];
    NSString *port1     = [NSString stringWithFormat:@"%d",[[[appbookmark params] copy] intForKey:@"port"]];
    NSString *domain1   = [[[appbookmark params] copy] StringForKey:@"domain"];
    //NSString *url=@"http://";
    url1 = [url1 stringByAppendingString:host1];
    url1 = [url1 stringByAppendingString:@":"];
    url1 = [url1 stringByAppendingString:port1];
    //url = [url stringByAppendingString:@"/RAPAGENT.xgi?CMD=GETApplication&Language=ZH-CN&User="];
    url1 = [url1 stringByAppendingString:@"/"];
    url1 = [url1 stringByAppendingString:@"AgentPage.aspx"];
    url1 = [url1 stringByAppendingString:@"?CMD=PowerOperate&Language=ZH-CN&User="];
    url1 = [url1 stringByAppendingString:userName1];
    url1 = [url1 stringByAppendingString:@"&PWD="];
    url1 = [url1 stringByAppendingString:pwd1];
    url1 = [url1 stringByAppendingString:@"&Domain="];
    if (domain1) {
        url1 = [url1 stringByAppendingString:domain1];
    }
    
    //url = [url stringByAppendingString:pwd];
    //url = [url stringByAppendingString:@"&Domain=ry"];
    url1 = [url1 stringByAppendingString:@"&Auth_Flag=&AuthType=0"];
    url1 = [url1 stringByAppendingString:@"&SvrId="];
    url1 = [url1 stringByAppendingString:appInfo.serverid];
    url1 = [url1 stringByAppendingString:@"&DesktopId="];
    url1 = [url1 stringByAppendingString:desktopid];  //modify wlp [self GetComputer]
    url1 = [url1 stringByAppendingString:@"&Operation=3"];
    NSLog(@"GetApplication:%@", url1);
    //url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    url1 = [url1 stringByAddingPercentEscapesUsingEncoding:gbkEncoding];
    
    //NSURL *reURL = [[NSURL alloc] initWithString:url];
    //NSData *dataOfUrl = [[NSData alloc] initWithContentsOfURL:reURL];
    NSURL *reURL1 = [NSURL URLWithString:url1];
    NSURLRequest *request = [NSURLRequest requestWithURL:reURL1];
    urlconn = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    
}
- (void) powerdown
{
    NSData *dataOfUrl;
    powercmd = 1;
    powerflag = 1;
    DataModel *appInfo = [Applist objectAtIndex:SelectedIndex.row];
    //int serverid = [appInfo.serverid intValue];
    showTip = YES;
    [self.tableView reloadData];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:SelectedIndex];
    
    UIImageView *icoView = (UIImageView *)[cell viewWithTag:2];
    
    //给当前所选的Table Cell添加显示状态信息层；
    statuView = [[[UIView alloc] initWithFrame:CGRectMake(icoView.frame.origin.x, icoView.frame.size.height+5, cell.frame.size.width, 44)] autorelease];
    UIActivityIndicatorView *gear = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    gear.frame = CGRectMake(0, 11, 22.0, 22.0);
    [gear startAnimating];
    [statuView addSubview:gear];
    
    UILabel *statuLabel = [[[UILabel alloc] initWithFrame:CGRectMake(25, 11, statuView.frame.size.width - 40, 22)] autorelease];
    [statuLabel setTag:4];
    statuLabel.text = [[NSBundle mainBundle] localizedStringForKey:@"poweroff" value:@"正在关机请稍候。。。" table:nil];
    [statuLabel setFont:[UIFont systemFontOfSize:14]];
    statuLabel.backgroundColor = [UIColor clearColor];
    [statuView addSubview:statuLabel];
    [statuView removeFromSuperview];
    [cell.contentView addSubview:statuView];
    int index = [SelectedIndex indexAtPosition:([SelectedIndex length] - 1)];
    DataModel *app = [Applist objectAtIndex:index];
    curAppID = app.appId;
    //[self disableInterface];
    NSString *desktopid=[appInfo.appId substringFromIndex:3];
    appagentpage = @"AgentPage.aspx";
    NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *url1=@"http://";
    NSString *urlver1=@"http://";
    NSString *host1     = [[[appbookmark params] copy] StringForKey:@"hostname"];
    NSString *userName1 = [[[appbookmark params] copy] StringForKey:@"username"];
    NSString *pwd1      = [[[appbookmark params] copy] StringForKey:@"password"];
    //NSString *pwd      = [KeychainServices retrieveGenericPasswordForConnectionSettings:connectionsSettings];
    NSString *port1     = [NSString stringWithFormat:@"%d",[[[appbookmark params] copy] intForKey:@"port"]];
    NSString *domain1   = [[[appbookmark params] copy] StringForKey:@"domain"];
    //NSString *url=@"http://";
    url1 = [url1 stringByAppendingString:host1];
    url1 = [url1 stringByAppendingString:@":"];
    url1 = [url1 stringByAppendingString:port1];
    //url = [url stringByAppendingString:@"/RAPAGENT.xgi?CMD=GETApplication&Language=ZH-CN&User="];
    url1 = [url1 stringByAppendingString:@"/"];
    url1 = [url1 stringByAppendingString:appagentpage];
    url1 = [url1 stringByAppendingString:@"?CMD=PowerOperate&Language=ZH-CN&User="];
    url1 = [url1 stringByAppendingString:userName1];
    url1 = [url1 stringByAppendingString:@"&PWD="];
    url1 = [url1 stringByAppendingString:pwd1];
    url1 = [url1 stringByAppendingString:@"&Domain="];
    url1 = [url1 stringByAppendingString:domain1];
    url1 = [url1 stringByAppendingString:@"&Auth_Flag=&AuthType=0"];
    url1 = [url1 stringByAppendingString:@"&SvrId="];
    url1 = [url1 stringByAppendingString:appInfo.serverid];
    url1 = [url1 stringByAppendingString:@"&DesktopId="];
    url1 = [url1 stringByAppendingString:desktopid];  //modify wlp [self GetComputer]
    url1 = [url1 stringByAppendingString:@"&Operation=1"];
    NSLog(@"GetApplication:%@", url1);
    //url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    url1 = [url1 stringByAddingPercentEscapesUsingEncoding:gbkEncoding];
    
    //NSURL *reURL = [[NSURL alloc] initWithString:url];
    //NSData *dataOfUrl = [[NSData alloc] initWithContentsOfURL:reURL];
    NSURL *reURL1 = [NSURL URLWithString:url1];
    NSURLRequest *request = [NSURLRequest requestWithURL:reURL1];
    urlconn = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    /*dataOfUrl = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
     if (dataOfUrl == nil){
     //[dataOfUrl release];
     //[reURL release];
     return false;
     }
     else{
     
     connectionTimer=[NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
     }*/
    
}

- (void) registertimer
{
    //timer对象
    
}
//- (void) handleTimer: (NSTimer *) timer

- (void) timerFired:(NSTimer *) timer
{
    [timer invalidate];
    //[reURL release];
    //[request release];
    //appdata = dataOfUrl;
    
    //}
    //[reURL release];
    //[request release];*/
    [NSThread detachNewThreadSelector:@selector(getappdata) toTarget:self withObject:nil];}
- (void) gotoreload
{
    if((powercmd == 0)||(powercmd == 2))
    {
        if([powerstate isEqualToString:@"2"])
        {
            showTip = NO;
            [statuView removeFromSuperview];
            [self.tableView reloadData];
        }
        else
        {
            connectionTimer=[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
        }
    }
    if(powercmd == 1)
    {
        if([powerstate isEqualToString:@"1"])
        {
            showTip = NO;
            [statuView removeFromSuperview];
            [self.tableView reloadData];
            
        }
        else
        {
            connectionTimer=[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
        }
    }
    
}
-(void) getappdata
{
    // NSData *dataOfUrl;
    NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *host1     = [[[appbookmark params] copy] StringForKey:@"hostname"];
    NSString *userName1 = [[[appbookmark params] copy] StringForKey:@"username"];
    logmode = [[[appbookmark params] copy] intForKey:@"logmode"];
    //if(logmode  == 0)
    //{
    NSString *pwd1      = [[[appbookmark params] copy] StringForKey:@"password"];
    
    //NSString *pwd      = [KeychainServices retrieveGenericPasswordForConnectionSettings:connectionsSettings];
    
    NSString *port1     = [NSString stringWithFormat:@"%d",[[[appbookmark params] copy] intForKey:@"port"]];
    NSString *domain1   = [[[appbookmark params] copy] StringForKey:@"domain"];
    NSString *url = @"http://";
    timerflag = 1;
    url = [url stringByAppendingString:host1];
    url = [url stringByAppendingString:@":"];
    url = [url stringByAppendingString:port1];
    url = [url stringByAppendingString:@"/"];
    url = [url stringByAppendingString:@"AgentPage.aspx"];
    url = [url stringByAppendingString:@"?CMD=GETAppList&Language=ZH-CN&User="];
    url = [url stringByAppendingString:userName1];
    url = [url stringByAppendingString:@"&PWD="];
    url = [url stringByAppendingString:pwd1];
    url = [url stringByAppendingString:@"&Domain="];
    if (domain1) {
        url = [url stringByAppendingString:domain1];
    }
    url = [url stringByAppendingString:@"&AuthFlag=&AuthType="];
    url = [url stringByAppendingString:@"0"];
    url = [url stringByAppendingString:@"&Policy=6,n,y,n,n"];
    url = [url stringByAppendingString:@"&OS=iOS"];
    //    [appdata release];
    //    appdata = nil;
    //start reading file data
    //url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    url = [url stringByAddingPercentEscapesUsingEncoding:gbkEncoding];
    NSLog(@"the url is %@",url);
    //NSURL *reURL = [[NSURL alloc] initWithString:url];
    //NSData *dataOfUrl = [[NSData alloc] initWithContentsOfURL:reURL];
    NSURL *reURL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:reURL];
    //urlconn = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    dataOfUrl = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //[appdata release];
    appdata = dataOfUrl;
    [self loadDataToCellPower:YES parentDir:@"AppList_NULL"];
    if(startupflag == 1)
    {
        startupflag = 0;
        //showTip = NO;
        //[statuView removeFromSuperview];
        [self.tableView reloadData];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:SelectedIndex];
        
        UIImageView *icoView = (UIImageView *)[cell viewWithTag:2];
        
        //给当前所选的Table Cell添加显示状态信息层；
        statuView = [[[UIView alloc] initWithFrame:CGRectMake(icoView.frame.origin.x, icoView.frame.size.height+5, cell.frame.size.width, 44)] autorelease];
        UIActivityIndicatorView *gear = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
        gear.frame = CGRectMake(0, 11, 22.0, 22.0);
        [gear startAnimating];
        [statuView addSubview:gear];
        
        UILabel *statuLabel = [[[UILabel alloc] initWithFrame:CGRectMake(25, 11, statuView.frame.size.width - 40, 22)] autorelease];
        [statuLabel setTag:4];
        statuLabel.text = [[NSBundle mainBundle] localizedStringForKey:@"startup" value:@"正在重启请稍候" table:nil];
        [statuLabel setFont:[UIFont systemFontOfSize:14]];
        statuLabel.backgroundColor = [UIColor clearColor];
        [statuView addSubview:statuLabel];
        [statuView removeFromSuperview];
        [cell.contentView addSubview:statuView];
        connectionTimer=[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
    }
    else
    {
        [self performSelectorOnMainThread:@selector(gotoreload) withObject:nil waitUntilDone:YES];
    }
    return ;
}
- (void) powerup
{
    NSData *dataOfUrl;
    powercmd = 0;
    powerflag = 1;
    DataModel *appInfo = [Applist objectAtIndex:SelectedIndex.row];
    //int serverid = [appInfo.serverid intValue];
    showTip = YES;
    [self.tableView reloadData];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:SelectedIndex];
    
    UIImageView *icoView = (UIImageView *)[cell viewWithTag:2];
    
    //给当前所选的Table Cell添加显示状态信息层；
    statuView = [[[UIView alloc] initWithFrame:CGRectMake(icoView.frame.origin.x, icoView.frame.size.height+5, cell.frame.size.width, 44)] autorelease];
    UIActivityIndicatorView *gear = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    gear.frame = CGRectMake(0, 11, 22.0, 22.0);
    [gear startAnimating];
    [statuView addSubview:gear];
    
    UILabel *statuLabel = [[[UILabel alloc] initWithFrame:CGRectMake(25, 11, statuView.frame.size.width - 40, 22)] autorelease];
    [statuLabel setTag:4];
    statuLabel.text = [[NSBundle mainBundle] localizedStringForKey:@"poweron" value:@"正在开机请稍候。。。" table:nil];
    [statuLabel setFont:[UIFont systemFontOfSize:14]];
    statuLabel.backgroundColor = [UIColor clearColor];
    [statuView addSubview:statuLabel];
    [statuView removeFromSuperview];
    [cell.contentView addSubview:statuView];
    int index = [SelectedIndex indexAtPosition:([SelectedIndex length] - 1)];
    DataModel *app = [Applist objectAtIndex:index];
    curAppID = app.appId;
    appagentpage = @"AgentPage.aspx";
    NSString *desktopid=[appInfo.appId substringFromIndex:3];
    NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *url1=@"http://";
    NSString *urlver1=@"http://";
    NSString *host1     = [[[appbookmark params] copy] StringForKey:@"hostname"];
    NSString *userName1 = [[[appbookmark params] copy] StringForKey:@"username"];
    NSString *pwd1      = [[[appbookmark params] copy] StringForKey:@"password"];
    //NSString *pwd      = [KeychainServices retrieveGenericPasswordForConnectionSettings:connectionsSettings];
    NSString *port1     = [NSString stringWithFormat:@"%d",[[[appbookmark params] copy] intForKey:@"port"]];
    NSString *domain1   = [[[appbookmark params] copy] StringForKey:@"domain"];
    //NSString *url=@"http://";
    url1 = [url1 stringByAppendingString:host1];
    url1 = [url1 stringByAppendingString:@":"];
    url1 = [url1 stringByAppendingString:port1];
    //url = [url stringByAppendingString:@"/RAPAGENT.xgi?CMD=GETApplication&Language=ZH-CN&User="];
    url1 = [url1 stringByAppendingString:@"/"];
    url1 = [url1 stringByAppendingString:appagentpage];
    url1 = [url1 stringByAppendingString:@"?CMD=PowerOperate&Language=ZH-CN&User="];
    url1 = [url1 stringByAppendingString:userName1];
    url1 = [url1 stringByAppendingString:@"&PWD="];
    url1 = [url1 stringByAppendingString:pwd1];
    url1 = [url1 stringByAppendingString:@"&Domain="];
    url1 = [url1 stringByAppendingString:domain1];
    //url = [url stringByAppendingString:pwd];
    //url = [url stringByAppendingString:@"&Domain=ry"];
    url1 = [url1 stringByAppendingString:@"&Auth_Flag=&AuthType=0"];
    url1 = [url1 stringByAppendingString:@"&SvrId="];
    url1 = [url1 stringByAppendingString:appInfo.serverid];
    url1 = [url1 stringByAppendingString:@"&DesktopId="];
    url1 = [url1 stringByAppendingString:desktopid];  //modify wlp [self GetComputer]
    url1 = [url1 stringByAppendingString:@"&Operation=2"];
    NSLog(@"GetApplication:%@", url1);
    //url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    url1 = [url1 stringByAddingPercentEscapesUsingEncoding:gbkEncoding];
    
    //NSURL *reURL = [[NSURL alloc] initWithString:url];
    //NSData *dataOfUrl = [[NSData alloc] initWithContentsOfURL:reURL];
    NSURL *reURL1 = [NSURL URLWithString:url1];
    NSURLRequest *request = [NSURLRequest requestWithURL:reURL1];
    urlconn = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    /*dataOfUrl = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
     NSLog(@"the result is %@",dataOfUrl);
     if (dataOfUrl == nil){
     return false;
     }
     else{
     
     [self disableInterface];
     connectionTimer=[NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
     }*/
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        [[NSBundle mainBundle] loadNibNamed:@"AppCell" owner:self options:NULL];
        cell = AppCell;
        
        if (indexPath.row < appRootCount)
        {
            DataModel *appInfo = [Applist objectAtIndex:indexPath.row];
            UILabel *appName = (UILabel *)[cell viewWithTag:1];
            appName.text = appInfo.appName;
            
            UIImageView *appImg = (UIImageView *)[cell viewWithTag:2];
            UIImage *img = [[UIImage alloc] initWithData:appInfo.icoData];
            appImg.image = img;
            [img release];
        }
        else
        {
            DataModel *appInfo = [DirList objectAtIndex:indexPath.row-appRootCount];
            UILabel *appName = (UILabel *)[cell viewWithTag:1];
            appName.text = appInfo.appName;
            
            UIImageView *appImg = (UIImageView *)[cell viewWithTag:2];
            UIImage *img = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"catalog" ofType:@"png"]];
            appImg.image = img;
            [img release];
        }
    }
    return cell;
}

- (void) didUserCancelConection{
    //终止rdp连接
    [delegate cancelLastConnectRequest];
    //恢复界面
    [self enableInterface];
}

- (void) DidRunApp{
    //showTip = YES;
    [self.tableView reloadData];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:SelectedIndex];
    UIButton *appButton = (UIButton *)[cell viewWithTag:3];
    UIImage *appImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"stop2" ofType:@"png"]];
    appButton.imageView.image = appImage;
    [appButton addTarget:self action:@selector(didUserCancelConection) forControlEvents:UIControlEventTouchDown];
    appButton.hidden = NO;
    //    UIImageView *icoView = (UIImageView *)[cell viewWithTag:2];
    
    //给当前所选的Table Cell添加显示状态信息层；
    /*statuView = [[[UIView alloc] initWithFrame:CGRectMake(icoView.frame.origin.x, icoView.frame.size.height+5, cell.frame.size.width, 44)] autorelease];
     UIActivityIndicatorView *gear = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
     gear.frame = CGRectMake(0, 11, 22.0, 22.0);
     [gear startAnimating];
     [statuView addSubview:gear];
     
     UILabel *statuLabel = [[[UILabel alloc] initWithFrame:CGRectMake(25, 11, statuView.frame.size.width - 40, 22)] autorelease];
     [statuLabel setTag:4];
     statuLabel.text = [[NSBundle mainBundle] localizedStringForKey:@"ReadyForConn" value:@"Ready for connecting" table:nil];
     [statuLabel setFont:[UIFont systemFontOfSize:14]];
     statuLabel.backgroundColor = [UIColor clearColor];
     [statuView addSubview:statuLabel];
     [statuView removeFromSuperview];
     [cell.contentView addSubview:statuView];*/
    int index = [SelectedIndex indexAtPosition:([SelectedIndex length] - 1)];
    DataModel *app = [Applist objectAtIndex:index];
    curAppID = app.appId;
    //[self disableInterface];
    //获取rap文件
    if (![self GetApplication]){
        //获取rap文件失败
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[NSBundle mainBundle] localizedStringForKey:@"AlertTitle" value:@"Error Informaion" table:nil] message:[[NSBundle mainBundle] localizedStringForKey:@"AppMessage" value:@"Get Applist Error" table:nil] delegate:self cancelButtonTitle:[[NSBundle mainBundle] localizedStringForKey:@"OKBtnCaption" value:@"OK" table:nil]  otherButtonTitles: nil];
        [alert setTag:2];
        [alert show];
        [alert release];
        [self enableInterface];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (([indexPath indexAtPosition:([indexPath length] - 1)] == [SelectedIndex indexAtPosition:([SelectedIndex length] - 1)]) && showTip)
        return 100.0;
    return tableView.rowHeight;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(appdesktop==0)
    {
        if (indexPath.row >= appRootCount)
        {
            DataModel *data = [DirList objectAtIndex:indexPath.row-appRootCount];
            [self loadDataToCell:NO parentDir:data.appName];
            [[self tableView] reloadData];
            return;
        }
        if (CanSelectApp == FALSE) return;
        if (SelectedIndex)
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:SelectedIndex];
            UIButton *appButton = (UIButton *)[cell viewWithTag:3];
            appButton.hidden = TRUE;
        }
        [SelectedIndex autorelease];
        SelectedIndex = [indexPath retain];
        
        /* UITableViewCell *cell = [tableView cellForRowAtIndexPath:SelectedIndex];
         UIButton *appButton = (UIButton *)[cell viewWithTag:3];
         UIImage *appImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"play2" ofType:@"png"]];
         appButton.imageView.image = appImage;
         [appButton addTarget:self action:@selector(DidRunApp) forControlEvents:UIControlEventTouchDown];
         appButton.hidden = NO;*/
        [self DidRunApp];
    }
    else{
        if(showTip==NO)
        {
            showTip = YES;
            
            if (indexPath.row >= appRootCount)
            {
                DataModel *data = [DirList objectAtIndex:indexPath.row-appRootCount];
                [self loadDataToCell:NO parentDir:data.appName];
                [[self tableView] reloadData];
                return;
            }
            if (CanSelectApp == FALSE) return;
            if (SelectedIndex)
            {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:SelectedIndex];
                UIButton *appButton = (UIButton *)[cell viewWithTag:3];
                appButton.hidden = TRUE;
            }
            [SelectedIndex autorelease];
            SelectedIndex = [indexPath retain];
            [self.tableView reloadData];
            /*UITableViewCell *cell = [tableView cellForRowAtIndexPath:SelectedIndex];
             UIButton *appButton = (UIButton *)[cell viewWithTag:3];
             UIImage *appImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"play2" ofType:@"png"]];
             appButton.imageView.image = appImage;
             [appButton addTarget:self action:@selector(DidRunApp) forControlEvents:UIControlEventTouchDown];
             appButton.hidden = NO;*/
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:SelectedIndex];
            UIImageView *icoView = (UIImageView *)[cell viewWithTag:2];
            
            //给当前所选的Table Cell添加显示状态信息层；
            statuView = [[[UIView alloc] initWithFrame:CGRectMake(icoView.frame.origin.x, icoView.frame.size.height+5, cell.frame.size.width, 44)] autorelease];
            //[statuView setBackgroundColor:[UIColor blueColor]];
            UIView *lablelview = [[[UIView alloc] initWithFrame:CGRectMake(statuView.frame.origin.x, icoView.frame.size.height+45, cell.frame.size.width, 88)] autorelease];
            /*UIActivityIndicatorView *gear = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
             gear.frame = CGRectMake(0, 11, 22.0, 22.0);
             [gear startAnimating];
             [statuView addSubview:gear];*/
            
            /*UILabel *statuLabel = [[[UILabel alloc] initWithFrame:CGRectMake(25, 11, statuView.frame.size.width - 40, 22)] autorelease];
             [statuLabel setTag:4];
             statuLabel.text = [[NSBundle mainBundle] localizedStringForKey:@"ReadyForConn" value:@"Ready for connecting" table:nil];
             [statuLabel setFont:[UIFont systemFontOfSize:14]];
             statuLabel.backgroundColor = [UIColor clearColor];
             [statuView addSubview:statuLabel];*/
            //UIButton *powerup = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 20, 20)];
            //[powerup setImage:[UIImage imageNamed:@"stop2"] forState:UIControlStateNormal];
            DataModel *appInfo = [Applist objectAtIndex:indexPath.row];
            //if((appInfo.desktoptype).alloc
            NSString *desktoptp=appInfo.desktoptype;
            
            
            UIButton *appstart = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 40, 40)];
            [appstart setImage:[UIImage imageNamed:@"play2"] forState:UIControlStateNormal];
            appstart.hidden = NO;
            //[powerup
            [appstart addTarget:self action:@selector(DidRunApp) forControlEvents:UIControlEventTouchDown];
            [statuView addSubview:appstart];
            UIButton *powerup = [[UIButton alloc] initWithFrame:CGRectMake(0+75, 5, 40, 40)];
            [powerup setImage:[UIImage imageNamed:@"poweron"] forState:UIControlStateNormal];
            powerup.hidden = NO;
            [powerup addTarget:self action:@selector(powerup) forControlEvents:UIControlEventTouchDown];
            //[powerup
            [statuView addSubview:powerup];
            //[cell.contentView addSubview:statuView];
            UIButton *powerdn = [[UIButton alloc] initWithFrame:CGRectMake(0+150, 5, 40, 40)];
            [powerdn setImage:[UIImage imageNamed:@"poweroff"] forState:UIControlStateNormal];
            powerdn.hidden = NO;
            [powerdn addTarget:self action:@selector(powerdown) forControlEvents:UIControlEventTouchDown];
            [statuView addSubview:powerdn];
            UIButton *startup = [[UIButton alloc] initWithFrame:CGRectMake(0+225, 5, 40, 40)];
            [startup setImage:[UIImage imageNamed:@"restart"] forState:UIControlStateNormal];
            startup.hidden = NO;
            [startup addTarget:self action:@selector(startup) forControlEvents:UIControlEventTouchDown];
            [statuView addSubview:startup];
            if([desktoptp isEqualToString:@"1"])
            {
                powerup.hidden = YES;
                powerdn.hidden = YES;
                startup.hidden = YES;
                UILabel *Label1 = [[[UILabel alloc] initWithFrame:CGRectMake(8, 45, 40, 15)] autorelease];
                //[statuLabel setTag:4];
                Label1.text=@"运行";
                [Label1 setFont:[UIFont systemFontOfSize:14]];
                Label1.backgroundColor = [UIColor clearColor];
                [statuView addSubview:Label1];
            }
            else
            {
                UILabel *Label1 = [[[UILabel alloc] initWithFrame:CGRectMake(8, 45, 40, 15)] autorelease];
                //[statuLabel setTag:4];
                Label1.text=@"运行";
                [Label1 setFont:[UIFont systemFontOfSize:14]];
                Label1.backgroundColor = [UIColor clearColor];
                [statuView addSubview:Label1];
                UILabel *Label2 = [[[UILabel alloc] initWithFrame:CGRectMake(8+75, 45, 40, 15)] autorelease];
                //[statuLabel setTag:4];
                Label2.text=@"开机";
                [Label2 setFont:[UIFont systemFontOfSize:14]];
                Label2.backgroundColor = [UIColor clearColor];
                [statuView addSubview:Label2];
                UILabel *Label3 = [[[UILabel alloc] initWithFrame:CGRectMake(8+150, 45, 40, 15)] autorelease];
                //[statuLabel setTag:4];
                Label3.text=@"关机";
                [Label3 setFont:[UIFont systemFontOfSize:14]];
                Label3.backgroundColor = [UIColor clearColor];
                [statuView addSubview:Label3];
                [cell.contentView addSubview:statuView];
                UILabel *Label4 = [[[UILabel alloc] initWithFrame:CGRectMake(8+225, 45, 40, 15)] autorelease];
                Label4.text=@"重启";
                [Label4 setFont:[UIFont systemFontOfSize:14]];
                Label4.backgroundColor = [UIColor clearColor];
                [statuView addSubview:Label4];
                
            }
            [cell.contentView addSubview:statuView];
            
        }
        else
        {
            showTip = NO;
            [statuView removeFromSuperview];
            [self.tableView reloadData];
        }
    }
}


/*
 // Override to support conditional editing of the table view.
 */

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
/*删除手势
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 }
 */

- (void)setDelegate:(id)object
{
    if (delegate)
    {
        [delegate release];
    }
    delegate = object;
    [object retain];
}

- (id)delegate
{
    return delegate;
}

- (IBAction)backFavorite:(id)sender
{
    //[delegate backFavoriteChooser];
    [[self navigationController] popViewControllerAnimated:YES];
    [delegate renametablebartitle];
}
//////////////////////////////////////////////
/// UINavigationControllerDelegate Methods ///
//////////////////////////////////////////////
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
{}
//Disabled portions of the interface when a connection attempt is made.
- (void)disableInterface
{
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    //Disable tableview scrolling.
    self.tableView.scrollEnabled = NO;
    CanSelectApp = FALSE;
}

//Enables portions of the interface disabled by the previous method.  Called
//when the interface needs to be turned back on after a failed or aborted connection
//attempt.
- (void)enableInterface
{
    self.navigationItem.leftBarButtonItem.enabled = YES;
    
    //Turn scrolling back on.
    self.tableView.scrollEnabled = YES;
    showTip = NO;
    [self.tableView reloadData];
    CanSelectApp = TRUE;
}

- (void)EventDisconnect
{
    [self.navigationItem setRightBarButtonItem:nil];
    [self enableInterface];
}

- (void)EventConnected
{
    //[self enableInterface];
}

- (void)EventConnectFail
{
    [self enableInterface];
}

- (void)EventConnectStatus:(int)status
{
    
}

- (void)EventRapShellOK
{
    [delegate RunAppID:curAppID ver:(int)vernum];
}

- (void)EventRunTip:(NSString *)msg
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:SelectedIndex];
    UILabel *statuLabel = (UILabel *)[cell viewWithTag:4];
    statuLabel.text = msg;
}
- (void)EventRunError:(NSString *)msg
{
    
}
@end