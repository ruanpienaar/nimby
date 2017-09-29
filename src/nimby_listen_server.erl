-module(nimby_listen_server).

-export([
    start_link/2
]).

start_link(Host, Port) ->
    proc_lib:spawn_link(fun() ->
        process_flag(trap_exit, true),
        init(Host, Port)
    end).

init(Host, Port) ->
    {ok, LS} = listen(Host, Port),
    loop(LS).

loop(LS) ->
    LoopPid = self(),
    AcceptorPid = spawn_link(fun() -> acceptor_loop(LoopPid, LS) end),
    loop(LS, [], AcceptorPid).

loop(LS, SocketPids, AcceptorPid) ->
    receive
        {new_socket, Socket, AccPid} ->
            Pid = nimby_sock:start_link(Socket),
            io:format("~p ! {new_controlling_pid, ~p}~n", [AccPid, Pid]),
            AccPid ! {new_controlling_pid, Pid},
            loop(LS, [Pid|SocketPids], AcceptorPid);
        {'EXIT', AcceptorPid, Reason} ->
            io:format("AcceptorPid Died! ~p~n", [Reason]),
            NewAcceptorPid = spawn_link(fun() -> acceptor_loop(self(), LS) end),
            loop(LS, SocketPids, NewAcceptorPid);
        {'EXIT', FromPid, normal} ->
            NewSocketPids =
                case lists:member(FromPid, SocketPids) of
                    true ->
                        % nimby_sock died
                        SocketPids -- [FromPid];
                    false ->
                        % something else died...
                        io:format("~p {'EXIT', ~p, normal}~n", [?MODULE, FromPid]),
                        SocketPids
                end,
            loop(LS, NewSocketPids, AcceptorPid);
        Y ->
            io:format("~p Y received ~p~n", [?MODULE, Y]),
            loop(LS, SocketPids, AcceptorPid)
    end.

listen(Host, Port) ->
    {ok, LS} = gen_tcp:listen(Port, [binary, {reuseaddr, true}]).

acceptor_loop(LoopPid, LS) ->
     case gen_tcp:accept(LS) of
        {ok, Socket} ->
            ok = inet:setopts(Socket, [{active, false}]),
            io:format("~p ! {new_socket, ~p}~n", [LoopPid, Socket]),
            LoopPid ! {new_socket, Socket, self()},
            receive
                {new_controlling_pid, SockPid} ->
                    ok = gen_tcp:controlling_process(Socket, SockPid)
            end;
        {error, Reason} ->
            io:format("~p Could not accept new Socket connection reason ~p~n", [?MODULE, Reason])
    end,
    acceptor_loop(LoopPid, LS).