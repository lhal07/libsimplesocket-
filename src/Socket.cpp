// Implementation of the Socket class.


#include "Socket.h"
#include "string.h"
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <iostream>
#include <sys/time.h>


Socket::Socket() :
  m_sock ( -1 )
{

  memset ( &m_addr,
      0,
      sizeof ( m_addr ) );

}

Socket::~Socket()
{
  if ( is_valid() )
    ::close ( m_sock );
}

bool Socket::create()
{
  m_sock = socket ( AF_INET,
      SOCK_STREAM,
      0 );

  if ( ! is_valid() )
    return false;


  // TIME_WAIT - argh
  int on = 1;
  if ( setsockopt ( m_sock, SOL_SOCKET, SO_REUSEADDR, ( const char* ) &on, sizeof ( on ) ) == -1 )
    return false;


  return true;

}



bool Socket::bind ( const int port )
{

  if ( ! is_valid() )
  {
    return false;
  }



  m_addr.sin_family = AF_INET;
  m_addr.sin_addr.s_addr = INADDR_ANY;
  m_addr.sin_port = htons ( port );

  int bind_return = ::bind ( m_sock,
      ( struct sockaddr * ) &m_addr,
      sizeof ( m_addr ) );


  if ( bind_return == -1 )
  {
    return false;
  }

  return true;
}


bool Socket::listen() const
{
  if ( ! is_valid() )
  {
    return false;
  }

  int listen_return = ::listen ( m_sock, MAXCONNECTIONS );


  if ( listen_return == -1 )
  {
    return false;
  }

  return true;
}


bool Socket::accept ( Socket& new_socket ) const
{
  int addr_length = sizeof ( m_addr );
  new_socket.m_sock = ::accept ( m_sock, ( sockaddr * ) &m_addr, ( socklen_t * ) &addr_length );

  if ( new_socket.m_sock <= 0 )
    return false;
  else
    return true;
}


bool Socket::send ( const std::string s ) const
{
  int status = ::send ( m_sock, s.c_str(), s.size(), MSG_NOSIGNAL );
  if ( status == -1 )
  {
    return false;
  }
  else
  {
    return true;
  }
}


int Socket::recv ( std::string& s ) const
{
  char buf [ MAXRECV + 1 ];

  s = "";

  memset ( buf, 0, MAXRECV + 1 );

  int status = ::recv ( m_sock, buf, MAXRECV, 0 );

  if ( status == -1 )
  {
    std::cout << "status == -1   errno == " << errno << "  in Socket::recv\n";
    return 0;
  }
  else if ( status == 0 )
  {
    return 0;
  }
  else
  {
    s = buf;
    return status;
  }
}


int Socket::recv_timeout ( std::string& s , int timeout) const
{
    int size_recv , total_size= 0;
    struct timeval begin , now;
    char chunk[MAXRECV + 1];
    double timediff;
     
    s = "";
    memset ( chunk, 0, MAXRECV + 1 );

    //make socket non blocking
    fcntl(m_sock, F_SETFL, O_NONBLOCK);
     
    //beginning time
    gettimeofday(&begin , NULL);
     
    while(1)
    {
        gettimeofday(&now , NULL);
         
        //time elapsed in seconds
        timediff = (now.tv_sec - begin.tv_sec) + 1e-6 * (now.tv_usec - begin.tv_usec);
         
        //if you got some data, then break after timeout
        if( total_size > 0 && timediff > timeout )
        {
            break;
        }
         
        else if( timediff > timeout)
        {
            gettimeofday(&begin , NULL);
        }
         
        memset(chunk ,0 , MAXRECV);  //clear the variable
        if((size_recv =  ::recv(m_sock , chunk , MAXRECV , 0) ) < 0)
        {
            //if nothing was received then we want to wait a little before trying again, 0.1 seconds
            usleep(100000);
        }
        else
        {
            total_size += size_recv;
            s += std::string(chunk);
            //printf("%s" , chunk);
            //reset beginning time
            gettimeofday(&begin , NULL);
        }
    }
     
    return total_size;
}


bool Socket::connect ( const std::string host, const int port )
{
  if ( ! is_valid() ) return false;

  m_addr.sin_family = AF_INET;
  m_addr.sin_port = htons ( port );

  int status = inet_pton ( AF_INET, host.c_str(), &m_addr.sin_addr );

  if ( errno == EAFNOSUPPORT ) return false;

  status = ::connect ( m_sock, ( sockaddr * ) &m_addr, sizeof ( m_addr ) );

  if ( status == 0 )
    return true;
  else
    return false;
}

void Socket::set_non_blocking ( const bool b )
{

  int opts;

  opts = fcntl ( m_sock,
      F_GETFL );

  if ( opts < 0 )
  {
    return;
  }

  if ( b )
    opts = ( opts | O_NONBLOCK );
  else
    opts = ( opts & ~O_NONBLOCK );

  fcntl ( m_sock,
      F_SETFL,opts );

}

bool Socket::is_connected()
{
  int error_code;
  socklen_t error_code_size = sizeof(error_code);
  if (!getsockopt(m_sock, SOL_SOCKET, SO_ERROR, &error_code, &error_code_size)) return true;
  return true;
}
