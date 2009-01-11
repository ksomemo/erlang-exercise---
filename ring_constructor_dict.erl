-module(ring_constructor_dict).
-export([construct/1, prepare/2]).

construct(N) when N > 0 ->
    Pids = dict:from_list(
	     lists:map(fun(I) -> {I-1, spawn(?MODULE, prepare, [self(), I])} end, 
		       lists:seq(1, N))),
    lists:foreach(fun(I) ->
			  Pid  = Pids:fetch(I),
			  Prev = Pids:fetch((I-1+N) rem N),
			  Next = Pids:fetch((I+1) rem N),
			  Pid ! {self(), {Prev, Next}}
			  end,
		 lists:seq(0, N-1)),
    Pids:fetch(0).

prepare(Builder, Pos)  ->
    receive
	{Builder, {Prev, Next}} ->
	    loop(Pos, Prev, Next)
    end.

loop(1, _Prev, Next)   -> lib_ring:entryloop(Next);
loop(_Pos, Prev, Next) -> lib_ring:loop(Prev, Next).
