-module(nimby).

-export([
    connect/2,
    send/2
]).

connect(Host, Port) ->
    gen_tcp:connect(Host, Port, [binary]).

send(Socket, {M, F, A}) ->
    gen_tcp:send(Socket, bin_format({M, F, A})).

bin_format({M, F, A}) ->
    MB = term_to_binary(M),
    FB = term_to_binary(F),
    AB = term_to_binary(A),
    <<
        (byte_size(MB)):8,
        (byte_size(FB)):8,
        (byte_size(AB)):8,
        MB/binary,
        FB/binary,
        AB/binary
    >>.