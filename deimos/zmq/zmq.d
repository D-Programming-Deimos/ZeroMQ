/*
    Copyright (c) 2007-2016 Contributors as noted in the AUTHORS file

    This file is part of libzmq, the ZeroMQ core engine in C++.

    libzmq is free software; you can redistribute it and/or modify it under
    the terms of the GNU Lesser General Public License (LGPL) as published
    by the Free Software Foundation; either version 3 of the License, or
    (at your option) any later version.

    As a special exception, the Contributors give you permission to link
    this library with independent modules to produce an executable,
    regardless of the license terms of these independent modules, and to
    copy and distribute the resulting executable under terms of your choice,
    provided that you also meet, for each linked independent module, the
    terms and conditions of the license of that module. An independent
    module is a module which is not derived from or based on this library.
    If you modify this library, you must extend this exception to your
    version of the library.

    libzmq is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
    License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    *************************************************************************
    NOTE to contributors. This file comprises the principal public contract
    for ZeroMQ API users. Any change to this file supplied in a stable
    release SHOULD not break existing applications.
    In practice this means that the value of constants must not change, and
    that old values may not be reused for new constants.
    *************************************************************************
*/
module deimos.zmq.zmq;

import core.stdc.config;

nothrow extern (C)
{

/*  Version macros for compile-time API version detection                     */
enum
{
    ZMQ_VERSION_MAJOR   = 4,
    ZMQ_VERSION_MINOR   = 2,
    ZMQ_VERSION_PATCH   = 0
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

/*  Context options                                                           */
enum
{
    ZMQ_IO_THREADS  = 1,
    ZMQ_MAX_SOCKETS = 2,
    ZMQ_SOCKET_LIMIT = 3,
    ZMQ_THREAD_PRIORITY = 3,
    ZMQ_THREAD_SCHED_POLICY = 4,
    ZMQ_MAX_MSGSZ = 5,
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
int zmq_ctx_shutdown(void* context);
int zmq_ctx_set(void* context, int option, int optval);
int zmq_ctx_get(void* context, int option);

/*  Old (legacy) API                                                          */
void* zmq_init(int io_threads);
int zmq_term(void* context);
int zmq_ctx_destroy(void* context);


/******************************************************************************/
/*  0MQ message definition.                                                   */
/******************************************************************************/

/* Some architectures, like sparc64 and some variance of aarch64, enforce pointer
 * alignment and raise sigbus on violations. Make sure applications allocate
 * zmq_msg_t on addresses aligned on a pointer-size-boundary to avoid this issue.
 */
struct zmq_msg_t
{
    align((void*).sizeof) ubyte[64] _;
}

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
    ZMQ_BLOCKY                  = 70,
    ZMQ_XPUB_MANUAL             = 71,
    ZMQ_XPUB_WELCOME_MSG        = 72,
    ZMQ_STREAM_NOTIFY           = 73,
    ZMQ_INVERT_MATCHING         = 74,
    ZMQ_HEARTBEAT_IVL           = 75,
    ZMQ_HEARTBEAT_TTL           = 76,
    ZMQ_HEARTBEAT_TIMEOUT       = 77,
    ZMQ_XPUB_VERBOSER           = 78,
    ZMQ_CONNECT_TIMOUT          = 79,
    ZMQ_TCP_MAXRT               = 80,
    ZMQ_THREAD_SAFE             = 81,
    ZMQ_MULTICAST_MAXTPDU       = 84,
    ZMQ_VMCI_BUFFER_SIZE        = 85,
    ZMQ_VMCI_BUFFER_MIN_SIZE    = 86,
    ZMQ_VMCI_BUFFER_MAX_SIZE    = 87,
    ZMQ_VMCI_CONNECT_TIMEOUT    = 88,
    ZMQ_USE_FD                  = 89,
}


/*  Message options                                                           */
enum
{
    ZMQ_MORE = 1,
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

/*  RADIO_DISH protocol                                                       */
enum
{
    ZMQ_GROUP_MAX_LENGTH = 15,
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

/* Deprecated Message options                                                 */
enum
{
    ZMQ_SRCFD = 2,
}

/******************************************************************************/
/*  0MQ socket events and monitoring                                          */
/******************************************************************************/

/*  Socket transport events (TCP, IPC, and TIPC only)                                */

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
    ZMQ_POLLERR = 4,
    ZMQ_POLLPRI = 8,
}

struct zmq_pollitem_t
{
    void* socket;
    version (Windows)
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
struct iovec;
int zmq_sendiov(void* s, iovec* iov, size_t count, int flags);
int zmq_recviov(void* s, iovec* iov, size_t* count, int flags);

/******************************************************************************/
/*  Encryption functions                                                      */
/******************************************************************************/

/*  Encode data with Z85 encoding. Returns encoded data                       */
char* zmq_z85_encode(char* dest, ubyte* data, size_t size);

/*  Decode data with Z85 encoding. Returns decoded data                       */
ubyte* zmq_z85_decode(ubyte* dest, char* string_);

/*  Generate z85-encoded public and private keypair with tweetnacl/libsodium. */
/*  Returns 0 on success.                                                     */
int zmq_curve_keypair(char* z85_public_key, char* z85_secret_key);

/*  Derive the z85-encoded public key from the z85-encoded secret key.        */
/*  Returns 0 on success.                                                     */
int zmq_curve_public(char* z85_public_key, const(char)* z85_secret_key);

/******************************************************************************/
/*  Atomic utility methods                                                    */
/******************************************************************************/
void* zmq_atomic_counter_new();
void zmq_atomic_counter_set(void* counter, int value);
int zmq_atomic_counter_inc(void* counter);
int zmq_atomic_counter_dec(void* counter);
int zmq_atomic_counter_value(void* counter);
void zmq_atomic_counter_destroy(void** counter_p);

/******************************************************************************/
/*  These functions are not documented by man pages -- use at your own risk.  */
/*  If you need these to be part of the formal ZMQ API, then (a) write a man  */
/*  page, and (b) write a test case in tests.                                 */
/******************************************************************************/

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


/******************************************************************************/
/*  These functions are DRAFT and disabled in stable releases, and subject to */
/*  change at ANY time until declared stable.                                 */
/******************************************************************************/
version(ZMQ_BUILD_DRAFT_API)
{
/*  DRAFT Socket types.                                                       */
enum
{
    ZMQ_SERVER  = 12,
    ZMQ_CLIENT  = 13,
    ZMQ_RADIO   = 14,
    ZMQ_DISH    = 15,
    ZMQ_GATHER  = 16,
    ZMQ_SCATTER = 17,
    ZMQ_DGRAM   = 18,
}

/*  DRAFT Socket methods.                                                     */
int zmq_join(void* s, const(char)* group);
int zmq_leave(void* s, const(char)* group);

/*  DRAFT Msg methods.                                                        */
int zmq_msg_set_routing_id(zmq_msg_t* msg, uint routing_id);
uint zmq_msg_routing_id(zmq_msg_t* msg);
int zmq_msg_set_group(zmq_msg_t* msg, const(char)* group);
const(char)* zmq_msg_group(zmq_msg_t* msg);

/******************************************************************************/
/*  Poller polling on sockets,fd, and thread-safe sockets                     */
/******************************************************************************/

struct zmq_poller_event_t
{
    void* socket;
    version(Windows)
    {
        SOCKET fd;
    }
    else
    {
        int fd;
    }
    void* user_data;
    short events;
}

void* zmq_poller_new();
int  zmq_poller_destroy(void** poller_p);
int  zmq_poller_add(void* poller, void* socket, void* user_data, short events);
int  zmq_poller_modify(void* poller, void* socket, short events);
int  zmq_poller_remove(void* poller, void* socket);
int  zmq_poller_wait(void* poller, zmq_poller_event_t* event, c_long timeout);
int  zmq_poller_wait_all(void* poller, zmq_poller_event_t* events, int n_events, c_long timout);

version (Windows)
{
    int zmq_poller_add_fd(void* poller, SOCKET fd, void* user_data, short events);
    int zmq_poller_modify_fd(void* poller, SOCKET fd, short events);
    int zmq_poller_remove_fd(void* poller, SOCKET fd);
}
else
{
    int zmq_poller_add_fd(void* poller, int fd, void* user_data, short_events);
    int zmq_poller_modify_fd(void* poller, int fd, short events);
    int zmq_poller_remove_fd(void* poller, int fd);
}

/******************************************************************************/
/*  Scheduling timers                                                         */
/******************************************************************************/

alias zmq_timer_fn = void function(int timer_id, void* arg);

void*  zmq_timers_new();
int    zmq_timers_destroy(void** timers_p);
int    zmq_timers_add(void* timers, size_t interval, zmq_timer_fn handler, void* arg);
int    zmq_timers_cancel(void* timers, int timer_id);
int    zmq_timers_set_interval(void* timers, int timer_id, size_t interval);
int    zmq_timers_reset(void* timers, int timer_id);
c_long zmq_timers_timeout(void* timers);
int    zmq_timers_execute(void* timers);

} // version(ZMQ_BUILD_DRAFT_API)

}// extern (C)
