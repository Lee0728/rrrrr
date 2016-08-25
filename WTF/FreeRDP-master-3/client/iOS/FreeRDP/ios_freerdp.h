/*
 RDP run-loop
 
 Copyright 2013 Thinstuff Technologies GmbH, Authors: Martin Fleisz, Dorian Johnson
 
 This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
 If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

#import <CoreGraphics/CoreGraphics.h>

#import <freerdp/freerdp.h>
#import <freerdp/channels/channels.h>
#import "TSXTypes.h"
#import "Utils.h"

@class RDPSession, RDPSessionView;

// FreeRDP extended structs
typedef struct mf_info mfInfo;
int getchannelid;
char output[40];
typedef struct mf_context
{
	rdpContext _p;
	
	mfInfo* mfi;
	rdpSettings* settings;
} mfContext;

typedef struct ShellClientMSG_new {
    unsigned char Flag[3];
    unsigned short MSGID;
    char AppID[12];    //启动的应用程序的ID
    char strlen[4];//应用程序的
    char AppParam[4];
} *PShellClientMSG_new,TShellClientMSG_new;
struct mf_info
{
	// RDP
	freerdp* instance;
	mfContext* context;
	rdpContext* _context;
	
	// UI
	RDPSession* session;
	
	// Graphics
	CGContextRef bitmap_context;
	
	// Events
	int event_pipe_producer, event_pipe_consumer;

	// Tracking connection state
	volatile TSXConnectionState connection_state;
	volatile BOOL unwanted; // set when controlling Session no longer wants the connection to continue
};


#define MFI_FROM_INSTANCE(inst) (((mfContext*)((inst)->context))->mfi)


enum MF_EXIT_CODE
{
	MF_EXIT_SUCCESS = 0,

	MF_EXIT_CONN_FAILED = 128,
	MF_EXIT_CONN_CANCELED = 129,
    MF_EXIT_LOGON_TIMEOUT = 130,
	
	MF_EXIT_UNKNOWN = 255
};
#pragma pack(1)
typedef struct Param_new{
    unsigned int WParam;
    unsigned int LParam;
    unsigned int Reso;
} *PParam_new,TParam_new;
typedef struct Param{
    unsigned int WParam;
    unsigned int LParam;
} *PParam,TParam;
typedef struct ShellServerMSG_new{
    unsigned char Flag[3];
    unsigned short MSGID;
    TParam Param;
} *PShellServerMSG_new,TShellServerMSG_new;
typedef struct ShellServerMSG {
    unsigned char Flag[3];
    unsigned short MSGID;
    char AppID[256];
    TParam Param;
} *PShellServerMSG,TShellServerMSG;

typedef struct ShellClientMSG {
    unsigned char Flag[3];
    unsigned short MSGID;
    char AppID[256];    //启动的应用程序的ID
    signed char AppParam[256];//应用程序的
    TParam Param;
} *PShellClientMSG,TShellClientMSG;

typedef struct WideString
{
    char c1;
    char c2;
} TWideString,*PWideString;
void seamless_process2(UINT8* data,int size,freerdp* instance,int channelId);
void ios_init_freerdp(void);
void ios_uninit_freerdp(void);
void seamless_process1(UINT8* data,int size,freerdp* instance,int channelId);
freerdp* ios_freerdp_new(void);
int ios_run_freerdp(freerdp* instance);
void ios_freerdp_free(freerdp* instance);
void Sendvitualtext(freerdp* instance,unsigned short Code,NSString *appIDorNil);



