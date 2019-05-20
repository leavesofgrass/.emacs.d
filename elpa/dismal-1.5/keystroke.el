;;; keystroke.el --- Keystroke-level model to be incorporated into Dismal

;; Copyright (C) 1994, 2013 Free Software Foundation, Inc.

;; Author: Sarah Nichols, University of Nottingham

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

;; Lisp functions that implement the
;; For a full description of use, see
;;   Nichols, S., & Ritter, F. E. (1994).  A theoretically motivated tool
;;   for automatically generating command aliases.  Proceedings of
;;   Chi '95. 393-400.
;;
;;
;; This file contains two usable functions.
;;
;; The first function is used to calculate the time to enter
;; a command that given as an argument when the function is
;; called, or entered as a value in a Dismal spreadsheet cell.
;; It will compute the number of mental operators needed, but it can
;; also take that as an optional arguement if the analyst knows that this
;; is higher or lower than expected.  The default algorithm give one Mop
;; per word separated by a dash or space.  This rule is
;; derived from the heuristic specified by Card et al (1983, Figure 8.2
;; rule 2).  It was specifically used when looking at Soar commands
;; -- the structure of which meant that this approach was particularly
;; appropriate.
;;
;; The default specifications for the variable that are included here
;; are the length of the Mental Operator -- 1.35 seconds as specified
;; by Card et al (1981), and the typing speed. This is in words per
;; minute so that is can be easily altered to suit different users, and
;; a simple modification to the function could allow the individual's
;; typing speed to be entered into a cell on a spreadsheet, and the
;; value read from there.  The klm--const value is a necessary constant
;; used to convert from words per minute to average time for a keystroke
;; in seconds, and was derived from Card et al (1981).
;;
;; Two example sheets like this are included, one called keystroke4.dis,
;; a complete version, and one called simple-keystroke.dis, a simpler
;; version.

;;; Code:

(defvar klm--mop 1.35 "Mental operator value in seconds.")

;;; Word per minute typing speed for average no-secretary expert typist
(defvar klm--wpm 40 "Typing speed in words per minute.")

;;; Constant divisor used to calculate average time per keystroke from wpm
;; 10.80/wpm = Time (sec) per keypress (Card et al)
(defvar klm--const 10.80 "Constant to convert wpm to s/keystroke.")


;;;
;;; 	I.	command-time: Time to enter a command
;;;
;;; Takes COMMAND (a string) as arguement, automatically calculates
;;; mental operators by looking for hyphens, and includes average typing
;;; speed from wpm to return time to execute command in seconds.

(add-hook 'dis-user-cell-functions #'klm-time)

(defun klm-time (command &optional nm)
  "Time to type COMMAND <SPC | CR>, including the number of mental ops
\(optionally passed in)."
  (interactive)
  (if (not (stringp command)) (error "%s not a string" command))
  (let (tk ; keystroke time
        tm ; mental time
        (count 0))   ; count of chars
    ;; read klm--wpm
    (if (= 0 klm--wpm)
        (setq klm--wpm (read-minibuffer "Enter typing speed: ")))
    ;; calculate tk, 10.80/wpm = Time (s) per keypress (Card et al.)
    (setq tk (* (1+ (length command))  (/ klm--const klm--wpm)))
    ;; check number of mental operators required - one per command
    ;; and one per dash
    ;; nm - number of mental operators used
    (if (numberp nm)
         nil
       (setq nm 1) ; you get one for the command
       (while (< count (length command))
         (if (or (string= "-" (substring command count (1+ count)))
                 (string= " " (substring command count (1+ count))))
             (setq nm (1+ nm)))
           (setq count (1+ count))))
    ;; calculate Tm, time for mental ops
    (setq tm (* nm klm--mop))
    ;; calculate keystroke value (Texecute)
    ;; return total time
    (+ tk tm) ))

;; (klm-time "kjsdhfkjsdhkfjhk")

(provide 'keystroke)
;;; keystroke.el ends here
