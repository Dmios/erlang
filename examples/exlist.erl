-module(exlist).
-export([llength/1]).

llength([]) -> 0;
llength([First|Rest]) ->
   1 + llength(Rest).
