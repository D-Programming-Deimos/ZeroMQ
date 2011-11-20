//
//  Hello World client
//  Connects REQ socket to tcp://localhost:5555
//  Sends "Hello" to server, expects "World" back
//
import zmq;
import std.string;
import std.stdio;

void main()
{
    void* context = zmq_init(1);

    ///  Socket to talk to server
    writeln("Connecting to Hello World Server...");
    void* requester = zmq_socket(context, ZMQ_REQ);
    zmq_connect(requester, toStringz("tcp://localhost:5555"));

    foreach(request_nbr; 0..10)
    {
        zmq_msg_t request;
        zmq_msg_init_size(&request, 5);

        ///memcpy (zmq_msg_data (&request), "Hello", 5);
        ///Slicing calls memcpy internally.
        immutable(void*) source = "Hello".ptr;

        (zmq_msg_data(&request))[0..5] = source[0..5];

        writefln("Client: Sending Hello %d...", request_nbr);
        zmq_send(requester, &request, 0);
        zmq_msg_close(&request);

        zmq_msg_t reply;
        zmq_msg_init(&reply);
        zmq_recv(requester, &reply, 0);
        writefln("Client: Received World %d", request_nbr);
        zmq_msg_close(&reply);
    }

    zmq_close(requester);
    zmq_term(context);
}
