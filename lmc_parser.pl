:- retractall(labels(_, _)).
%% Normalizza la stringa elimianando i commenti

out([], []).
out([H | T], [H1 | T1]) :-
    make(H, H1),
    out(T, T1), !.

make([], []).
make(H, List2) :-
    string_chars(H, H1),
    remove_comment_(H1, List),
    unify(List, List2), !.

interpreter([], []).
interpreter([H | T], [H2 | T2]) :-
    label2(H, H1),
    interpreter_(H1, H2),
    interpreter(T, T2), !.

interpreter_([], []).
interpreter_([H | T], [H1 | T1]) :-
    atom_to_instruction(H, H1),
    interpreter_(T, T1), !.

remove_comment_([], []).
remove_comment_([H, H | _], []) :-
    atom_string('/', H).
remove_comment_([H | T], [H | Z]) :-
    remove_comment_(T, Z).

unify([], []).
unify(H, L) :-
    string_chars(L, H).

%% Prende in input un atomo-istruzione e lo trasforma
%% nel corrispettivo numerico

% atom_to_instruction/2 string_upper/2 string_to_number/2

atom_to_instruction(Term, Numb) :-
    string_upper(Term, X),
    string_to_number(X, Numb),!.

string_to_number(Inst, InstNumb) :-
    Y = ["HLT","ADD", "SUB",
         "STA"," ", "LDA",
         "BRA", "BRZ","BRP"],
    nth0(InstNumb, Y ,Inst),
    member(Inst, Y), !.

string_to_number(Inst, Num) :-
    number_string(Num, Inst).

string_to_number("INP", 901).
string_to_number("OUT", 902).
string_to_number("DAT", 0).
string_to_number(String, String).

label([], _, []).
label([H  | T], Index, [H1 | T1]):-
    split_string(H, " ", "\s", List),
    label1(List, Index, H1),
    Index1 is Index + 1,
    label(T, Index1, T1), !.

label1(List, Index, Mem) :-
    length(List, 3),
    nth0(0, List, Elem, Mem),
    assert(labels(Elem, Index)), !.
label1(List, Index, Mem ):-
    length(List, 2),
    nth0(0, List, Elem),
    nth0(1, List, Elem1),
    string(Elem),
    string_upper(Elem1, Elem2),
    is_member(Elem2),
    nth0(0,List, _, Mem),
    assert(labels(Elem, Index)), !.
label1(List, _, List).

label2(List, List2) :-
    length(List, 2),
    nth0(1, List, Elem),
    string(Elem),
    labels(Elem, N),
    replace(1, List, N, List2), !.
label2(List, List).

%% Implementazioni necessarie
listp([]).
listp([_|_]).

append_([], L, L).
append_([H | T], L, [H | X]) :- append_(T, L, X).

value_([], []).
value_([H | T], [H1 | T1]) :-
    value(H, H1),
    value_(T, T1),!.

value([H1, H2], Value) :-
       Value is (H1 * 100) + H2.
value([H1 | _], [H1]).

flatten_([],[]).
flatten_([H|T],Z):-
    listp(H),
    flatten(H,X),
    flatten(T,Y),
    append_(X,Y,Z), !.
flatten_([H|T],[H|X]) :-
    flatten_(T,X), !.

flatten_1([], []).
flatten_1([H | T], [H1 | T1]) :-
    flatten_(H, H1),
    flatten_1(T, T1), !.

replace(Pos,List,Elem,NewList):-
    nth0(Pos,List,_,TmpList),
    nth0(Pos,NewList,Elem,TmpList).

is_member(X) :-
    Y = ["HLT", "ADD", "SUB",
         "STA", "LDA", "BRA",
         "BRZ", "BRP", "DAT",
         "INP", "OUT"],
    member(X,Y), !.

list(Mem, Mem3) :-
    length(Mem, Index),
    Index1 is 100 - Index,
    list_(Index1, Mem2),
    append(Mem, Mem2, Mem3).

list_(0, []).
list_(Length, [H | T]):-
    Length \= 0,
    H = 0,
    Length1 is Length - 1,
    list_(Length1, T).
