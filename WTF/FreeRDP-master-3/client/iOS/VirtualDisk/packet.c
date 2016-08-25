//
//  packet.c
//  FreeRDP
//
//  Created by 吴 永华 on 14-4-4.
//
//

#include <stdio.h>
#include <tcp.h>
#include <stdlib.h>
#include <packect.h>

//发送包头
/*int sendcmd(int length ,unsigned short *Cmdchar)
{

const char *host = "192.168.2.108";
sockfd = vitrual_tcp_connect(host,5890);
unsigned char *str = (unsigned char*)Cmdchar;
//Send_Packet_Plist();
unsigned char *data = malloc(length);

   
data[0]=0x73;
data[1]=0x70;
data[2]=0x66;
data[3]=0x73;
data[4]=length;
data[5]=0;
data[6]=0;
data[7]=0;
data[8]=0;
data[9]=0;
    data[10] = 0;
    data[11] = 117;
for(int i=10;i<length;i++)
{
    data[i] = *str;
    printf("the str is %d \n",data[i]);
    str++;
}


vitrual_tcp_write(sockfd, data, length);
    return 0;
}*/
int VirtualTcpConnect(const char *host,int port)
{
    sockfd = vitrual_tcp_connect(host,port);
    printf("the sockfd is %d",sockfd);
    return sockfd;
}
int Sendcmd(int length,unsigned short *Cmdchar,int cmdtype,char*hostname,int port)
{
    VirtualTcpConnect(hostname, port);
    if(sockfd == -1)
    {
        return -1;
    }
    else
    {
    unsigned char *str = (unsigned char*)Cmdchar;
    unsigned char *data = (unsigned char*)malloc(length*sizeof(unsigned char));
    struct packethead datahead;
    datahead.Packetflag = flaghead;
    datahead.Packetlength = length;
    datahead.Packetcontent = cmdtype;
    int m = sizeof(datahead);
    printf("the m is %d",m);
    memcpy(data,(char *)(&datahead),10);
    memcpy(data+10,str,length-10);
    vitrual_tcp_write(sockfd, data, length);
    free(data);
    return 0;
    }
}
int Sendcmdupload(int length,unsigned short *Cmdchar)
{

    unsigned char *str = (unsigned char*)Cmdchar;
    unsigned char *data = malloc(length);
    struct packethead datahead;
    datahead.Packetflag = flaghead;
    datahead.Packetlength = length;
    datahead.Packetcontent = upload;
    int m = sizeof(datahead);
    printf("the m is %d",m);
    memcpy(data,(char *)(&datahead),10);
    memcpy(data+10,str,length-10);
    vitrual_tcp_write(sockfd, data, length);
    return 0;
}
int Sendcmddownload(int length,unsigned short *Cmdchar)
{
    const char *host = "192.168.2.108";
    sockfd = vitrual_tcp_connect(host,5890);
    unsigned char *str = (unsigned char*)Cmdchar;
    unsigned char *data = malloc(length);
    data[0]=0x73;
    data[1]=0x70;
    data[2]=0x66;
    data[3]=0x73;
    data[4]= length&0xff;
    data[5]= (length>>8)&0xff;
    data[6]= (length>>16)&0xff;
    data[7]= (length>>24)&0xff;
    /*data[4]=length;
     data[5]=0;
     data[6]=0;
     data[7]=0;*/
    data[8]=4;
    data[9]=0;
    
    for(int i=10;i<length;i++)
    {
        
        data[i] = *str;
        printf("the str is %d \n",data[i]);
        str++;
    }
    for(int i=0;i<100;i++)
    {
        //printf("the data is %d",data[i]);
    }
    vitrual_tcp_write(sockfd, data, length);
    return 0;
}
int writefile(int length,unsigned char* data)
{
    vitrual_tcp_write(sockfd, data, length);
    return 0;
}
int readgetstrlength(int length)
{
    struct packethead *getdatahead;
    unsigned char *data=(unsigned)malloc(length);

    vitrual_tcp_read(sockfd,data,length);
    getdatahead = (struct packethead *)data;
    int getlength = getdatahead->Packetlength;
    printf("the getlength is %d",getlength);
    return getlength;
}
unsigned char* readcommand(int length)
{
    unsigned char *data=(unsigned)malloc(length);
    
    vitrual_tcp_read(sockfd,data,length);
    /*if(num!=length)
     {
     printf("the length is %d",num);
     }*/
    /*for(int i=0;i<length;i++)
     {
     printf("the readdata is %d",data[i]);
     }*/
    return data;
}
unsigned char* readcmd(int length,int *numreceive)
{
    //VirtualTcpConnect("192.168.2.116", 5890);
    unsigned char *data=(unsigned)malloc(length);
    
     *numreceive= vitrual_tcp_read(sockfd,data,length);
    /*if(num!=length)
    {
    printf("the length is %d",num);
    }*/
    /*for(int i=0;i<length;i++)
    {
        printf("the readdata is %d",data[i]);
    }*/
    return data;
}
long long int readcmddownloadlength(void)
{
    unsigned char *data;
    long long int *getdata;
    getdata = malloc(sizeof(long long int));
    data = (unsigned char*)readcmdhead(18)+10;
    for(int i =0;i<8;i++)
    {
        printf("the getdata is %d",*(data+i));
    }
    getdata = (long long int *)data;
    printf("the getdata is %lld",*getdata);
    /*for(int i=0;i<8;i++)
    {
        *((unsigned char *)(getdata+i)) = *(data+7-i);
        
    }
    for(int i=0;i<8;i++)
    {
        printf("the data is %d",*((unsigned char *)(getdata+i)));
    }*/
    return *getdata;
}
unsigned char* readcmdhead(long int length)
{
    unsigned char *data=(unsigned char*)malloc(length);
    memset(data,0,length);
    vitrual_tcp_read(sockfd,data,length);
    
    for(int i=0;i<18;i++)
    {
       // printf("the data is %d",data[i]);
    }
    return data;
    
    //free(data);
    //return (data[5]<<8)+data[4];
}
void delay_time(int i)
{
    while(--i);
}
unsigned short* readcmdstr(int length)
{
    unsigned char *data= (unsigned char *)malloc(length);
    
    vitrual_tcp_read(sockfd,data,length);
    unsigned short*unidata = (unsigned short *)data;
    for(int i=0;i<length;i++)
    {
        //printf("the data is %d",data[i]);
    }
    return unidata;
}
int utf8_to_unicode(uint8_t *in, uint16_t **out, int *outsize)
{
    uint8_t *p = in;
    uint16_t *result = NULL;
    int resultsize = 0;
    uint8_t *tmp = NULL;
    
    result = (uint16_t *)malloc(strlen(in) * 2 + 2); /* should be enough */
    memset(result, 0, strlen(in) * 2 + 2);
    tmp = (uint8_t *)result;
    
    while(*p)
    {
        if (*p >= 0x00 && *p <= 0x7f)
        {
            *tmp = *p;
            tmp++;
            *tmp = '\0';
            resultsize += 2;
        }
        else if ((*p & (0xff << 5))== 0xc0)
        {
            uint16_t t = 0;
            uint8_t t1 = 0;
            uint8_t t2 = 0;
            
            t1 = *p & (0xff >> 3);
            p++;
            t2 = *p & (0xff >> 2);
            
            *tmp = t2 | ((t1 & (0xff >> 6)) << 6);//t1 >> 2;
            tmp++;
            
            *tmp = t1 >> 2;//t2 | ((t1 & (0xff >> 6)) << 6);
            tmp++;
            
            resultsize += 2;
        }
        else if ((*p & (0xff << 4))== 0xe0)
        {
            uint16_t t = 0;
            uint8_t t1 = 0;
            uint8_t t2 = 0;
            uint8_t t3 = 0;
            
            t1 = *p & (0xff >> 3);
            p++;
            t2 = *p & (0xff >> 2);
            p++;
            t3 = *p & (0xff >> 2);
            
            //Little Endian
            *tmp = ((t2 & (0xff >> 6)) << 6) | t3;//(t1 << 4) | (t2 >> 2);
            tmp++;
            
            *tmp = (t1 << 4) | (t2 >> 2);//((t2 & (0xff >> 6)) << 6) | t3;
            tmp++;
            resultsize += 2;
        }
        
        p++;
    }
    
    *tmp = '\0';
    tmp++;
    *tmp = '\0';
    resultsize += 2;
    
    *out = result;
    *outsize = resultsize; 
    return 0;
}
char* unicode_to_utf8(uint16_t *in, int insize)
{
    int i = 0;
    int outsize = 0;
    int charscount = 0;
    char *result = NULL;
    char *tmp = NULL;
    
    charscount = insize / sizeof(uint16_t);
    result = (char *)malloc(charscount * 3 + 1);
    memset(result, 0, charscount * 3 + 1);
    tmp = result;
    
    for (i = 0; i < charscount; i++)
    {
        uint16_t unicode = in[i];
        
        if (unicode >= 0x0000 && unicode <= 0x007f)
        {
            *tmp = (uint8_t)unicode;
            //printf("the tmp is %d",*tmp);
            tmp += 1;
            outsize += 1;
        }
        else if (unicode >= 0x0080 && unicode <= 0x07ff)
        {
            *tmp = 0xc0 | (unicode >> 6);
           // printf("the tmp is %d",*tmp);
            tmp += 1;
            *tmp = 0x80 | (unicode & (0xff >> 2));
            //printf("the tmp is %d",*tmp);
            tmp += 1;
            outsize += 2;
        }
        else if (unicode >= 0x0800 && unicode <= 0xffff)
        {
            //printf("the unicode is %d",unicode);
            *tmp = 0xe0 | (unicode >> 12);
            //printf("the tmp is %d",*tmp);
            tmp += 1;
            *tmp = 0x80 | (unicode >> 6 & 0x003f);
            //printf("the tmp is %d",*tmp);
            tmp += 1;
            *tmp = 0x80 | (unicode & (0xff >> 2));
            //printf("the tmp is %c",*tmp);
            tmp += 1;
            outsize += 3;
        }
        
    }
    
    *tmp = '\0';
    //*out = result;
    return result;
   // return 0;
}
int enc_unicode_to_utf8_one(unsigned long unic, unsigned char *pOutput,
                            int outSize)
{
    //assert(pOutput != NULL);
    //assert(outSize >= 6);
    
    if ( unic <= 0x0000007F )
    {
        // * U-00000000 - U-0000007F:  0xxxxxxx
        *pOutput     = (unic & 0x7F);
        return 1;
    }
    else if ( unic >= 0x00000080 && unic <= 0x000007FF )
    {
        // * U-00000080 - U-000007FF:  110xxxxx 10xxxxxx
        *(pOutput+1) = (unic & 0x3F) | 0x80;
        *pOutput     = ((unic >> 6) & 0x1F) | 0xC0;
        return 2;
    }
    else if ( unic >= 0x00000800 && unic <= 0x0000FFFF )
    {
        // * U-00000800 - U-0000FFFF:  1110xxxx 10xxxxxx 10xxxxxx
        *(pOutput+2) = (unic & 0x3F) | 0x80;
        *(pOutput+1) = ((unic >>  6) & 0x3F) | 0x80;
        *pOutput     = ((unic >> 12) & 0x0F) | 0xE0;
        return 3;
    }
    else if ( unic >= 0x00010000 && unic <= 0x001FFFFF )
    {
        // * U-00010000 - U-001FFFFF:  11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
        *(pOutput+3) = (unic & 0x3F) | 0x80;
        *(pOutput+2) = ((unic >>  6) & 0x3F) | 0x80;
        *(pOutput+1) = ((unic >> 12) & 0x3F) | 0x80;
        *pOutput     = ((unic >> 18) & 0x07) | 0xF0;
        return 4;
    }
    else if ( unic >= 0x00200000 && unic <= 0x03FFFFFF )
    {
        // * U-00200000 - U-03FFFFFF:  111110xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
        *(pOutput+4) = (unic & 0x3F) | 0x80;
        *(pOutput+3) = ((unic >>  6) & 0x3F) | 0x80;
        *(pOutput+2) = ((unic >> 12) & 0x3F) | 0x80;
        *(pOutput+1) = ((unic >> 18) & 0x3F) | 0x80;
        *pOutput     = ((unic >> 24) & 0x03) | 0xF8;
        return 5;
    }
    else if ( unic >= 0x04000000 && unic <= 0x7FFFFFFF )
    {
        // * U-04000000 - U-7FFFFFFF:  1111110x 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
        *(pOutput+5) = (unic & 0x3F) | 0x80;
        *(pOutput+4) = ((unic >>  6) & 0x3F) | 0x80;
        *(pOutput+3) = ((unic >> 12) & 0x3F) | 0x80;
        *(pOutput+2) = ((unic >> 18) & 0x3F) | 0x80;
        *(pOutput+1) = ((unic >> 24) & 0x3F) | 0x80;
        *pOutput     = ((unic >> 30) & 0x01) | 0xFC;
        return 6;
    }
    
    return 0;  
}