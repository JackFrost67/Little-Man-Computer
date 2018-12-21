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
    Inst>199,
    Inst<300,
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
    Inst>299,
    Inst<400,
    X is Inst mod 100,
    Pc1 is Pc+1,
    replace(X, Mem, Acc, Mem2).

%%load
one_instruction(state(_, Pc, Mem, Input, Output, Flag),
		state(Y, Pc1, Mem, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst, _),
    Inst>499,
    Inst<600,
    X is Inst mod 100,
    nth0(X, Mem, Y),
    Pc1 is Pc+1.

%%branch
one_instruction(state(Acc, Pc, Mem, Input, Output, Flag),
		state(Acc, Pc1, Mem, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst, _),
    Inst>599,
    Inst<700,
    Pc1 is Inst mod 100.

%%branch if zero
one_instruction(state(Acc, Pc, Mem, Input, Output, Flag),
		state(Acc, Pc1, Mem, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst),
    Inst>699,
    Inst<800,
    Acc = 0,
    Flag = "NoFlag",
    Pc1 is Inst mod 100.
one_instruction(state(Acc, Pc, Mem, Input, Output, Flag),
		state(Acc, Pc1, Mem, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst),
    Inst>699,
    Inst<800,
    Pc1 is Pc + 1.

%%branch if positive
one_instruction(state(Acc, Pc, Mem, Input, Output, Flag),
		state(Acc, Pc1, Mem, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst, _),
    Inst>799,
    Inst<900,
    Flag = "NoFlag",
    Pc1 is Inst mod 100.
one_instruction(state(Acc, Pc, Mem, Input, Output, Flag),
		state(Acc, Pc1, Mem, Input, Output, Flag)) :-
    nth0(Pc, Mem, Inst, _),
    Inst>799,
    Inst<900,
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



















