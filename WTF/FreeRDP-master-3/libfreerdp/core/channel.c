/**
 * FreeRDP: A Remote Desktop Protocol Implementation
 * Virtual Channels
 *
 * Copyright 2011 Vic Lee
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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <freerdp/freerdp.h>
#include <freerdp/peer.h>
#include <freerdp/constants.h>
#include <winpr/stream.h>

#include "rdp.h"
#include "channel.h"

BOOL freerdp_channel_send(rdpRdp* rdp, UINT16 channel_id, BYTE* data, int size)
{
	wStream* s;
	UINT32 flags;
	int i, left;
    size = 25;
	int chunk_size;
	rdpChannel* channel = NULL;
    printf("the size is %d",size);
    for(i=0;i<=10;i++)
    {
        printf("the MSG is %d\n",data[i]);
    }
	for (i = 0; i < rdp->settings->ChannelCount; i++)
	{
        printf("the channelid is %d",rdp->settings->ChannelDefArray[i].ChannelId);
		if (rdp->settings->ChannelDefArray[i].ChannelId == channel_id)
		{
			channel = &rdp->settings->ChannelDefArray[i];
            printf("the channel is %d",channel_id);
			break;
		}
	}

	if (!channel)
	{
		fprintf(stderr, "freerdp_channel_send: unknown channel_id %d\n", channel_id);
		return FALSE;
	}

	flags = CHANNEL_FLAG_FIRST;
	left = size;

	while (left > 0)
	{
		s = rdp_send_stream_init(rdp);

		if (left > (int) rdp->settings->VirtualChannelChunkSize)
		{
			chunk_size = rdp->settings->VirtualChannelChunkSize;
		}
		else
		{
			chunk_size = left;
			flags |= CHANNEL_FLAG_LAST;
		}

		if ((channel->options & CHANNEL_OPTION_SHOW_PROTOCOL))
		{
			flags |= CHANNEL_FLAG_SHOW_PROTOCOL;
		}

		Stream_Write_UINT32(s, size+1);
        printf("the size is %d",size+1);
		Stream_Write_UINT32(s, flags);
        printf("the flags is %d",flags);
		Stream_EnsureCapacity(s, chunk_size+1);
        printf("the data is %d",data[0]);
        printf("the data is %d",data[1]);
        printf("the data is %d",data[2]);
        printf("the data is %d",data[3]);
        printf("the data is %d",data[4]);
        printf("the data is %d",data[5]);
        printf("the data is %d",data[6]);
        printf("the data is %d",data[7]);
        printf("the data is %d",data[8]);
        printf("the data is %d",data[0]);
        printf("the data is %d",data[0]);
        printf("the data is %d",data[0]);
        printf("the data is %d",data[0]);
        printf("the data is %d",data[0]);
        printf("the data is %d",data[0]);
        printf("the data is %d",data[0]);
		Stream_Write(s, data, chunk_size+1);
        printf("the chunk_size is %d",chunk_size+1);
		rdp_send(rdp, s, channel_id);

		data += chunk_size;
		left -= chunk_size;
		flags = 0;
	}

	return TRUE;
}

BOOL freerdp_channel_process(freerdp* instance, wStream* s, UINT16 channel_id)
{
	UINT32 length;
	UINT32 flags;
	int chunk_length;

	if (Stream_GetRemainingLength(s) < 8)
		return FALSE;
   
	Stream_Read_UINT32(s, length);
	Stream_Read_UINT32(s, flags);
	chunk_length = Stream_GetRemainingLength(s);
    
	IFCALL(instance->ReceiveChannelData, instance,
		channel_id, Stream_Pointer(s), chunk_length, flags, length);

	return TRUE;
}

BOOL freerdp_channel_peer_process(freerdp_peer* client, wStream* s, UINT16 channel_id)
{
	UINT32 length;
	UINT32 flags;
	int chunk_length;

	if (Stream_GetRemainingLength(s) < 8)
		return FALSE;

	Stream_Read_UINT32(s, length);
	Stream_Read_UINT32(s, flags);
	chunk_length = Stream_GetRemainingLength(s);

	IFCALL(client->ReceiveChannelData, client,
		channel_id, Stream_Pointer(s), chunk_length, flags, length);

	return TRUE;
}
