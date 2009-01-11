-module(ring_constructor_child).
-export([construct/1, prepare/1, prepare/3]).

construct(N) when N > 0 ->
    spawn(?MODULE, prepare, [N]).

prepare(1) ->
    lib_ring:entryloop(self());
prepare(N) ->
    Next = spawn(?MODULE, prepare, [self(), self(), N-1]),
    lib_ring:entryloop(Next).

prepare(First, Prev, 1) ->
    lib_ring:loop(Prev, First);
prepare(First, Prev, N) ->
    Next = spawn(?MODULE, prepare, [First, self(), N-1]),
    lib_ring:loop(Prev, Next).
