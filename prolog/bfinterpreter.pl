%%%%%%%%
% syntax
%%%%%%%%

bf_program --> commands.

commands --> command.
commands --> command, commands.

command --> [>].
command --> [<].
command --> [+].
command --> [-].
command --> [.].
command --> [,].
command --> ['['], commands, [']'].

%%%%%%%%%%%
% semantics
%%%%%%%%%%%

bf_program( fun(S0, S, apply(S0, S, M))) --> commands(M).

commands( M ) --> command(M).
commands( fun(S0, S, ( apply(S0, S1, Mc), apply(S1,S, Mco) ) )) -->
	command(Mc), commands(Mco).

% move to next cell
command( fun((Pos,V,L0),(Pos1,N1,L),
	(Pos1 is Pos+1, del(Pos=_,L0,L1), (V = 0, L = L1, ! ; L = [Pos=V | L1]), (memb(Pos1=N1,L), ! ; N1 = 0)))) -->
	[>].

% move to previous cell
command( fun((Pos,V,L0),(Pos1,N1,L),
	(Pos1 is Pos-1, del(Pos=_,L0,L1), (V = 0, L = L1, ! ; L = [Pos=V | L1]), (memb(Pos1=N1,L), ! ; N1 = 0)))) -->
	[<].

% increment current cell value by 1
command( fun((P,V,L),(P,V1,L), (V1 is V+1) )) -->
	[+].

% decrement current cell value by 1
command( fun((P,V,L),(P,V1,L), (V1 is V-1) )) -->
	[-].

% print ASCII value of the current cell
command( fun(S,S,(S = (_,N,_), format("~c",N)) )) -->
	['.'].

% read one character into current cell
command( fun((P,_,L),(P,X,L), get_single_char(X) )) -->
	[','].

% while loop
command( fun(S0,S1,loop(S0, M, S1))) -->
	['['], commands(M), [']'].

% empty while loop is not cool
command( fun(S,S,true) ) -->
	['[', ']'].

% if current value is nonzero, do another iteration
loop(S0, Ins, S):-
	S0 = (_,N,_),
	N > 0,!,
	copy_term(Ins,InsC),
	apply(S0,S1,Ins),
	loop(S1,InsC,S).

loop(S,_,S).

% execute the given function
apply(X, Y, fun(X, Y, Constraints)):-
	Constraints.

% append/3 copy 
conc([],L,L).
conc([H|T],L,[H|NT]):-
	conc(T,L,NT).

% delete element implementation that doesn't fail
% when element isn't in the list
del(_, [], []).
del(X, [X|T], T).
del(X, [Y|T], [Y|NT]):-
	X \= Y,
	del(X,T,NT).

% member/2 copy
memb(X, [X|_]).
memb(X, [Y|T]):-
	X \= Y,
	memb(X,T).

read_bf_program(Filename,List):-
	open(Filename,read,Str),
	read_bf_helper(Str,List),
	close(Str).

read_bf_helper(S,[]):-
	at_end_of_stream(S),!.
read_bf_helper(S,NT):-
	get_char(S,H),
	read_bf_helper(S,T),
	( % remove irrelevant characters
		memb(H,[<,>,+,-,'.',',','[',']']),
		NT = [H|T]
		;
		NT = T
	).

bf_state((0,0,[0=0])).

execute_bf_program(File,Output):-
	read_bf_program(File,I),
	bf_state(S),
	bf_program(M,I,[]),
	apply(S,Output,M),
	!.

%%%%%%%%%%%%
% test cases
%%%%%%%%%%%%

program0( [
+,+,+,+,+,+,'[',>,+,+,+,+,+,+,+,+,+,+,<,-,']',>,+,+,+,+,+,'.'
]).

program1([
',',<,+,+,+,+,'[',-,>,-,-,-,-,-,-,-,-,-,-,<,']',>,-,-,-,-,-,-,-,-,>,',',
<,<,+,+,+,+,'[',-,>,>,-,-,-,-,-,-,-,-,-,-,<,<,']',>,>,-,-,-,-,-,-,-,-,
<,'[',>,'[',>,+,>,+,<,<,-,']',>,>,'[',-,<,<,+,>,>,']',<,<,<,-,']',>,>
]).


test0(Z):-
	write('should print A\n'),
	program0(P),
	bf_state(S),
	bf_program(M,P,[]),
	apply(S,Z,M).

test1(Z):-
	write('multiplicate given digits\n'),
	program1(P),
	bf_state(S),
	bf_program(M,P,[]),
	apply(S,Z,M),
	Z = (_,V,_),
	write('result: '),
	write(V).

% vim: ft=prolog
