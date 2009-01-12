-module(lib_ring).
-export([entryloop/1, loop/2, start/3]).

-record(payload, {client, message, counter}).

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
	{_, #payload{counter=0, message=Msg}=P} ->
	    ?TRACE("finishi rotations of ~p~n", [Msg]),
	    P#payload.client ! {self(), Msg},
	    entryloop(Next);

	{_, #payload{counter=C}=P} ->
	    ?TRACE("last ~p rotations of ~p~n", [C, P#payload.message]),
	    Next ! {self(), P#payload{counter=C-1}},
	    entryloop(Next)
    end.

loop(Prev, Next) ->
    receive
	{Prev, Payload} when is_record(Payload, payload) ->
	    ?TRACE("pass ~p to the next node ~p~n", [Payload#payload.message, Next]),
	    Next ! {self(), Payload},
	    loop(Prev, Next)
    end.

start(Pid, M, Msg) when M >= 0 ->
    rpc(Pid, #payload{client=self(), counter=M, message=Msg}).
