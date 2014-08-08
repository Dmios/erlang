-module(mess_server).
-export([start_server/0, server/0]).

-include("mess_interface.hrl").

server() ->
   process_flag(trap_exit, true),
   server([]).

server(User_List) ->
   io:format("User List = ~p~n", [User_List]),
   receive
      #logon{client_pid=From, username=Name} ->
          New_User_List = server_logon(From, Name, User_List),
          server(New_User_List);
      {'Exit', From, _} ->
          New_User_List = server_logoff(From, User_List),
          server(New_User_List);
      #message{client_pid=From, to_name=To, message=Message} ->
          server_transfer(From, To, Message, User_List),
          server(User_List)
    end.

start_server() ->
    register(messenger, spawn(?MODULE, server, [])).  

server_logon(From, Name, User_List) ->
    case lists:keymember(Name, 2, User_List) of
        true -> 
             From ! #abort_client{message=user_exists_at_other_node},
             User_List;
        false ->
             From ! #server_reply{message=logged_on},
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

