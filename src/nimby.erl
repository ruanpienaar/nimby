-module(nimby).

-export([
    connect/2,
    send/2,
    enc_term/1,
    dec_bin/1,
    enc_resp/1,
    dec_resp/1
]).

connect(Host, Port) ->
    gen_tcp:connect(Host, Port, [binary]).

send(Socket, {M, F, A}) ->
    ok = gen_tcp:send(Socket, enc_term({M, F, A})),
    inet:setopts(Socket, [{active, false}]),
    {ok, BinResp} = gen_tcp:recv(Socket, 0, 5000),
    dec_resp(BinResp).

enc_term(T={_M, _F, _A}) ->
    term_to_binary(T).

dec_bin(T) ->
    {_M, _F, _A} = binary_to_term(T).

enc_resp(Term) ->
    term_to_binary(Term).

dec_resp(Bin) ->
    binary_to_term(Bin).