//
//  DIMime.h
//  GwtClient_IOS
//
//  Created by WuYonghua on 11-10-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
#include "rdesktop.h"

#define MIME_PAD_CHAR  61
#define MIME_ENCODE_LINE_BREAK 76
#define MIME_DECODE_LINE_BREAK 57
#define MIME_BUFFER_SIZE  2736	

#pragma pack(1)
typedef struct TByte3{
    uint8 b1;
    uint8 b2;
    uint8 b3;
} *PByte3;

typedef struct TByte4{
    uint8 b1;
    uint8 b2;
    uint8 b3;
    uint8 b4;
} *PByte4;


void MimeDecode(const char *inputBuffer,int bufferLen,uint32 *newLen,char *outputBuffer);
void MimeEncode(const char *inputBuffer,uint32 bufferLen,char *outputBuffer);