-module(max_list).
-export([max_list/1]).

max_list([Head|Tail]) ->
   max_list(Tail, Head).

max_list([], Res) ->
   Res;
max_list([Head | Tail], Result) when Head > Result ->
   max_list(Tail, Head);
max_list([Head | Tail], Result) ->
   max_list(Tail, Result).
