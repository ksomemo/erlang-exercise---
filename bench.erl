-module(bench).
-export([run_main/1, run_main/0]).

run_main()  -> main([]).
run_main(L) -> main(L).

main([Constructor, N1, M1]) ->
    [N, M] = lists:map(fun atom_to_integer/1, [N1, M1]),
    io:format("Constructor=~p, N=~p, M=~p~n", [Constructor, N, M]),
    bench(fun() -> ring_server:start(ring_server:construct(N, Constructor), M, foo) end),
    init:stop().

atom_to_integer(A) ->
    list_to_integer(atom_to_list(A)).

bench(Fun) ->
    statistics(runtime),
    statistics(wall_clock),
    Fun(),
    {_, Time1} = statistics(runtime),
    {_, Time2} = statistics(wall_clock),
    U1 = Time1 / 1000,
    U2 = Time2 / 1000,
    io:format("time=~p, (~p) seconds~n", [U1, U2]).
