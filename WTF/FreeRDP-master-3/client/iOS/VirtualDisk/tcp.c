//
//  tcp.c
//  FreeRDP
//
//  Created by 吴 永华 on 14-4-4.
//
//

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <winpr/windows.h>

#include <winpr/crt.h>

#include <freerdp/utils/tcp.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <time.h>
#include <errno.h>
#include <fcntl.h>

#ifndef _WIN32

#include <netdb.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <net/if.h>
#include "tcp.h"
#ifdef __APPLE__
#ifndef TCP_KEEPIDLE
#define TCP_KEEPIDLE TCP_KEEPALIVE
#endif
#endif

#else /* ifdef _WIN32 */

#include <winpr/windows.h>

#include <winpr/crt.h>

#define SHUT_RDWR SD_BOTH
#define close(_fd) closesocket(_fd)
#endif

#ifndef MSG_NOSIGNAL
#define MSG_NOSIGNAL 0

#endif

int vitrual_tcp_connect(const char* hostname, int port)
{
	int status;
	int sockfd;
	char servname[10];
	struct addrinfo* ai;
	struct addrinfo* res;
	struct addrinfo hints = { 0 };
    
	memset(&hints, 0, sizeof(struct addrinfo));
	hints.ai_family = AF_UNSPEC;
	hints.ai_socktype = SOCK_STREAM;
    
	sprintf_s(servname, sizeof(servname), "%d", port);
	status = getaddrinfo(hostname, servname, &hints, &res);
    
	if (status != 0)
	{
		fprintf(stderr, "tcp_connect: getaddrinfo (%s)\n", gai_strerror(status));
		return -1;
	}
    
	sockfd = -1;
    
	for (ai = res; ai; ai = ai->ai_next)
	{
		sockfd = socket(ai->ai_family, ai->ai_socktype, ai->ai_protocol);
        
		if (sockfd < 0)
			continue;
        
		if (connect(sockfd, ai->ai_addr, ai->ai_addrlen) == 0)
		{
			fprintf(stderr, "connected to %s:%s\n", hostname, servname);
			break;
		}
        
		close(sockfd);
		sockfd = -1;
	}
    
	freeaddrinfo(res);
    
	if (sockfd == -1)
	{
		fprintf(stderr, "unable to connect to %s:%s\n", hostname, servname);
		return -1;
	}
    
	return sockfd;
}

int vitrual_tcp_read(int sockfd, BYTE* data, int length)
{
	int status;
    
	status = recv(sockfd, data, length, 0);
    
	if (status == 0)
	{
		return -1; /* peer disconnected */
	}
	else if (status < 0)
	{
#ifdef _WIN32
		int wsa_error = WSAGetLastError();
        
		/* No data available */
		if (wsa_error == WSAEWOULDBLOCK)
			return 0;
        
		fprintf(stderr, "recv() error: %d\n", wsa_error);
#else
		/* No data available */
		if (errno == EAGAIN || errno == EWOULDBLOCK)
			return 0;
        
		perror("recv");
#endif
		return -1;
	}
    
	return status;
}

int vitrual_tcp_write(int sockfd, BYTE* data, int length)
{
	int status;
    
	status = send(sockfd, data, length, MSG_NOSIGNAL);
    
	if (status < 0)
	{
#ifdef _WIN32
		int wsa_error = WSAGetLastError();
        
		/* No data available */
		if (wsa_error == WSAEWOULDBLOCK)
			status = 0;
        else
            perror("send");
#else
		if (errno == EAGAIN || errno == EWOULDBLOCK)
			status = 0;
		else
			perror("send");
#endif
	}
    
	return status;
}

int Send_Packet_Plist(void)
{
    //int m = sizeof(struct _Packectdata);
    //unsigned char *data = malloc(16);
    Packectdata getdata;// = (Packectdata *)data;
    //PPackectdata->content=malloc(sizeof(char));
    unsigned char* senddata = malloc(30);
    //unsigned char packetflag[4] = {0x73,0x66,0x70,0x73};
    getdata.packectflag[0] = 0x73;
    getdata.packectflag[1] = 0x66;
    getdata.packectflag[2] = 0x70;
    getdata.packectflag[3] = 0x73;
    getdata.lenth = 30;
    getdata.type = 0;
    //getdata.content = (unsigned char*)cmd;
    //data->type =
    char *mydata = (char *)(&getdata);
    //memcpy(senddata,mydata,10);
    for(int i=0;i<10;i++)
    {
        *(++senddata)=*mydata;
        mydata++;
        i++;
    }
    //vitrual_tcp_write
    return 0;
}