-module(lib_ring).
-export([entryloop/1, loop/2, start/3]).

-ifdef(debug).
-define(TRACE(TEMPLATE, ARGS), io:format(TEMPLATE, ARGS)).
-else.
-define(TRACE(TEMPLATE, ARGS), void).
-endif.

rpc(Pid, Request) ->
    Pid ! {self(), Request},
    receive
	{Pid, Response} ->
	    Response
    end.

entryloop(Next) ->
    receive
	{_, {0, Msg, Client}} ->
	    ?TRACE("finishi rotation of ~p~n", [Msg]),
	    Client ! {self(), Msg},
	    entryloop(Next);

	{_, {M, Msg, Client}} ->
	    ?TRACE("last ~p rotations of ~p~n", [M, Msg]),
	    Next ! {self(), {M-1, Msg, Client}},
	    entryloop(Next)
    end.

loop(Prev, Next) ->
    receive
	{Prev, {_M, _Msg, _Client}=Req} ->
	    ?TRACE("pass ~p to the next node ~p~n", [_Msg, Next]),
	    Next ! {self(), Req},
	    loop(Prev, Next)
    end.

start(Pid, M, Msg) when M >= 0 ->
    rpc(Pid, {M, Msg, self()}).
