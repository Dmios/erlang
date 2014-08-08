-module(hello).
-export([fact/1]).

fact(0) -> 1;

fact(N) ->
   if 
       N < 0 -> 
            negative_not_accepted;
       N > 0 ->
            N * fact(N - 1)
   end.
