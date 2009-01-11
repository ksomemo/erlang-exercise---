-module(ring_constructor_list).
-export([construct/1, prepare/2]).

nth0(I, L) ->
    lists:nth(I+1, L).

construct(N) when N > 0 ->
    Pids = lists:map(fun(I) -> spawn(?MODULE, prepare, [self(), I]) end, 
		     lists:seq(1, N)),
    lists:foreach(fun(I) ->
			  Pid  = nth0(I, Pids),
			  Prev = nth0((I-1+N) rem N, Pids),
			  Next = nth0((I+1) rem N,   Pids),
			  Pid ! {self(), {Prev, Next}}
			  end,
		 lists:seq(0, N-1)),
    nth0(0, Pids).

prepare(Builder, Pos)  ->
    receive
	{Builder, {Prev, Next}} ->
	    loop(Pos, Prev, Next)
    end.

loop(1, _Prev, Next)   -> lib_ring:entryloop(Next);
loop(_Pos, Prev, Next) -> lib_ring:loop(Prev, Next).
