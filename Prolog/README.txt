Matricola: 829937 - Fabio D'Elia

-*- Mode: Prolog -*-

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
    %La chiamata split_string/4 genera una lista di liste, in cui ogni lista
    %rappresenta una riga ed ogni elemento della lista è una instruzione o
    %un etichetta o un valore appartenente alla riga.
    %Da cui in poi verranno eseguite delle chiamate ricorsive innestate
    %atte a scorrere la lista contentente le liste e ad analizzare il loro
    %contenuto.
    %Tutto le chiamate ricorsive atte a prelevare la lista interna sono
    %identificate dall'underscore (ID_/n).

%out_/2:
    %Rappresenta la chiamata alla ricorsione di out/2. Quest'ultimo ha il 
    %compito di rimuovere i commenti richiamando a sua volta il predicato
    %remove_comment/2. La successiva chiamata di delete/3 serve a rimuovere
    %le carcasse di liste/elementi vuoti presenti nella lista madre.

%label/4:
    %In questo predicato vengono prelevate le etichette e inserite in una lista
    %contenente in INDEX l'etichetta ed in INDEX + 1 l'indice di memoria a cui
    %la l'etichetta si riferisce.

