-module(echo_gen_sup).
-behaviour(supervisor).

-export([start_link/1, start_child/0]).
-export([init/1]).

start_link(ListenSocket) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, [ListenSocket]).

start_child() ->
    supervisor:start_child(?MODULE, []).

init([ListenSocket]) ->
    spawn(fun listener_pool/0),
    {ok,{
       {simple_one_for_one, 60, 3000},
       [
        {echo_gen,
         {echo_gen, start_link, [ListenSocket]},
         transient, 1000, worker, [echo_gen]}
       ]
      }}.

listener_pool() ->
    io:format("echo_gen listener pool~n"),
    [start_child() || _ <- lists:seq(1, 2)].
