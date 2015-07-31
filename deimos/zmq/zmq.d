/*
    Copyright (c) 2007-2014 Contributors as noted in the AUTHORS file

    This file is part of 0MQ.

    0MQ is free software; you can redistribute it and/or modify it under
    the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation; either version 3 of the License, or
    (at your option) any later version.

    0MQ is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    *************************************************************************
    NOTE to contributors. This file comprises the principal public contract
    for ZeroMQ API users (along with zmq_utils.h). Any change to this file
    supplied in a stable release SHOULD not break existing applications.
    In practice this means that the value of constants must not change, and
    that old values may not be reused for new constants.
    *************************************************************************
*/
module deimos.zmq.zmq;

import core.stdc.config;

nothrow @nogc extern (C)
{

/*  Version macros for compile-time API version detection                     */
enum
{
    ZMQ_VERSION_MAJOR   = 4,
    ZMQ_VERSION_MINOR   = 1,
    ZMQ_VERSION_PATCH   = 1
}

int ZMQ_MAKE_VERSION(int major, int minor, int patch)
{
    return major * 10000 + minor * 100 + patch;
}
enum ZMQ_VERSION =
    ZMQ_MAKE_VERSION(ZMQ_VERSION_MAJOR, ZMQ_VERSION_MINOR, ZMQ_VERSION_PATCH);

/******************************************************************************/
/*  0MQ errors.                                                               */
/******************************************************************************/

/*  A number random anough not to collide with different errno ranges on      */
/*  different OSes. The assumption is that error_t is at least 32-bit type.   */
enum
{
    ZMQ_HAUSNUMERO = 156384712,

/*  On Windows platform some of the standard POSIX errnos are not defined.    */
    ENOTSUP         = (ZMQ_HAUSNUMERO + 1),
    EPROTONOSUPPORT = (ZMQ_HAUSNUMERO + 2),
    ENOBUFS         = (ZMQ_HAUSNUMERO + 3),
    ENETDOWN        = (ZMQ_HAUSNUMERO + 4),
    EADDRINUSE      = (ZMQ_HAUSNUMERO + 5),
    EADDRNOTAVAIL   = (ZMQ_HAUSNUMERO + 6),
    ECONNREFUSED    = (ZMQ_HAUSNUMERO + 7),
    EINPROGRESS     = (ZMQ_HAUSNUMERO + 8),
    ENOTSOCK        = (ZMQ_HAUSNUMERO + 9),
    EMSGSIZE        = (ZMQ_HAUSNUMERO + 10),
    EAFNOSUPPORT    = (ZMQ_HAUSNUMERO + 11),
    ENETUNREACH     = (ZMQ_HAUSNUMERO + 12),
    ECONNABORTED    = (ZMQ_HAUSNUMERO + 13),
    ECONNRESET      = (ZMQ_HAUSNUMERO + 14),
    ENOTCONN        = (ZMQ_HAUSNUMERO + 15),
    ETIMEDOUT       = (ZMQ_HAUSNUMERO + 16),
    EHOSTUNREACH    = (ZMQ_HAUSNUMERO + 17),
    ENETRESET       = (ZMQ_HAUSNUMERO + 18),

/*  Native 0MQ error codes.                                                   */
    EFSM            = (ZMQ_HAUSNUMERO + 51),
    ENOCOMPATPROTO  = (ZMQ_HAUSNUMERO + 52),
    ETERM           = (ZMQ_HAUSNUMERO + 53),
    EMTHREAD        = (ZMQ_HAUSNUMERO + 54)
}//enum error_code

/*  This function retrieves the errno as it is known to 0MQ library. The goal */
/*  of this function is to make the code 100% portable, including where 0MQ   */
/*  compiled with certain CRT library (on Windows) is linked to an            */
/*  application that uses different CRT library.                              */
int zmq_errno();

/*  Resolves system errors and 0MQ errors to human-readable string.           */
const(char)* zmq_strerror(int errnum);

/*  Run-time API version detection                                            */
void zmq_version (int *major, int *minor, int *patch);

/******************************************************************************/
/*  0MQ infrastructure (a.k.a. context) initialisation & termination.         */
/******************************************************************************/

/*  New API                                                                   */
/*  Context options                                                           */
enum
{
    ZMQ_IO_THREADS  = 1,
    ZMQ_MAX_SOCKETS = 2,
    ZMQ_SOCKET_LIMIT = 3,
    ZMQ_THREAD_PRIORITY = 3,
    ZMQ_THREAD_SCHED_POLICY = 4,
}

/*  Default for new contexts                                                  */
enum
{
    ZMQ_IO_THREADS_DFLT  = 1,
    ZMQ_MAX_SOCKETS_DFLT = 1023,
    ZMQ_THREAD_PRIORITY_DFLT = -1,
    ZMQ_THREAD_SCHED_POLICY_DFLT = -1,
}

void* zmq_ctx_new();
int zmq_ctx_term(void* context);
int zmq_ctx_shutdown(void* ctx_);
int zmq_ctx_set(void* context, int option, int optval);
int zmq_ctx_get(void* context, int option);

/*  Old (legacy) API                                                          */
void* zmq_init(int io_threads);
int zmq_term(void* context);
int zmq_ctx_destroy(void* context);


/******************************************************************************/
/*  0MQ message definition.                                                   */
/******************************************************************************/

struct zmq_msg_t { ubyte[64] _; }

int zmq_msg_init(zmq_msg_t* msg);
int zmq_msg_init_size(zmq_msg_t* msg, size_t size);
int zmq_msg_init_data(zmq_msg_t* msg, void* data, size_t size,
    void function(void* data, void* hint) nothrow ffn, void* hint);
int zmq_msg_send(zmq_msg_t* msg, void* s, int flags);
int zmq_msg_recv(zmq_msg_t* msg, void* s, int flags);
int zmq_msg_close(zmq_msg_t* msg);
int zmq_msg_move(zmq_msg_t* dest, zmq_msg_t* src);
int zmq_msg_copy(zmq_msg_t* dest, zmq_msg_t* src);
void* zmq_msg_data(zmq_msg_t* msg);
size_t zmq_msg_size(zmq_msg_t* msg);
int zmq_msg_more(zmq_msg_t* msg);
int zmq_msg_get(zmq_msg_t* msg, int property);
int zmq_msg_set(zmq_msg_t* msg, int property, int optval);
const(char)* zmq_msg_gets(zmq_msg_t* msg, const(char)* property);

/******************************************************************************/
/*  0MQ socket definition.                                                    */
/******************************************************************************/

/*  Socket types.                                                             */
enum
{
    ZMQ_PAIR        = 0,
    ZMQ_PUB         = 1,
    ZMQ_SUB         = 2,
    ZMQ_REQ         = 3,
    ZMQ_REP         = 4,
    ZMQ_DEALER      = 5,
    ZMQ_ROUTER      = 6,
    ZMQ_PULL        = 7,
    ZMQ_PUSH        = 8,
    ZMQ_XPUB        = 9,
    ZMQ_XSUB        = 10,
    ZMQ_STREAM      = 11,
}

/*  Deprecated aliases                                                        */
enum
{
    ZMQ_XREQ        = ZMQ_DEALER,
    ZMQ_XREP        = ZMQ_ROUTER,
}

/*  Socket options.                                                           */
enum
{
    ZMQ_AFFINITY        = 4,
    ZMQ_IDENTITY        = 5,
    ZMQ_SUBSCRIBE       = 6,
    ZMQ_UNSUBSCRIBE     = 7,
    ZMQ_RATE            = 8,
    ZMQ_RECOVERY_IVL    = 9,
    ZMQ_SNDBUF          = 11,
    ZMQ_RCVBUF          = 12,
    ZMQ_RCVMORE         = 13,
    ZMQ_FD              = 14,
    ZMQ_EVENTS          = 15,
    ZMQ_TYPE            = 16,
    ZMQ_LINGER          = 17,
    ZMQ_RECONNECT_IVL   = 18,
    ZMQ_BACKLOG         = 19,
    ZMQ_RECONNECT_IVL_MAX = 21,
    ZMQ_MAXMSGSIZE      = 22,
    ZMQ_SNDHWM          = 23,
    ZMQ_RCVHWM          = 24,
    ZMQ_MULTICAST_HOPS  = 25,
    ZMQ_RCVTIMEO        = 27,
    ZMQ_SNDTIMEO        = 28,
    ZMQ_LAST_ENDPOINT   = 32,
    ZMQ_ROUTER_MANDATORY        = 33,
    ZMQ_TCP_KEEPALIVE           = 34,
    ZMQ_TCP_KEEPALIVE_CNT       = 35,
    ZMQ_TCP_KEEPALIVE_IDLE      = 36,
    ZMQ_TCP_KEEPALIVE_INTVL     = 37,
    ZMQ_IMMEDIATE               = 39,
    ZMQ_XPUB_VERBOSE            = 40,
    ZMQ_ROUTER_RAW              = 41,
    ZMQ_IPV6                    = 42,
    ZMQ_MECHANISM               = 43,
    ZMQ_PLAIN_SERVER            = 44,
    ZMQ_PLAIN_USERNAME          = 45,
    ZMQ_PLAIN_PASSWORD          = 46,
    ZMQ_CURVE_SERVER            = 47,
    ZMQ_CURVE_PUBLICKEY         = 48,
    ZMQ_CURVE_SECRETKEY         = 49,
    ZMQ_CURVE_SERVERKEY         = 50,
    ZMQ_PROBE_ROUTER            = 51,
    ZMQ_REQ_CORRELATE           = 52,
    ZMQ_REQ_RELAXED             = 53,
    ZMQ_CONFLATE                = 54,
    ZMQ_ZAP_DOMAIN              = 55,
    ZMQ_ROUTER_HANDOVER         = 56,
    ZMQ_TOS                     = 57,
    ZMQ_CONNECT_RID             = 61,
    ZMQ_GSSAPI_SERVER           = 62,
    ZMQ_GSSAPI_PRINCIPAL        = 63,
    ZMQ_GSSAPI_SERVICE_PRINCIPAL= 64,
    ZMQ_GSSAPI_PLAINTEXT        = 65,
    ZMQ_HANDSHAKE_IVL           = 66,
    ZMQ_SOCKS_PROXY             = 68,
    ZMQ_XPUB_NODROP             = 69,
}


/*  Message options                                                           */
enum
{
    ZMQ_MORE = 1,
    ZMQ_SRCFD = 2,
    ZMQ_SHARED = 3,
}

/*  Send/recv options.                                                        */
enum
{
    ZMQ_DONTWAIT = 1,
    ZMQ_SNDMORE = 2
}

/*  Security mechanisms                                                       */
enum
{
    ZMQ_NULL = 0,
    ZMQ_PLAIN = 1,
    ZMQ_CURVE = 2,
    ZMQ_GSSAPI = 3,
}

/*  Deprecated options and aliases                                            */
enum
{
    ZMQ_TCP_ACCEPT_FILTER       = 38,
    ZMQ_IPC_FILTER_PID          = 58,
    ZMQ_IPC_FILTER_UID          = 59,
    ZMQ_IPC_FILTER_GID          = 60,
    ZMQ_IPV4ONLY                = 31,
    ZMQ_DELAY_ATTACH_ON_CONNECT = ZMQ_IMMEDIATE,
    ZMQ_NOBLOCK                 = ZMQ_DONTWAIT,
    ZMQ_FAIL_UNROUTABLE         = ZMQ_ROUTER_MANDATORY,
    ZMQ_ROUTER_BEHAVIOR         = ZMQ_ROUTER_MANDATORY,
}

/******************************************************************************/
/*  0MQ socket events and monitoring                                          */
/******************************************************************************/

/*  Socket transport events (TCP and IPC only)                                */

enum
{
    ZMQ_EVENT_CONNECTED          = 0x0001,
    ZMQ_EVENT_CONNECT_DELAYED    = 0x0002,
    ZMQ_EVENT_CONNECT_RETRIED    = 0x0004,
    ZMQ_EVENT_LISTENING          = 0x0008,
    ZMQ_EVENT_BIND_FAILED        = 0x0010,
    ZMQ_EVENT_ACCEPTED           = 0x0020,
    ZMQ_EVENT_ACCEPT_FAILED      = 0x0040,
    ZMQ_EVENT_CLOSED             = 0x0080,
    ZMQ_EVENT_CLOSE_FAILED       = 0x0100,
    ZMQ_EVENT_DISCONNECTED       = 0x0200,
    ZMQ_EVENT_MONITOR_STOPPED    = 0x0400,
    ZMQ_EVENT_ALL                = 0xFFFF,
}

/*  Socket event data  */
struct zmq_event_t {
    ushort event;   // id of the event as bitfield
    int value;      // value is either error code, fd or reconnect interval
}

void* zmq_socket(void*, int type);
int zmq_close(void* s);
int zmq_setsockopt(void* s, int option, const void* optval, size_t optvallen);
int zmq_getsockopt(void* s, int option, void* optval, size_t *optvallen);
int zmq_bind(void* s, const char* addr);
int zmq_connect(void* s, const char* addr);
int zmq_unbind(void* s, const char* addr);
int zmq_disconnect(void* s, const char* addr);
int zmq_send(void* s, const void* buf, size_t len, int flags);
int zmq_send_const(void *s, const void* buf, size_t len, int flags);
int zmq_recv(void* s, void* buf, size_t len, int flags);
int zmq_socket_monitor(void* s, const char* addr, int events);


/******************************************************************************/
/*  I/O multiplexing.                                                         */
/******************************************************************************/

enum
{
    ZMQ_POLLIN  = 1,
    ZMQ_POLLOUT = 2,
    ZMQ_POLLERR = 4
}

struct zmq_pollitem_t
{
    void* socket;
    version (win32)
    {
        SOCKET fd;
    }
    else
    {
        int fd;
    }
    short events;
    short revents;
}

enum ZMQ_POLLITEMS_DFLT = 16;

int zmq_poll(zmq_pollitem_t* items, int nitems, c_long timeout);

/******************************************************************************/
/*  Message proxying                                                          */
/******************************************************************************/

int zmq_proxy(void* frontend, void* backend, void* capture);
int zmq_proxy_steerable (void *frontend, void *backend, void *capture, void *control);

/******************************************************************************/
/*  Probe library capabilities                                                */
/******************************************************************************/

enum ZMQ_HAS_CAPABILITIES = 1;
int zmq_has(const(char)* capability);

/*  Deprecated aliases */
enum
{
    ZMQ_STREAMER     = 1,
    ZMQ_FORWARDER    = 2,
    ZMQ_QUEUE        = 3
}

/*  Deprecated methods */
int zmq_device(int type, void* frontend, void* backend);
int zmq_sendmsg(void* s, zmq_msg_t* msg, int flags);
int zmq_recvmsg(void* s, zmq_msg_t* msg, int flags);


/******************************************************************************/
/*  Encryption functions                                                      */
/******************************************************************************/

/*  Encode data with Z85 encoding. Returns encoded data                       */
char* zmq_z85_encode(char* dest, ubyte* data, size_t size);

/*  Decode data with Z85 encoding. Returns decoded data                       */
ubyte* zmq_z85_decode(ubyte* dest, char* string_);

/*  Generate z85-encoded public and private keypair with libsodium.           */
/*  Returns 0 on success.                                                     */
int zmq_curve_keypair(char* z85_public_key, char* z85_secret_key);


/******************************************************************************/
/*  These functions are not documented by man pages -- use at your own risk.  */
/*  If you need these to be part of the formal ZMQ API, then (a) write a man  */
/*  page, and (b) write a test case in tests.                                 */
/******************************************************************************/

struct iovec;

int zmq_sendiov(void* s, iovec* iov, size_t count, int flags);
int zmq_recviov(void* s, iovec* iov, size_t* count, int flags);

/*  Helper functions are used by perf tests so that they don't have to care   */
/*  about minutiae of time-related functions on different OS platforms.       */

/*  Starts the stopwatch. Returns the handle to the watch.                    */
void* zmq_stopwatch_start();

/*  Stops the stopwatch. Returns the number of microseconds elapsed since     */
/*  the stopwatch was started.                                                */
c_ulong zmq_stopwatch_stop(void* watch_);

/*  Sleeps for specified number of seconds.                                   */
void zmq_sleep(int seconds_);

/* Start a thread. Returns a handle to the thread.                            */
void* zmq_threadstart(void function(void*) nothrow func, void* arg);

/* Wait for thread to complete then free up resources.                        */
void zmq_threadclose(void* thread);


}// extern (C)
