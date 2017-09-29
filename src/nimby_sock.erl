-module(nimby_sock).

-export([
	start_link/1
]).

start_link(Socket) ->
	proc_lib:spawn_link(fun() ->
		process_flag(trap_exit, true),
		gen_tcp:controlling_process(self()),
        tcp_loop(Socket)
	end).

tcp_loop(Socket) ->
    receive
        X ->
            io:format("X received ~p~n", [X]),
            tcp_loop(Socket)
    end.


	