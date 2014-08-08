-module(useless).
-export([old_enough/1, dup/2, map/2]).

old_enough(X) when X >= 16 -> true;
old_enough(_) -> false.

dup(0, _) -> [];
dup(N, Term) ->
	[Term|dup(N - 1, Term)].

map(_, []) -> [];
map(F, [H|T]) -> 
	[F(H)|map(F, T)].
