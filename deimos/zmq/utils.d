/*
    Copyright (c) 2007-2013 Contributors as noted in the AUTHORS file

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
*/

module deimos.zmq.utils;

import core.stdc.config;

nothrow extern (C)
{

/*Handle DSO symbol visibility  */
/++
#if defined _WIN32
#   if defined DLL_EXPORT
#       define ZMQ_EXPORT __declspec(dllexport)
#   else
#       define ZMQ_EXPORT __declspec(dllimport)
#   endif
#else
#   if defined __SUNPRO_C  || defined __SUNPRO_CC
#       define ZMQ_EXPORT __global
#   elif (defined __GNUC__ && __GNUC__ >= 4) || defined __INTEL_COMPILER
#       define ZMQ_EXPORT __attribute__ ((visibility("default")))
#   else
#       define ZMQ_EXPORT
#   endif
#endif
++/

/* These functions are documented by man pages                                */

/* Encode data with Z85 encoding. Returns encoded data                        */
char *zmq_z85_encode (char *dest, ubyte *data, size_t size);

/* Decode data with Z85 encoding. Returns decoded data                        */
ubyte *zmq_z85_decode (ubyte *dest, char *string);

/* Generate z85-encoded public and private keypair with libsodium.            */
/* Returns 0 on success.                                                      */
int zmq_curve_keypair (char *z85_public_key, char *z85_secret_key);

alias typeof(*(void function(void*)).init) zmq_thread_fn;

/*  These functions are not documented by man pages                           */

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
void *zmq_threadstart (zmq_thread_fn* func, void* arg);

/* Wait for thread to complete then free up resources.                        */
void zmq_threadclose (void* thread);

}
