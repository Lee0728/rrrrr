//
//  packect.h
//  FreeRDP
//
//  Created by 吴 永华 on 14-4-4.
//
//

#ifndef FreeRDP_packect_h
#define FreeRDP_packect_h
#define flaghead 0x73667073
#define list 0x0000
#define delete 0x01
#define upload 0x03
#define download 0x0004
#define newfoldcmd 0x0005

int sockfd;
struct packethead{
    unsigned int Packetflag;
    unsigned int Packetlength;
    unsigned short Packetcontent;
    
};
char* unicode_to_utf8(uint16_t *in, int insize);
int Sendcmd(int length,unsigned short *Cmdchar,int cmdtype,char*hostname,int port);
int Sendcmdupload(int length,unsigned short *Cmdchar);
unsigned char* readcmd(int length,int *numreceive);
int writefile(int length,unsigned char* data);
void delay_time(int i);
int Sendcmddownload(int length,unsigned short *Cmdchar);
unsigned char* readcmdend(int length);
unsigned short* readcmdstr(int length);
unsigned char* readcmdhead(long int length);
long long int readcmddownloadlength(void);
unsigned char* readcommand(int length);
int VirtualTcpConnect(const char *host,int port);
int enc_unicode_to_utf8_one(unsigned long unic, unsigned char *pOutput,
                            int outSize);
//unsigned char* unicode_to_utf8(uint16_t *in, int insize);
#endif
