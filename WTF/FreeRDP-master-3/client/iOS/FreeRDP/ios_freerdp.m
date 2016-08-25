/*
 RDP run-loop
 
 Copyright 2013 Thinstuff Technologies GmbH, Authors: Martin Fleisz, Dorian Johnson
 
 This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
 If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

#import <freerdp/utils/event.h>
#import <freerdp/gdi/gdi.h>
#import <freerdp/channels/channels.h>
#import <freerdp/client/channels.h>
#import <freerdp/client/cmdline.h>
#include "DIMime.h"
#import "ios_freerdp.h"
#import "ios_freerdp_ui.h"
#import "ios_freerdp_events.h"

#import "RDPSession.h"
//16.07.18

#pragma mark Connection helpers
#define MIME_BUFFER_SIZE  2736
#define CH_HEADER_FLAG_SHELL    "Wi4H"
static BOOL
ios_pre_connect(freerdp * instance)
{	
	rdpSettings* settings = instance->settings;	

	settings->AutoLogonEnabled = settings->Password && (strlen(settings->Password) > 0);
	
	// Verify screen width/height are sane
	if ((settings->DesktopWidth < 64) || (settings->DesktopHeight < 64) || (settings->DesktopWidth > 4096) || (settings->DesktopHeight > 4096))
	{
		NSLog(@"%s: invalid dimensions %d %d", __func__, settings->DesktopWidth, settings->DesktopHeight);
		return FALSE;
	}
	
	BOOL bitmap_cache = settings->BitmapCacheEnabled;
	
	settings->OrderSupport[NEG_DSTBLT_INDEX] = TRUE;
	settings->OrderSupport[NEG_PATBLT_INDEX] = TRUE;
	settings->OrderSupport[NEG_SCRBLT_INDEX] = TRUE;
	settings->OrderSupport[NEG_OPAQUE_RECT_INDEX] = TRUE;
	settings->OrderSupport[NEG_DRAWNINEGRID_INDEX] = FALSE;
	settings->OrderSupport[NEG_MULTIDSTBLT_INDEX] = FALSE;
	settings->OrderSupport[NEG_MULTIPATBLT_INDEX] = FALSE;
	settings->OrderSupport[NEG_MULTISCRBLT_INDEX] = FALSE;
	settings->OrderSupport[NEG_MULTIOPAQUERECT_INDEX] = TRUE;
	settings->OrderSupport[NEG_MULTI_DRAWNINEGRID_INDEX] = FALSE;
	settings->OrderSupport[NEG_LINETO_INDEX] = TRUE;
	settings->OrderSupport[NEG_POLYLINE_INDEX] = TRUE;
	settings->OrderSupport[NEG_MEMBLT_INDEX] = bitmap_cache;
	settings->OrderSupport[NEG_MEM3BLT_INDEX] = TRUE;
	settings->OrderSupport[NEG_MEMBLT_V2_INDEX] = bitmap_cache;
	settings->OrderSupport[NEG_MEM3BLT_V2_INDEX] = FALSE;
	settings->OrderSupport[NEG_SAVEBITMAP_INDEX] = FALSE;
	settings->OrderSupport[NEG_GLYPH_INDEX_INDEX] = TRUE;
	settings->OrderSupport[NEG_FAST_INDEX_INDEX] = TRUE;
	settings->OrderSupport[NEG_FAST_GLYPH_INDEX] = TRUE;
	settings->OrderSupport[NEG_POLYGON_SC_INDEX] = FALSE;
	settings->OrderSupport[NEG_POLYGON_CB_INDEX] = FALSE;
	settings->OrderSupport[NEG_ELLIPSE_SC_INDEX] = FALSE;
	settings->OrderSupport[NEG_ELLIPSE_CB_INDEX] = FALSE;
	
    settings->FrameAcknowledge = 10;
    //instance->settings->StaticChannelArray[0]->argc = strlen("CSML");
    //instance->settings->StaticChannelArray[0]->argv = &"CSML";

    freerdp_client_load_addins(instance->context->channels, instance->settings);

	freerdp_channels_pre_connect(instance->context->channels, instance);

	return TRUE;
}

static BOOL ios_post_connect(freerdp* instance)
{
	mfInfo* mfi = MFI_FROM_INSTANCE(instance);

    instance->context->cache = cache_new(instance->settings);
    
	// Graphics callbacks
	ios_allocate_display_buffer(mfi);
	instance->update->BeginPaint = ios_ui_begin_paint;
	instance->update->EndPaint = ios_ui_end_paint;
	instance->update->DesktopResize = ios_ui_resize_window;
		
	// Channel allocation
	freerdp_channels_post_connect(instance->context->channels, instance);

	[mfi->session performSelectorOnMainThread:@selector(sessionDidConnect) withObject:nil waitUntilDone:YES];
	return TRUE;
}

static int ios_receive_channel_data(freerdp* instance, int channelId, UINT8* data, int size, int flags, int total_size)
{
    //return freerdp_channels_data(instance, channelId, data, size, flags, total_size);
   // seamless_process(data,size，instance);
    //seamless_process1(data, size ,instance,channelId);
    
    if(instance->settings->vernum<6)    // vernum：版本号
    {
        seamless_process2(data, total_size ,instance,channelId);
    }
    else
    {
       seamless_process1(data, size ,instance,channelId); 
    }
    return 0;
}
void Sendvitualtext(freerdp* instance,unsigned short Code,NSString *appIDorNil)
{
    if(instance->settings->vernum<6)
    {
        TShellClientMSG clientMSG;
        const char *tmp;
        char encodeBuf[(2736+2)/3*4+2736/57*2-1];
        memset(encodeBuf, 0,sizeof(encodeBuf));
        memset(&clientMSG, 0, sizeof(TShellClientMSG));
        clientMSG.Flag[0] = 0x5a;
        clientMSG.Flag[1] = 0x2e;
        clientMSG.Flag[2] = 0x07;
        clientMSG.MSGID = Code;
        
        /*if (Code == MSG_SYSCMD_SETTINGCHANGE)
         {
         clientMSG.Param.WParam = 0;
         clientMSG.Param.LParam = 0x00100010;
         }*/
        
        
        //AppId转化成bytes
        NSData *data = [appIDorNil dataUsingEncoding: -2147482062];
        tmp = [data bytes];
        memcpy(clientMSG.AppID,tmp,[data length]);
        
        //tmp = (char *)[appIDorNil cStringUsingEncoding:NSUTF8StringEncoding];
        //memcpy(clientMSG.AppID,tmp,[appIDorNil lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
        //加密源数据
        MimeEncode((const char *)&clientMSG, sizeof(TShellClientMSG),encodeBuf);
        
        printf("the size is %d",(int)sizeof(TShellClientMSG));
        size_t len = strlen(encodeBuf);
        TWideString ws[len+1];
        memset(ws, 0, len+1);
        
        for(int i = 0; i<len; i++)
        {
            ws[i].c1 = encodeBuf[i];
            ws[i].c2 = 0;
        }
        for(int i=0;i<20;i++)
        {
            printf("the ws is %d",*((char *)&ws[i]));
            //printf("the ws is %d",ws[i].c2);

        }
       // printf("the channel len is %d",2*len+1);
        //VirtualChannels_send(conn, (char *)ws);
        printf("the get channelid is %d",getchannelid);
        printf("the len is %lu",2*len);
//        16.07.28
//        freerdp_channel_send(instance->context->rdp,getchannelid,ws,2*len);

    }
    else
    {
    TShellClientMSG_new clientMSG1;
    const char *tmp;
    NSData *data = [appIDorNil dataUsingEncoding: -2147482062];
    tmp = [data bytes];
    NSLog(@"the Code is %d",Code);
    //char output[40];
    memset(output, 0,40);
    memset(&clientMSG1,0,sizeof(clientMSG1));
    //char encodeBuf[(2736+2)/3*4+2736/57*2-1];
    //memset(encodeBuf, 0,sizeof(encodeBuf));
    output[0]=0x5a;
    output[1]=0x2e;
    output[2]=0x07;
    output[3]=Code&0xff;
    output[4]=(Code>>8)&0xff;
    //&clientMSG1=malloc(sizeof(TShellClientMSG_new)+[data length]-3);
    /* memset((char *)&clientMSG1, 0, sizeof(TShellClientMSG_new)+[data length]-3);
     clientMSG1.Flag[0] = ShellMsgFlag0;
     clientMSG1.Flag[1] = ShellMsgFlag1;
     clientMSG1.Flag[2] = ShellMsgFlag2;
     clientMSG1.MSGID = Code;*/
    //clientMSG.strlen=0;
    /*if (Code == MSG_SYSCMD_SETTINGCHANGE)
     {
     //clientMSG.Param.WParam = 0;
     //clientMSG.Param.LParam = 0x00100010;
     }*/
    
    
    //AppId转化成bytes
    //memcpy(clientMSG.strlen,0,4);
    
    /*output[21]=*tmp;
     output[22]=*(tmp+1);
     output[23]='\0';*/
    /*clientMSG1.strlen[0]=0;
     clientMSG1.strlen[1]=0;
     clientMSG1.strlen[2]=0;
     clientMSG1.strlen[3]=0;
     clientMSG1.AppParam[0]=*tmp;
     clientMSG1.AppParam[1]=*(tmp+1);
     //clientMSG1.AppParam[0]=*(tmp+2);
     //clientMSG1.AppParam[0]=*(tmp+3);*/
    memcpy(&output[21],tmp,[data length]);
    for(int i=0;i<25;i++)
    {
        printf("the tmp is %d",output[i]);
    }
    //*(clientMSG1.AppParam+[data length])='\0';
    //int len = 21+[data length]+1;
    int len = 21+[data length]+1;
    output[len]='\0';
    //VirtualChannels_send_new(conn, output,40);
//        16.07.18
//    freerdp_channel_send(instance->context->rdp,getchannelid,output,25);
    }
}

void virtual_send(NSString* appid,freerdp* instance,int channelId)
{
    if(instance->settings->vernum<6)
    {
        TShellClientMSG clientMSG;
        const char *tmp;
        char encodeBuf[(2736+2)/3*4+2736/57*2-1];
        memset(encodeBuf, 0,sizeof(encodeBuf));
        memset(&clientMSG, 0, sizeof(TShellClientMSG));
        clientMSG.Flag[0] = 0x5a;
        clientMSG.Flag[1] = 0x2e;
        clientMSG.Flag[2] = 0x07;
        clientMSG.MSGID = 0x04;
        
        /*if (Code == MSG_SYSCMD_SETTINGCHANGE)
         {
         clientMSG.Param.WParam = 0;
         clientMSG.Param.LParam = 0x00100010;
         }*/
        
        
        //AppId转化成bytes
        NSData *data = [appid dataUsingEncoding: -2147482062];

        //NSData *data = [appIDorNil dataUsingEncoding: -2147482062];
        tmp = [data bytes];
        memcpy(clientMSG.AppID,tmp,[data length]);
        
        //tmp = (char *)[appIDorNil cStringUsingEncoding:NSUTF8StringEncoding];
        //memcpy(clientMSG.AppID,tmp,[appIDorNil lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
        //加密源数据
        MimeEncode((const char *)&clientMSG, sizeof(TShellClientMSG),encodeBuf);
        
        printf("the size is %d",(int)sizeof(TShellClientMSG));
        size_t len = strlen(encodeBuf);
        TWideString ws[len+1];
        memset(ws, 0, len+1);
        
        for(int i = 0; i<len; i++)
        {
            ws[i].c1 = encodeBuf[i];
            ws[i].c2 = 0;
        }
        for(int i=0;i<20;i++)
        {
            printf("the ws is %d",*((char *)&ws[i]));
            //printf("the ws is %d",ws[i].c2);
            
        }
        // printf("the channel len is %d",2*len+1);
        //VirtualChannels_send(conn, (char *)ws);
        printf("the get channelid is %d",getchannelid);
//        16.07.18
//        freerdp_channel_send(instance->context->rdp,getchannelid,ws,2*len);
        
    }
    else
    {

    const char* tmp1;
    BYTE *tmp;
    //memset(&clientMSG1, 0, sizeof(TShellClientMSG_new));
    rdpSettings* settings = instance->settings;
    tmp = malloc(25);
    memset(tmp, 0,25);

    tmp[0] = 0x5A;
    tmp[1] = 0x2E;
    tmp[2] = 0x07;
    tmp[3] = 4;
    tmp[4] = 0;
    //NSString *appid = @"APP00000001";
    NSData *data1 = [appid dataUsingEncoding: -2147482062];
    tmp1 = [data1 bytes];
    //NSData *data;
    memcpy(&tmp[5],settings->appid,[data1 length]);
    //byte *data = (byte*)&clientMSG1;
    NSLog(@"the data is %d",tmp[0]);
    NSLog(@"the data is %d",tmp[1]);
    NSLog(@"the data is %d",tmp[2]);
    NSLog(@"the data is %d",tmp[3]);
    NSLog(@"the data is %d",tmp[4]);
    NSLog(@"the data is %d",tmp[5]);
    NSLog(@"the data is %d",tmp[6]);
    NSLog(@"the data is %d",tmp[7]);
    NSLog(@"the data is %d",tmp[8]);
    NSLog(@"the data is %d",tmp[9]);
    NSLog(@"the data is %d",tmp[10]);
//        16.07.18
//    freerdp_channel_send(instance->context->rdp,channelId,tmp,25);
    }
}
void seamless_process1(UINT8* data,int size,freerdp* instance,int channelId)
{
    //printf("seamless_process\n");

    unsigned char inbuff[26];	   // Buffer to read incoming data into

    int pkglen;

    int i,lowbyte,highbyte,msg_id;

    int i1;
    unsigned char buf[2000];
    memset(buf,0,2000);
    mfContext* context = (mfContext*)instance->context;
	mfInfo* mfi = context->mfi;
	pkglen = size;//stream_get_size(s);
    //printf("s->end is %d\n",*s->end);
    //printf("the pkglen is %d\n",pkglen);
	/* str_handle_lines requires null terminated strings */
	
    
    //printf("the pkglen22 is %d\n",pkglen);
	//STRNCPY(buf, (unsigned char *) s->p, pkglen);
	printf("seamless_process======================================================start\n");
    for(i1= 0; i1 < pkglen; i1++)
    {
        buf[i1] = data[i1];
        printf("%02X" ,buf[i1]);
    }
    printf("\namless_process======================================================end\n");
    for(i=0;i<25;i++)
    {
        inbuff[i] = 0;
    }
    
    printf("the buf[0] is %0x\n",buf[0]);
    printf("the buf[1] is %0x\n",buf[1]);
    printf("the buf[2] is %0x\n",buf[2]);
    
    if((buf[0] == 0x5A)&&(buf[1] == 0x2E)&&(buf[2] == 0x07))
    {
        //clientmsg[0] = buf[0];
        // clientmsg[1] = buf[1];
        // clientmsg[2] = buf[2];
        printf("buf[3] = %d\n", buf[3]);
        printf("buf[4] = %d\n", buf[4]);
        if(buf[3]>=0)
        {
			lowbyte = (int)buf[3];
        }
        else
        {
			lowbyte=(int)buf[3]+256;
        }
        if(buf[4]>0)
        {
			highbyte=((int)buf[4])<<8;
        }
        else
        {
			highbyte=((int)buf[4]+256)<<8;
        }
        msg_id = highbyte+lowbyte;
        printf("msgid = %d\n", msg_id);
        if(msg_id == 4096)
        {
            printf("logon\n");
            [mfi->session performSelectorOnMainThread:@selector(Logonmessage) withObject:nil waitUntilDone:YES];
            //write(sockfd, "logon", strlen("logon"));
        }
        else if(msg_id == 16385)
        {
            printf("shellok\n");
            [mfi->session performSelectorOnMainThread:@selector(Appshellok) withObject:nil waitUntilDone:YES];
            getchannelid = channelId;
            NSLog(@"the channelid is %d",channelId);
            //TShellClientMSG_new clientMSG1;
            //virtual_send(@"APP00000001",instance,channelId);

        }
        else if(msg_id == 16386)
        {
            // printf("APPSTART\n");
            //write(sockfd, "APPSTART", strlen("APPSTART"));
            //xf_seamless(buf,pkglen);
            printf("Appstart\n");
            [mfi->session performSelectorOnMainThread:@selector(Appstartmessage) withObject:nil waitUntilDone:YES];
        }
        else
        {
           // freerdp_channel_send(instance->context->rdp,channelId,data,size);
        }
    }
    else if((buf[0] == 0x3F)&&(buf[1] == 0xEE)&&(buf[2] == 0x03))
    {
        int i2,rect[10];
        for(i2=0;i2<=7;i2++)
        {
            rect[i2]=buf[26+i2];
            printf("the rect is %d",rect[i2]);
        }
        int x = rect[0]+rect[1]*256;
        int y = rect[2]+rect[3]*256;
        int width = rect[4]+rect[5]*256;
        int height = rect[6]+rect[7]*256;
        NSLog(@"the create is %d",buf[15]);
        NSLog(@"the parent is %d",buf[13]);
        NSLog(@"the sml is %d the smly is %d the smlwidth is %d the smlheight is %d",x,y,width,height);
    }
}
void seamless_process2(UINT8* data,int size,freerdp* instance,int channelId)
{
    const char *buf;
    char strHead[5];
    char outputBuf[(MIME_BUFFER_SIZE+3)/4*3-1];
    int len = size;
    unsigned int newLen;
    mfContext* context = (mfContext*)instance->context;
	mfInfo* mfi = context->mfi;
    memset(outputBuf, 0, sizeof(outputBuf));
    if (len < 4){
        return;
    }
    else
    {
        buf = (char *)(data);
        memset(strHead, 0, 5);
        memcpy(strHead, buf, 4);
        
        if (strcmp(strHead,CH_HEADER_FLAG_SHELL) == 0)
        {
            MimeDecode(buf,len,&newLen,outputBuf);
            if (newLen != sizeof(TShellServerMSG))
            {
                //error("Error on MimeDecode");
            }
            else
            {
                PShellServerMSG p=(PShellServerMSG)outputBuf;
                char flag1 = p->Flag[0];
                char flag2 = p->Flag[1];
                char flag3 = p->Flag[2];
                printf("the flag1 flag2 flag3 is %d,%d,%d",flag1,flag2,flag3);
                unsigned short msgid=p->MSGID;
                printf("msgid = %d\n", msgid);
                if(msgid == 4096)
                {
                    printf("logon\n");
                    [mfi->session performSelectorOnMainThread:@selector(Logonmessage) withObject:nil waitUntilDone:YES];
                    //write(sockfd, "logon", strlen("logon"));
                }
                else if(msgid == 16385)
                {
                    printf("shellok\n");
                    [mfi->session performSelectorOnMainThread:@selector(Appshellok) withObject:nil waitUntilDone:YES];
                    //TShellClientMSG_new clientMSG1;
                    NSLog(@"the channel id is %d",channelId);
                    getchannelid = channelId;
                    //virtual_send(@"APP00000001",instance,channelId);
                }
                else if(msgid == 16386)
                {
                    // printf("APPSTART\n");
                    //write(sockfd, "APPSTART", strlen("APPSTART"));
                    //xf_seamless(buf,pkglen);
                    printf("Appstart\n");
                    [mfi->session performSelectorOnMainThread:@selector(Appstartmessage) withObject:nil waitUntilDone:YES];
                    
                }
                else
                {
                    // freerdp_channel_send(instance->context->rdp,channelId,data,size);
                }
            }
        }
    }
}
void ios_process_channel_event(rdpChannels* channels, freerdp* instance)
{
    wMessage* event = freerdp_channels_pop_event(channels);
    if (event)
        freerdp_event_free(event);
}

#pragma mark -
#pragma mark Running the connection

int
ios_run_freerdp(freerdp * instance)
{
	mfContext* context = (mfContext*)instance->context;
	mfInfo* mfi = context->mfi;
	rdpChannels* channels = instance->context->channels;
		
	mfi->connection_state = TSXConnectionConnecting;
	
	if (!freerdp_connect(instance))
	{
		NSLog(@"%s: inst->rdp_connect failed", __func__);
		return mfi->unwanted ? MF_EXIT_CONN_CANCELED : MF_EXIT_CONN_FAILED;
	}
	
	if (mfi->unwanted)
		return MF_EXIT_CONN_CANCELED;

	mfi->connection_state = TSXConnectionConnected;
			
	// Connection main loop
	NSAutoreleasePool* pool;
	int i;
	int fds;
	int max_fds;
	int rcount;
	int wcount;
	void* rfds[32];
	void* wfds[32];
	fd_set rfds_set;
	fd_set wfds_set;
    struct timeval timeout;
    int select_status;
	
	memset(rfds, 0, sizeof(rfds));
	memset(wfds, 0, sizeof(wfds));

	while (!freerdp_shall_disconnect(instance))
	{
		rcount = wcount = 0;
		
		pool = [[NSAutoreleasePool alloc] init];

		if (freerdp_get_fds(instance, rfds, &rcount, wfds, &wcount) != TRUE)
		{
			NSLog(@"%s: inst->rdp_get_fds failed", __func__);
			break;
		}

		if (freerdp_channels_get_fds(channels, instance, rfds, &rcount, wfds, &wcount) != TRUE)
		{
			NSLog(@"%s: freerdp_chanman_get_fds failed", __func__);
			break;
		}

		if (ios_events_get_fds(mfi, rfds, &rcount, wfds, &wcount) != TRUE)
		{
			NSLog(@"%s: ios_events_get_fds", __func__);
			break;
		}
		
		max_fds = 0;
		FD_ZERO(&rfds_set);
		FD_ZERO(&wfds_set);
		
		for (i = 0; i < rcount; i++)
		{
			fds = (int)(long)(rfds[i]);
			
			if (fds > max_fds)
				max_fds = fds;
			
			FD_SET(fds, &rfds_set);
		}
        
		if (max_fds == 0)
			break;
	
        timeout.tv_sec = 1;
        timeout.tv_usec = 0;

        select_status = select(max_fds + 1, &rfds_set, NULL, NULL, &timeout);
        
        // timeout?
        if (select_status == 0)
            continue;
        else if (select_status == -1)
		{
			/* these are not really errors */
			if (!((errno == EAGAIN) ||
				  (errno == EWOULDBLOCK) ||
				  (errno == EINPROGRESS) ||
				  (errno == EINTR))) /* signal occurred */
			{
				NSLog(@"%s: select failed!", __func__);
				break;
			}
		}
		
		// Check the libfreerdp fds
		if (freerdp_check_fds(instance) != true)
		{
			NSLog(@"%s: inst->rdp_check_fds failed.", __func__);
			break;
		}
		
		// Check input event fds
		if (ios_events_check_fds(mfi, &rfds_set) != TRUE)
		{
			// This event will fail when the app asks for a disconnect.
			//NSLog(@"%s: ios_events_check_fds failed: terminating connection.", __func__);
			break;
		}
		
		// Check channel fds
		if (freerdp_channels_check_fds(channels, instance) != TRUE)
		{
			NSLog(@"%s: freerdp_chanman_check_fds failed", __func__);
			break;
		}
        ios_process_channel_event(channels, instance);

		[pool release]; pool = nil;
	}	

	CGContextRelease(mfi->bitmap_context);
	mfi->bitmap_context = NULL;	
	mfi->connection_state = TSXConnectionDisconnected;
	
	// Cleanup
	freerdp_channels_close(channels, instance);
	freerdp_disconnect(instance);
	gdi_free(instance);
    cache_free(instance->context->cache);
	
	[pool release]; pool = nil;
	return MF_EXIT_SUCCESS;
}

#pragma mark -
#pragma mark Context callbacks

int ios_context_new(freerdp* instance, rdpContext* context)
{
	mfInfo* mfi = (mfInfo*)calloc(1, sizeof(mfInfo));
	((mfContext*) context)->mfi = mfi;
	context->channels = freerdp_channels_new();
	ios_events_create_pipe(mfi);
	
	mfi->_context = context;
	mfi->context = (mfContext*)context;
	mfi->context->settings = instance->settings;
	mfi->instance = instance;
	return 0;
}

void ios_context_free(freerdp* instance, rdpContext* context)
{
	mfInfo* mfi = ((mfContext*) context)->mfi;
	freerdp_channels_free(context->channels);
	ios_events_free_pipe(mfi);
	free(mfi);
}

#pragma mark -
#pragma mark Initialization and cleanup

freerdp* ios_freerdp_new()
{
	freerdp* inst = freerdp_new();
	
	inst->PreConnect = ios_pre_connect;
	inst->PostConnect = ios_post_connect;
	inst->Authenticate = ios_ui_authenticate;
	inst->VerifyCertificate = ios_ui_check_certificate;
    inst->VerifyChangedCertificate = ios_ui_check_changed_certificate;
    inst->ReceiveChannelData = ios_receive_channel_data;
    
	inst->ContextSize = sizeof(mfContext);
	inst->ContextNew = ios_context_new;
	inst->ContextFree = ios_context_free;
	freerdp_context_new(inst);
    
    // determine new home path
    NSString* home_path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    free(inst->settings->HomePath);
    free(inst->settings->ConfigPath);
    inst->settings->HomePath = strdup([home_path UTF8String]);
    inst->settings->ConfigPath = strdup([[home_path stringByAppendingPathComponent:@".freerdp"] UTF8String]);

	return inst;
}

void ios_freerdp_free(freerdp* instance)
{
	freerdp_context_free(instance);
	freerdp_free(instance);
}

void ios_init_freerdp()
{
	signal(SIGPIPE, SIG_IGN);
	freerdp_channels_global_init();
    freerdp_register_addin_provider(freerdp_channels_load_static_addin_entry, 0);
}

void ios_uninit_freerdp()
{
	freerdp_channels_global_uninit();
}

