-module(echo_worker_sup).
-behaviour(supervisor).

-export([start_link/2, start_child/1, listener_pool/1]).
-export([init/1]).

start_link(Module, ListenSocket) ->
    supervisor:start_link({local, Module}, Module, [ListenSocket]).

start_child(Module) ->
    supervisor:start_child(Module, []).

init([Module, ListenSocket]) ->
    spawn(?MODULE, listener_pool, [Module]),
    {ok,{
       {simple_one_for_one, 60, 3000},
       [
        {Module,
         {Module, start_link, [ListenSocket]},
         transient, 1000, worker, [Module]}
       ]
      }}.

listener_pool(Module) ->
    io:format("echo_gen listener pool~n"),
    [start_child(Module) || _ <- lists:seq(1, 2)].
