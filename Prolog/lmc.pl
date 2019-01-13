%%%% Matricola: 829937 Fabio D'Elia
%%%% Progetto LMC - LITTLE MAN COMPUTER

%%%% -*- Mode: Prolog -*-

%%%% lmc.pl

%%%lmc_run/3
lmc_run(Filename, Input, Output) :-
    lmc_load(Filename, Mem),
    execution_loop(state(0, 0, Mem, Input, [], "NoFlag"), Output), !.

%%%lmc_load/2
lmc_load(FileName, Mem2) :-
    open(FileName, read, BufferIn),
    read_string(BufferIn, "", " \r\t", _, X),
    string_upper(X, X1),
    split_string(X1, "\n", " ", Y),
    out_(Y, Z),
    delete(Z, "", Z2),
    label(Z2, 0, Z3, Labels),
    flatten(Labels, Labels1),
    interpreter_(Z3, Z4, Labels1),
    value_(Z4, Z5),
    flatten(Z5, Mem),
    list(Mem, Mem2),
    close(BufferIn).

%%%out_/2
%%%out_(List, NewList).
out_([], []).
out_([H | T], [H1 | T1]) :-
    out(H, H1),
    out_(T, T1), !.

%%%out/2
%%%out(String, NoComment).
out([], []).
out(H, List2) :-
    string_chars(H, H1),
    remove_comment(H1, List),
    string_chars(List2, List), !.

%%%remove_comment/2
%%%remove comments, just for fun
remove_comment([], []).
remove_comment([H, H | _], []) :-
    atom_string('/', H).
remove_comment([H | T], [H | Z]) :-
    remove_comment(T, Z).

%%%interpreter_/3
%%%interpreter(ListOfLists, NewListOfLists).
%%%parse the instruction.
%%%labels resolved.
interpreter_([], [], _).
interpreter_([H | T], [H2 | T2], Labels) :-
    label2(H, H1, Labels),
    interpreter(H1, H2),
    interpreter_(T, T2, Labels), !.

%%%interpreter/2
%%%interpreter(List, ParsedList).
interpreter([], []).
interpreter([H | T], [H1 | T1]) :-
    string_to_number(H, H1),
    interpreter(T, T1), !.

%%%string_to_number/2
%%%from string to code
string_to_number(Inst, InstNumb) :-
    Y = ["HLT", "ADD", "SUB",
         "STA", " ", "LDA",
         "BRA", "BRZ", "BRP"],
    nth0(InstNumb, Y, Inst),
    member(Inst, Y), !.
string_to_number(Inst, Num) :-
    string(Inst),
    number_string(Num, Inst).
string_to_number("INP", 901).
string_to_number("OUT", 902).
string_to_number("DAT", 0).
string_to_number(String, String).

%%%label/4
%%%label(ListOfString, Index, NewList, ListOfLabels).
%%%catching labels
label([], _, [], []).
label([H | T], Index, [H1 | T1], [H2 | T2]):-
    split_string(H, " ", "\s", List),
    label1(List, Index, H1, H2),
    Index1 is Index + 1,
    label(T, Index1, T1, T2), !.

%%%label1/4
%%%label1(ListOfWords, Index, NewList, ListOfLabels).
%%%catching labels for real
label1(List, Index, Mem, [Elem, Index]) :-
    length(List, 3),
    nth0(0, List, Elem, Mem),!.
label1(List, Index, Mem, [Elem, Index]):-
    length(List, 2),
    nth0(0, List, Elem),
    nth0(1, List, Elem1),
    is_member(Elem1),
    nth0(0,List, _, Mem),!.
label1(List, _, List, 0).

%%%label2/3
%%%label2(List, NewList, ListOfLabels).
%%%solving labels
label2(List, List, _) :-
    length(List, 2),
    nth0(0, List, Dat),
    Dat = "DAT",
    nth0(1, List, Elem),
    number(Elem), !.
label2(List, List2, Labels) :-
    length(List, 2),
    nth0(1, List, Elem),
    nth0(Index, Labels, Elem),
    Index1 is Index + 1,
    nth0(Index1, Labels, Numb),
    replace(1, List, Numb, List2), !.
label2(List, List, _).

%%%value_/2
%%%value_(ListOfLists, NewListOfCodes).
value_([], []).
value_([H | T], [H1 | T1]) :-
    value(H, H1),
    value_(T, T1),!.

%%%value/2
%%%value(Instruction, InstructionCode).
%%%get the code
value([H1, H2], Value) :-
    Value is (H1 * 100) + H2.
value([H1 | _], [H1]).

%%%replace/4
replace(Pos, List, Elem, NewList):-
    nth0(Pos, List, _, TmpList),
    nth0(Pos, NewList, Elem, TmpList).

%%%is_member/1
%%%how to understand if somenthing is a label or not
is_member(X) :-
    Y = ["HLT", "ADD", "SUB",
         "STA", "LDA", "BRA",
         "BRZ", "BRP", "DAT",
         "INP", "OUT"],
    member(X, Y), !.

%%%list/2
list(Mem, Mem3) :-
    length(Mem, Index),
    Index1 is 100 - Index,
    list_(Index1, Mem2),
    append(Mem, Mem2, Mem3).

%%%list_/2
list_(0, []).
list_(Length, [H | T]):-
    Length \= 0,
    H = 0,
    Length1 is Length - 1,
    list_(Length1, T).

%%%% -*- END OF PARSER -*-

%%%%execution_loop/2
execution_loop(state(Acc, Pc, Mem, Input, Output, Flag), Output1):-
    length(Mem, Len),
    Pc < Len,
    one_instruction(state(Acc, Pc, Mem, Input, Output, Flag), NewState),
    execution_loop(NewState, Output1), !.
execution_loop(state(_, Pc, Mem, _, Output, _), Output1):-
    length(Mem, Len),
    Pc = Len,
    flatten(Output, Output1).
execution_loop(halted_state(_, _, _, _, Output, _), Output1):-
     flatten(Output, Output1).

%%%%somma
one_instruction(state(Acc, Pc, Mem, Input, Output, _),
                state(Acc1, Pc1, Mem, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst),
    Inst > 99,
    Inst < 200,
    X is Inst mod 100,
    nth0(X, Mem, Y),
    Pc1 is Pc + 1,
    Ris is Acc + Y,
    Ris >= 1000,
    Flag = "Flag",
    Acc1 is Ris mod 1000.
one_instruction(state(Acc, Pc, Mem, Input, Output, _),
                state(Acc1, Pc1, Mem, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst),
    Inst > 99,
    Inst < 200,
    X is Inst mod 100,
    nth0(X, Mem, Y),
    Pc1 is Pc + 1,
    Ris is Acc + Y,
    Flag = "NoFlag",
    Acc1 is Ris mod 1000.

%%%%sottrazione
one_instruction(state(Acc, Pc, Mem, Input, Output, _),
                state(Acc1, Pc1, Mem, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst),
    Inst > 199,
    Inst < 300,
    X is Inst mod 100,
    nth0(X, Mem, Y),
    Pc1 is Pc + 1,
    Ris is Acc - Y,
    Ris < 0,
    Flag = "Flag",
    Acc1 is Ris mod 1000.
one_instruction(state(Acc, Pc, Mem, Input, Output, _),
                state(Acc1, Pc1, Mem, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst),
    Inst > 199,
    Inst < 300,
    X is Inst mod 100,
    nth0(X, Mem, Y),
    Pc1 is Pc + 1,
    Ris is Acc - Y,
    Flag = "NoFlag",
    Acc1 is Ris mod 1000.

%%%store
one_instruction(state(Acc, Pc, Mem, Input, Output, Flag),
                state(Acc, Pc1, Mem2, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst),
    Inst > 299,
    Inst < 400,
    X is Inst mod 100,
    Pc1 is Pc + 1,
    replace(X, Mem, Acc, Mem2).

%%%load
one_instruction(state(_, Pc, Mem, Input, Output, Flag),
                state(Y, Pc1, Mem, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst),
    Inst > 499,
    Inst < 600,
    X is Inst mod 100,
    nth0(X, Mem, Y),
    Pc1 is Pc + 1.

%%%branch
one_instruction(state(Acc, Pc, Mem, Input, Output, Flag),
                state(Acc, Pc1, Mem, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst),
    Inst > 599,
    Inst < 700,
    Pc1 is Inst mod 100.

%%%branch if zero
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

%%%branch if positive
one_instruction(state(Acc, Pc, Mem, Input, Output, Flag),
                state(Acc, Pc1, Mem, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst),
    Inst > 799,
    Inst < 900,
    Flag = "NoFlag",
    Pc1 is Inst mod 100.
one_instruction(state(Acc, Pc, Mem, Input, Output, Flag),
                state(Acc, Pc1, Mem, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst),
    Inst > 799,
    Inst < 900,
    Pc1 is Pc + 1.

%%%input
one_instruction(state(_, Pc, Mem, Input, Output, Flag),
                state(NewAcc, Pc1, Mem, Input1, Output, Flag)) :-
    nth0(Pc, Mem, Inst),
    Inst is 901,
    nth0(0, Input, Acc1, Input1),
    NewAcc is mod(Acc1, 1000),
    Pc1 is Pc + 1.

%%%output
one_instruction(state(Acc, Pc, Mem, Input, Output, Flag),
                state(Acc, Pc1, Mem, Input, [Output, Acc], Flag)) :-
    nth0(Pc, Mem, Inst),
    Inst is 902,
    Pc1 is Pc + 1.

%%%halt
one_instruction(state(Acc, Pc, Mem, Input, Output, Flag),
                halted_state(Acc, Pc, Mem, Input, Output, Flag)).


%%%% end of file -- lmc.pl
