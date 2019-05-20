;;; make-km-aliases.el --- A simple way to create Dismal aliases

;; Copyright (C) 1994, 2013 Free Software Foundation, Inc.

;; Author: Frank Ritter & Nichols

;;; Commentary:

;;; Code:

(defvar dismal-old-aliases nil "*Old commands that you have passed in.")
(make-variable-buffer-local 'dismal-old-aliases)

(defvar dismal-new-aliases nil "*Aliases that you have created.") 
(make-variable-buffer-local 'dismal-new-aliases)

(defvar dismal-dup-aliases nil "*Where possible clashes are stored.")
(make-variable-buffer-local 'dismal-dup-aliases)

(add-hook 'dis-user-cell-functions #'dismal-init-make-aliases)

(defun dismal-init-make-aliases ()
  "Clear out the global variables for make-aliases."
  (interactive)
  (setq dismal-old-aliases nil)  
  (setq dismal-new-aliases nil)
  (setq dismal-dup-aliases nil)
  (message "Cleared out dismal-make-alias state."))

(defun dismal-display-dup-aliases ()
  "Print out the duplicated aliases so far for make-aliases."
  (interactive)
  (let ((old-buffer (current-buffer))
        (dups dismal-dup-aliases))
    (pop-to-buffer sm-help-buffer)
    (erase-buffer)
    (insert "Duplicate aliases stored on dismal-dup-aliases :\n\n")
    (mapc (function (lambda (x)
             (insert (prin1-to-string x))))
          dups)
    (goto-char (point-min))  ))


;;;
;;;	I.	dismal-make-alias
;;;

(add-hook 'dis-user-cell-functions 'dismal-make-alias)

(defun dismal-make-alias (old) 
  "Make an alias given an OLD command.
If OLD is less than 5 char, 
use the first character.  Else take the take the first letter of each
word.  \\[dismal-init-make-aliases] must be called first."
  ;; check that old command is a string
  (if (not (stringp old)) (error "%s not a string" old))
  (let (new
        (current-cell (cons dismal-current-col dismal-current-row)))
    (setq dismal-old-aliases (cons (cons old current-cell) dismal-old-aliases))
    (cond ((> (length old) 5)
           ;; if long, take first letter of each word
           (let ((count 0))
             (setq new (substring old 0 1))
             (while (< count (length old))
               (if (string= "-" (substring old count (1+ count)))
                   (setq new (concat new (substring old (1+ count) 
                                                    (+ count 2)))))
               (setq count (1+ count)))
             (if (eq (length new) 1)
                 (setq new (concat new (substring old 1 2))))))
          ;; if short, just take first letter
          (t (setq new (substring old 0 1))))
    ;; keep track of duplicate aliases
    (setq new (cons new current-cell))
    (if (dismal--match-old-alias new)
        (setq dismal-dup-aliases (cons new dismal-dup-aliases))
      (setq dismal-new-aliases (cons new dismal-new-aliases)))
    ;; return the alias
    (car new)))
(define-obsolete-function-alias 'make-alias #'dismal-make-alias "Dismal-1.5")

;; (member (cons "nu" (cons 1 2))  (list (cons "nu" (cons 1 2)) ))

;; (member "ru" '("ru" "asdf"))

(defun dismal--match-old-alias (new)
 "Return t if new alias matches but cell does not."
 (let ((alias (car new))
       (cell (cdr new)))
   (dismal--recursive-match-old-alias alias cell dismal-new-aliases)))

(defun dismal--recursive-match-old-alias (alias cell set)
 "Return t if new alias matches but cell does not."
 (cond ((not set) nil)
       ((string= alias (car (car set)))
        (if (and (equal (car cell) (car (cdr (car set))))
                 (equal (cdr cell) (cdr (cdr (car set)))))
            (dismal--recursive-match-old-alias alias cell (cdr set))
          ;; return t
          t))
       (t (dismal--recursive-match-old-alias alias cell (cdr set)))))


;;; 
;;;	II.	Some testing code.
;;;

;; (dismal-init-make-aliases)
;; (dismal-make-alias "chunk-free-prblem-spaces")
;; dismal-old-aliases
;; dismal-new-aliases
;; dismal-dup-aliases






(provide 'make-km-aliases)
;;; make-km-aliases.el ends here
