-module(powers).
-export([raise/2, nth_root/2]).

raise(X, N) ->
	if 
	   N =:= 0 -> 1;
	   N =:= 1 -> X;
	   N > 0   -> raise(X, N, 1);
	   N < 0   -> 1.0 / raise(X, N * -1)
	end.

raise(X, N, Acc) ->
	if
	   N =:= 0 -> Acc;
	   true    -> raise(X, N - 1, X * Acc)
	end.

nth_root(X, N , A) ->
	io:format("Current guess is ~p~n", [A]),
	F = raise(A, N) - X,
	Fprime = N * raise(A, N - 1),
	Next = A - F / Fprime,
	Change = abs(Next - A),
	if 
	   Change < 0.00000001 -> Next;
	   true -> nth_root(X, N, Next)
	end.

nth_root(X, N) -> 
	nth_root(X, N, X / 2.0).
