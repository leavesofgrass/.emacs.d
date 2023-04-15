;;; auto-aligner.el --- Specialized extensions to Dismal to support aligning two sequences  -*- lexical-binding:t -*-

;; Copyright (C) 1992, 2013, 2018 Free Software Foundation, Inc.

;; Author: Frank Ritter
;; Created-On: Wed May 20 15:50:22 1992

;; This is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This software is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this software.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(require 'dismal-data-structures)
(require 'dismal)
(require 'rmatrix)


;;;; i.	dis-auto-align-model variables

;; General algorithm taken from p. 190, Card, Moran, & Newell.
;; Extensions:
;;  * our predseq ends up being a list of cell references
;;  * we don't just want to compute the final comparison, we also want
;;    to realign
;;  * has to be run in buffer with dismal-matrix bound

;; How to use this:
;; . turn auto-update off
;; . insert file of trace
;; . set up middle-column
;; . set up new things in dis-paired-regexps to match with (if necc)
;; . call auto-aligner

;; "regexps that match valid obs codes"

(defvar dis-paired-regexps nil
  "*The list of paired expressions the user defines the match with.")

(defconst dis-auto-aligner-version "1.1 of 8-10-93")
;; 1.1 has improved moving up in lineness


;;;; I.	auto-align-model variables

;; (dis-auto-align-model "B" "J" 82 498) ; for unit
;; (dis-auto-align-model "D" "M" 64 380) ; for old unit
;; (dis-auto-align-model "B" "J" 64 380) ; for unit
;; (dis-auto-align-model "B" "J" 50 555) ; for array
;; (dis-auto-align-model "B" "J" 50 640) ; for array5, after auto-align
;; (dis-auto-align-model "B" "J" 50 640) ; for array5, after auto-align
;; (dis-auto-align-model "B" "J" 42 222) ; for precision
;; (dis-auto-align-model "B" "J" 42 222) ; for axis

(defvar dis--predseq)
(defvar dis--predseqresult)
(defvar dis--predlength)
(defvar dis--obsseq)
(defvar dis--obsseqresult)
(defvar dis--obslength)
(defvar dis--score)
(defvar dis--max-seq-length)
(defvar dis--length-of-result)

(defun dis-auto-align-model (obs-col pred-col start-row end-row)
  "Aligns the two meta-column rows based on matching up what's in OBS-COL
and PRED-COL, doing it for all rows between START-ROW and END-ROW.
dis-paired-regexps defines what matches between the rows."
  (interactive "sSubject column to align with (a letter):
sModel column to align with (a letter):
nStarting row:
nEnding row: ")
 (if (not (y-or-n-p (format "Align col %s to col %s, from row %s to row %s? "
                            obs-col pred-col start-row end-row)))
     nil
 (if (or (not (boundp 'dismal-matrix)) (not dismal-matrix))
     (error "dis-auto-align-model can only be called in a dismal buffer")
 (message "Setting up alignment...")
 ;; set up the individual items you'll match on each side
 (let* ((obs-regexps  (mapcar #'car dis-paired-regexps))
        (pred-regexps (mapcar #'cdr dis-paired-regexps))
        ;; put these variables into a let after debug
        (obs-col (dismal-convert-colname-to-number obs-col))
        (pred-col (dismal-convert-colname-to-number pred-col))
        (obs-range-list
         (dismal-make-range start-row obs-col end-row obs-col))
        (pred-range-list (dismal-make-range start-row pred-col end-row pred-col))
        (dis--obsseq (dis-match-list obs-range-list obs-regexps))
        (dis--predseq (dis-match-list pred-range-list pred-regexps))

        ;; Step 1.  Initialize
        (dis--obslength (length dis--obsseq))
        (dis--predlength (length dis--predseq))
        (dis--score (matrix-create))
        ;; fill dis--score's edges with 0's
        (i 0) (j 0))
 (while (<= i dis--predlength)
   (matrix-set dis--score i 0 0)
   (setq i (1+ i)))
 (while (<= j dis--obslength)
   (matrix-set dis--score 0 j 0)
   (setq j (1+ j)))

 ;; Step 2. Compute the scores for a matrix with one row for every operator
 ;; in the predicted sequence and one column for every operator in the
 ;;  observed sequence.
 (message
   "Computing score matrix for %s observed actions by %s predicted actions..."
    dis--obslength dis--predlength)
 (setq i 1)
 (while (<= i dis--predlength)
   (setq j 1)
   (while (<= j dis--obslength)
     (if (dis--auto-align-test i j dis--predseq dis--obsseq)
         (matrix-set dis--score i j (1+ (matrix-ref dis--score (1- i) (1- j))))
         ; else
         (matrix-set dis--score i j
                     (max (matrix-ref dis--score (1- i) j)
                          (matrix-ref dis--score i (1- j)))))
     (setq j (1+ j)))
   (setq i (1+ i)))

 ;; Step 3.  Traverse the matrix forward along the path of higest scores
 ;; but do it front first...
 (message "Computing best match...")
 (let* ((dis--max-seq-length
         (matrix-ref dis--score dis--predlength dis--obslength))
        (dis--length-of-result
         (+ dis--max-seq-length
            (- dis--predlength dis--max-seq-length)
            (-  dis--obslength dis--max-seq-length)))
        (_ (dis--card-compute-best-match))
        (match-amount (/ (* 100 (- (+ dis--predlength dis--obslength) dis--length-of-result)) ;; # of matches
                       (max 1 dis--predlength dis--obslength)))
        (optimistic-match-amount
       (/ (* 100 (- (+ dis--predlength dis--obslength) dis--length-of-result)) ;; # of matches
          (max 1 (min dis--predlength dis--obslength)))))
 ;; equivalent formula:
 ;; (/ (* 100 (matrix-ref dis--score dis--predlength dis--obslength))
 ;;    dis--length-of-result)
 ;;   e.g.,   10 & 10, 8 matches + 4, or 12 total
 ;;           10 & 10, 1 match, +18
 (beep t)
 (if (y-or-n-p (format "Do you want matches (%s %% matched) moved up in line? "
                       match-amount))
     (dis--move-references-forward obs-col pred-col))

 ;; Step 4a.  Approve the matches you have found
 (dis--choose-to-do-edits)

 ;; Step 5.  Generate a report
 (let* ((old-buffer (current-buffer))
        (old-buffer-file-name buffer-file-name)
        (new-buffer (get-buffer-create "*auto-align-model Output*"))
        dis--obsseqresult
        dis--predseqresult)
   (with-current-buffer new-buffer
    (goto-char (point-max))
    (if (not (= (point) 0))
        (insert "*********************************************************\n"))
    (save-excursion
      (insert "dis-auto-align-model Output " dis-auto-aligner-version "\n"
              (format "Aligned col %s to col %s, from row %s to %s \n"
                      obs-col pred-col start-row end-row))
      (insert "For file: " (or old-buffer-file-name
                               (buffer-name)) "\n" (current-time-string) "\n"
              "\nMatching pairs:\n")
      (mapc (function (lambda (pair) (insert (format "%s  to  %s\n" (car pair)
                                                     (cdr pair)))))
            dis-paired-regexps)
      (insert (format "\nMatch = %s %%\n" match-amount))
      (insert (format "\nOptimistic Match = %s %%\n" optimistic-match-amount))
      (insert (format "    %10s %10s  %20s  %30s\n" "Observed" "Predicted"
                      "Obs value" "Pred value"))
      (setq i 1)
      (while  (<= i dis--length-of-result)
         (let ((obsvalue (if (aref dis--obsseqresult i)
                             (with-current-buffer old-buffer
                             (dismal-get-val (car (aref dis--obsseqresult i))
                                           (cdr (aref dis--obsseqresult i))))
                             "nil"))
               (predvalue (if (aref dis--predseqresult i)
                              (with-current-buffer old-buffer
                              (dismal-get-val (car (aref dis--predseqresult i))
                                           (cdr (aref dis--predseqresult i))))
                               "nil")))
         (let ((obs-value (aref dis--obsseqresult i))
               (pred-value (aref dis--predseqresult i)))
         (insert (format "%2s: " i)
                 (if obs-value
                      (format "%6s%4s "  (dismal-convert-number-to-colname (cdr obs-value)) (car obs-value))
                      (format "%10s " obs-value))
                 (if pred-value
                      (format "%6s%4s "  (dismal-convert-number-to-colname (cdr pred-value)) (car pred-value))
                      (format "%10s " pred-value))
                 (format " %15s  %25s\n"
                          (substring obsvalue 0 (min 20 (length obsvalue)))
                          (substring predvalue 0 (min 30 (length predvalue))))))
         (setq i (1+ i))))
      (display-buffer new-buffer)
      (pop-to-buffer new-buffer)
      (pop-to-buffer old-buffer))))

 ;; Step 6.  Align the matches you have found
 (if (not dis-middle-col)
     (error
   "Can't tell where data stops/model begins: you must set dis-middle-col"))

 (if (not (y-or-n-p (format "Do you want the %s matches out of %s aligned? "
                            dis--max-seq-length (max dis--predlength dis--obslength))))
      nil
   (let ((new-rows (dis-align-columns)))
   (beep t)
   ;; Now go through and delete any completely blank rows
   (if (not (y-or-n-p (format "Do you want blank lines deleted? ")))
       nil
     (dis-delete-blank-rows start-row (+ end-row new-rows)))))
 (message "Thank you for using dis-auto-align-model.")   )))))


;;;; II.	Utilities

;; (string-match "place-atom \\([0-9]*\\), \\1" "place-atom 33, 33")
;; move the edit references so that they are later.
;; vaiables should be put into a lets
;; ** assumes working with columns 1 and 9 ****
(defun dis--move-references-forward (obs-col _pred-col)
  ;; low-post-number is where to start looking for something to move
  ;; observed on LHS, predicted nominally on RHS
  (let ((i 1))
    ;; (setq obs-col 1)
    ;; (setq pred-col 9)
  (while (< i (1- (length dis--predseqresult)))
    ;; Set up
    (let* ((my-quit-flag nil)
           (obs-result (aref dis--obsseqresult i))
           (pred-result (aref dis--predseqresult i)))
    (if (not (and obs-result pred-result))
        nil ;; quit, he's not paired so can't move, rest in progn
    (let* ((obs-val (dismal-get-val (car obs-result) (cdr obs-result)))
           (obs-match-string
            (car (dis--matching-regexp obs-val dis-paired-regexps)))
           ;; (pred-match-string
           ;;  (cdr (dis--matching-regexp obs-val dis-paired-regexps)))
           (low-post-number (1+ i))
           new-obs-result)

    ;; (my-message "Doing now ** i= %s, lowpost= %s, flag= %s  finali= %s"
    ;;            i low-post-number my-quit-flag (length dis--predseqresult))
    ;; Search
    (while (and (not my-quit-flag)
                (setq new-obs-result (aref dis--obsseqresult low-post-number))
                (< low-post-number (length dis--predseqresult)))
      ;; (message "Doing i= %s, lowpost= %s, flag= %s  finali= %s"
      ;;           i low-post-number my-quit-flag (length dis--predseqresult))
      ;; (beep t) (sit-for 2)
      (let* ((new-obs-val (dismal-get-val (car new-obs-result) obs-col))
             (new-pred-result (aref dis--predseqresult low-post-number)))
      ;; find a colleague who will move to your place
      (cond ((and new-obs-val
                 (string-match obs-match-string new-obs-val)
                 (not new-pred-result))
             (message "Moving %s at %s matching %s to %s"
                      obs-match-string obs-result pred-result new-obs-result)
             (sit-for 1)
             (aset dis--predseqresult i nil)
             (aset dis--predseqresult low-post-number pred-result)
             (setq my-quit-flag t))
            ((and new-obs-val
                 new-pred-result)
             (setq my-quit-flag t))
            (t (setq low-post-number (1+ low-post-number)))))))))
    (setq i (1+ i))  )))

;;     (if (= i 1)
;;         (setq low-post-number min-row)
;;       (setq low-post-number (1+ (car (aref dis--obsseqresult (1- i))))))
;;     (if (= i (length dis--predseqresult))
;;         (setq high-post-number max-row)
;;       (setq max-post-number (1+ (car (aref dis--obsseqresult (1+ i))))))

;; Compute the best match, starting from the front
(defun dis--card-compute-best-match ()
  ;; dis--predseq comes in as a global
  ;; dis--obsseq comes in as a global

  ;; Counters into final sequences
  (let ((p dis--predlength)                 ; counter into predicted sequence
        (o dis--obslength)                  ; counter into observed sequence
        ;; k is length of match since we use position 0 in array
        (k (- (+ dis--predlength dis--obslength) dis--max-seq-length)))
    ;; The results
    ;; add 1 to k, arrays are 0 based reference
    (setq dis--predseqresult (make-vector (1+ k) nil))
    (setq dis--obsseqresult (make-vector (1+ k) nil))

    (while (not (and (= p 0) (= o 0)))
      (cond ((and (not (= p 0))
                  (or (= o 0) (> (matrix-ref dis--score (1- p) o)
                                 (matrix-ref dis--score (1- p) (1- o)))))
             (aset dis--predseqresult k (nth (1- p) dis--predseq))
             (aset dis--obsseqresult k nil)
             (setq p (1- p))
             (setq k (1- k)))
            ((and (not (= o 0))
                  (or (= p 0) (> (matrix-ref dis--score p (1- o))
                                 (matrix-ref dis--score (1- p) (1- o)))))
             (aset dis--predseqresult k nil)
             (aset dis--obsseqresult  k (nth (1- o) dis--obsseq))
             (setq o (1- o))
             (setq k (1- k)))
            (t
             (aset dis--predseqresult k (nth (1- p) dis--predseq))
             (aset dis--obsseqresult  k (nth (1- o) dis--obsseq))
             (setq p (1- p))
             (setq o (1- o))
             (setq k (1- k))))
      )))


;; (my-message "offset: %s matched %s" offset matched)
;; (my-message "offset: %s matched %s i-test: %s j-test %s"
;;             offset matched i-test j-test)
;; (y-or-n-p (format "Doing real test on %s %s, scores: %s %s %s %s "
;;                   i-test j-test dis--score0 dis--score+j dis--score+i dis--score+i+j))



; (dis-align-columns 19 11)
;; needs cleaned up
(defun dis-align-columns ()
  ;; Align the pred-row with the obs-row looking across dis-middle-col
  ;; returns how many rows it added
  ;; Assumes done from front at initial time, easiest, maybe not best
  ;; assumes that cells below lowest of p-row and o-row aren't aligned
  (let ((i 0)
        (p-offset 0)
        (o-offset 0))
    (while (<= i dis--length-of-result)
      (message "Checking position %s of %s..." i dis--length-of-result)
      (let* ((pred-cell (aref dis--predseqresult i))
             (obs-cell (aref dis--obsseqresult i))
             (p-row (if pred-cell (+ p-offset (dismal-address-row pred-cell))))
             (o-row (if obs-cell (+ o-offset (dismal-address-row obs-cell))))  )
        (if (and pred-cell obs-cell)
            (let* ( (offset (abs (- p-row o-row))) )
              (message "Aligning position %s of %s..." i dis--length-of-result)
              ;; works from front, and keeps cum. offsets for each side
              ;; so only has to do adds to one side
              (cond ((= p-row o-row) nil)
                    ((> p-row o-row)    ; move o-row down
                     (setq o-offset (+ o-offset offset))
                     (dismal-insert-range-cells o-row 0
                                                o-row dis-middle-col offset))
                    ((> o-row p-row)    ; move p-row down
                     (setq p-offset (+ p-offset offset))
                     (dismal-insert-range-cells p-row (1+ dis-middle-col)
                                                p-row dismal-max-col offset))))))
      (setq i (1+ i)) )
    (max p-offset o-offset)))


(defun dis--choose-to-do-edits ()  ;(dis--choose-to-do-edits)
 ;; Uses dynamic scoping, so watch out...
 ;; on y, do nothing, on n, remove from match, on j, quit
 ;; (my-message "entering choose-to-do-edits")
 (let ((do-edit nil) (just-do-rest nil)
       (i 0))
 (while (and (< i dis--length-of-result) (not just-do-rest))
  (let* ((pred-cell (aref dis--predseqresult i))
         (obs-cell (aref dis--obsseqresult i))
         (p-row (if pred-cell  (dismal-address-row pred-cell)))
         (o-row (if obs-cell   (dismal-address-row obs-cell)))  )
  (if (not (and pred-cell obs-cell))
      nil
    ;; I'm happy to make user type CR to be sure.
    (dismal-set-mark (dismal-address-row obs-cell)
                     (dismal-address-col obs-cell))
    (dismal-jump-to-cell (dismal-address-row pred-cell)
                         (dismal-address-col pred-cell))
    (setq do-edit
          (dismal-read-minibuffer
             (format
    "Align match %s/%s, row %s:<%s> with row %s:<%s>? (y/n/a accept the rest)"
                     (1+ i) dis--length-of-result
                     o-row (dismal-get-val o-row (dismal-address-col obs-cell))
                     p-row (dismal-get-val p-row (dismal-address-col pred-cell)))
             nil "y"))
    (cond ;; ((string= do-edit "b")
          ;;  (message (substitute-command-keys
	  ;;     "So look at speadsheet, exit with \\[exit-recursive-edit]"))
          ;;  (recursive-edit))
          ((string= do-edit "y"))
          ((string= do-edit "n")
           (aset dis--predseqresult i nil)
           (aset dis--obsseqresult i nil))
          ((string= do-edit "a")
           (setq just-do-rest t))))
   (setq i (1+ i))))  ))


(defun dis--auto-align-test (i j predseq obsseq)
  ;; finds the cells that match things on dis-paired-regexps
  (let* ((predcell-ref (nth (1- i) predseq))
         (obscell-ref (nth (1- j) obsseq))
         (pred-val (dismal-get-val (car predcell-ref) (cdr predcell-ref)))
         (obs-val (dismal-get-val (car obscell-ref) (cdr obscell-ref))))
  (dis--auto-align-test-regexps pred-val obs-val dis-paired-regexps)))

(defun dis--auto-align-test-regexps (pred-val obs-val regexps)
  ;; (my-message "matchine %s %s with %s" pred-val obs-val regexps)
  (cond ((not regexps) nil)
        ((and (consp regexps) (stringp (cdr regexps)))
         (and (string-match (cdr regexps) pred-val)
              (string-match (car regexps) obs-val)))
        (t (or (dis--auto-align-test-regexps pred-val obs-val (car regexps))
               (dis--auto-align-test-regexps pred-val obs-val (cdr regexps))))))


;; (string-match "Tiny" "Boy, I am Tiny I think")
(defun dis--matching-regexp (obs-val regexps)
  (cond ((not regexps) nil)
        ((and (consp regexps) (stringp (cdr regexps)))
         (if (string-match (car regexps) obs-val)
             regexps
             nil))
        (t (or (dis--matching-regexp obs-val (car regexps))
               (dis--matching-regexp obs-val (cdr regexps))))))

(provide 'auto-aligner)
;;; auto-aligner.el ends here
