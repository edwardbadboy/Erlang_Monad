-module(maybem).
-export([return/1, bind/2, pass/2, concat/2,
	ll/1, lr/1, main/0]).
-include("maybem.hrl").

return(Value)->
	#maybe{just=Value}.

bind(nothing, _)->
	nothing;
bind(#maybe{just=Value}, Func) when is_function(Func,1)->
	Func(Value).

pass(X, Y) when is_record(X,maybe), is_record(Y,maybe)->
	bind(X, fun(_)->Y end).

concat(Maybe, Funs)when is_list(Funs) ->
	lists:foldl(fun(F, X)->bind(X, F) end, Maybe, Funs).

ll(L) ->
	fun
		({Left,Right}) when Left+L >= 0 ->
			Left1=Left+L,
			if (erlang:abs(Right-Left1)=<3) -> #maybe{just={Left1,Right}};
				true->nothing
			end;
		(_) -> nothing
	end.

lr(R) ->
	fun
	   ({Left,Right}) when Right+R >= 0 ->
			Right1=Right+R,
			if (erlang:abs(Right1-Left)=<3) -> #maybe{just={Left,Right1}};
				true->nothing
			end;
		(_) -> nothing
	end.

main()->
	?MODULE:concat(return({0,0}), [ll(1),lr(10),ll(2)]).
