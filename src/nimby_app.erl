-module(nimby_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

-include("nimby.hrl").

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    nimby_sup:start_link().

stop(_State) ->
    ok.
