;;; dismal-data-structures.el --- Misc data structures for Dismal

;; Copyright (C) 1994, 2013 Free Software Foundation, Inc.

;; Author: Frank E. Ritter, ritter@cs.cmu.edu
;; Created-On: 14 May 94

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

(eval-when-compile (require 'cl-lib))

;;;; vii.	Data structures

;; Column format macros:
(cl-defstruct (dismal-col-format
               (:type vector))
  width decimal alignment)

;; Address accessor functions:  these are cons of row and col numbers
(defmacro dismal-make-address (r c) (list 'cons r c))
(defmacro dismal-address-row (address) (list 'car address))
(defmacro dismal-address-col (address) (list 'cdr address))

(defsubst dismal-addressp (arg)
   (and (consp arg)
        (numberp (car arg))
        (numberp (cdr arg))))

;; Cells: these can be changed by insertion other cells
;; Cell accessor functions:  these are cells that can be relative addresses
(defconst dismal-cell-types '(dismal-r-c- dismal-rfc- dismal-r-cf dismal-rfcf))

(defmacro dis-cell-row (cell) (list 'nth 1 cell))
(defmacro dis-cell-col (cell) (list 'nth 2 cell))

(defsubst dismal-cellp (arg)
   (and (listp arg)
        (= (length arg) 3)
        ;; could add tests here for valus of cell
        (memq (car arg) dismal-cell-types)))

;; redefined in dismal.el
(defvar dismal-max-row 0)
(defvar dismal-max-col 0)


;; Range accessor functions:
;; (setq a (dismal-make-range 2 3 4 5))

(defun dismal-make-range (start-row start-col end-row end-col)
  (setq end-row (min end-row dismal-max-row))
  (setq end-col (min end-col dismal-max-col))
  `(dismal-range (dismal-r-c- ,start-row ,start-col)
                 (dismal-r-c- ,end-row ,end-col)))

(defmacro dismal-range-1st-cell (range)  `(nth 1 ,range))
(defmacro dismal-range-2nd-cell (range)  `(nth 2 ,range))
(defmacro dismal-range-1st-row (range)
  `(cadr (dismal-range-1st-cell ,range)))
(defmacro dismal-range-1st-col (range)
  `(cl-caddr (dismal-range-1st-cell ,range)))
(defmacro dismal-range-2nd-row (range)
  `(cadr (dismal-range-2nd-cell ,range)))
(defmacro dismal-range-2nd-col (range)
  `(cl-caddr (dismal-range-2nd-cell ,range)))

(defvar dismal-range 'dismal-range)

(defsubst dismal-rangep (arg)
  (and (listp arg)
       (eq (car arg) 'dismal-range)
       (= (length arg) 3)))

(cl-defstruct (dismal-range-buffer
               (:type vector))
  length width matrix)

;;;; xi.	Preliminary macro(s)

;; used for troubleshooting
(defmacro dismal--my-message (&rest body)
 `(and (boundp 'my-debug) my-debug
       (progn (message  ,@body)
              (sit-for 2))))

(defmacro dismal-save-excursion-quietly (&rest body)
  (declare (debug t))
  `(let ( ;; (dismal-show-ruler nil)
         (old-row dismal-current-row)
         (old-col dismal-current-col)
         (old-hscroll (window-hscroll))
         (old-window (selected-window)))
     (progn ,@body)
     (dismal-jump-to-cell-quietly
      (if (< old-row dismal-max-row)
          old-row
        dismal-max-row)
      (if (< old-col dismal-max-col)
          old-col
        dismal-max-col))
     (set-window-hscroll old-window old-hscroll)))

(defmacro dismal-save-excursion (&rest body)
  (declare (debug t))
  `(let ( ;; (dismal-show-ruler nil) ; autoshowing ruler is too slow
         (old-row dismal-current-row)
         (old-col dismal-current-col)
         (old-hscroll (window-hscroll))
         (old-window (selected-window)))
     (progn ,@body)
     (dismal-jump-to-cell (if (< old-row dismal-max-row)
                              old-row
                            dismal-max-row)
                          (if (< old-col dismal-max-col)
                              old-col
                            dismal-max-col))
     (set-window-hscroll old-window old-hscroll)))

(defun dismal-eval (object)
  ;; If object has no value, print it as a string.
  (if (or (stringp object) (listp object)
          ;; put back in ;; 13-Jul-92 -FER, so qreplace can work on numbers
          (numberp object)
          (and (symbolp object) (boundp object)))
      (eval object)
    (prin1-to-string object)))

(defmacro dismal-mark-row ()
  '(let ((result (aref dismal-mark 0)))
     (if (numberp result)
         result
         (error "Mark not set"))))

(defmacro dismal-mark-col ()
  '(let ((result (aref dismal-mark 1)))
     (if (numberp result)
         result
         (error "Mark not set"))))

(provide 'dismal-data-structures)
;;; dismal-data-structures.el ends here
