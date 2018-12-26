;;;;; Matricola: 829937 - Fabio D'Elia
;;;;; Progetto LMC - LITTLE MAN COMPUTER

;;;; -*- Mode: Lisp -*-

;;;; lmc.lisp

;;; lmc-run/2
;; lancia il programma e genera lo stato

(defun lmc-run (path input)
  (let* ((mem (lmc-load path))
	 (state (list 'STATE
		      :ACC 0
		      :PC 0
		      :MEM mem
		      :IN input
		      :OUT nil
		      :FLAG 'NOFLAG
		      )))
    (execution-loop state)))

;;; lmc-load/1
;; carica il fila e genera la memoria

(defun lmc-load (path)
  (let*((list (remove nil (read-file path)))
	(label-list (label list list))
	(new-list (remove-label list label-list))
	(inter-list (interpreter new-list new-list (flatten label-list)))
	(value-list (value inter-list))
	(nil-list (make-list (- 100 (- (length value-list) 1))))
	(memory (fill nil-list value-list :end 1)))
   (flatten (substitute 0 'nil memory))))

;;; read-file/1
;; legge il file e richiama remove-comment/1

(defun read-file (path)
  (with-open-file (f path  :direction :input)
    (labels ((read-helper ()
	       (let ((line (read-line f nil nil)))
		 (when line (cons (remove-comment (subseq line 0
							  (search "//" line)))
				  (read-helper))))))
      (read-helper))))

;;; convert-string/1
;; genera una lista di simboli eliminando spazi in eccesso/non desiderati 

(defun convert-string (str)
  (when (string/=  str "")
    (multiple-value-bind (value num-chars) (read-from-string str nil)
      (when value
	(cons value (convert-string (subseq str num-chars)))))))

;;; remove-comment/1

(defun remove-comment (str)
  (when (eq (search "//" str) nil)
    (multiple-value-bind (value num-chars) (read-from-string str nil)
      (when value
	(cons value (remove-comment (subseq str num-chars)))))))

;;; flatten/1

(defun flatten (x)
  (cond ((null x) x)
	((atom x) (list x))
	(T (append (flatten (first x))
		   (flatten (rest x))))))

;;; label/2
;; gestione delle etichette
;; list usata per la ricorsione
;; list1 come riferimento per l'indirizzo dell'etichetta

(defun label (list list1)
  (let*((e (car list)) ;;riga
	(w (nth 0 e))) ;;primo elemento (etichetta)
    (unless (eq e nil)
      (cond ((= (length e) 3)
	     (cons (cons w
			 (cons (position e list1) nil))
		   (label (cdr list) list1)))
	    ((and (= (length e) 2) (eq
				    (position w
					      '(HLT ADD SUB STA LDA BRA
						BRZ BRP DAT INP OUT))
				    nil))
	     (cons (cons w
			 (cons (position e list1) nil))
		   (label (cdr list) list1)))
	    (t (label (cdr list) list1))))))

;;; remove-label/2

(defun remove-label (list label)
  (let* ((e (car label))
	 (n (car (cdr e)))
	 (new-list (substitute (remove (car e)  (nth n list))
			       (nth n  list) list)))
    (unless (eq (cdr label) nil)
      (cons new-list (remove-label new-list (cdr label))))
    (replace list new-list)))

;;; interpreter/3
;; prendo un simbolo della lista
;; valuto la sua posizione nella lista delle operazioni
;; assegno il valore che è nella cella adiacente

(defun interpreter (list list1 label)
  (let ((e (car list))
	(operands
	 '(HLT 0 ADD 1 SUB 2 STA 3 LDA 5 BRA 6
	   BRZ 7 BRP 8 DAT 0 INP 901 OUT 902)))
    (unless (eq list  nil)
      (cond ((and (eql (length e) 2) (typep (car (cdr e)) 'symbol))
	     (cons
	      (list (nth (+ (position (car e) operands) 1) operands)
		    (nth (+ (position (car(cdr e)) label) 1) label))
	      (interpreter (cdr list) list1 label)))
	    ((eq (length e) 2)
	     (cons
	      (list (nth (+ (position (car e) operands) 1) operands)
		    (car(cdr e)))
	      (interpreter (cdr list) list1 label)))
	    (t (cons
		(list (nth (+ (position (car e) operands) 1) operands))
		(interpreter (cdr list) list1 label)))))
    ))

;;; value/1
;; prendo ogni elemento della lista
;; moltiplico per 100 il valore dell'operazione
;; sommo il numero della cella

(defun value (memory)
  (let ((e (car memory)))
    (unless (eq e nil)
      (cond ((eq (length e) 2)
	     (cons (+ (*(car e) 100) (car(cdr e)))
		   (value (cdr memory))))
	    (t (cons (car e) (value (cdr memory))))))))

;; -*- END OF PARSER -*-

;;; execution-loop/1

(defun execution-loop (state)
  (let ((new-state (one-instruction state)))
    (cond ((< (nth 4 state) 99)
	   (cond
	     ((eq (nth 0 new-state) 'HALTED-STATE) (nth 10 new-state))
	     (t (execution-loop new-state)))))))

;;; one-instruction/1

(defun one-instruction (state)
  (let*((instruction (floor (nth (nth 4 state) (nth 6 state)) 100))
	(inp-out (nth (nth 4 state) (nth 6 state)))
	(new-pc (+ (nth 4 state) 1))
	(num-cell (mod (nth (nth 4 state) (nth 6 state)) 100))
	(mem-cell (nth num-cell (nth 6 state))))
    (cond ((or (= instruction 0) (= instruction 4)) (hlt state)) ;; DONE
	  ((= instruction 1) (add state mem-cell new-pc)) ;; DONE
	  ((= instruction 2) (sub state mem-cell new-pc)) ;; DONE
	  ((= instruction 3) (sta state num-cell new-pc)) ;; DONE
	  ((= instruction 5) (lda state mem-cell new-pc)) ;; DONE
	  ((= instruction 6) (bra state num-cell)) ;; DONE
	  ((= instruction 7) (brz state num-cell new-pc)) ;; DONE
	  ((= instruction 8) (brp state num-cell new-pc)) ;; DONE
	  (t (cond ((= inp-out 901) (inp state new-pc)) ;; DONE
		   (t (out state new-pc))))))) ;; DONE

(defun hlt (state)
  (substitute 'HALTED-STATE 'STATE state))

(defun add (state mem-cell new-pc)
  (let ((new-acc (+ (nth 2 state) mem-cell)))
    (cond((>= new-acc 1000)
	  (setf (nth 12 state) 'FLAG)
	  (setf (nth 2 state) (mod new-acc 1000)))
	 (t (setf (nth 2 state) new-acc)
	     (setf (nth 12 state) 'NOFLAG)))
    (setf (nth 4 state) new-pc)
    state))

(defun sub (state mem-cell new-pc)
  (let ((new-acc (- (nth 2 state) mem-cell)))
    (cond((< new-acc 0)
	  (setf (nth 12 state) 'FLAG)
	  (setf (nth 2 state) (mod new-acc 1000)))
	 (t (setf (nth 2 state) new-acc)
	     (setf (nth 12 state) 'NOFLAG)))
    (setf (nth 4 state) new-pc)
    state))

(defun sta (state num-cell new-pc)
  (setf (nth num-cell (nth 6 state)) (nth 2 state))
  (setf (nth 4 state) new-pc)
  state)

(defun lda (state mem-cell new-pc)
  (setf (nth 2 state) mem-cell)
  (setf (nth 4 state) new-pc)
  state)

(defun bra (state num-cell)
  (setf (nth 4 state) num-cell)
  state)

(defun brz (state num-cell new-pc)
  (cond ((and (= (nth 2 state) 0) (eq (nth 12 state) 'NOFLAG))
	 (bra state num-cell))
	(t (setf (nth 4 state) new-pc)))
  state)

(defun brp (state num-cell new-pc)
    (cond ((eq (nth 12 state) 'NOFLAG)
	   (bra state num-cell))
	  (t (setf (nth 4 state) new-pc)))
    state)

(defun inp (state new-pc)
  (let ((element (car (nth 8 state)))
	 (list (rest (nth 8 state))))
    (setf (nth 2 state) element)
    (setf (nth 8 state) list)
    (setf (nth 4 state) new-pc)
    state))

(defun out (state new-pc)
  (let ((element (nth 2 state))
	(out-list (nth 10 state)))
    (setf (nth 10 state) (append out-list (list element)))
    (setf (nth 4 state) new-pc)
    state))


;;;; end of file -- lmc.pl
