-module(contm).
-include("contm.hrl").
-export([return/1, bind/2, pass/2, run/2, callcc/1]).

return(X)-> #cont{ ct=fun(K)->K(X)end }.

bind(#cont{ct=CT}, F) -> #cont{ct=
	fun(K)-> CT( 
		fun(A)-> #cont{ct=V}=F(A), V(K) end
		)
	end
}.

pass(X, Y) when is_record(X,cont), is_record(Y,cont)->
	?MODULE:bind(X, fun(_)->Y end).

run(#cont{ct=CT}, K)->CT(K).

callcc(F)->#cont{ct=
	fun(K)-> #cont{ct=V} =
		F( fun(A)->#cont{ct=fun(_)->K(A)end}end ),
		V(K)
	end
}.
