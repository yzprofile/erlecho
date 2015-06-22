-module(echo_gen).
-behaviour(gen_server).
-export([start_link/1, client/2]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         code_change/3, terminate/2]).

-record(state, {socket}).

client(PortNo,Message) ->
    {ok, Sock} = gen_tcp:connect("localhost",PortNo,[{active,false},
                                                     {packet,2}]),
    gen_tcp:send(Sock, Message),
    A = gen_tcp:recv(Sock,0),
    gen_tcp:close(Sock),
    A.

start_link(Socket) ->
    gen_server:start_link(?MODULE, Socket, []).

init(Socket) ->
    {ok, #state{socket=Socket}, 0}.

handle_call(_E, _From, State) ->
    {noreply, State}.

handle_cast(_E, State) ->
    {noreply, State}.

handle_info(timeout, S = #state{socket=ListenSocket}) ->
    {ok, AcceptSocket} = gen_tcp:accept(ListenSocket),
    echo_gen_sup:start_child(),
    send(AcceptSocket, "accepted~n", []),
    {noreply, S#state{socket=AcceptSocket}};


handle_info({tcp, _Port, Data}, S = #state{socket=Socket}) ->
    send(Socket, Data, []),
    {noreply, S};

handle_info({tcp_closed, _Socket}, S = #state{}) ->
    io:format("echo_gen close ~p~n", [_Socket]),
    {stop, normal, S};
handle_info({tcp_error, _Socket}, S = #state{}) ->
    io:format("echo_gen close ~p~n", [_Socket]),
    {stop, normal, S};
handle_info(E, S) ->
    io:format("unexpected: ~p~n", [E]),
    {noreply, S}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

terminate(normal, _State) ->
    ok;
terminate(Reason, _State) ->
    io:format("terminate reason: ~p~n", [Reason]).

send(Socket, Str, Args) ->
    ok = gen_tcp:send(Socket, io_lib:format(Str, Args)),
    ok = inet:setopts(Socket, [{active, once}]),
    ok.
    
