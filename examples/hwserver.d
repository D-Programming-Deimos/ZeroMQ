//
//  Hello World server
//  Binds REP socket to tcp://*:5555
//  Expects "Hello" from client, replies with "World"
//
import zmq;
import std.stdio;
import std.string;

void main()
{
    void* context = zmq_init(1);

    ///  Socket to talk to clients
    void* responder = zmq_socket(context, ZMQ_REP);
    zmq_bind(responder, toStringz("tcp://*:5555"));

    while(true)
    {
        ///  Wait for next request from client
        zmq_msg_t request;
        zmq_msg_init(&request);
        zmq_recv(responder, &request, 0);

        writeln("Server: Recieved Hello");
        zmq_msg_close(&request);


        ///  Send reply back to client
        zmq_msg_t reply;
        zmq_msg_init_size(&reply, 5);

        ///memcpy (zmq_msg_data (&request), "Hello", 5);
        ///Slicing calls memcpy internally.
        immutable(void*) source = "World".ptr;
        (zmq_msg_data(&reply))[0..5] = source[0..5];
        zmq_send(responder, &reply, 0);
        zmq_msg_close(&reply);
    }
    ///  We never get here but if we did, this would be how we end
    zmq_close(responder);
    zmq_term(context);
}
