-module(calc).
-export([rpn/1]).

rpn(L) when is_list(L) ->
	[Res] = lists:foldl(fun rpn/2, [], string:tokens(L, " ")),
	Res.

rpn("+", [N1,N2|S]) -> [N2+N1|S];
rpn(X, Stack) -> [read(X)|Stack].

read(N) ->
	case string:to_float(N) of
		{error, no_float} -> list_to_integer(N);
		{F, _} -> F
	end.

