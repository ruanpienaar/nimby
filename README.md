# nimby
Not in my back yard!

## Server
nimby_listen_server:start_link("localhost", 12345).

## Client
{ok, S} = nimby:connect("localhost", 12345).
nimby:send(S, {erlang, now, []}).  
