-module(testm).
-export([ll/2, lr/2, testmaybem/0,
		testlistm/0, pyth/1, kmove/1, kmove3/1, kin3move/2, combinationl/2, combinationl2/2,
		teststack/0,
		factor2/1, factors/1, testcallcc1/0, testcallcc2/0, combination/2]).
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

combl2(_Start, _End, 0=_Select, R)-> listm:return(lists:reverse(R));
combl2(Start, End, Select, R)-> listm do {
	listm:guard( Select>0 andalso Select=<(End-Start+1) );;
	I << lists:seq(Start, End);;
	combl2(I+1, End, Select-1, [I|R])
}.

combinationl2(Total, Select)->
	combl2(1, Total, Select, []).

combl(_Start, _End, 0=_Select)-> listm:return([]);
combl(Start, End, Select)-> listm do {
	listm:guard( Select>0 andalso Select=<(End-Start+1) );;
	H << lists:seq(Start, End);;
	T << combl(H+1, End, Select-1);;
	listm:return([H|T])
}.

combinationl(Total, Select)->
	combl(1, Total, Select).

pop()->#st{s=fun([H|T])->{H,T}end}.
push(X)->#st{s=fun(L)->{{},[X|L]}end}.

teststack()-> ST = stm do {
	A << pop();;
	push(A+1);;
	B << stm:sget();;
	io:format("stack now ~w~n",[B]),
	stm:sput([8,8,8]);;
	push(5)
},
stm:run(ST,[3,2,1]).

pushcont(Newcont)->
	L=case erlang:get(checkpoint) of
		undefined->[];
		List->List
	end,
	erlang:put(checkpoint, [Newcont|L]).

popcont()->
	[H|T]=erlang:get(checkpoint),
	erlang:put(checkpoint, T),
	H.

clearcont()->erlang:erase(checkpoint).

guess()-> contm do {
	contm:callcc(
		fun(K)-> contm do {
			pushcont(K), contm:return(true)
		} end )
}.

fail()-> contm do {
	K=popcont(),
	K(false)
}.

integer_r(A,B) when is_integer(A), is_integer(B), A=<B -> contm do {
	R << guess();;
	if(R)-> contm:return(A); true->integer_r(A+1,B) end
};
integer_r(_,_) -> contm do {
	fail()
}.

factor2_try(N)-> contm do{
	I << integer_r(2, N);;
	J << integer_r(2, I);;
	case I*J of
		N -> contm:return([I,J]);
		_ -> fail()
	end
}.

factor2(N)-> C= contm do{
	R << guess();;
	case R of
		true-> factor2_try(N);
		_ -> contm:return([N])
	end
},
contm:run(C, fun(X)->clearcont(),X end).

factors(N)->
	case factor2(N) of
		[N]->[N];
		[F1,F2]->lists:append(factors(F1),factors(F2))
	end.

testcallcc1()-> C = contm do{
	X << contm:callcc(
		fun(E)-> contm do {
			erlang:put(exitp,E),
			E(10);;
			contm:return(20)
		} end
	);;
	contm:return(X*X)
},
contm:final(C).

testcallcc2()-> C = contm do{
	E=erlang:get(exitp), E(11)
},
contm:final(C).

comb(_Start, _End, 0=_Select, R) -> contm do{
	io:format("~w~n",[lists:reverse(R)]),
	fail()
};
comb(Start, End, Select, R) when Select>0, Select=<(End-Start+1) -> contm do{
	I << integer_r(Start, End);;
	comb(I+1, End, Select-1, [I|R])
};
comb(_Start, _End, _Select, _R) -> contm do{
	fail()
}.

combination(Total, Select)-> C = contm do{
	R << guess();;
	if R -> comb(1, Total, Select, []); true->contm:return(ok) end
}, contm:run(C, fun(X)->clearcont(),X end).
