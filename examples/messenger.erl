-module(messenger).
-export([start_server/0, server/0, logon/1, logoff/0, message/2, client/2]).

server_node() -> messenger@weblogic.

server() ->
   process_flag(trap_exit, true),
   server([]).

server(User_List) ->
   receive
      {From, logon, Name} ->
          New_User_List = server_logon(From, Name, User_List),
          server(New_User_List);
      {'Exit', From, _} ->
          New_User_List = server_logoff(From, User_List),
          server(New_User_List);
      {From, message_to, To, Message} ->
          server_transfer(From, To, Message, User_List),
          io:format("list is now: ~p~n", [User_List]),
          server(User_List)
    end.

start_server() ->
    register(messenger, spawn(messenger, server, [[]])).  

server_logon(From, Name, User_List) ->
    case lists:keymember(Name, 2, User_List) of
        true -> 
             From ! #abort_client{message=user_exists_at_other_node},
             User_List;
        false ->
             From ! #servert_reply{message=logged_on},
             link(From),
             [{From, Name} | User_List]
    end.

server_logoff(From, User_List) ->
    lists:keydelete(From, 1, User_List).

server_transfer(From, To, Message, User_List) ->
    case lists:keysearch(From, 1, User_List) of
        false ->
           From ! #abort_client{message=you_are_not_logged_on};
        {value, {_, Name}} ->
           server_transfer(From, Name, To, Message, User_List)
    end.

server_transfer(From, Name, To, Message, User_List) ->
    case lists:keysearch(To, 2, User_List) of
       false ->
          From ! #server_reply{message=receiver_not_found};
       {value, {ToPid, To}} ->
          ToPid ! #message_from{from_name=Name, message=Message},
          From ! #server_reply{message=sent}
    end.


logon(Name) ->
    case whereis(mess_client) of
           undefined ->
               register(mess_client, spawn(messenger, client, [server_node(), Name]));
           _ -> already_logged_on
    end.

logoff() ->
    mess_client ! logoff.

message(ToName, Message) ->
    case whereis(mess_client) of
           undefined ->
               not_logged_on;
           _ -> mess_client ! {message_to, ToName, Message},
                ok
    end.

client(Server_Node, Name) ->
    {messenger, Server_Node} ! #logon{client_pid=self(), username=Name},
    await_result(),
    client(Server_Node).

client(Server_Node) ->
    receive 
         logoff -> 
            exit(normal);
         #message_to{to_name=ToName, message=Message} ->
            {messenger, Server_Node} ! #message{client_pid=self(), to_name=ToName, message=Message},
            await_result();
         {message_from, FromName, Message} ->
            io:format("Message from ~p: ~p~n", [FromName, Message])
     end,
     client(Server_Node).

await_result() ->
     receive
          #abort_client{message=Why} ->
              io:format("~p~n", [Why]),
              exit(normal);
          #server_reply{message=What} ->
              io:format("~p~n", [What])
     after 10000 ->
              io:format("Server shutted down~n", []),
              exit(timeout)
     end.


