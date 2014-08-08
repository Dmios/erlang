-module(reverse).
-export([reverse/1]).

reverse(List) -> 
   reverse(List, []).

reverse([Head | Tail], Reversed) ->
   reverse(Tail, [Head | Reversed]);
reverse([], Reversed) ->
   Reversed.
