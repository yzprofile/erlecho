-module(echo).
-export([start_link/1, stop/1]).
-export([client/2, acceptor/1]).


stop(_) ->
    ok.

start_link(ListenSocket) ->
    io:format("echo serve on: ~p~n", [ListenSocket]),
    Pid = spawn_link(?MODULE, acceptor, [ListenSocket]),
    {ok, Pid}.

acceptor(ListenSocket) ->
    {ok, Socket} = gen_tcp:accept(ListenSocket),
    echo_accept_sup:start_child(),
    handle(Socket).

%% Echoing back whatever was obtained
handle(Socket) ->
    inet:setopts(Socket, [{active, once}]),
    receive
        {tcp, Socket, <<"quit", _/binary>>} ->
            io:format("~p connection quit~n", [self()]),
            gen_tcp:close(Socket);
        {tcp, Socket, Msg} ->
            io:format("~p got data: ~p~n", [self(), Msg]),
            gen_tcp:send(Socket, Msg),
            handle(Socket);
        Error ->
            io:format("~p error ~p~n", [self(), Error]),
            ok
    end.

client(PortNo,Message) ->
    {ok,Sock} = gen_tcp:connect("localhost",PortNo,[{active,false}]),
    gen_tcp:send(Sock, Message),
    A = gen_tcp:recv(Sock,0),
    gen_tcp:close(Sock),
    A.
