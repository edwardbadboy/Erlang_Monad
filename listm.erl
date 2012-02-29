-module(listm).
-export([return/1, bind/2, pass/2, guard/1
	]).

return(Value)->
	[Value].

bind(L,F)->
	lists:flatmap(F,L).

pass(X, Y) when is_list(X), is_list(Y)->
	bind(X, fun(_)->Y end).

guard(true)->?MODULE:return({});
guard(false)->[].
