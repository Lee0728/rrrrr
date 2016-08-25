/**
 * FreeRDP: A Remote Desktop Protocol Implementation
 * Sample Virtual Channel
 *
 * Copyright 2009-2012 Jay Sorg
 * Copyright 2010-2012 Vic Lee
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#ifndef _WIN32
#include <sys/time.h>
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <winpr/crt.h>

#include <freerdp/types.h>
#include <freerdp/constants.h>
#include <winpr/stream.h>
#include <freerdp/utils/list.h>
#include <freerdp/utils/svc_plugin.h>

#include "echo_main.h"

struct CSMP_plugin
{
	rdpSvcPlugin plugin;
    
	/* put your private data here */
    
};

static void CSMP_process_interval(rdpSvcPlugin* plugin)
{
	//printf("CSMP_process_interval:\n");
}

static void CSMP_process_receive(rdpSvcPlugin* plugin, wStream* data_in)
{
	int bytes;
	wStream* data_out;
	CSMPPlugin* CSMP = (CSMPPlugin*) plugin;
	unsigned char buf[2000];
	int i1 = 0;
    
	
    
	//printf("CSML_process_receive:\n");
    
	if (CSMP == NULL)
	{
		printf("CSML_process_receive: CSML is nil\n");
		return;
	}
    
	/* process data in(from server) here */
	/* here we just send the same data back */
    
	if(data_in != NULL )
	{
		bytes = data_in->length;
	}
	printf("CSML_process_receive: got bytes %d\n", bytes);
	//if (bytes > 0 && bytes < 2000)
	//{
    
    seamless_process(plugin,data_in);
    //}
    /*int bytes;
     STREAM* data_out;
     CSMPPlugin* CSMP = (CSMPPlugin*) plugin;
     
     //printf("CSMP_process_receive:\n");
     
     if (CSMP == NULL)
     {
     printf("CSMP_process_receive: CSMP is nil\n");
     return;
     }
     
     
     
     if(data_in != NULL )
     {
     bytes = stream_get_size(data_in);
     }
     printf("CSMP_process_receive: got bytes %d\n", bytes);
     if (bytes > 0 && bytes < 2000)
     {
     
     //seamless_process(plugin,data_in);
     
     
     //	data_out = stream_new(bytes);
     //	stream_copy(data_out, data_in, bytes);
     
     
     //	bytes = stream_get_length(data_in);
     //	printf("CSMP_process_receive: sending bytes %d\n", bytes);
     
     //	svc_plugin_send(plugin, data_out);
     }
     
     stream_free(data_in);*/
}

static void CSMP_process_connect(rdpSvcPlugin* plugin)
{
	CSMPPlugin* CSMP = (CSMPPlugin*) plugin;
	DEBUG_SVC("connecting");
    
	printf("CSMP_process_connect:\n");
    
	if (CSMP == NULL)
	{
		return;
	}
    
	/* if you want a call from channel thread once is a while do this */
	/*plugin->interval_ms = 1000;
     plugin->interval_callback = CSMP_process_interval;
     plugin->receive_callback = CSMP_process_receive;*/
    
}

static void CSMP_process_event(rdpSvcPlugin* plugin, wMessage* event)
{
	printf("CSMP_process_event:\n");
    
	/* events comming from main freerdp window to plugin */
	/* send them back with svc_plugin_send_event */
    
	freerdp_event_free(event);
}

static void CSMP_process_terminate(rdpSvcPlugin* plugin)
{
	CSMPPlugin* CSMP = (CSMPPlugin*)plugin;
    
	printf("CSMP_process_terminate:\n");
    
	if (CSMP == NULL)
	{
		return;
	}
    
	/* put your cleanup here */
    
	free(plugin);
}

#define VirtualChannelEntry	CSMP_VirtualChannelEntry

int VirtualChannelEntry(PCHANNEL_ENTRY_POINTS pEntryPoints)
{
	CSMPPlugin* _p;
    
	_p = (CSMPPlugin*) malloc(sizeof(CSMPPlugin));
	ZeroMemory(_p, sizeof(CSMPPlugin));
    
	_p->plugin.channel_def.options =
    CHANNEL_OPTION_INITIALIZED |
    CHANNEL_OPTION_ENCRYPT_RDP |
    CHANNEL_OPTION_COMPRESS_RDP |
    CHANNEL_OPTION_SHOW_PROTOCOL;
    
	strcpy(_p->plugin.channel_def.name, "CSMP");
    
	_p->plugin.connect_callback = CSMP_process_connect;
	_p->plugin.receive_callback = CSMP_process_receive;
	_p->plugin.event_callback = CSMP_process_event;
	_p->plugin.terminate_callback = CSMP_process_terminate;
    
	svc_plugin_init((rdpSvcPlugin*) _p, pEntryPoints);
    
	return 1;
}
