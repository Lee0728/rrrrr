//
//  tcp.h
//  FreeRDP
//
//  Created by 吴 永华 on 14-4-4.
//
//

#ifndef FreeRDP_tcp_h
#define FreeRDP_tcp_h
#include <freerdp/utils/tcp.h>

typedef struct packet{
    char packectflag[4];
    unsigned int lenth;
    unsigned short type;
    unsigned char *content;
}Packectdata;

int Send_Packet_Plist(void);
int vitrual_tcp_connect(const char* hostname, int port);
int vitrual_tcp_read(int sockfd, BYTE* data, int length);
int vitrual_tcp_write(int sockfd, BYTE* data, int length);

#endif
