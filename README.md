ZeroMQ bindings for the D programming language
==============================================
This repository contains D bindings to the [ZeroMQ] C library (libzmq).
It is part of [Deimos] and is maintained by the [Deimos team].

Like all Deimos bindings, these are just D prototypes for the C functions.
For a higher-level D wrapper, see e.g. [zmqd]

Usage
-----
To use these bindings, simply add

    import deimos.zmq.zmq;

to your D program and link it with the `zmq` library.

Versioning
----------
Starting with v5.0.0, the version numbers of these bindings no longer
correspond to upstream ZeroMQ versions. This allows us to follow the
[Semantic Versioning] scheme and increment the version number when we
make changes that do not correspond to upstream changes (e.g. to fix
bugs in the bindings).

The corresponding ZeroMQ version is indicated after the bindings version,
following a plus sign.  For example, the tag `v5.0.0+zmq-4-2-2` indicates
bindings version 5.0.0, corresponding to ZeroMQ version 4.2.2.

Up to and including v4.2.2, the bindings versions corresponded exactly to
upstream ZeroMQ versions.

Authors
-------
These bindings were originally based on code by [itiu].  For the full
list of contributors, see the [Contributors] page on GitHub.

[ZeroMQ]: http://zeromq.org
[Deimos]: https://github.com/D-Programming-Deimos
[Deimos team]: https://github.com/orgs/D-Programming-Deimos/people
[zmqd]: https://github.com/kyllingstad/zmqd
[Semantic Versioning]: https://semver.org
[itiu]: https://github.com/itiu
[Contributors]: https://github.com/D-Programming-Deimos/ZeroMQ/graphs/contributors
