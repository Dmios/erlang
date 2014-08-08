-module(geom).
-export([area/1]).

area({Shape, A, B}) ->
	area(Shape, A, B).

area(Shape, A, B) when A > 0, B > 0 -> 
	case Shape of
		rectangle -> A * B;
		triangle  -> A * B / 2.0;
		ellipse   -> A * B * math:pi() 
	end;

area(_, _, _) -> 0.
