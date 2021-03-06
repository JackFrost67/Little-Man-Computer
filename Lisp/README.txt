

-*- Lisp README -*-

Il programma prende in input il path ad un file in assembly (formato .lmc),
la lista di input, computa e ne restituisce il risultato.
Per questo progetto ho usato Emacs (mi rifiuto di usare 
quell'aborto di LispWorks) usando la repository kelleyk/emacs
(perchè le icone di emacs25 sono davvero brutte) in combinata con slime
e sbcl.
Il mio .emacs è disponibile su Github: https://github.com/JackFrost67
Qualsiasi pull request è ben accetta.

lmc-run/2 : 
    Funzione che prende in input il path, riferito al file .lmc, 
    e la lista in input. 
    lmc-run/2 contiene le chiamate a lmc-load/1, che genera la memoria, 
    e execution-loop/2.

lmc-load/1 : 
    Funzione che genera la memoria. 
    Contiene tutti i predicati che manipolano la lista di simboli
    derivanti da remove-file/1.
    La funzione conclude con la concatenazione della lista parsata
    e la lista contenenti tanti zeri quante le celle di memoria vuote.

read-file/1 : 
    Prende in input il path riferito al file .lmc. 
    Genera la lista di simboli che rappresentano le istruzioni in assembly.
    Gestisce anche la rimozione degli spazi e dei commenti.

label/2 :
    Prende in input la lista gestita da read-file/1 due volte.
    La lista list viene fatta scorrere attraverso una chiamata ricorsiva, 
    mentre list1 serve da riferimento per assegnare all'etichetta
    l'indice a cui l'etichetta si riferisce.
    La lista di etichette viene costrutita in questo modo:
        - si preleva l'etichetta e l'indice di memoria.
        - si inseriscono nella lista gli elementi prelevati in modo
          sequenziale.

remove-label/2 :
    Prende in input la lista in output da label/2 e la lista di label.
    Rimuove tutti le dichiarazioni, ovvero ogni etihetta presente
    all'inizio della riga.
    Da questo punto in poi list sarà composta da liste rappresentanti 
    righe di codice scritte in assembly, di lunghezza due o uno nel caso
    di istruzioni come INP/OUT/DAT.

interpreter/2:
    Qui avviene il vero parsing. 
    La funzione prende in input la lista derivante da remove-label/2
    e la lista label, contenente tutte le etichette e i suoi riferimenti.
    Al suo interno viene dichiarata la lista operands che contiene tutte 
    le operazioni e i suoi codici macchina.
    In output si avrà una lista di liste contenenti il codice riferito 
    all'operazione e il riferimento all'etichetta, se questa è presente.

value/1 :
    Prende in input la lista parsata da interpreter/2. Qui si genera
    finalmente il codice macchina riferito al codice assembly.
    Si esegue un'operazione aritmetica per ottenere il codice macchina.

execution-loop/1:
    Prende in input lo stato, creato nella chiamata di lmc-run/2 ed esegue 
    i loop consumando sia gli elementi della lista INPUT (se presenti) sia
    gli elementi della memoria generata, fino a quando non viene trovata 
    un'istruzione non valida o un HLT. In questo caso restituisce la lista
    di OUTPUT. 
    In caso contrario chiama la one-instruction/1 (come richiesto).

one-instruction/1:
    Prende in input lo stato e modifica le sue componenti in base
    all'istruzine corrente identificata dal PC (program-counter).
    Se l'istruzione viene identificata come HLT o non è valida la macchina
    va in HALTED-STATE e blocca la sua computazione.
    Lo stato della macchina è identificata dal primo elemento (posizione 0) 
    della lista state.
    Il resto della lista identifica, corrispettivamente, l'ACCUMULATORE, 
    il PC, la MEMORIA, la lista di INPUT, la lista di OUTPUT e il FLAG che
    viene attivato/disattivato in particolari situazioni.
