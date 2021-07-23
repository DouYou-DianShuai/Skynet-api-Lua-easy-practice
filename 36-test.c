#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <pthread.h>
#include <arpa/inet.h>
#include <sys/types.h>


void *readaaa(void *arg)
{
    pthread_detach(pthread_self());
    int fd = *(int *)arg;

        char buffer[1024] = {0};
    while(1)
    {
        // int ret = read(fd,buffer,1024);
        // if(ret == 0)
        // {
        //     printf("连接段开\n");
        //     close(fd);
        //     exit(0);
        // }
        // else if(ret < 0)
        // {
        //     exit(0);
        // }
        // else if(ret > 0)
        // {
        //     printf("服务器回复buffer:%s\n",buffer);
        // }
    }
    return 0;
}


int main()
{
    int fd = socket(AF_INET,SOCK_STREAM,0);
    struct sockaddr_in  aaa ;
    aaa.sin_family = AF_INET;
    inet_pton(AF_INET,"127.0.0.1",&aaa.sin_addr.s_addr);
    aaa.sin_port=htons(8900);
    connect(fd,(struct sockaddr*)&aaa,sizeof(aaa));
    pthread_t aaaaa;
    pthread_create(&aaaaa,NULL,readaaa,&fd);


    
        char buffer[1024] = {"ajsaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"};
    while(1)
    {
        sleep(0.001);
        write(fd,buffer,strlen(buffer));
        write(fd,buffer,strlen(buffer));
    }





}