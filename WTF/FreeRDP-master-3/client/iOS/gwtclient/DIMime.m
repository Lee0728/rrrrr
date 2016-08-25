//
//  DIMime.c
//  iRdesktop
//
//  Created by WuYonghua on 11-9-14.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//{ The mime encoding table. Do not alter. }
#include "DIMime.h"

unsigned char MIME_ENCODE_TABLE[64] = 
{
    65,  66,  67,  68,  69,  70,  71,  72, //  00 - 07
    73,  74,  75,  76,  77,  78,  79,  80, //  08 - 15
    81,  82,  83,  84,  85,  86,  87,  88, //  16 - 23
    89,  90,  97,  98,  99, 100, 101, 102, //  24 - 31
    103, 104, 105, 106, 107, 108, 109, 110, //  32 - 39
    111, 112, 113, 114, 115, 116, 117, 	118, //  40 - 47
    119, 120, 121, 122,  48,  49,  50,  51, //  48 - 55
    52,  53,  54,  55,  56,  57,  43,  47  //  56 - 63
}; 

uint32 MIME_DECODE_TABLE[256] = 
{
    255, 255, 255, 255, 255, 255, 255, 255, //   0 -   7
    255, 255, 255, 255, 255, 255, 255, 255, //   8 -  15
    255, 255, 255, 255, 255, 255, 255, 255, //  16 -  23
    255, 255, 255, 255, 255, 255, 255, 255, //  24 -  31
    255, 255, 255, 255, 255, 255, 255, 255, //  32 -  39
    255, 255, 255,   62, 255, 255, 255,  63, //  40 -  47
    52,  53,  54,  55,  56,  57,  58,  59, //  48 -  55
    60,  61, 255, 255, 255, 255, 255, 255, //  56 -  63
    255,   0,   1,   2,   3,   4,   5,   6, //  64 -  71
    7,   8,   9,  10,  11,  12,  13,  14, //  72 -  79
    15,  16,  17,  18,  19,  20,  21,  22, //  80 -  87
    23,  24,  25, 255, 255, 255, 255, 255, //  88 -  95
    255,  26,  27,  28,  29,  30,  31,  32, //  96 - 103
    33,  34,  35,  36,  37,  38,  39,  40, // 1 4 - 111
    41,  42,  43,  44,  45,  46,  47,  48, // 112 - 119
    49, 50, 51, 255, 255, 255, 255, 255, // 120 - 127
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,       
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255
};

/****************************
 Encoding Core
 ***************************/
void MimeEncodeFullLines(const char *inputBuf,const uint32 inputLen,const char *outputBuf)
{
    uint32 B,innerLimit,outerLimit;
    PByte3 inPtr;
    PByte4 outPtr;
    
    if (inputLen < MIME_DECODE_LINE_BREAK)  return;
    inPtr = (PByte3)inputBuf;
    outPtr = (PByte4)outputBuf;
    
    innerLimit = (int)inPtr;
    innerLimit += MIME_DECODE_LINE_BREAK;
    
    outerLimit = (int)inPtr;
    outerLimit += inputLen;
    
    //multiple line loop
    do
    {//single line loop
        do
        {//read 3 bytes from inputbuf
            B = inPtr->b1;
            B <<= 8;
            B |= inPtr->b2;
            B <<= 8;
            B |= inPtr->b3;
            inPtr++;
            //write 4 bytes to outputbuf (in reverse order)
            outPtr->b4 = MIME_ENCODE_TABLE[B & 0x3F];
            B >>= 6;
            outPtr->b3 = MIME_ENCODE_TABLE[B & 0x3F];
            B >>= 6;
            outPtr->b2 = MIME_ENCODE_TABLE[B & 0x3F];
            B >>= 6;
            outPtr->b1 = MIME_ENCODE_TABLE[B];
            outPtr++;
        }while ((int)inPtr < innerLimit);
        
        //write line break (CRLF).
        outPtr->b1 = 13;
        outPtr->b2 = 10;
        outPtr = (PByte4)((int)outPtr + 2);
        
        innerLimit += MIME_DECODE_LINE_BREAK;
        
    }while(innerLimit <= outerLimit);
}

void MimeEncodeNoCRLF(const char *inputBuf,const uint32 inputLen,const char *outputBuf)
{
    uint32 B,innerLimit,outerLimit;
    PByte3 inPtr;
    PByte4 outPtr;
    
    if (inputLen == 0) return;
    
    inPtr = (PByte3)inputBuf;
    outPtr = (PByte4)outputBuf;
    
    outerLimit = inputLen / 3 * 3;
    
    innerLimit = (int)inPtr;
    innerLimit += outerLimit;
    
    //last line loop
    while ((int)inPtr < innerLimit) 
    {
        //read 3 bytes from inputbuf
        B = inPtr->b1;
        B <<= 8;
        B |= inPtr->b2;
        B <<= 8;
        B |= inPtr->b3;
        inPtr++;
        
        //write 4 bytes to  outputbuf (in reverse order)
        outPtr->b4 = MIME_ENCODE_TABLE[B & 0x3F];
        B >>=6;
        outPtr->b3 = MIME_ENCODE_TABLE[B & 0x3F];
        B >>=6;
        outPtr->b2 = MIME_ENCODE_TABLE[B & 0x3F];
        B >>=6;
        outPtr->b1 = MIME_ENCODE_TABLE[B];
        outPtr++;
    }
    //end of data &padding;
    switch (inputLen - outerLimit)
    {
    case 1:
            B = inPtr->b1;
            B <<= 4;
            outPtr->b2 = MIME_ENCODE_TABLE[B & 0x3F];
            
            B >>= 6;
            outPtr->b1 = MIME_ENCODE_TABLE[B];
            outPtr->b3 = MIME_PAD_CHAR;
            outPtr->b4 = MIME_PAD_CHAR;
            break;
    case 2:
            B = inPtr->b1;
            B <<= 8;
            B |= inPtr->b2;
            B <<= 2;
            outPtr->b3 = MIME_ENCODE_TABLE[B & 0x3F];
            B >>= 6;
            outPtr->b2 = MIME_ENCODE_TABLE[B & 0x3F];
            B >>= 6;
            outPtr->b1 = MIME_ENCODE_TABLE[B];
            outPtr->b4 = MIME_PAD_CHAR; //pad remaining byte
            break;
    }
    
}

/****************************
 Decoding Core
 ****************************/
uint32 MimeDecodePartial(const char *inputBuf,uint32 inputBufLen,char *outputBuf,uint32 *byteBuf,uint32 *byteBufSpace)
{
    uint32 lByteBuf,lBytebufSpace,C;
    uint8 *inPtr,*outerLimit;
    PByte3 outPtr;
    
    if (inputBufLen > 0){
        inPtr = (UInt8 *)inputBuf;
        outerLimit = inPtr + inputBufLen;
        outPtr = (PByte3)outputBuf;
        lByteBuf = *byteBuf;
        lBytebufSpace = *byteBufSpace;
        
        while (inPtr != outerLimit)
        {
            C = MIME_DECODE_TABLE[*inPtr];
            inPtr++;
            if (C == 0xFF) continue;
            lByteBuf <<= 6;
            lByteBuf |= C;
            lBytebufSpace--;
           
            if (lBytebufSpace != 0) continue;
            
            (*outPtr).b3 = (uint8)lByteBuf;
            lByteBuf >>= 8;
            
            (*outPtr).b2 = (uint8)lByteBuf;
            lByteBuf >>= 8;
            
            (*outPtr).b1 = (uint8)lByteBuf;
            
            lByteBuf = 0;
            outPtr++;
            lBytebufSpace = 4;
        }
    	*byteBuf = lByteBuf;
        *byteBufSpace = lBytebufSpace;
        int ret = ((char *)outPtr - outputBuf);
        return ret;
    }
    return 0;
};

uint32 MimeDecodepartialEnd(char *outputBuf,uint32 byteBuf,uint32 byteBufSpace,uint32 endIdx)
{
    uint32 lbyteBuf;
    char s[2];
    switch (byteBufSpace)
    {
    case 1:
            lbyteBuf = byteBuf >> 2;
            s[1] = (uint8)lbyteBuf;
            lbyteBuf >>= 8;
            s[0] = (uint8)lbyteBuf;
            outputBuf[endIdx + 1] = s[0];
            outputBuf[endIdx + 2] = s[1];  
            return 2;
            break;
    case 2:
            lbyteBuf = byteBuf >> 4;
            s[0] = (uint8)lbyteBuf;
            outputBuf[endIdx + 1] = s[0];
            return 1;
            break;
    default:
            return 0;
            break;
    }
};
/***************************/
/* function for outer call */
/***************************/
void MimeEncode(const char *inputBuffer,uint32 bufferLen,char *outputBuffer)
{
    uint32 IDelta,ODelta;
    char inputBuf[MIME_BUFFER_SIZE];
    memset(inputBuf, 0, bufferLen);
    memcpy(inputBuf, inputBuffer, bufferLen);
    
    MimeEncodeFullLines(inputBuf,bufferLen,outputBuffer);
    
    IDelta = bufferLen / MIME_DECODE_LINE_BREAK;
    ODelta = IDelta * (MIME_ENCODE_LINE_BREAK + 2);
    IDelta = IDelta * MIME_DECODE_LINE_BREAK;
    MimeEncodeNoCRLF((char *)(inputBuf+IDelta), bufferLen-IDelta, (char *)(outputBuffer+ODelta));
};

void MimeDecode(const char *inputBuffer,int bufferLen,uint32 *newLen, char *outputBuffer)
{
    uint32 byteBuf = 0;
    uint32 byteBufSpace = 4;
    
    char inputBuf[MIME_BUFFER_SIZE];
    memset(inputBuf, 0, sizeof(inputBuf));

    memcpy(inputBuf, inputBuffer,bufferLen);
    
    *newLen = MimeDecodePartial(inputBuf, bufferLen, outputBuffer, &byteBuf, &byteBufSpace);
    *newLen += MimeDecodepartialEnd(outputBuffer, byteBuf, byteBufSpace,*newLen);
};




