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
enum ZMQ_VERSION_MAJOR = 4;
enum ZMQ_VERSION_MINOR = 3;
enum ZMQ_VERSION_PATCH = 1;

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
const(char)* zmq_strerror(int errnum_);

/*  Run-time API version detection                                            */
void zmq_version (int* major_, int* minor_, int* patch_);

/******************************************************************************/
/*  0MQ infrastructure (a.k.a. context) initialisation & termination.         */
/******************************************************************************/

/*  Context options                                                           */
enum ZMQ_IO_THREADS = 1;
enum ZMQ_MAX_SOCKETS = 2;
enum ZMQ_SOCKET_LIMIT = 3;
enum ZMQ_THREAD_PRIORITY = 3;
enum ZMQ_THREAD_SCHED_POLICY = 4;
enum ZMQ_MAX_MSGSZ = 5;
enum ZMQ_MSG_T_SIZE = 6;
enum ZMQ_THREAD_AFFINITY_CPU_ADD = 7;
enum ZMQ_THREAD_AFFINITY_CPU_REMOVE = 8;
enum ZMQ_THREAD_NAME_PREFIX = 9;

/*  Default for new contexts                                                  */
enum
{
    ZMQ_IO_THREADS_DFLT = 1,
    ZMQ_MAX_SOCKETS_DFLT = 1023,
    ZMQ_THREAD_PRIORITY_DFLT = -1,
    ZMQ_THREAD_SCHED_POLICY_DFLT = -1,
}

void* zmq_ctx_new();
int zmq_ctx_term(void* context_);
int zmq_ctx_shutdown(void* context_);
int zmq_ctx_set(void* context_, int option_, int optval_);
int zmq_ctx_get(void* context_, int option_);

/*  Old (legacy) API                                                          */
void* zmq_init(int io_threads_);
int zmq_term(void* context_);
int zmq_ctx_destroy(void* context_);


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

int zmq_msg_init(zmq_msg_t* msg_);
int zmq_msg_init_size(zmq_msg_t* msg_, size_t size_);
int zmq_msg_init_data(
    zmq_msg_t* msg_, void* data_, size_t size_, void function(void* data_, void* hint_) nothrow ffn_, void* hint_);
int zmq_msg_send(zmq_msg_t* msg_, void* s_, int flags_);
int zmq_msg_recv(zmq_msg_t* msg_, void* s_, int flags_);
int zmq_msg_close(zmq_msg_t* msg_);
int zmq_msg_move(zmq_msg_t* dest_, zmq_msg_t* src_);
int zmq_msg_copy(zmq_msg_t* dest_, zmq_msg_t* src_);
void* zmq_msg_data(zmq_msg_t* msg_);
size_t zmq_msg_size(const(zmq_msg_t)* msg_);
int zmq_msg_more(const(zmq_msg_t)* msg_);
int zmq_msg_get(const(zmq_msg_t)* msg_, int property_);
int zmq_msg_set(zmq_msg_t* msg_, int property_, int optval_);
const(char)* zmq_msg_gets(const(zmq_msg_t)* msg_,
                          const(char)* property_);

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
enum ZMQ_AFFINITY = 4;
enum ZMQ_ROUTING_ID = 5;
enum ZMQ_SUBSCRIBE = 6;
enum ZMQ_UNSUBSCRIBE = 7;
enum ZMQ_RATE = 8;
enum ZMQ_RECOVERY_IVL = 9;
enum ZMQ_SNDBUF = 11;
enum ZMQ_RCVBUF = 12;
enum ZMQ_RCVMORE = 13;
enum ZMQ_FD = 14;
enum ZMQ_EVENTS = 15;
enum ZMQ_TYPE = 16;
enum ZMQ_LINGER = 17;
enum ZMQ_RECONNECT_IVL = 18;
enum ZMQ_BACKLOG = 19;
enum ZMQ_RECONNECT_IVL_MAX = 21;
enum ZMQ_MAXMSGSIZE = 22;
enum ZMQ_SNDHWM = 23;
enum ZMQ_RCVHWM = 24;
enum ZMQ_MULTICAST_HOPS = 25;
enum ZMQ_RCVTIMEO = 27;
enum ZMQ_SNDTIMEO = 28;
enum ZMQ_LAST_ENDPOINT = 32;
enum ZMQ_ROUTER_MANDATORY = 33;
enum ZMQ_TCP_KEEPALIVE = 34;
enum ZMQ_TCP_KEEPALIVE_CNT = 35;
enum ZMQ_TCP_KEEPALIVE_IDLE = 36;
enum ZMQ_TCP_KEEPALIVE_INTVL = 37;
enum ZMQ_IMMEDIATE = 39;
enum ZMQ_XPUB_VERBOSE = 40;
enum ZMQ_ROUTER_RAW = 41;
enum ZMQ_IPV6 = 42;
enum ZMQ_MECHANISM = 43;
enum ZMQ_PLAIN_SERVER = 44;
enum ZMQ_PLAIN_USERNAME = 45;
enum ZMQ_PLAIN_PASSWORD = 46;
enum ZMQ_CURVE_SERVER = 47;
enum ZMQ_CURVE_PUBLICKEY = 48;
enum ZMQ_CURVE_SECRETKEY = 49;
enum ZMQ_CURVE_SERVERKEY = 50;
enum ZMQ_PROBE_ROUTER = 51;
enum ZMQ_REQ_CORRELATE = 52;
enum ZMQ_REQ_RELAXED = 53;
enum ZMQ_CONFLATE = 54;
enum ZMQ_ZAP_DOMAIN = 55;
enum ZMQ_ROUTER_HANDOVER = 56;
enum ZMQ_TOS = 57;
enum ZMQ_CONNECT_ROUTING_ID = 61;
enum ZMQ_GSSAPI_SERVER = 62;
enum ZMQ_GSSAPI_PRINCIPAL = 63;
enum ZMQ_GSSAPI_SERVICE_PRINCIPAL= 64;
enum ZMQ_GSSAPI_PLAINTEXT = 65;
enum ZMQ_HANDSHAKE_IVL = 66;
enum ZMQ_SOCKS_PROXY = 68;
enum ZMQ_XPUB_NODROP = 69;
enum ZMQ_BLOCKY = 70;
enum ZMQ_XPUB_MANUAL = 71;
enum ZMQ_XPUB_WELCOME_MSG = 72;
enum ZMQ_STREAM_NOTIFY = 73;
enum ZMQ_INVERT_MATCHING = 74;
enum ZMQ_HEARTBEAT_IVL = 75;
enum ZMQ_HEARTBEAT_TTL = 76;
enum ZMQ_HEARTBEAT_TIMEOUT = 77;
enum ZMQ_XPUB_VERBOSER = 78;
enum ZMQ_CONNECT_TIMOUT = 79;
enum ZMQ_TCP_MAXRT = 80;
enum ZMQ_THREAD_SAFE = 81;
enum ZMQ_MULTICAST_MAXTPDU = 84;
enum ZMQ_VMCI_BUFFER_SIZE = 85;
enum ZMQ_VMCI_BUFFER_MIN_SIZE = 86;
enum ZMQ_VMCI_BUFFER_MAX_SIZE = 87;
enum ZMQ_VMCI_CONNECT_TIMEOUT = 88;
enum ZMQ_USE_FD = 89;
enum ZMQ_GSSAPI_PRINCIPAL_NAMETYPE = 90;
enum ZMQ_GSSAPI_SERVICE_PRINCIPAL_NAMETYPE = 91;
enum ZMQ_BINDTODEVICE = 92;


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
enum ZMQ_GROUP_MAX_LENGTH = 15;

/*  Deprecated options and aliases                                            */
enum ZMQ_IDENTITY = ZMQ_ROUTING_ID;
enum ZMQ_CONNECT_RID = ZMQ_CONNECT_ROUTING_ID;
enum ZMQ_TCP_ACCEPT_FILTER = 38;
enum ZMQ_IPC_FILTER_PID = 58;
enum ZMQ_IPC_FILTER_UID = 59;
enum ZMQ_IPC_FILTER_GID = 60;
enum ZMQ_IPV4ONLY = 31;
enum ZMQ_DELAY_ATTACH_ON_CONNECT = ZMQ_IMMEDIATE;
enum ZMQ_NOBLOCK = ZMQ_DONTWAIT;
enum ZMQ_FAIL_UNROUTABLE = ZMQ_ROUTER_MANDATORY;
enum ZMQ_ROUTER_BEHAVIOR = ZMQ_ROUTER_MANDATORY;

/* Deprecated Message options                                                 */
enum ZMQ_SRCFD = 2;

/******************************************************************************/
/*  GSSAPI definitions                                                        */
/******************************************************************************/

/*  GSSAPI principal name types                                               */
enum ZMQ_GSSAPI_NT_HOSTBASED = 0;
enum ZMQ_GSSAPI_NT_USER_NAME = 1;
enum ZMQ_GSSAPI_NT_KRB5_PRINCIPAL = 2;

/******************************************************************************/
/*  0MQ socket events and monitoring                                          */
/******************************************************************************/

/*  Socket transport events (TCP, IPC, and TIPC only)                                */

enum ZMQ_EVENT_CONNECTED = 0x0001;
enum ZMQ_EVENT_CONNECT_DELAYED = 0x0002;
enum ZMQ_EVENT_CONNECT_RETRIED = 0x0004;
enum ZMQ_EVENT_LISTENING = 0x0008;
enum ZMQ_EVENT_BIND_FAILED = 0x0010;
enum ZMQ_EVENT_ACCEPTED = 0x0020;
enum ZMQ_EVENT_ACCEPT_FAILED = 0x0040;
enum ZMQ_EVENT_CLOSED = 0x0080;
enum ZMQ_EVENT_CLOSE_FAILED = 0x0100;
enum ZMQ_EVENT_DISCONNECTED = 0x0200;
enum ZMQ_EVENT_MONITOR_STOPPED = 0x0400;
enum ZMQ_EVENT_ALL = 0xFFFF;
/*  Unspecified system errors during handshake. Event value is an errno.      */
enum ZMQ_EVENT_HANDSHAKE_FAILED_NO_DETAIL = 0x0800;
/*  Handshake complete successfully with successful authentication (if        *
 *  enabled). Event value is unused.                                          */
enum ZMQ_EVENT_HANDSHAKE_SUCCEEDED = 0x1000;
/*  Protocol errors between ZMTP peers or between server and ZAP handler.     *
 *  Event value is one of ZMQ_PROTOCOL_ERROR_*                                */
enum ZMQ_EVENT_HANDSHAKE_FAILED_PROTOCOL = 0x2000;
/*  Failed authentication requests. Event value is the numeric ZAP status     *
 *  code, i.e. 300, 400 or 500.                                               */
enum ZMQ_EVENT_HANDSHAKE_FAILED_AUTH = 0x4000;
enum ZMQ_PROTOCOL_ERROR_ZMTP_UNSPECIFIED = 0x10000000;
enum ZMQ_PROTOCOL_ERROR_ZMTP_UNEXPECTED_COMMAND = 0x10000001;
enum ZMQ_PROTOCOL_ERROR_ZMTP_INVALID_SEQUENCE = 0x10000002;
enum ZMQ_PROTOCOL_ERROR_ZMTP_KEY_EXCHANGE = 0x10000003;
enum ZMQ_PROTOCOL_ERROR_ZMTP_MALFORMED_COMMAND_UNSPECIFIED = 0x10000011;
enum ZMQ_PROTOCOL_ERROR_ZMTP_MALFORMED_COMMAND_MESSAGE = 0x10000012;
enum ZMQ_PROTOCOL_ERROR_ZMTP_MALFORMED_COMMAND_HELLO = 0x10000013;
enum ZMQ_PROTOCOL_ERROR_ZMTP_MALFORMED_COMMAND_INITIATE = 0x10000014;
enum ZMQ_PROTOCOL_ERROR_ZMTP_MALFORMED_COMMAND_ERROR = 0x10000015;
enum ZMQ_PROTOCOL_ERROR_ZMTP_MALFORMED_COMMAND_READY = 0x10000016;
enum ZMQ_PROTOCOL_ERROR_ZMTP_MALFORMED_COMMAND_WELCOME = 0x10000017;
enum ZMQ_PROTOCOL_ERROR_ZMTP_INVALID_METADATA = 0x10000018;
// the following two may be due to erroneous configuration of a peer
enum ZMQ_PROTOCOL_ERROR_ZMTP_CRYPTOGRAPHIC = 0x11000001;
enum ZMQ_PROTOCOL_ERROR_ZMTP_MECHANISM_MISMATCH = 0x11000002;
enum ZMQ_PROTOCOL_ERROR_ZAP_UNSPECIFIED = 0x20000000;
enum ZMQ_PROTOCOL_ERROR_ZAP_MALFORMED_REPLY = 0x20000001;
enum ZMQ_PROTOCOL_ERROR_ZAP_BAD_REQUEST_ID = 0x20000002;
enum ZMQ_PROTOCOL_ERROR_ZAP_BAD_VERSION = 0x20000003;
enum ZMQ_PROTOCOL_ERROR_ZAP_INVALID_STATUS_CODE = 0x20000004;
enum ZMQ_PROTOCOL_ERROR_ZAP_INVALID_METADATA = 0x20000005;

void* zmq_socket(void*, int type_);
int zmq_close(void* s_);
int zmq_setsockopt(void* s_, int option_, const void* optval_, size_t optvallen_);
int zmq_getsockopt(void* s_, int option_, void* optval_, size_t *optvallen_);
int zmq_bind(void* s_, const char* addr_);
int zmq_connect(void* s_, const char* addr_);
int zmq_unbind(void* s_, const char* addr_);
int zmq_disconnect(void* s_, const char* addr_);
int zmq_send(void* s_, const void* buf_, size_t len_, int flags_);
int zmq_send_const(void *s_, const void* buf_, size_t len_, int flags_);
int zmq_recv(void* s_, void* buf_, size_t len_, int flags_);
int zmq_socket_monitor(void* s_, const char* addr_, int events_);


/******************************************************************************/
/*  Deprecated I/O multiplexing. Prefer using zmq_poller API                  */
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
        import core.sys.windows.winsock2: SOCKET;
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

int zmq_poll(zmq_pollitem_t* items_, int nitems_, c_long timeout_);

/******************************************************************************/
/*  Message proxying                                                          */
/******************************************************************************/

int zmq_proxy(void* frontend_, void* backend_, void* capture_);
int zmq_proxy_steerable(void* frontend_,
                        void* backend_,
                        void* capture_,
                        void* control_);

/******************************************************************************/
/*  Probe library capabilities                                                */
/******************************************************************************/

enum ZMQ_HAS_CAPABILITIES = 1;
int zmq_has(const(char)* capability_);

/*  Deprecated aliases */
enum
{
    ZMQ_STREAMER     = 1,
    ZMQ_FORWARDER    = 2,
    ZMQ_QUEUE        = 3
}

/*  Deprecated methods */
int zmq_device(int type_, void* frontend_, void* backend_);
int zmq_sendmsg(void* s_, zmq_msg_t* msg_, int flags_);
int zmq_recvmsg(void* s_, zmq_msg_t* msg_, int flags_);
struct iovec;
int zmq_sendiov(void* s_, iovec* iov_, size_t count_, int flags_);
int zmq_recviov(void* s_, iovec* iov_, size_t* count_, int flags_);

/******************************************************************************/
/*  Encryption functions                                                      */
/******************************************************************************/

/*  Encode data with Z85 encoding. Returns encoded data                       */
char* zmq_z85_encode(char* dest_, const(ubyte)* data_, size_t size_);

/*  Decode data with Z85 encoding. Returns decoded data                       */
ubyte* zmq_z85_decode(ubyte* dest_, const(char)* string_);

/*  Generate z85-encoded public and private keypair with tweetnacl/libsodium. */
/*  Returns 0 on success.                                                     */
int zmq_curve_keypair(char* z85_public_key_, char* z85_secret_key_);

/*  Derive the z85-encoded public key from the z85-encoded secret key.        */
/*  Returns 0 on success.                                                     */
int zmq_curve_public(char* z85_public_key_,
                     const(char)* z85_secret_key_);

/******************************************************************************/
/*  Atomic utility methods                                                    */
/******************************************************************************/
void* zmq_atomic_counter_new();
void zmq_atomic_counter_set(void* counter_, int value_);
int zmq_atomic_counter_inc(void* counter_);
int zmq_atomic_counter_dec(void* counter_);
int zmq_atomic_counter_value(void* counter_);
void zmq_atomic_counter_destroy(void** counter_p_);

/******************************************************************************/
/*  Scheduling timers                                                         */
/******************************************************************************/

enum ZMQ_HAVE_TIMERS = true;

alias zmq_timer_fn = void function(int timer_id, void* arg);

void* zmq_timers_new();
int zmq_timers_destroy(void** timers_p);
int zmq_timers_add(void* timers, size_t interval, zmq_timer_fn handler, void* arg);
int zmq_timers_cancel(void* timers, int timer_id);
int zmq_timers_set_interval(void* timers, int timer_id, size_t interval);
int zmq_timers_reset(void* timers, int timer_id);
c_long zmq_timers_timeout(void* timers);
int zmq_timers_execute(void* timers);


/******************************************************************************/
/*  These functions are not documented by man pages -- use at your own risk.  */
/*  If you need these to be part of the formal ZMQ API, then (a) write a man  */
/*  page, and (b) write a test case in tests.                                 */
/******************************************************************************/

/*  Helper functions are used by perf tests so that they don't have to care   */
/*  about minutiae of time-related functions on different OS platforms.       */

/*  Starts the stopwatch. Returns the handle to the watch.                    */
void* zmq_stopwatch_start();

/*  Returns the number of microseconds elapsed since the stopwatch was        */
/*  started, but does not stop or deallocate the stopwatch.                   */
c_ulong zmq_stopwatch_intermediate(void* watch_);

/*  Stops the stopwatch. Returns the number of microseconds elapsed since     */
/*  the stopwatch was started, and deallocates that watch.                    */
c_ulong zmq_stopwatch_stop(void* watch_);

/*  Sleeps for specified number of seconds.                                   */
void zmq_sleep(int seconds_);

/* Start a thread. Returns a handle to the thread.                            */
void* zmq_threadstart(void function(void*) nothrow func_, void* arg_);

/* Wait for thread to complete then free up resources.                        */
void zmq_threadclose(void* thread_);


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

/*  DRAFT Socket options.                                                     */
enum ZMQ_ZAP_ENFORCE_DOMAIN = 93;
enum ZMQ_LOOPBACK_FASTPATH = 94;
enum ZMQ_METADATA = 95;
enum ZMQ_MULTICAST_LOOP = 96;
enum ZMQ_ROUTER_NOTIFY = 97;

/*  DRAFT Context options                                                     */
enum ZMQ_ZERO_COPY_RECV = 10;

/*  DRAFT Socket methods.                                                     */
int zmq_join(void* s, const(char)* group);
int zmq_leave(void* s, const(char)* group);

/*  DRAFT Msg methods.                                                        */
int zmq_msg_set_routing_id(zmq_msg_t* msg, uint routing_id);
uint zmq_msg_routing_id(zmq_msg_t* msg);
int zmq_msg_set_group(zmq_msg_t* msg, const(char)* group);
const(char)* zmq_msg_group(zmq_msg_t* msg);

/*  DRAFT Msg property names.                                                 */
enum ZMQ_MSG_PROPERTY_ROUTING_ID = "Routing-Id";
enum ZMQ_MSG_PROPERTY_SOCKET_TYPE = "Socket-Type";
enum ZMQ_MSG_PROPERTY_USER_ID = "User-Id";
enum ZMQ_MSG_PROPERTY_PEER_ADDRESS = "Peer-Address";

/*  Router notify options                                                     */
enum ZMQ_NOTIFY_CONNECT = 1;
enum ZMQ_NOTIFY_DISCONNECT = 2;

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
int zmq_poller_destroy(void** poller_p);
int zmq_poller_add(void* poller, void* socket, void* user_data, short events);
int zmq_poller_modify(void* poller, void* socket, short events);
int zmq_poller_remove(void* poller, void* socket);
int zmq_poller_wait(void* poller, zmq_poller_event_t* event, c_long timeout);
int zmq_poller_wait_all(void* poller,
                        zmq_poller_event_t* events,
                        int n_events,
                        c_long timout);

version (Windows)
{
    int zmq_poller_add_fd(void* poller, SOCKET fd, void* user_data, short events);
    int zmq_poller_modify_fd(void* poller, SOCKET fd, short events);
    int zmq_poller_remove_fd(void* poller, SOCKET fd);
}
else
{
    int zmq_poller_add_fd(void* poller, int fd, void* user_data, short events);
    int zmq_poller_modify_fd(void* poller, int fd, short events);
    int zmq_poller_remove_fd(void* poller, int fd);
}

int zmq_socket_get_peer_state(void* socket,
                              const(void)* routing_id,
                              size_t routing_id_size);

} // version(ZMQ_BUILD_DRAFT_API)

}// extern (C)
