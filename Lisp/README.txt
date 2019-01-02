Matricola: 829937 - Fabio D'Elia

-*- Mode: Lisp -*-

lmc-run/2 : 
    Predicato che prende in input il path, riferito al file .lmc, 
    e la lista in input. 
    lmc-run/2 contiene le chiamate a lmc-load/1, che genera la memoria, 
    e execution-loop/2.

lmc-load/1 : 
    Predicato che genera la memoria. 
    Contiene tutti i predicati che manipolano la lista di simboli
    derivanti da remove-file/1.
    Il predicato conclude con la concatenazione della lista parsata
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
    Il predicato prende in input la lista derivante da remove-label/2
    e la lista label, contenente tutte le etichette e i suoi riferimenti.
    Al suo interno viene dichiarata la lista operands che contiene tutte 
    le operazioni e i suoi codici macchina.
    In output si avrà una lista di liste contenenti il codice riferito 
    all'operazione e il riferimento all'etichetta, se questa è presente.

value/1 :
    Prende in input la lista parsata da interpreter/2. Qui si genera
    finalmente il codice macchina riferito al codice assembly.
    Si esegue un'operazione aritmetica per ottenere il codice macchina.





