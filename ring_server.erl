-module(ring_server).
-export([construct/1, construct/2, start/3]).

-ifndef(DEFAULT_CONSTRUCOTR).
-define(DEFAULT_CONSTRUCOTR, ring_constructor_dict).
-endif.

construct(N) ->
    construct(N, ?DEFAULT_CONSTRUCOTR).

construct(N, Constructor) when is_atom(Constructor) ->
    Constructor:construct(N).

start(Ring, M, Msg) ->
    lib_ring:start(Ring, M, Msg).
