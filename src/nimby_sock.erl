-module(nimby_sock).

-export([
	start_link/1
]).

start_link(Socket) ->
	proc_lib:spawn_link(fun() ->
		process_flag(trap_exit, true),
        ok = inet:setopts(Socket, [{active, true}]),
        tcp_loop(Socket)
	end).

tcp_loop(Socket) ->
    receive
        {tcp, Socket, Bin} ->
            {M, F, A} = nimby:dec_bin(Bin),
            % io:format("dec bin ~p~n", [{M, F, A}]),
            Result =
                try
                    %% How does rex "apply"/run the code remotely ?
                    erlang:apply(M, F, A)
                catch
                    C:E ->
                        {C, E, erlang:get_stacktrace()}
                end,
            % io:format("result ~p~n", [Result]),
            ok = gen_tcp:send(Socket, nimby:enc_resp(Result)),
            tcp_loop(Socket);
        {tcp_closed, Socket} ->
            ok = gen_tcp:close(Socket),
            io:format("~p {tcp_closed, ~p}~n", [?MODULE, Socket]),
            ok;
        X ->
            io:format("~p X received ~p~n", [?MODULE, X]),
            tcp_loop(Socket)
    end.