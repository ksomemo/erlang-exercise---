-module(lib_ring).
-export([entryloop/1, loop/2, start/3]).

-record(payload, {client, message, counter, first}).

-ifdef(debug).
-define(TRACE(TEMPLATE, ARGS), io:format(TEMPLATE, ARGS)).
-else.
-define(TRACE(TEMPLATE, ARGS), void).
-endif.

entryloop(Next)  -> loop(Next).
loop(_Prev, Next) -> loop(Next).

loop(Next) ->
    Self = self(),
    receive
	#payload{first=Self, counter=C, message=Msg}=P ->
	    if
		C > 0 -> ?TRACE("last ~p rotations of ~p~n", [C, Msg]),
			 Next ! P#payload{counter=C-1};
		true  -> ?TRACE("finishi rotations of ~p~n", [Msg]),
			 P#payload.client ! {Self, Msg}
	    end;
	P when is_record(P, payload) ->
	    ?TRACE("pass ~p to the next node ~p~n", [P#payload.message, Next]),
	    Next ! P
    end,
    loop(Next).

start(Pid, M, Msg) when M >= 0 ->
    Pid ! #payload{client=self(), counter=M, message=Msg, first=Pid},
    receive
	{Pid, Response} ->
	    Response
    end.
