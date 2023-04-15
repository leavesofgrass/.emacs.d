;;; log.el --- Command usage log for Michael Hucka  -*- lexical-binding:t -*-

;; Copyright (C) 1991, 2013 Free Software Foundation, Inc.

;; Author: Erik Altmann, Frank Ritter & Nick Jackson
;; Created-On: Sat Nov 14 19:24:27 1992

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

;;;; PURPOSE
;;
;; Logs state information about an editing session, including
;; keystrokes (with timestamps, command names, but no longer
;; arguments), file snapshots, process output, and temporary
;; buffers.  Provides some parsing functions for the data.
;;
;;;; USE
;;
;; 5. Start logging ("M-x log-session-mode").
;;
;;    State is written in "Log.<type>.timestamp", where <type> is
;;    "keys" (keystrokes), "temp-buffers" (an accumulation of temp
;;    buffer contents), or a process name.  Change directory where
;;    state files are written with M-x log-data-directory.
;;
;;    A separate backup is made for a file every time it's saved,
;;    in the file's directory.
;;
;;    State files and backups are compressed (end in ".Z").
;;
;; 6. Stop logging (exit Emacs) or turn off logging with log-session-mode.
;;
;; 7. Uncompress and visit a keystroke log file, then run
;; "log-time-episodes" on the buffer, and "log-spread-out" on the
;; output of that.  Then try "log-collapse" to collapse and count
;; series of the same character.
;;
;;
;;;; THE KEYSTROKE LOG
;;
;; Keystrokes accumulate in the buffer " *log*", one entry per line,
;; until there are lots of them, when they're written to a file and
;; compressed.  To make one big log with line numbers, "uncompress
;; Log.keys.*; cat -n Log.keys* > keystroke-log.txt".  (You might
;; first want to cut out the first few lines of the first log file,
;; which identify the system and user.)
;;
;; Command arguments appear at the "effects column", at the right
;; end of each line.  Buffer switches log the destination buffer,
;; cursor line, and the window's location over the buffer.  Yanks
;; and kills log their contents, indented to effects column.
;;
;; (old) Sample filename and log data:
;;
;;    % head -18 Sat-Nov-28-04:48:22-1992
;;    User: Erik Altmann
;;    Creation-date: Sat Nov 28 04:44:17 1992
;;    System: SARCO.SOAR.CS.CMU.EDU
;;
;;    17642.234  [G]c       self-insert-command
;;    17642.297  [G]u       self-insert-command
;;    17642.437  [G]t       self-insert-command
;;    17643.015  [G]^M      newline-and-indent
;;    17643.594  [G]t       self-insert-command
;;    17643.672  [G]e       self-insert-command
;;    17643.937  [G]x       self-insert-command
;;    17644.781  [G]t       self-insert-command
;;    17647.703  ^[h        backward-kill-word             text
;;    17647.890  ^[h        backward-kill-word             cut
;;                                                         text
;;    17650.406  [G]^Y      yank                           cut
;;                                                         text
;;    %
;;
;;    Column 1 - timestamp (seconds)
;;    Column 2 - [keymap]keystroke-sequence
;;    Column 3 - command name
;;    Column 4 - command effects
;;
;; New sample filename and log data:
;;
;;	User: Frank Ritter
;;	Creation-date: Fri Dec  2 12:34:04 1994
;;	System: shelley.psyc.nott.ac.uk
;;	Start-buffer: bob.dis
;;	71644.290   y          exit-minibuffer
;;	71646.060   ^N         exit-minibuffer
;;	71646.150   ^N         dis-forward-row
;;	71646.650   ^P         dis-forward-row
;;	71646.770   ^P         dis-backward-row
;;	71648.100   e          dis-backward-row
;;	71648.430   m          dis-edit-cell-plain
;;	71648.660   y          self-insert-command
;;	71648.860   __         self-insert-command
;;
;;
;;;; DATA CODES
;;
;;   A space (" ") logs as a double underscore ("__").
;;
;;   [HERE: other codes...]
;;
;;;; NOTES AND BUGS
;;
;; * should check before saving files.
;; * should write a header, of what it is and who it's for.
;; * 19.29 now has (current-time), which could replace much of this

;; Uses post-command-hook.
;;
;; Loads either before or after other packages, and loads safely on
;; top of itself.
;;
;; Uses temp-buffer-show-hook, but tries to be
;; smart about existing hooks (??).
;;
;; Doesn't deal with mouse events.

;;; Code:

(eval-when-compile (require 'cl-lib))

(defvar *log-data-directory*
  (concat (getenv "HOME") "/")
  ;; HERE: should write all files here
  ;;"./"
  "*Directory in which to write the keys buffer.")

(defun log-data-directory (dir)
  "Prompts for a directory in which to write Log.stuff files."
  (interactive
   (list (expand-file-name
	  (read-file-name (format "Logging in %s.  Change to: " *log-data-directory*)
			  (concat (getenv "HOME") "/")
			  *log-data-directory* 'require))))
  (setq *log-data-directory* (expand-file-name dir)))

(defvar log-compress! t ;; -fer
  "*If t, compress before writing output.")

(defvar log-keys-buffer-name " *keys-log*"	; named to be hidden
  "Name of buffer in which keystrokes are logged.")

(defvar log-temp-buffer-name " *temp-buffer-log*"
  "Name of buffer in which output of temporary buffers is logged.")

(defvar log-auto-save-interval 500
  "*Number of keystrokes to record in one file.")

;; entry:
;; sorta more hidden, system globals

(defvar log-auto-save-counter 0)

(define-obsolete-variable-alias 'log-running 'log-session-mode "Dismal-1.6")
;;;###autoload
(define-minor-mode log-session-mode
  "Minor mode to log a session (keystrokes, timestamps etc)."
  :global t
  (if log-session-mode
      (add-hook 'post-command-hook #'log-stamp-date)
    (remove-hook 'post-command-hook #'log-stamp-date)))

(define-obsolete-function-alias 'log-initialize 'log-session-mode "Dismal-1.6")

;; 11-17-94 -fer
(defun log-quit ()
  "Turn off logging."
  (interactive)
  (log-session-mode -1))
(make-obsolete 'log-quit 'log-session-mode "Dismal-1.6")

;;     (log-modify-keymap (current-global-map) "[G]")
(defvar log-keymaps-modified nil)	; keymaps are a lattice...
(defun log-modify-keymap (keymap prefix)
  (if (and keymap			; locals can be nil
	   (not (memq keymap log-keymaps-modified)))
      (progn
	(setq log-keymaps-modified (cons keymap log-keymaps-modified))
	(cond ((arrayp keymap)		; full keymap (an array)
	       (log-walk-full keymap prefix))
	      ((and (keymapp keymap)		; sparse
		    (consp keymap))
	       (log-walk-sparse keymap prefix))
	      ((and (keymapp keymap)		; ESC-prefix, etc.
		    (fboundp keymap))
	       (if (arrayp (symbol-function keymap))
		   (log-walk-full (symbol-function keymap) prefix)
		 (log-walk-sparse (symbol-function keymap) prefix)))
	      (t
	       (error (format "log-modify-keymap: can't parse %s"
			      keymap)))))))

;; walks down an array:
(defun log-walk-full (keymap prefix)
  (let ((len (length keymap))
	(i 0))
    (while (< i len)
      (let ((command (aref keymap i)))
	(cond ((keymapp command)        ; nested keymap: recurse
	       (log-modify-keymap command (text-char-description i)))

	      ;; nested keymap, wrapped in a list (?!), so recurse
	      ;; (12-May-93 - FER):
	      ((and (listp command) (keymapp (car command)))
	       (log-modify-keymap (car command) (text-char-description i)))

	      ((null command))          ; nil entry, often many

	      ((log-wrap-this-p command) ; 1-14-94 - call early, for "t" case
	       (log-set-full keymap i (log-wrap command prefix)))
	      ;; dunno, so flag it, and don't wrap it:
	      (t
	       (log-warn (format "log-walk-full: not wrapping: %s" command)))
	      ))
      (setq i (1+ i)))))

;; walks down a list:
(defun log-walk-sparse (keymap prefix)
  (while keymap
    (if (cdr-safe (car-safe keymap))
	(cond ((and (keymapp (cdr (car keymap))) ; nested keymap, so recurse
                    (char-or-string-p (car (car keymap)))) ;; -fer
	       (log-modify-keymap (cdr (car keymap))
				  (text-char-description (car (car keymap)))))

	      ;; nested keymap, wrapped in a list, so recurse (adapted
	      ;; from 12-May-93 above; may never happen):
	      ((and (listp (cdr (car keymap))) (keymapp (car (cdr (car keymap)))))
	       (log-modify-keymap (cdr (car keymap))
				  (text-char-description (car (car keymap)))))

	      ((log-wrap-this-p (cdr (car keymap))) ; 1-14-94 - as above
	       (log-set-sparse (car keymap)
			       (log-wrap (cdr (car keymap)) prefix)))

              ;; dunno, so flag it, and don't wrap it:
	      (t
	       (log-warn (format "log-walk-sparse: not wrapping: %s"
				 (cdr (car keymap)))))
	      ))
    (setq keymap (cdr keymap))))

;; 1-14-94 - sez whether we want to wrap this.  put commands and
;; functions to ignore in here.
(defun log-wrap-this-p (thing)
  (and (or (commandp thing)		; command (maybe lambda) or macro
	   (and (symbolp thing)
		(fboundp thing)))	; non-interactive, eg x-cut-text

       (not (and (symbolp thing)
                 (memq thing '(;;x-mouse-ignore ;Called on either up or down.
                               ;;x-flush-mouse-queue ;Called on mouse-up/down.
                               ))))))

;; record errors in wrapping keystrokes in a buffer; one
;; occasionally finds keys bound to functions that someone forget to
;; define, but that shouldn't kill us:
(defun log-warn (msg)
  (let ((buf (get-buffer-create "*log-warnings*")))
    (with-current-buffer buf
      (goto-char (point-max))
      (insert (format "%s\n" msg)))
    ;; (if log-initialized			; won't see this otherwise
    ;;     (message "Warning recorded in buffer *log-warnings*."))
    ))

(defun log-gen-args (command)
  (let* ((sf (symbol-function command))
	 (nargs (if (listp sf)
		    (length (car (cdr sf)))
		  0))
	 arglist)
    (while (> nargs 0)
      (setq arglist (cons (intern (concat "arg" nargs)) arglist))
      (setq nargs (1- nargs)))
    arglist))

(defun log-set-full (keymap index command)
  (aset keymap index command))

(defun log-set-sparse (the-car command)
  (setcdr the-car command))

(defvar log--wrappers nil)

(defun log-wrap (command prefix)
  "Returns a wrapper for COMMAND, or just COMMAND if it's a keymap or
already wrapped.  PREFIX is an optional string, usually the command prefix."
  (if (or (keymapp command)
          (memq command log--wrappers)  ; Already wrapped?
	  (not (log-wrap-this-p command)))
      command
    (let ((f
           (lambda ()
             (interactive)
             (log-keystroke             ; send prefix and command
              prefix
              (prin1-to-string (if (consp command)
                                   (car command) ;The command itself is a λ.
                                 command)))
             (setq this-command command) ; don't want the wrapper
             (command-execute command))))
      (push f log--wrappers)
      f)))

(defun log-keystroke (the-keymap the-command)
  (let ((log-buffer (get-buffer-create log-keys-buffer-name))
	(indent-tabs-mode nil))		; indent with spaces
    (if (eq (setq log-auto-save-counter (1- log-auto-save-counter)) 0)
	(progn (log-do-auto-save)
	       (setq log-auto-save-counter log-auto-save-interval)))
    (with-current-buffer log-buffer
      (let ((indent-tabs-mode nil))
        (goto-char (point-max))
        (if (not (bolp)) (insert "\n"))
        (insert (concat the-keymap ;; 18-2-94-FER fix for 19
                        (cond ((eq last-input-event 32) ; keystroke
                               "__")
                              ((numberp last-input-event)
                               (text-char-description
                                last-input-event))
                              (t last-input-event))))
        (indent-to-column 11 2)         ; whitespace
        (insert the-command)            ; command name
        (indent-to-column 40 1))	; effects column, prior to timestamp
      (log-timer-filter (let ((time (current-time)))
                          (format "%05d.%03d"
                                  (mod (+ (* 65536 (car time))
                                          (nth 1 time))
                                       100000)
                                  (/ (nth 2 time) 1000))))))
  nil)

(defun log-stamp-date ()
  (let ((log-buffer (get-buffer-create log-keys-buffer-name))
	(indent-tabs-mode nil))
    (if (eq (setq log-auto-save-counter (1- log-auto-save-counter)) 0)
	(progn (log-do-auto-save)
	       (setq log-auto-save-counter log-auto-save-interval)))
    (with-current-buffer log-buffer
      (let ((indent-tabs-mode nil))
        (goto-char (point-max))
        ;; (indent-to-column 40 1)
        (insert (format "\t%s\n\t" last-command))
        (insert
         (cond ((eq last-input-event 32)
                "__")
               ((numberp last-input-event)
                (text-char-description last-input-event))
               (t (format "%s" last-input-event))))
        ;;(indent-to-column 11 2)
        )
      (log-timer-filter (let ((time (current-time)))
                          (format "%05d.%03d"
                                  (mod (+ (* 65536 (car time))
                                          (nth 1 time))
                                       100000)
                                  (/ (nth 2 time) 1000)))))))

;; 10-1-93 - use a filter rather than an output buffer:
(defvar log-timestamp nil)

(defun log-timer-filter (output)
  ;; FIXME: Left over, from when we used an external timer.c program to get
  ;; time stamps.
  (with-current-buffer (get-buffer-create log-keys-buffer-name)
    (setq log-timestamp output)
    (let ((indent-tabs-mode nil))
      (goto-char (point-max))
      (beginning-of-line)
      (insert output)                   ; timestamp: c1-c9
      (indent-to-column 12 2))))	; whitespace

;; interface for dumping arguments to log.  [tried moving to a preset
;; column here, but was getting the command output in all sorts of
;; funny places.  now the timer sends a string padded on the right by
;; blanks.]
(defun log-command-in-process-buffer (str)
  "Funcalls COMMAND in the log buffer, to capture its output."
  (let ((log-buf (get-buffer log-keys-buffer-name)))
    (if (bufferp log-buf)
        (with-current-buffer log-buf
	  (goto-char (point-max))	; effects column, last line
	  (if (< 52 (current-column)) (insert "; "))  ; add to what's there
	  (insert str)))))

;; command redefinitons.  defvarring them makes the file reloadable,
;; and avoids making the new definitions visible as commands.  to
;; redefine something, do the right defvar below, then log-redefine it
;; in log-initialize.

;; 10-3-93 - reset hooks; see also log-new-load.  if temp*hook is nil,
;; emacs uses something to display the temp buffer, but we set it
;; emacs assumes we're taking care of it.  is display-buffer right?
(defun log-temp-buffer-show-hook (bufname)
  (let ((buf (get-buffer bufname)))
    (log-temp-buffer-show-hook-basic buf)
    ;; if we're it, display buffer too:
    (if (or (not (boundp 'temp-buffer-show-hook))
            (eq temp-buffer-show-hook 'log-temp-buffer-show-hook))
	(progn
	  (help-print-return-message)
	  (display-buffer bufname)))))

(defun log-temp-buffer-show-hook-basic (buf)
  (with-current-buffer buf
    (set-buffer-modified-p t))	; temp output doesn't modify a buffer
  (log-temp-buffer buf))

(defalias 'log-temp-buffer-show-function 'log-temp-buffer-show-hook)

;; automatically save log buffer and files visited by process buffers
;; when exiting.
(defun log-kill-emacs-hook ()
  (let ((inhibit-quit t))		; want these buffers!
    (log-do-auto-save)
    (log-save-accumulation-buffers)))

(defvar log-wrapped-filters nil)

;; sets a timestamped file with prefix FILE-PREFIX to be the file
;; visited by BUFNAME, creating the buffer if necessary.  returns the
;; buffer.
(defun log-accumulation-file (file-prefix bufname)
  (let* ((buf (get-buffer-create bufname))
	 (filename (concat *log-data-directory*
			   "Log." file-prefix "." (log-get-time-string))))
    (with-current-buffer buf
      ;; don't write-file, because that changes the buffer name
      ;; too.  auto-save and hope files don't get too big.
      (setq buffer-file-name filename)
      (auto-save-mode 1))
    (log-command-in-process-buffer (concat "visiting<>" filename))
    buf))

;; data processing utilities:

(defvar log--lex-id)
(defvar log--lex-pause)
(defvar log--lex-start)
(defvar log--lex-end)
(defvar log--lex-duration)
(defvar log--lex-keys)
(defvar log--lex-timestamp)
(defvar log--lex-line-number)
(defvar log--lex-keymap)

;; sets:
;;   log--lex-id (string)
;;   log--lex-pause
;;   log--lex-start (integer, as string)
;;   log--lex-end (integer as string or nil)
;;   log--lex-duration (integer as string or nil)
;;   log--lex-keys (string)
(defun log-lex-episode-line ()
  (setq
   log--lex-id nil
   log--lex-pause nil
   log--lex-start nil
   log--lex-end nil
   log--lex-duration nil
   log--lex-keys nil)
  (save-excursion
    (beginning-of-line)
    (skip-chars-forward " \t")		; skip leading whitespace, if any
    ;; id:
    (if (not (looking-at "\\([0-9]+\.[0-9]+\\)[ \t]"))
	()
      (setq log--lex-id (buffer-substring (match-beginning 1) (match-end 1)))
      (goto-char (match-end 0))
      (skip-chars-forward " \t"))
    ;; pause:
    (if (not (looking-at "[0-9]+\.[0-9]+"))
	()
      (setq log--lex-pause (match-string 0))
      (goto-char (match-end 0))
      (skip-chars-forward " \t"))
    ;; start:
    (if (not (looking-at "[0-9]+\.[0-9]+"))
	()
      (setq log--lex-start (match-string 0))
      (goto-char (match-end 0))
      (skip-chars-forward " \t"))
    ;; end and duration, maybe; this can't match a key sequence,
    ;; because of the intermediate whitespace:
    (if (not (looking-at "\\([0-9]+\.[0-9]+\\)[ \t]+\\([0-9]+\.[0-9]+\\)"))
	()
      (setq log--lex-end (match-string 1))
      (setq log--lex-duration (match-string 2))
      (goto-char (match-end 0))
      (skip-chars-forward " \t"))
    (if (not (looking-at "\\(.*\\)\n"))
	()
      (setq log--lex-keys (buffer-substring (match-beginning 1) (match-end 1))))))

(defun log-floatify (int)
  (format "%s.%s" (/ int 10) (% int 10)))

;; 12-23-93 - with hundredths, big numbers were overflowing:
;(defun log-intify (string-float)
;  "STRING-FLOAT is decimal seconds, with 1 or more places after the
;decimal.   Returns integer tenths of a second.  For use with
;log-float-and-round-num."
;  (let* ((decimal (string-match "\\." string-float))
;         (decimal-places (1- (- (length string-float) decimal)))
;         (decimal-part (string-to-number (substring string-float (1+ decimal)))))
;    (+ (* 100
;          (string-to-number (substring string-float 0 decimal)))
;       (cond ((= decimal-places 1)
;              (* 10 decimal-part))
;             ((= decimal-places 2)
;              decimal-part)
;             ((= decimal-places 3)
;              (round decimal-part 10))
;             (t                         ; vaguely appropriate
;              0)))))

(defun log-intify (string-float)
  "STRING-FLOAT is decimal seconds, with 1 or more places after the
decimal.   Returns integer tenths of a second.  For use with
`log-float-and-round-num'.  See also `log-integer-second'."
  (let* ((decimal (string-match "\\." string-float))
	 (decimal-places (1- (- (length string-float) decimal)))
	 (decimal-part (string-to-number (substring string-float (1+ decimal)))))
    (+ (* 10				; 12-23-93 - 100 to 10
	  (string-to-number (substring string-float 0 decimal)))
       (round decimal-part (log-raise 10 (1- decimal-places))))))

(defun log-raise (base exp)
  "Raise BASE to non-negative EXP."
  (let ((r 1))
    (while (cl-plusp exp)
      (setq r (* r base))
      (cl-decf exp))
    r))

;; 12-23-93 - with hundredths, big numbers were overflowing:
;(defun log-float-and-round-num (int)
;  "INT is integer tenths of a second.   Returns a string float, in
;seconds with one decimal place.  For use on log-initify-ed numbers."
;  (let* ((whole (/ int 100))
;         (part (round (% int 100) 10)))
;    (if (= part 10)
;        (format "%s.0" (1+ whole))
;      (format "%s.%s" whole part))))

(defun log-float-and-round-num (int)
  "INT is integer tenths of a second.   Returns a string float, in
seconds with one decimal place.  For use on log-initify-ed numbers."
  (format "%s.%s" (/ int 10) (% int 10)))

(defun log-spread-out ()
  "On data generated by `log-time-episodes', spreads records out
on a time-line, one second per line.  Output to *log-spread-out*."
  (interactive)
  (let (line
	log--lex-id				; fields in line
	log--lex-pause
	log--lex-start
	log--lex-end
	log--lex-duration
	log--lex-keys
	start
	(end nil)
	(output-buf (get-buffer-create "*log-spread-out*"))
	)
    (with-current-buffer output-buf
      (erase-buffer))
    (save-excursion
      (goto-char (point-min))		; find 1st non-blank line
      (skip-chars-forward " \t\n")
      (log-lex-episode-line)
      (setq line (log-integer-second log--lex-start))
      (while (not (eobp))
	(log-lex-episode-line)
	(with-current-buffer output-buf
	  (setq start (log-integer-second log--lex-start))
	  (while (< line start)
	    (insert (format "%8s\n" line))
	    (cl-incf line))
	  (insert (format "%8s\t%8s\t%8s\t%8s"
			  line log--lex-id log--lex-pause log--lex-start))
	  (if (not log--lex-end)
	      (insert (format "\t%8s\t%8s\t%s\n" "" "" log--lex-keys))
	    (setq end (log-integer-second log--lex-end))
	    (if (>= line end)
		(insert (format "\t%8s\t%8s\t%s\n"
                                log--lex-end log--lex-duration log--lex-keys))
	      (insert (format "\t%8s\t%8s\t%s\n" "" "" log--lex-keys))
	      (cl-incf line)
	      (while (< line end)
		(insert (format "%8s\n" line))
		(cl-incf line))
	      (insert (format "%8s\t%8s\t%8s\t%8s\t%8s\t%8s\t%s\n"
			      line
			      "" "" ""
			      log--lex-end
			      log--lex-duration
			      ""))))
	  (cl-incf line))
	(forward-line 1)))
    (pop-to-buffer output-buf)
    (goto-char (point-min))))

(defun log-integer-second (string-float)
  "Returns rounded whole part of STRING-FLOAT.  Based on log-intify."
  (let* ((decimal (string-match "\\." string-float))
	 (decimal-places (1- (- (length string-float) decimal)))
	 (decimal-part (string-to-number
                        (substring string-float (1+ decimal)))))
    (+ (string-to-number (substring string-float 0 decimal))
       (round decimal-part (log-raise 10 decimal-places)))))

(defvar *log-time-episodes-interval* 100
  "*Used by log-time-episodes to create new episodes.")

;; 8-1-93 -
(defun log-time-episodes ()
  "Like `log-meta-command-episodes', but also breaks a string when
the pause between keystrokes is longer than 1 second.
Prints episode start/end times and inter-episode intervals and episode
durations, but leaves out command names and arguments.  First output
field is episode start time in original format, for tracing to other
representations.  Output to *log-time-episodes*."
  (interactive)
  (let ((previous-was-episode nil)
	previous-was-kill
	(current-is-kill nil)
	(current-timestamp 0)
	(previous-timestamp 0)
	(episode-beginning 0)
	episode-len
	log--lex-line-number			; globals used by log-lex-line
	log--lex-timestamp			; as integer tenths-of-seconds
	log--lex-keymap
	log--lex-keys
	(output-buf (get-buffer-create "*log-time-episodes*"))
        pause)
    (with-current-buffer output-buf
      (erase-buffer))
    (save-excursion
      (goto-char (point-min))
      (while (not (eobp))
	(log-lex-line)			; moves point!
	(if log--lex-timestamp		; not an add-one kill/yank
	    (with-current-buffer output-buf
	      (setq previous-timestamp current-timestamp)
	      ;; 11-8-93 - need the whole thing, because intervals
	      ;; between episodes get long (cf "minusp")
	      (setq current-timestamp (log-intify log--lex-timestamp))
	      (setq pause (- current-timestamp previous-timestamp))
	      (if (cl-minusp pause)
		  ;; then one of the eight-digit begin-end
		  ;; brackets have wrapped (cf "minusp"):
		  (setq pause (+ pause 1000000)))
	      (setq previous-was-kill current-is-kill)
	      (setq current-is-kill (log-line-is-kill))
	      ;; if not a meta-command, and no big pause, and not
	      ;; other things, append to episode:
	      (if (and log--lex-keymap
		       ;; HERE:
		       ;;(> *log-time-episodes-interval* pause)
		       (> 10 pause)	; ie, > 1 sec
		       ;; not 1st of a sequence of kills:
		       (or previous-was-kill (not current-is-kill))
		       ;; not first command after a kill:
		       (not (and previous-was-kill (not current-is-kill)))
		       )
		  (progn
		    (insert log--lex-keys)
		    (setq previous-was-episode t))

		;; ELSE previous episode ends and next one begins.

		(skip-chars-backward "^ \t") ; backward over inserted keys
		;; if previous episode had only one keystroke, insert NA for
		;; end timestamp, else end timestamp is that of last key in
		;; episode:
		(if (not previous-was-episode)
		    (insert (format "%6s\t%6s\t" "" ""))
		  (setq previous-was-episode nil)
		  (setq episode-len (- previous-timestamp episode-beginning))
		  (if (cl-minusp episode-len)
		      ;; then one of the seven-digit begin-end
		      ;; brackets have wrapped (cf "minusp"):
		      (setq episode-len (+ episode-len 1000000)))
		  (insert (format "%6s\t%6s\t"
				  (log-float-and-round-num previous-timestamp)
				  (log-float-and-round-num episode-len))))
		(setq episode-beginning current-timestamp)
		(end-of-line)
		(insert "\n")

		;; insert episode start time in original format, for
		;; mapping; preceding pause, episode start time, and first
		;; keys in episode:
		(insert (format "%s\t%6s\t%6s\t%s"
				log--lex-timestamp
				(if (not (zerop previous-timestamp))
				    (log-float-and-round-num pause)
				  "0.0")
				(log-float-and-round-num current-timestamp)
				log--lex-keys)))))
	(forward-line 1)))
    (pop-to-buffer output-buf)
    (skip-chars-backward "^ \t")
    (insert (format "%6s\t%6s\t" "" ""))
    (goto-char (point-min))
    (insert "\n")
    (goto-char (point-min))))

;; HERE: fix this to save excursion and move to beginning of line.
;; sets:
;;   log--lex-line-number (string or nil)
;;   log--lex-timestamp (string representing integer milliseconds)
;;   log--lex-keymap (string or nil)
;;   log--lex-keys (string)
;; assumes point is at bol, and leaves point wherever.
(defun log-lex-line ()
  (setq log--lex-line-number nil
	log--lex-timestamp nil
	log--lex-keymap nil
	log--lex-keys nil)
  (skip-chars-forward " \t")		; skip whitespace befor field 1
  (if (not (looking-at "\\([0-9]+\\)[ \t]"))	; line number?
      ()
    (setq log--lex-line-number (match-string 1))
    (goto-char (match-end 0))
    (skip-chars-forward " \t"))
  (if (not (looking-at "[0-9]+\.[0-9]+")) ; timestamp?
      ()
    (setq log--lex-timestamp (buffer-substring (match-beginning 0)
					  (match-end 0)))
    (goto-char (match-end 0))
    (skip-chars-forward " \t")
    ;; remaining fields non-nil are contingent on there being a timestamp:
    (if (not (looking-at "\[[A-Z]+\\??\]"))	; keymap?
	()
      (setq log--lex-keymap (match-string 0))
      (goto-char (match-end 0)))
    (re-search-forward "\\([^ \t]*\\)")	; match keys (assumes trailing ws)
    (setq log--lex-keys (buffer-substring (match-beginning 1) (match-end 1)))
    ;; don't bother with command name or args for now, but it's
    ;; probably simple enough.
    ))

;; t if the current log line is part of a kill or yank.
;; needs the line to be lexed, doesn't care about point.
(defun log-line-is-kill ()
  (or (not log--lex-timestamp)
      (string-match "\\^\\(K\\|W\\|Y\\)" log--lex-keys)))

;; 6-20-93 -
(defun log-meta-command-episodes ()
  "Destructively filters a keystroke log buffer to organize keystrokes
into epidodes.   Lines for commands invoked via C-x or M-x
\(meta-commands, loosely), as well as kills and yanks, are left intact.
For other lines, only the keys get through:
----
     1	6204.696  ^X^F       find-file
     2	6207.462  [G]f       self-insert-command
     3	6207.696  [G]r       self-insert-command
-- becomes:
     1	6204.696  ^X^F       find-file
fr
----
Provides high compression but a coarse view of the data.  Good for
finding strings typed by the user.  See also log-collapse-repeats and
log-time-episodes."
  (interactive)
  (save-excursion
    (let ((catenating nil)
	  previous-was-kill
	  (current-is-kill nil))
      (goto-char (point-min))
      ;; delete yank/kill lines after the first (which probably won't
      ;; have NNNN.NNN timestamps):
      (delete-non-matching-lines "^.*[0-9][0-9][0-9][0-9]\.[0-9][0-9][0-9].*")
      ;; search for log.el's keymap format, eg, "[G]" for global map, because
      ;; ^X and ESC command sequences don't have this.  exempt the
      ;; first of sequence of kills, wipes, and yanks.
      (while (not (eobp))
	(setq previous-was-kill current-is-kill)
	;; HERE: replace with a call to log-line-is-kill:
	(setq current-is-kill  (string-match "\\^\\(K\\|W\\|Y\\)"
					  (buffer-substring
					   ;; WARNING: there's a magic
					   ;; number 30 here; search
					   ;; for "effects column".
					   (point) (+ (point) 30))))
	;; HERE: does this get "[D?]"?  use log-lex-line?
	(if (and (looking-at ".*\[[A-Z]*\]\\([^ ]*\\).*\n") ; keymap?
		 (or previous-was-kill
		     (not current-is-kill)))
	    ;; delete all of the log line except the keystrokes
	    (progn
	      (replace-match "\\1")
	      (setq catenating t))
	  ;; ELSE leave the log line intact
	  (if catenating		; end current string
	      (progn
		(setq catenating nil)
		(insert "\n")))
	  (forward-line 1))))))


(defun log-collapse-repeats ()
  "Collapses sequences of 3 or more repeats of selected character
pairs.  Eg,^N^N^N^N______^A^A becomes ^N4... __3... ^A^A.  (Note the
spaces, which can't otherwise get into the data.)  Collapses ^A-^Z,
^? and __."
  (interactive)
  (save-excursion
    (let ((count 0))
      (goto-char (point-min))
      (while (not (eobp))
	(cond ((and (zerop count)
		    (looking-at "\\(\\^[A-Z?]\\|__\\)\\1\\1")) ; three pair
	       (setq count 3)
	       (forward-char 2)
	       (delete-char 2))		; delete middle, look at last pair
	      ((and (>= count 3)
		    (looking-at "\\(\\^[A-Z?]\\|__\\)\\1")) ; another beyond
	       (cl-incf count)
	       (delete-char 2))
	      ((and (>= count 3)
		    (not (looking-at "\\(\\^[A-Z?]\\|__\\)\\1"))) ; end
	       (delete-char 2)		; empty the pair queue
	       (insert (format "%s... " count))
	       (setq count 0))
	      (t
	       (forward-char 1)))))))

;; other utilities:

;; 10-1-93 -
;; if the buffer hasn't been saved in some other way, and we might
;; care about it, save its contents.  temp buffers may not be marked
;; as modified.
(defun log-temp-buffer (buf &optional is-so-modified)
  (if (bufferp buf)
      (with-current-buffer buf
	(if (or (not (or (buffer-modified-p) is-so-modified))
		(buffer-file-name buf)
		(eq buf (get-buffer log-keys-buffer-name))
		(eq buf (get-buffer log-temp-buffer-name))
		;; can we get the minibuffer directly?
		(eq buf (window-buffer (minibuffer-window))) )
	    ()
	  ;; grab new output in this buffer:
	  (let* ((separator
		  (format "logged<>%s<>%s" (buffer-name buf) log-timestamp))
		 (log-buf (get-buffer log-temp-buffer-name)))
            ;; If the accumulation buffer's died, set up another:
            (if (not log-buf)
                (setq log-buf (log-accumulation-file
                               "temp-buffers" log-temp-buffer-name)))
	    (with-current-buffer log-buf
	      (goto-char (point-max))
	      (if (not (bolp)) (insert "\n"))
	      (insert (concat separator "\n"))
	      (insert-buffer-substring buf))
	    (set-buffer-modified-p nil) ; blech; 12-22-93 - HERE: why do this?
	    (log-command-in-process-buffer separator))))))

;; 9-28-93 - quietly save accumulation buffers, w/o backups:
(defun log-save-accumulation-buffers ()
  ;; save accumulated temp buffer output:
  (if (bufferp (get-buffer log-temp-buffer-name))
      (with-current-buffer (get-buffer log-temp-buffer-name)
	(save-buffer 0)))
  ;; save process buffers:
  (log-save-process-buffers))

(defun log-save-process-buffers ()
  (let ((l (process-list))
        process)
    (while l
      (setq process (car l))
      (if (and (process-buffer process)	; seems nil can have a file-name
	       (buffer-file-name (process-buffer process)))
	  (with-current-buffer (process-buffer process)
	    (save-buffer 0)))
      (setq l (cdr l)))))

(defun log-screen ()
  (concat "screen<>" (log-screen-info)))

;; 9-28-93 - return line-number/top-line:bottom-line.  from what-line.
(defun log-screen-info ()
  (interactive)
  (save-restriction
    (widen)
    (save-excursion
      (beginning-of-line)		; don't be at eol
      (let* ((top-line (1+ (count-lines 1 (window-start
					   (selected-window))))))
	(format "%d:%d-%d"
		(+ top-line
		   (count-lines (window-start (selected-window)) (point)))
		top-line
		(+ top-line (window-height) -2))))))

(defun log-current-buffer ()
  (let ((str (concat "now-in<>"
                     (buffer-name (current-buffer))
                     "<>"
                     (log-screen-info))))
    (lambda () (insert str))))

(defun log-insert-kill ()
  (let ((start (point))
	(indent-tabs-mode nil))		; indent with spaces
    (insert (car kill-ring-yank-pointer))
    ;; indent all of a multi-line kill to start at effects column:
    (indent-rigidly (progn (save-excursion
			     (goto-char start) (forward-line) (point)))
		    (point)
		    52)))

(defun log-do-auto-save ()		; would a macro be faster?
  "Save buffer in time-stamped file name, then clear buffer."
  (if (bufferp (get-buffer log-keys-buffer-name))
      (let ((save-buf (find-file-noselect
		       (concat *log-data-directory*
			       "Log.keys."
			       (log-get-time-string))))
	    (log-buf (get-buffer log-keys-buffer-name))
	    (require-final-newline t))	; for catenating log files
	(with-current-buffer save-buf
	  (insert-buffer-substring log-buf)
	  (save-buffer)
          (if log-compress! ;; -fer
              (call-process "compress" nil 0 nil (buffer-name save-buf))))
	(kill-buffer save-buf)
	(with-current-buffer log-buf
	  (erase-buffer)))))

;; date/timestamp for the log file:

(defun log-get-time-string ()
  (let* ((time-string (current-time-string))
	 (gronk (substring time-string 8 9))) ; maybe blank
    (concat
     (substring time-string 0 3) ; day
     "-" (substring time-string 4 7) ; month
     "-" (if (string-equal gronk " ")
	     (substring time-string 9 10) ; date, 1<10
	   (substring time-string 8 10)) ; date, 9<...
     "-" (substring time-string 11 19) ; hh:mm:ss
     "-" (substring time-string 20 24) ; year
     )))

;;;; still todo:

;;
;;     why does comint-bol (^A) crap out?

;;   the read-char definition means that ^S (and ^R) get logged
;;     twice [G]^R...isearch-backward [R]^R...read-char
;;   make documentation current
;;   make sure there's no version control for 'cuum buffers
;;   can we compress trace files?
;;   log modified temp buffers when leaving them?
;;   have a test to see if current buffer changes, output name of new buffer
;;   do something to capture output of temp and (mainly) process buffers
;;     [8-16-93] in the intermim, just write buffer to a file; then
;;       killing the buffer will prompt emacs to prompt for a save.
;;     [9-26-93] for process buffers (ie shell), need to make sure that
;;       killing the buffer doesn't hurt.
;;   decide what to do about, say ^X <pause> b, which registers
;;     only the time of the "b"
;;
;;;; old todo:
;;   Xbe smarter about the mouse [12-30-93, after s12]
;;     Xoutput cursor position, command, etc  [see below]
;;     ?parse it better; add to log-collapse? [?]
;;     Xget meaningful output - line & column numbers would do
;;       [1-14-94 - outputs args to mouse command, incl.
;;        (xpos ypos) in character OFFSET from top left of SCREEN]
;;     Xget x-cut-text wrapped in the keymap
;;     Xget the lisp code wrapped - x-cut-text, x-get-cut-buffer [an arg]
;;     Xmaybe don't wrap x-flush-mouse-queue [right]
;;   Xdiscovered from s12's run that mouse events show up as
;;     Xtwin x-flush-mouse-queue's--why? [12-22-93]
;;   Xfigure out why characters typed to i-search don't show (8-2-93)
;;   Xmake up/down movement keys put out line and column numbers? [don't need]
;;   Xstore diffs in backup files (see "overwrite" in K&P) [compress backups]
;;   Xwrap with-output-to-temp-buffer
;;   Xcompress keystroke logs on the fly ("call-process...")
;;   Xwrite temp buffer log when exiting
;;   Xwrap set-process-filter, for procs that don't use a process buffer
;;   Xwrite filter-output buffer like i do keys buffer
;;   Xchange keystroke logging to use a process filter, to get timestamps
;;   Xmake buffer-logging modular
;;   Xwrap set-process-buffer, in case buf changes after start-proces
;;   Xhave character deletes put out what they're deleting (time*.s7.ann*.txt:7858; 9-14-93)
;;   Xget ^W to print its arguments (if there's really a place it doesn't)
;;      [9-27-93 - s7's keystrokes are ok; might have been fooled by \n.
;;   Xredefine define-key and its relations
;;   Xwalk control-x, esc, and local (?) maps
;;   Xwrite the log file
;;   Xinstall the coarse log [wrap yanks, kills, other-window]
;;   Xdump a dribble like open-dribble, so we can compare to make sure
;;     we got all keystrokes [got most of them,i think]
;;   Xdump the original keymaps, for getting the commands back [now
;;     print commands]
;;   Xfset-ed macros?
;;   Xminibuffer completion map?
;;   Xwrap use-local-map? [put a hook on find-file-hooks] [wrapped
;;     other-window with log-modify-local-maps; sooner or later, will
;;     get all of them...]
;;   Xaccessible-keymaps, to get all maps
;;   Xmake timer portable to other systems
;;   Xtest with completion stuff loaded (first!)
;;   Xget rid of nfound in timer.c (save some time)
;;
;;;; History:

;; 12-2-94 - modified to work in 19, sorta.  Not as clean or commented,
;;   but not bad.  Useful for undergraduate practicals.
;;
;; 1-14-94 - smarter mouse behavior.  x-flush-mouse-queue was it,
;;   getting called on both up and down clicks.  now this and
;;   x-mouse-ignore aren't logged, and other mouse functions are,
;;   along with their args.  seems mouse functions aren't
;;   interactive, and get args directly when they're dispatched, so
;;   changed log-call to deal with args when they're there.
;;
;; 12-23-93 - timestamps (in log-time-episodes) were overflowing;
;;   changed from 100s of a second to 10s.
;;
;; 12-22-93 - display-time is a process whose buffer is whatever
;;   buffer you're in.  this confused the code in log-initialize
;;   that set buffer-file-names for existing process buffers,
;;   causing it to change the name of a text buffer.  fixed that and
;;   some other contingencies.
;;
;; 12-20-93 - "(accept-process-output log-timer-process 1)"; "1" was
;;    wrong; how'd it get there?
;;
;; 11-9-93 - log-time-episodes and log-spread-out now take bigger
;;   timestamps (5+3 digits).  episode brackets are 5+1, the 5
;;   because a very long interval (two emacs, in different windows)
;;   would cause aliasing, the 1 because that's all that's useful in
;;   spread-out format.  floats now represented internally as
;;   hundredth-second ints.
;;
;; 10-13-93 - key logs written with require-final-newline t.
;;
;; 10-4-93 - popper was redefining pop-to-buffer, causing a binding
;;   loop; log-new-load now resets most functions before calling
;;   load, then restores the redefinitions.  removed "list*" (see
;;   below).  log.el loads into a bare editor, and my .emacs (which
;;   loads popper) loads after.  compress snapshots.
;;
;;     note: log.el breaks substitute-command-keys (because keys are all
;;     lambdas), which has a byte-code.
;;
;; 10-3-93 - set hooks better; tried to set temp-buffer-show-hook.
;;   replaced dolist; can't figure out where to get it, or where i
;;   get backquote.
;;
;; 10-2-93 - keystroke files get compressed when written.  filenames
;;   are better.  wrote some code and fixed some bugs from within an
;;   editor that was logging.
;;
;; 10-1-93 - now filters output of timer, and blocks on read to
;;   synchronize; maybe this will prevent any future instances of
;;   things being written in the log out ofkilter, and we can now
;;   get the timestamp by itself.  process buffers and filters now
;;   log process output.
;;
;; 9-28-93 - logs chars deleted, forwards or backwards, and screen
;;   info for scrolls and buffer leaps (#6 and #7, in updated list);
;;   quietly visits a timestamped file for each new or existing
;;   process buffer, quietly writing it when buffers are killed or
;;   saved (#2); prints characters entered to isearch (but won't
;;   get other read-char args unless the .el files for the functions
;;   are reloaded).
;;
;; 9-27-93 - priorities:
;;      X1. preimages - copy the original; does "~" do it?
;;         no: user may start in the middle of a session
;;      X2. save process buffers
;;      3. accumulate output of temp buffers
;;      4. isearch - record arguments
;;      X5. checkpoints a diff at every save
;;         . wrap auto-save to record a timestamp with the file
;;         attribute representing time that i see with an ls; set
;;         delete-auto-save-files (215) to nil
;;         . change save-buffer to call backup-buffer every save
;;         . change backup-buffer to timestamp filenames
;;         . set make-backup-files t
;;         . version-control (variable)
;;         . save-some-buffers in log-initialize, if that helps
;;      X6. scrolls put out line and column numbers
;;         . scroll-up, scroll-down, scroll-other-window all separate, C
;;      X7. deletes put out characters
;;      ?8. ^N, ^P put out line numbers [too slow?  'sides, have scrolls]
;;
;;      todo:
;;        copy all visited buffers on exit (?)
;;      emacs things to look at:
;;         checkpointing - "~" (#1)
;;         associating process buffers with file and auto-saving (#2)
;;         with-output-to-temp-buffer (#3)
;;         redefining read-char (#4)
;;         redefining isearch (#5)
;;
;;         append-to-file
;;         copy-file
;;         kept-old/new-versions (213)
;;     [initial version:]
;;      1. preimages - copy the original; does "~" do it?
;;         no: user may start in the middle of a session
;;      2. save process buffers
;;      3. accumulate output of temp buffers
;;      4. isearch - record arguments
;;      5. checkpoints a diff at every save
;;         . wrap auto-save to record a timestamp with the file
;;         attribute representing time that i see with an ls; set
;;         delete-auto-save-files (215) to nil
;;         . change save-buffer to call backup-buffer every save
;;         . change backup-buffer to timestamp filenames
;;         . set make-backup-files t
;;         . version-control (variable)
;;         . save-some-buffers in log-initialize, if that helps
;;
;;   did 1 and 5, by redefining save-buffer and
;;   find-backup-file-name.  log now points to backups, up to a
;;   hundred of which are made, every save.  saves all buffers on
;;   initialization after redefinition, to get preimages of buffers
;;   modified but not written at log-initialization.
;;
;;   the preimage is the set of first backups for each file after
;;   log-initialization.
;;
;; 9-26-93 - wrap find-file (and write-file?) to squirrel away the
;;   pre-image; also for reading files; and get snapshots when files
;;   are written!  what if source files are huge, changes small, and
;;   writes frequent?  store diffs, like RCS?
;;
;; 6-26-93 - Fixed up the keymap-walking functions to send warnings
;;   to a buffer instead of generating an error.  Also added fix
;;   that FER's sent me on 14 May.
;;
;;   Here's something odd (see ~/data/s10*/keystroke*/originals/).
;;   I suppose some buffer somewhere got clobbered, but it's beyond me.
;;
;;	9839.355  [G]^P      previous-line                  .52  ;; "." marks col 52, which was eol
;;	9842.996  [G]^P      previou[G]^P                   .52
;;	9843.496  previous-line [G]^P                          .55
;;	9843.527  previous-line [G]^P                          .55
;;	9843.574  previous-line [G]^P                          .55
;;	9843.605  previous-line [G]^P                          .55
;;	9843.636  previous-line [G]^P                          .55
;;	...
;;	9848.386  next-line  [G]^N                          .52  ;; "[" (3') begins where (3) did
;;	...
;;	9878.308  previous-line ^[>                            .55
;;	...
;;	9882.183  self-insert-command [D?]^M                         .61 ;; diff (9) is length of commands
;;	9883.511  sde-return [G]g                           .52
;;
;; 6-20-93 - Began adding functions to parse the logs; may never get
;;   beyond log-parse-1.
;;
;; 3-30-93 - added log-load-emergency-file and C-x4l binding, after
;;   losing gary's shell binding when the keybindings wedged.
;;   tim freeman pointed out that a back door would have been
;;   useful.  added test in log-keystroke ("3-30-93") that fixed the
;;   problem when exit-emacs queried about killing remaining
;;   processes; didn't seem to slow things down.
;;
;; 3-5-93 - ways to segment the log:
;;   . version-control, on the file visited by the log buffer.  but
;;   version-control isn't buffer-local, so it will be on for all
;;   files being edited.
;;   . do my own version-control; write the file, rename it to
;;   something that includes the version-control counter.  but that
;;   entails visiting a file, which means that one can't use the
;;   nice buffer name that begins with a leading blank.
;;
;; . Command arguments seem to reach the process buffer before the
;; output process, even though the commands that generate them are
;; called after the process is sent its string.  And
;; accept-process-output after the process-send-string didn't help.
;; And when using the debugger to trace calls to log-call (first)
;; and log-keystroke (second), the arguments and process output
;; reach the process buffer in the right order.  Some race
;; condition?
;;
;;   [ 11-18-92 - fixed by moving the process marker just before
;;   sending the new process string (in log-keystroke) rather than
;;   just after inserting command output in the process buffer
;;   (log-comman*).  execution order is now (1) log keystroke; (2)
;;   command output; (3) process output from #1 arrives at process
;;   mark, before command output (4) (next keystroke) process mark
;;   moved past command output.  #4 was happening after #2, meaning
;;   that #3 was appearing after the command output ]
;;
;; . Loses the logging of command arguments if packages loaded on
;; top of this re-defun the commands.  Popper.el is irresponsible in
;; this regard (it should define new functions that call the old
;; symbol-function, rather than clobber it with a defun).
;;
;;   [ 11-22-92 - keep track of all redefined functions, then
;;   redefine load to map log-redefine across the list.  made
;;   log-redefine "reentrant". ]
;;
;; 11-28-92 - indenting copy-as-kills is meant to improve
;;   filterability.  in particular, it means that keystrokes can be
;;   counted by filtering out lines that lead with spaces.
;;   important if one happens to yank mulitple lines from the log
;;   buffer...

(provide 'log)
;;; log.el ends here
