%%%%% Matricola: 829937 Fabio D'Elia
%%%%% Progetto LMC - LITTLE MAN COMPUTER

%%%% -*- Mode: Prolog -*-

%%%% lmc.pl

:- retractall(labels(_, _)).

%lmc_run/3
lmc_run(Filename,  Input, Output) :-
    lmc_load(Filename, Mem),
    execution_loop(state(0, 0, Mem, Input, [], "NoFlag"), Output), !.

%lmc_load/2
lmc_load(FileName, Mem2) :-
    open(FileName, read, BufferIn),
    read_string(BufferIn, "", " \r\t", _, X),
    split_string(X, "\n", " ", Y),
    delete(Y, "", W),
    out(W, Z),
    delete(Z, [], Z2),
    label(Z2, 0, Z3),
    interpreter(Z3, Z4),
    value_(Z4, Z5),
    flatten_(Z5, Mem),
    list(Mem, Mem2),
    close(BufferIn).

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
%
% atom_to_instruction/2 string_upper/2 string_to_number/2
%
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
listp([_ | _]).

append_([], L, L).
append_([H | T], L, [H | X]) :-
    append_(T, L, X).

value_([], []).
value_([H | T], [H1 | T1]) :-
    value(H, H1),
    value_(T, T1),!.

value([H1, H2], Value) :-
    Value is (H1 * 100) + H2.
value([H1 | _], [H1]).

flatten_([],[]).
flatten_([H | T], Z):-
    listp(H),
    flatten(H, X),
    flatten(T, Y),
    append_(X, Y, Z), !.
flatten_([H | T],[H | X]) :-
    flatten_(T, X), !.

flatten_1([], []).
flatten_1([H | T], [H1 | T1]) :-
    flatten_(H, H1),
    flatten_1(T, T1), !.

replace(Pos, List, Elem, NewList):-
    nth0(Pos, List, _, TmpList),
    nth0(Pos, NewList, Elem, TmpList).

is_member(X) :-
    Y = ["HLT", "ADD", "SUB",
         "STA", "LDA", "BRA",
         "BRZ", "BRP", "DAT",
         "INP", "OUT"],
    member(X, Y), !.

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

%%execution_loop
execution_loop(state(Acc, Pc, Mem, Input, Output, Flag), Output1):-
    length(Mem, Len),
    Pc < Len,
    one_instruction(state(Acc, Pc, Mem, Input, Output, Flag), NewState),
    execution_loop(NewState, Output1).

execution_loop(state(_, Pc, Mem, _, Output, _), Output):-
    length(Mem, Len),
    Pc = Len.
execution_loop(halted_state(_, _, _, _, Output, _), Output).

%%somma
one_instruction(state(Acc, Pc, Mem, Input, Output, _),
                state(Acc1, Pc1, Mem, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst, _),
    Inst>99,
    Inst<200,
    X is Inst mod 100,
    nth0(X, Mem, Y),
    Pc1 is Pc+1,
    Ris is Acc + Y,
    Ris < 1000,
    Flag = "NoFlag",
    Acc1 is Ris mod 1000.
one_instruction(state(Acc, Pc, Mem, Input, Output, _),
                state(Acc1, Pc1, Mem, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst, _),
    Inst>99,
    Inst<200,
    X is Inst mod 100,
    nth0(X, Mem, Y),
    Pc1 is Pc+1,
    Ris is Acc + Y,
    Ris >= 1000,
    Flag = "Flag",
    Acc1 is Ris mod 1000.

%%sottrazione
one_instruction(state(Acc, Pc, Mem, Input, Output, _),
                state(Acc1, Pc1, Mem, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst, _),
    Inst>199,
    Inst<300,
    X is Inst mod 100,
    nth0(X, Mem, Y),
    Pc1 is Pc+1,
    Ris is Acc - Y,
    Ris >= 0,
    Flag = "NoFlag",
    Acc1 is Ris mod 1000.
one_instruction(state(Acc, Pc, Mem, Input, Output, _),
                state(Acc1, Pc1, Mem, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst, _),
    Inst > 199,
    Inst < 300,
    X is Inst mod 100,
    nth0(X, Mem, Y),
    Pc1 is Pc+1,
    Ris is Acc - Y,
    Ris < 0,
    Flag = "Flag",
    Acc1 is Ris mod 1000.


%%store
one_instruction(state(Acc, Pc, Mem, Input, Output, Flag),
                state(Acc, Pc1, Mem2, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst, _),
    Inst > 299,
    Inst < 400,
    X is Inst mod 100,
    Pc1 is Pc+1,
    replace(X, Mem, Acc, Mem2).

%%load
one_instruction(state(_, Pc, Mem, Input, Output, Flag),
                state(Y, Pc1, Mem, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst, _),
    Inst > 499,
    Inst < 600,
    X is Inst mod 100,
    nth0(X, Mem, Y),
    Pc1 is Pc+1.

%%branch
one_instruction(state(Acc, Pc, Mem, Input, Output, Flag),
                state(Acc, Pc1, Mem, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst, _),
    Inst > 599,
    Inst < 700,
    Pc1 is Inst mod 100.

%%branch if zero
one_instruction(state(Acc, Pc, Mem, Input, Output, Flag),
                state(Acc, Pc1, Mem, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst),
    Inst > 699,
    Inst < 800,
    Acc = 0,
    Flag = "NoFlag",
    Pc1 is Inst mod 100.
one_instruction(state(Acc, Pc, Mem, Input, Output, Flag),
                state(Acc, Pc1, Mem, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst),
    Inst > 699,
    Inst < 800,
    Pc1 is Pc + 1.

%%branch if positive
one_instruction(state(Acc, Pc, Mem, Input, Output, Flag),
                state(Acc, Pc1, Mem, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst, _),
    Inst > 799,
    Inst < 900,
    Flag = "NoFlag",
    Pc1 is Inst mod 100.
one_instruction(state(Acc, Pc, Mem, Input, Output, Flag),
                state(Acc, Pc1, Mem, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst, _),
    Inst > 799,
    Inst < 900,
    Pc1 is Pc + 1.

%%input
one_instruction(state(_, Pc, Mem, Input, Output, Flag),
                state(Acc1, Pc1, Mem, Input1, Output, Flag)) :-
    nth0(Pc, Mem, Inst, _),
    Inst is 901,
    nth0(0, Input, Acc1, Input1),
    Pc1 is Pc + 1.

%%output
one_instruction(state(Acc, Pc, Mem, Input, Output, Flag),
                state(Acc, Pc1, Mem, Input, Output1, Flag)) :-
    nth0(Pc, Mem, Inst),
    Inst is 902,
    append(Output, [Acc], Output1),
    Pc1 is Pc + 1.

%%halt
one_instruction(state(Acc, Pc, Mem, Input, Output, Flag),
                halted_state(Acc, Pc, Mem, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst, _),
    Inst < 100, !.


%%%% end of file -- lmc.pl
