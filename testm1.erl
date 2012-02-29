-module(testm).
-export([testmaybem/0, testlistm/0, pyth/1, kmove/1, kmove3/1, kin3move/2, teststack/0]).
-include("maybem.hrl").
-include("stm.hrl").

testmaybem()-> maybem do {
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

testlistm()-> listm do {
	X<< [1,2,3];;
	Y<< [a,b,c];;
	listm:return({X,Y})
}.

pyth(N)-> listm do {
	A << lists:seq(1,N);;
	B << lists:seq(1,N);;
	C << lists:seq(1,N);;
	listm:guard(A+B+C=<N);;
	listm:guard(A*A+B*B==C*C);;
	listm:return({A,B,C})
}.

kmove({C,R})-> listm do {
	{C1,R1} << [{C+2,R-1},{C+2,R+1},{C-2,R-1},{C-2,R+1}  
               ,{C+1,R-2},{C+1,R+2},{C-1,R-2},{C-1,R+2}];;
	listm:guard(
		lists:member(C1,lists:seq(1,8)) and
		lists:member(R1,lists:seq(1,8)) );;
	listm:return({C1,R1})
}.

kmove3(Start)-> listm do {
	First << kmove(Start);;
	Second << kmove(First);;
	kmove(Second)
}.

kin3move(Start,End)-> lists:member(End, kmove3(Start)).

pop()->#st{s=fun([H|T])->{H,T}end}.
push(X)->#st{s=fun(L)->{{},[X|L]}end}.

teststack()-> ST = stm do {
	A << pop();;
	push(A+1);;
	B << stm:sget();;
	fun()->io:format("stack now ~w~n",[B]),
			stm:sput([8,8,8]) end();;
	push(5)
},
stm:run(ST,[3,2,1]).
