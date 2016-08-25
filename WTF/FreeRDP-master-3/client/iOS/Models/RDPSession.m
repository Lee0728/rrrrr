/*
 RDP Session object
 
 Copyright 2013 Thinstuff Technologies GmbH, Authors: Martin Fleisz, Dorian Johnson
 
 This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
 If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

#import "ios_freerdp.h"
#import "ios_freerdp_ui.h"
#import "ios_freerdp_events.h"

#import "RDPSession.h"
#import "TSXTypes.h"
#import "Bookmark.h"
#import "ConnectionParams.h"

//16.07.28
#import <sys/sysctl.h>

NSString* TSXSessionDidDisconnectNotification = @"TSXSessionDidDisconnect";
NSString* TSXSessionDidFailToConnectNotification = @"TSXSessionDidFailToConnect";

@interface RDPSession (Private)
- (void)runSession;
- (void)runSessionFinished:(NSNumber*)result;
- (mfInfo*)mfi;

// The connection thread calls these on the main thread.
- (void)sessionLogon;
- (void)sessionAppstart;
- (void)sessionShellok;
- (void)sessionWillConnect;
- (void)sessionDidConnect;
- (void)sessionDidDisconnect;
- (void)sessionDidFailToConnect:(int)reason;
- (void)sessionBitmapContextWillChange;
- (void)sessionBitmapContextDidChange;
- (void)Logonmessage;
- (void)Appstartmessage;
@end

@implementation RDPSession

@synthesize delegate=_delegate, params=_params, toolbarVisible = _toolbar_visible, uiRequestCompleted = _ui_request_completed, bookmark = _bookmark;

+ (void)initialize
{
    ios_init_freerdp();
}

- (void)setDelegate1:(id)object
{
    if (delegate1)
    {
        [delegate1 release];
    }
    delegate1 = object;
    [object retain];
}

- (id)delegate1
{
    return delegate1;
}
// Designated initializer.
- (id)initWithBookmark:(ComputerBookmark *)bookmark hostname:(NSString *)hostname port:(NSString *)port username:(NSString *)username password:(NSString *)password rapshell:(NSString *)rapshell safegateway:(int)safegateway Sessionid:(NSString*)Sessionid appid:(NSString *)appid
{
    printf("the safegateway is %d",safegateway);
	if (!(self = [super init]))
		return nil;
	
	if (!bookmark)
		[NSException raise:NSInvalidArgumentException format:@"%s: params may not be nil.", __func__];
	
    _bookmark = [bookmark retain];
	_params = [[bookmark params] copy];
    _name = [[bookmark label] retain];
    _delegate = nil;
    _toolbar_visible = YES;
	_freerdp = ios_freerdp_new();
    settings = _freerdp->settings;
    _ui_request_completed = [[NSCondition alloc] init];
    
    BOOL connected_via_3g = ![bookmark conntectedViaWLAN];
    
	// Screen Size is set on connect (we need a valid delegate in case the user choose an automatic screen size)
    
	// Other simple numeric settings
	if ([_params hasValueForKey:@"colors"])
		settings->ColorDepth = [_params intForKey:@"colors" with3GEnabled:connected_via_3g];
	
	//if ([_params hasValueForKey:@"port"])
//    settings->ServerPort = [_params intForKey:@"port"];
    int intport = [port intValue];
    settings->ServerPort = intport;
    
    settings->safegateway = safegateway;
    
    
    settings->appid = strdup([appid UTF8String]);
    NSLog(@"the set safegateway is %d",safegateway);
    settings->Sessionid = strdup([Sessionid UTF8String]);
    //settings->ServerPort = 5872;
	if ([_params boolForKey:@"console"])
		settings->ConsoleSession = 0;
    
	// connection info
    //settings->ServerHostname = strdup([_params UTF8StringForKey:@"hostname"]);
    settings->ServerHostname = strdup([hostname UTF8String]);
    //settings->ServerHostname = strdup("192.168.0.217");
	//settings->safegateway = false;
	// String settings
	//if ([[_params StringForKey:@"username"] length])
    //settings->Username = strdup([_params UTF8StringForKey:@"username"]);
    settings->Username = strdup([username UTF8String]);
    //settings->Username=strdup("administrator");
    NSLog(@"the hexxname is %s",settings->Username);
    //NSString *user = @"GWTkdtest";
    //settings->Username = strdup([user UTF8String]);
	//if ([[_params StringForKey:@"password"] length])
    //settings->Password = strdup([_params UTF8StringForKey:@"password"]);
    //password = @"2";
    settings->Password = strdup([password UTF8String]);
    //settings->Password = strdup("realor#123");
    NSLog(@"the password is %s",settings->Password);
    //NSString *pas = @"GwT_miOIycgr1JTl5e4Z";
    //settings->Password = strdup([pas UTF8String]);
	if ([[_params StringForKey:@"domain"] length])
        settings->Domain = strdup([_params UTF8StringForKey:@"domain"]);
    //NSString *domain = @"ry.com";
    //settings->Domain = strdup([domain UTF8String]);
	settings->ShellWorkingDirectory = strdup([_params UTF8StringForKey:@"working_directory"]);
	//settings->AlternateShell = strdup([_params UTF8StringForKey:@"remote_program"]);
    settings->AlternateShell = strdup([rapshell UTF8String]);
    //settings->AlternateShell = "";
	//settings->AlternateShell ="C:\Program Files\RealFriend\Rap Server\Bin\RapShell.exe /N:APP00000002 /U:admin /P:c4ca4238a0b923820dcc509a6f75849b /T:31333037343138323632 /S:0 /D:C1D1E1F1H2 /M:N77EBFC6A /H:0 /I:0 /E:sid00000807"
    //NSString *shell = @"\"C:\\Program Files\\RealFriend\\Rap Server\\Bin\\rapshell.exe\" //N:APP00000000 /U:kdtest /P:478adfe8c7a17ffc97220b38fab8e89d /T:31333037343138323632 /S:0 /D:C1D1E1F1H2 /M:I03e6c616 /H:0 /I:0 /E:sid00004027";
	//settings->AlternateShell = strdup([shell UTF8String]);
	// RemoteFX
	if ([_params boolForKey:@"perf_remotefx" with3GEnabled:connected_via_3g])
	{
		settings->RemoteFxCodec = TRUE;
		settings->FastPathOutput = TRUE;
		settings->ColorDepth = 32;
		settings->LargePointerFlag = TRUE;
        settings->FrameMarkerCommandEnabled = TRUE;
        settings->FrameAcknowledge = 10;
	}
	else
	{
		// enable NSCodec if remotefx is not used
		settings->NSCodec = TRUE;
	}
    
	settings->BitmapCacheV3Enabled = TRUE;
    
	// Performance flags
    settings->DisableWallpaper = ![_params boolForKey:@"perf_show_desktop" with3GEnabled:connected_via_3g];
    settings->DisableFullWindowDrag = ![_params boolForKey:@"perf_window_dragging" with3GEnabled:connected_via_3g];
    settings->DisableMenuAnims = ![_params boolForKey:@"perf_menu_animation" with3GEnabled:connected_via_3g];
    settings->DisableThemes = ![_params boolForKey:@"perf_windows_themes" with3GEnabled:connected_via_3g];
    settings->AllowFontSmoothing = [_params boolForKey:@"perf_font_smoothing" with3GEnabled:connected_via_3g];
    settings->AllowDesktopComposition = [_params boolForKey:@"perf_desktop_composition" with3GEnabled:connected_via_3g];
    
	settings->PerformanceFlags = PERF_FLAG_NONE;
    settings->DisableWallpaper=FALSE;
	if (settings->DisableWallpaper)
        settings->PerformanceFlags |= PERF_DISABLE_WALLPAPER;
	if (settings->DisableFullWindowDrag)
        settings->PerformanceFlags |= PERF_DISABLE_FULLWINDOWDRAG;
	if (settings->DisableMenuAnims)
		settings->PerformanceFlags |= PERF_DISABLE_MENUANIMATIONS;
	if (settings->DisableThemes)
        settings->PerformanceFlags |= PERF_DISABLE_THEMING;
	if (settings->AllowFontSmoothing)
		settings->PerformanceFlags |= PERF_ENABLE_FONT_SMOOTHING;
    if (settings->AllowDesktopComposition)
        settings->PerformanceFlags |= PERF_ENABLE_DESKTOP_COMPOSITION;
    
	if ([_params hasValueForKey:@"width"])
		settings->DesktopWidth = [_params intForKey:@"width"];
	if ([_params hasValueForKey:@"height"])
		settings->DesktopHeight = [_params intForKey:@"height"];
    NSLog(@"the destopwidth is %d desktopheight is %d",settings->DesktopWidth,settings->DesktopHeight);

    // security
    NSLog(@"the security is %d",[_params intForKey:@"security"]);
    switch ([_params intForKey:@"security"])
    {
        case TSXProtocolSecurityNLA:
//            settings->RdpSecurity = TRUE;
//            settings->TlsSecurity = FALSE;
//            settings->NlaSecurity = FALSE;
//            settings->ExtSecurity = FALSE;
            break;
            
        case TSXProtocolSecurityTLS:
//            settings->RdpSecurity = FALSE;
//            settings->TlsSecurity = TRUE;
//            settings->NlaSecurity = FALSE;
//            settings->ExtSecurity = FALSE;
            break;
            
        case TSXProtocolSecurityRDP:
            settings->ConsoleSession = YES;
//            settings->RdpSecurity = TRUE;
//            settings->TlsSecurity = FALSE;
//            settings->NlaSecurity = FALSE;
//            settings->ExtSecurity = FALSE;
//            settings->DisableEncryption = TRUE;
//            settings->EncryptionMethods = ENCRYPTION_METHOD_40BIT | ENCRYPTION_METHOD_128BIT | ENCRYPTION_METHOD_FIPS;
//            settings->EncryptionLevel = ENCRYPTION_LEVEL_CLIENT_COMPATIBLE;
            break;
        default:
            break;
    }
    settings->RdpSecurity = TRUE;
    settings->TlsSecurity = FALSE;
    settings->NlaSecurity = FALSE;
    settings->ExtSecurity = FALSE;
    settings->DisableEncryption = TRUE;
     settings->EncryptionMethods = ENCRYPTION_METHOD_40BIT | ENCRYPTION_METHOD_128BIT | ENCRYPTION_METHOD_FIPS;
     settings->EncryptionLevel = ENCRYPTION_LEVEL_CLIENT_COMPATIBLE;
    // ts gateway settings
    if ([_params boolForKey:@"enable_tsg_settings"])
    {
        settings->GatewayHostname = strdup([_params UTF8StringForKey:@"tsg_hostname"]);
        settings->GatewayPort = [_params intForKey:@"tsg_port"];
        settings->GatewayUsername = strdup([_params UTF8StringForKey:@"tsg_username"]);
        settings->GatewayPassword = strdup([_params UTF8StringForKey:@"tsg_password"]);
        settings->GatewayDomain = strdup([_params UTF8StringForKey:@"tsg_domain"]);
        settings->GatewayUsageMethod = TSC_PROXY_MODE_DIRECT;
        settings->GatewayEnabled = TRUE;
        settings->GatewayUseSameCredentials = FALSE;
    }
    
	// Remote keyboard layout
	settings->KeyboardLayout = 0x804;
    
	// Audio settings
    settings->AudioPlayback = FALSE;
    settings->AudioCapture = FALSE;
	
	[self mfi]->session = self;
	return self;
}

- (void) Sendtext:(unsigned short) Code text:(NSString *)appIDorNil
{
    Sendvitualtext(_freerdp,Code,appIDorNil);
}
- (NSString*)getMachine{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *name = malloc(size);
    sysctlbyname("hw.machine", name, &size, NULL, 0);
    
    NSString *machine = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
    NSLog(@"the machinename is %@",machine);
    free(name);
    
    if( [machine isEqualToString:@"i386"] || [machine isEqualToString:@"x86_64"] ) machine = @"ios_Simulator";
    else if( [machine isEqualToString:@"iPhone1,1"] ) machine = @"iPhone_1G";
    else if( [machine isEqualToString:@"iPhone1,2"] ) machine = @"iPhone_3G";
    else if( [machine isEqualToString:@"iPhone2,1"] ) machine = @"iPhone_3GS";
    else if( [machine isEqualToString:@"iPhone3,1"] ) machine = @"iPhone_4";
    else if( [machine isEqualToString:@"iPod1,1"] ) machine = @"iPod_Touch_1G";
    else if( [machine isEqualToString:@"iPod2,1"] ) machine = @"iPod_Touch_2G";
    else if( [machine isEqualToString:@"iPod3,1"] ) machine = @"iPod_Touch_3G";
    else if( [machine isEqualToString:@"iPod4,1"] ) machine = @"iPod_Touch_4G";
    else if( [machine isEqualToString:@"iPad1,1"] ) machine = @"iPad_1";
    else if( [machine isEqualToString:@"iPad2,1"] ) machine = @"iPad_2";
    
    return machine;
}
- (char *)gethostname
{
    return settings->ServerHostname;
}
- (void)Setvernum:(int)vernum
{
    settings->vernum = vernum;
}
- (void)Logonmessage
{
    [self performSelectorOnMainThread:@selector(sessionLogon) withObject:nil waitUntilDone:YES];
}
- (void)Appstartmessage
{
    [self performSelectorOnMainThread:@selector(sessionAppstart) withObject:nil waitUntilDone:YES];
}
- (void)Appshellok
{
    [self performSelectorOnMainThread:@selector(sessionShellok) withObject:nil waitUntilDone:YES];
}
- (void)close
{
    [[self delegate] logoff];
}
- (void)upkeyboard
{
    //[[self delegate] Setimepostion:imex imey:imey screenheight:settings->DesktopHeight];
}
- (void)dealloc
{
	[self setDelegate:nil];
    [_bookmark release];
    [_name release];
	[_params release];
    [_ui_request_completed release];
    
	ios_freerdp_free(_freerdp);
	
	[super dealloc];
}

- (CGContextRef)bitmapContext
{
    return [self mfi]->bitmap_context;
}

#pragma mark -
#pragma mark Connecting and disconnecting

- (void)connect
{
	// Set Screen Size to automatic if widht or height are still 0
    rdpSettings* settings = _freerdp->settings;
    NSLog(@"the desktopwidth is %d destopheight is %d",settings->DesktopWidth,settings->DesktopHeight);
	if (settings->DesktopWidth == 0 || settings->DesktopHeight == 0)
	{
        CGSize size = CGSizeZero;
        if ([[self delegate] respondsToSelector:@selector(sizeForFitScreenForSession:)])
            size = [[self delegate] sizeForFitScreenForSession:self];
        
        if (!CGSizeEqualToSize(CGSizeZero, size))
        {
            [_params setInt:size.width forKey:@"width"];
            [_params setInt:size.height forKey:@"height"];
            //settings->DesktopWidth = 1024;//size.width;
            //settings->DesktopHeight = 768;//size.height;
            settings->DesktopWidth = size.width;
            settings->DesktopHeight = size.height;
            NSLog(@"the desktopwidth is %d destopheight is %d",settings->DesktopWidth,settings->DesktopHeight);
        }
	}
    
    // TODO: This is a hack to ensure connections to RDVH with 16bpp don't have an odd screen resolution width
    //       Otherwise this could result in screen corruption ..
    if (settings->ColorDepth <= 16)
        settings->DesktopWidth &= (~1);
    
	[self performSelectorInBackground:@selector(runSession) withObject:nil];
}

- (void)disconnect
{
	mfInfo* mfi = [self mfi];
	
    ios_events_send(mfi, [NSDictionary dictionaryWithObject:@"disconnect" forKey:@"type"]);
    
	if (mfi->connection_state == TSXConnectionConnecting)
	{
		mfi->unwanted = YES;
		[self sessionDidDisconnect];
		return;
	}
}

- (TSXConnectionState)connectionState
{
	return [self mfi]->connection_state;
}

// suspends the session
-(void)suspend
{
    if(!_suspended)
    {
        _suspended = YES;
        //        instance->update->SuppressOutput(instance->context, 0, NULL);
    }
}

// resumes a previously suspended session
-(void)resume
{
    if(_suspended)
    {
        /*        RECTANGLE_16 rec;
         rec.left = 0;
         rec.top = 0;
         rec.right = instance->settings->width;
         rec.bottom = instance->settings->height;
         */
        _suspended = NO;
        //        instance->update->SuppressOutput(instance->context, 1, &rec);
        //        [delegate sessionScreenSettingsChanged:self];
    }
}

// returns YES if the session is started
-(BOOL)isSuspended
{
    return _suspended;
}

#pragma mark -
#pragma mark Input events

- (void)sendInputEvent:(NSDictionary*)eventDescriptor
{
	if ([self mfi]->connection_state == TSXConnectionConnected)
		ios_events_send([self mfi], eventDescriptor);
}

#pragma mark -
#pragma mark Server events (main thread)

- (void)setNeedsDisplayInRectAsValue:(NSValue*)rect_value
{
	if ([[self delegate] respondsToSelector:@selector(session:needsRedrawInRect:)])
		[[self delegate] session:self needsRedrawInRect:[rect_value CGRectValue]];
}


#pragma mark -
#pragma mark interface functions

- (UIImage*)getScreenshotWithSize:(CGSize)size
{
    NSAssert([self mfi]->bitmap_context != nil, @"Screenshot requested while having no valid RDP drawing context");
    
	CGImageRef cgImage = CGBitmapContextCreateImage([self mfi]->bitmap_context);
	UIGraphicsBeginImageContext(size);
	
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, size.height);
	CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, size.width, size.height), cgImage);
	
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
	CGImageRelease(cgImage);
	
	return viewImage;
}

- (rdpSettings*)getSessionParams
{
    return _freerdp->settings;
}

- (NSString*)sessionName
{
    return _name;
}

@end

#pragma mark -
@implementation RDPSession (Private)

- (mfInfo*)mfi
{
	return MFI_FROM_INSTANCE(_freerdp);
}

// Blocks until rdp session finishes.
- (void)runSession
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    // Run the session
    [self performSelectorOnMainThread:@selector(sessionWillConnect) withObject:nil waitUntilDone:YES];
    int result_code = ios_run_freerdp(_freerdp);
    [self mfi]->connection_state = TSXConnectionDisconnected;
    [self performSelectorOnMainThread:@selector(runSessionFinished:) withObject:[NSNumber numberWithInt:result_code] waitUntilDone:YES];
    
    [pool release];
}

// Main thread.
- (void)runSessionFinished:(NSNumber*)result
{
	int result_code = [result intValue];
	
	switch (result_code)
	{
		case MF_EXIT_CONN_CANCELED:
			[self sessionDidDisconnect];
			break;
		case MF_EXIT_LOGON_TIMEOUT:
		case MF_EXIT_CONN_FAILED:
			[self sessionDidFailToConnect:result_code];
			break;
		case MF_EXIT_SUCCESS:
		default:
			[self sessionDidDisconnect];
            break;
	}
}

#pragma mark -
#pragma mark Session management (main thread)
- (void)sessionLogon
{
    if ([[self delegate] respondsToSelector:@selector(sessionLogon:)])
		[[self delegate] sessionLogon:self];
}
- (void)sessionShellok
{
    if ([[self delegate] respondsToSelector:@selector(sessionShellok:)])
		[[self delegate] sessionShellok:self];
}
- (void)sessionAppstart
{
    //if ([[self delegate] respondsToSelector:@selector(sessionAppstart:)])
		[delegate1 sessionAppstart:self];
}
- (void)sessionWillConnect
{
	if ([[self delegate] respondsToSelector:@selector(sessionWillConnect:)])
		[[self delegate] sessionWillConnect:self];
}

- (void)sessionDidConnect
{
	if ([[self delegate] respondsToSelector:@selector(sessionDidConnect:)])
		[[self delegate] sessionDidConnect:self];
}

- (void)sessionDidFailToConnect:(int)reason
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TSXSessionDidFailToConnectNotification object:self];
    
	if ([[self delegate] respondsToSelector:@selector(session:didFailToConnect:)])
		[[self delegate] session:self didFailToConnect:reason];
}

- (void)sessionDidDisconnect
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TSXSessionDidDisconnectNotification object:self];
	
    if ([[self delegate] respondsToSelector:@selector(sessionDidDisconnect:)])
		[[self delegate] sessionDidDisconnect:self];
}

- (void)sessionBitmapContextWillChange
{
	if ([[self delegate] respondsToSelector:@selector(sessionBitmapContextWillChange:)])
		[[self delegate] sessionBitmapContextWillChange:self];
}

- (void)sessionBitmapContextDidChange
{
	if ([[self delegate] respondsToSelector:@selector(sessionBitmapContextDidChange:)])
		[[self delegate] sessionBitmapContextDidChange:self];
}

- (void)showGoProScreen
{
	if ([[self delegate] respondsToSelector:@selector(showGoProScreen:)])
		[[self delegate] showGoProScreen:self];
}

- (void)sessionRequestsAuthenticationWithParams:(NSMutableDictionary*)params
{
	if ([[self delegate] respondsToSelector:@selector(session:requestsAuthenticationWithParams:)])
		[[self delegate] session:self requestsAuthenticationWithParams:params];
}

- (void)sessionVerifyCertificateWithParams:(NSMutableDictionary*)params
{
	if ([[self delegate] respondsToSelector:@selector(session:verifyCertificateWithParams:)])
		[[self delegate] session:self verifyCertificateWithParams:params];    
}

@end
