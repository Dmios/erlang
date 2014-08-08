-module(monthes).
-export([days/2]).

days(Year, Month) ->
   Leap = if  
      trunc(Year / 400) * 400 == Year -> true;
      trunc(Year / 100) * 100 == Year -> false;
      trunc(Year / 4)   * 4   == Year -> true;
      true -> false
   end,
   
   case Month of
        jan -> 31;
        feb when Leap -> 29;
        feb -> 28
   end.
    
   
         
