-module(echo_app).
-behaviour(application).
-export([start/2, stop/1]).

start(_Type, _Args) ->
    {ok, Port} = application:get_env(port),
    {ok, GenPort} = application:get_env(gen_port),
    io:format("supersior start on port: ~p ~p~n", [Port, GenPort]),
    echo_sup:start_link(Port, GenPort).

stop(_) ->
    ok.
