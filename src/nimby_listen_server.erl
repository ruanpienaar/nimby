-module(nimby_listen_server).

-export([
    start_link/2
]).

start_link(Host, Port) ->
    proc_lib:spawn_link(fun() ->
        process_flag(trap_exit, true),
        listen(Host, Port)
    end).

listen(Host, Port) ->
    {ok, LS} = gen_tcp:listen(Port, [binary]),
    accept_loop(LS, []).

accept_loop(LS, Pids) ->
    {ok, Socket} = gen_tcp:accept(LS),
    Pid = nimby_sock:start_link(Socket),
    accept_loop(LS, [Pid|Pids]).