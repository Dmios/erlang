-module(threads).
-export([start/1, ping/2, pong/0]).

ping(N, Pong_Pid) ->
   link(Pong_Pid),
   ping1(N, Pong_Pid).

ping1(0, _) -> exit(ping);

ping1(N, Pong_Pid) ->
   Pong_Pid ! {ping, self()},
   receive 
       pong -> io:format("Ping get pong~n", [])
   end,
   ping1(N - 1, Pong_Pid).

pong() ->
   process_flag(trap_exit, true),
   pong1().

pong1() ->
   receive 
       {ping, Ping_PID} ->
           io:format("Pong get ping~n", []),
           Ping_PID ! pong,
           pong();
       {'EXIT', From, Reason} ->
           io:format("Get error message ~p~n", [{'EXIT', From, Reason}])
    after 10000 ->
           io:format("Pong timeout exception!~n",[])
   end.

start(Ping_Node) ->
   PongPID = spawn(threads, pong, []),
   spawn(Ping_Node, threads, ping, [3, PongPID]).

