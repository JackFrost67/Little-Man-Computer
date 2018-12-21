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



