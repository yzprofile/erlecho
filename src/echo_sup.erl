-module(echo_sup).
-behaviour(supervisor).

-export([start_link/2]).
-export([init/1]).

-define(TCP_OPTIONS, [binary, {active, false}, {reuseaddr, true}]).

start_link(Port, GenPort) ->
    io:format("supersior start~n"),
    supervisor:start_link({local, ?MODULE}, ?MODULE, [Port, GenPort]).


init([Port, GenPort]) ->
    {ok, Listen} = gen_tcp:listen(Port, ?TCP_OPTIONS),
    {ok, GenListen} = gen_tcp:listen(GenPort, ?TCP_OPTIONS),
    io:format("supersior listen on: ~p ~p~n", [Listen, GenListen]),
    {ok, {
       {one_for_one, 60, 3600},
       [
        {echo_accept_worker_sup,
         {echo_worker_sup, start_link, [echo_accept_sup, Listen]},
         permanent, 1000, supervisor, [echo_accept_sup]},
        {echo_gen_worker_sup,
         {echo_worker_sup, start_link, [echo_gen_sup, GenListen]},
         permanent, 1000, worker, [echo_gen_sup]}
       ]
      }}.
