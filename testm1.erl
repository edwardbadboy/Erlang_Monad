-module(testm).
-export([main/0]).
-include("maybem.hrl").

main()-> maybem do {
	X1 << ll({0,0},1);;
	X2 << lr(X1,1);;
	X3 << ll(X2,20);;
	lr(X3,2)
}.

ll({Left,Right},L) when Left+L >= 0 ->
	Left1=Left+L,
	if (erlang:abs(Right-Left1)=<3) -> #maybe{just={Left1,Right}};
		true->nothing
	end;
ll(_,_) -> nothing.

lr({Left,Right},R) when Right+R >= 0 ->
	Right1=Right+R,
	if (erlang:abs(Right1-Left)=<3) -> #maybe{just={Left,Right1}};
		true->nothing
	end;
lr(_,_) -> nothing.

