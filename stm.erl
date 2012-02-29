-module(stm).
-include("stm.hrl").
-export([return/1, bind/2, pass/2, sget/0, sput/1, run/2]).

return(X)-> #st{ s=fun(S)->{X,S}end }.

bind(#st{s=H}, F)->#st{s=
	fun(S)->
		{R,NewS}=H(S),
		#st{s=G}=F(R),
		G(NewS)
	end
}.

pass(X, Y) when is_record(X,st), is_record(Y,st)->
	bind(X, fun(_)->Y end).

sget()->#st{s=fun(S)->{S,S}end}.

sput(NewS)->#st{s=fun(_)->{{},NewS}end}.

run(#st{s=S}, V)->S(V).
