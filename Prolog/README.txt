Matricola: 829937 - Fabio D'Elia

-*- Prolog README-*-

Il programma prende in input il path ad un file in assembly (formato .lmc),
la lista di input, computa e ne restituisce il risultato.
Per questo progetto ho usato Emacs usando la repository kelleyk/emacs
(perchè le icone di emacs25 sono davvero brutte) in combinata con slime
e sbcl.
Il mio .emacs è disponibile su Github: https://github.com/JackFrost67
Qualsiasi pull request è ben accetta.

lmc_run/3:
    Predicato che prende in input il path relativo al file che si vuole 
    far girare sulla macchina e la lista di INPUT. In output restituirà la 
    lista di OUTPUT.
    
lmc_load/3:
    Prediato che genera la memoria. Prende in input il path relativo al file
    e restituisce la memoria parsata e pronta per essere eseguita.
    Al suo interno si hanno tutte le chiamate ai predicati atti al parsing
    del file dato come input.
    Qui sta il cuore pulsante della macchina. 
    La chiamata a read_string/5 restituisce una lista di stringhe corrispondenti
    alle righe del file. Ogni cella perciò rappresenta una riga del file.
    Viene di seguito fatto uno string_upper/2, essendo la macchina
    case-insensitive.
    La chiamata split_string/4 genera una lista di elementi, che rappresentano
    una riga del file dato in input.

%out_/2:
    Rappresenta la chiamata alla ricorsione di out/2. Quest'ultimo ha il 
    compito di rimuovere i commenti richiamando a sua volta il predicato
    remove_comment/2. La successiva chiamata di delete/3 serve a rimuovere
    gli elementi vuoti presenti nella lista.

label/4:
    In questo predicato vengono prelevate le etichette e inserite in una lista
    contenente alla posizione INDEX l'etichetta ed alla posizione INDEX + 1
    l'indice di memoria a cui l'etichetta si riferisce.
    Questo predicato si occupa anche di rimuovere le etichette, generando una
    lista di liste. Gli elementi di tale lista sono dunque righe di codice 
    assembly che verranno parsate in codice macchina.
    La flatten/2, chiamata sulla lista risultante si rivela necessaria per
    evitare chiamate ricorsive annidate per il prelevamento dell'etichetta
    e dell'indice.

interpreter_/3:
    Qui avviene il vero parsing. Viene fatta una chiamata ricorsiva annidata
    per il prelevamento della lista interna. Prima di parsare, avviene il 
    controllo delle etichette, assegnandogli il loro valore.
    Il predicato interpreter/2 si occupa di verificare che tipo di istruzione
    i tratta assegnando il suo numero indicativo.
    
value_/2:
    Predicato atto a gestire la chiamata ricorsiva annidata value/2, che 
    attraverso un'operazione aritmetica parsa il codice assembly in codice
    macchina.
