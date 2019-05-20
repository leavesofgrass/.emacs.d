;;; simple-menu.el --- Command-line menus made declaratively  -*- lexical-binding:t -*-

;; Copyright (C) 1991, 2013 Free Software Foundation, Inc.

;; Author: Frank Ritter & Roberto Ong
;; Created-On: Mon Oct 28 12:28:03 1991

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

;; We've completely rewritten the Chris Ward's menu system to suit our
;; needs.  It is a simple tty based menu system for providing a limited
;; number of choices in an extensible way.  We use it daily (well, not
;; really, we typically use the keystroke equivalents it teaches), but
;; the point is that it is robust enough to put out.  We have cut most
;; of Chris's Emacs commands from the menus, the present package is
;; offered more for applications, but I would be happy to paste stuff
;; people send me.  At the bottom of this file we provide a sample set
;; of menus for Emacs.

;;;; TODO:

;;  * Select menu items by the first *capital* letter in the menu
;;    label (e.g. select "About" with `a' but "aTtach" with `t')
;;  * Introduce some means of coping with long prompts, e.g. make
;;    minibuffer taller, or display options in another window with
;;    a short prompt in minibuffer


;;;;	iv.	OVERVIEW/INTRODUCTION
;;
;; Simple-menu is a way to provide simple menus, rather reminiscent of
;; the menus provided by the PDP software of McClellend & Rumelhart.  With
;; the simple menus defined here for gnu-emacs, an initial menu of
;; commands is displayed in the message line by calling sm-run-menu on a
;; previously defined menu.  The user types the first letter of an item to
;; select it, and a command gets executed, or a sub-menu is entered.
;; Often you will bind the top menu call to a key.
;;
;; The prompt that is displayed includes a reminder that help is available
;; by typing ``?''.  (Help is also available by typing ^h or SPC.)
;; The prompt can be a string (which will get a ":" tacked on to it),
;; a list that will get evaled, a variable that will get evaled, or a
;; function that will get funcalled.
;;
;; Simple menus are defined with def-menu.  This takes a menu-name, an
;; title, an intro help comment (ie.: "Pick a command"), and a list of
;; items to be put on the menu.  Each  menu item is a list with 2
;; components: 1) a display string, and 2) the command corresponding
;; to the string.  The first word is put in the menu, the first letter in
;; the string is used as the selector for the item (case insensitive),
;; and the whole string is used in the help display.
;; sm-def-menu and sm-add-to-menu allow you add commands to menus after they
;; have been created, and sm-clear-menu lets you start from scratch.
;;
;; For example, the menu item:
;;
;; ("Redraw         Redraw the screen."   recenter)
;;
;; would create the item Redraw in the menu, and the letter R would
;; select it.  In the help display, the full string would appear, along
;; with any keybindings for the command in the local buffer, in this case
;; the help line would look like
;;
;; Redraw         Redraw the screen. (C-l)
;;
;; The command given as the second argument can be either: 1) a simple
;; function name, 2) a list to eval, or 3) a menu name (symbol).  If you
;; want two commands there, wrap them in a progn because the internals of
;; the program use each list position.  The command should not display
;; a value with message as its result.
;;
;; If there is only one menu item, it is executed when the menu is run.
;; After an item is selected and sucessfully completed, a possible keybinding
;; or call via meta-X is displayed if possible.
;;
;;  Here's an example:
;;
;; (sm-def-menu 'simple-menu
;;   "Choose a simple command"
;;   "Here are some simple commands to choose from"
;; '(("Add 2 + 2      Add 2+2 and print it out for me."
;;    (progn (message "The Answer is %s." (+ 2 2))
;;           (sleep-for 2)))
;;   ("Redraw         Redraw the screen." recenter)
;;   ("Simple menu    Recurse and run this darn menu again." simple-menu)))
;;
;; sm-run-menu will start up the menu.  ^g will abort the menu.
;;   e.g., (sm-run-menu 'simple-menu) (if you have defined the menu above)
;;   e.g., (sm-run-menu 'emacs-menu)  (if you have loaded this file)
;; Binding this to a key makes the menu more usable.
;; sm-run-menu also takes a default, a string or symbol.  If the user
;; types a CR, the first letter of the string or symbol's name is
;; used to make the choice.
;;
;; (sm-add-to-menu

;;
;; The simple-menu code uses a primitive form of packages.  In order that
;; the function names here don't clash with other systems, all functions
;; and internal variables have had "sm-" prepended to them.  Where outside
;; packages would like to use them, the functions have been fset (copied
;; over) to function names without the "sm-".  Variables that are used
;; outside have not had "sm-" added to them.
;;
;; I will NOT maintain it in the traditional sense (mostly a note to myself to
;; get back to the thesis), but I will 1) incorporate changes that are
;; useful to me, 2) fix bugs that you notice that would bother my
;; application, and 3) incorporate good stuff you post me.
;;
;; I am willing to answer questions if things aren't clear on how to get
;; started.
;;
;; possible bugs/misfeatures:
;; * The command should not display a value with message as its result.

;;; Code:

(eval-when-compile (require 'cl-lib))

;;; 	vi.	Utilities

;; (first-word '("asdf" fun1))
;; (first-letter '("Asdf" fun1))

(defun sm-cant-do-this ()
  "Dummy function for menu item not yet implemented."
  (interactive)
  (message "No function to do this menu item yet."))

(defvar sm-run-menu-flag)
(defvar sm--current-key-map)

;;*created this function to quit simple-menu
;; allows a cleaner quit with C-g, 19-May-97 -FER
(defun sm-quit ()
  "Quit simple-menu to abort, or after a command has been evaluated."
  (if (boundp 'command)
      (sm-note-function-key command sm--current-key-map)
    (beep)
    (message "Quiting simple-menu"))
  ;; (beep) (message "hi") (sit-for 1)
  (setq sm-run-menu-flag nil)
  ;; (keyboard-quit)
  )

(defsubst sm-first-word (menu-item)
  "Return the first word of the first part (a string) of MENU-ITEM."
  (let ((string  (car menu-item)))
    (substring string 0 (string-match " " string))) )

(defsubst sm-first-letter (menu-item)
 "Return the first letter of the first part (a string) of MENU-ITEM."
 (let ((string  (sm-first-word menu-item)))
   (downcase (substring string 0 1))) )

;;*created the following functions for checking menu items with the same
;;*first letter
(defsubst sm-first-letter-items (items)
  "Return the list of the first letters of the menu ITEMS."
  (mapcar #'sm-first-letter items))

(defun sm-first-letter-tidy (letters)
  "Return the list of the first letters of the menu items removing any
duplicate letter(s)."
  (if (null letters)
      nil
    (let ((menu-letters (sm-remove-menu-item-letter
                         (car letters) (cdr letters))))
      (cons (car letters) (sm-first-letter-tidy menu-letters))) ))

(defun sm-remove-menu-item-letter (element list)
 "Return the list of the first-letters of the menu items with
the first-letter referred to by element removed."
 (cond (  (null list) nil)
       (  (equal (car list) element)
          (cdr list))
       (t (cons (car list)
                (sm-remove-menu-item-letter element (cdr list)))) ))



;;;
;;; 	I.	Variables and constants
;;;

(defvar sm-default-function 'sm-cant-do-this
  "*Default function to call if a menu item doesn't have a function
assigned to it.")

;; uses main help buffer, used to be *MENU Help*
(defconst sm-help-buffer "*Simple-Menu-Help*")

(defconst sm-help-string "? ")
(defconst sm-default-string "[%s]:")

(defconst sm-default-help-header "Commands in the")
(defconst sm-default-help-for-help
  "? or C-h or SPC to display this text at the first prompt.")

(defconst sm-default-help-footer
 "First letter of the line to choose a command.
 RET selects the item in [] (if any).    * - menu item not functional yet.
 / - item leads to another menu.         . - more information pompted for.

 Ctrl-G to quit this menu now.           C-d to backup one level.")


;; Not used yet, but kept around for version control and bug reports.
(defconst sm-version "1.7")


;; menus have the following fields:
;; prompt - the string used as the prompt before the choices
;; full-prompt - the string put in the message line
;; items - the list of items
;; prompt-header  - header (leading string) for the command line
;; help-header - header for the help buffer


;;;
;;; 	II.	Creating functions
;;;
;; menus are symbols,
;; the raw items are stored under the plist 'items
;; the list that is displayed is stored in their value,
;;    it is made by calling sm-menu-ized-items on the items,
;; the prompt-header is under the 'prompt-header property
;; the help-header   is under the 'help-header property.

(defun sm-menu-p (poss-menu)
 "Return t if item is a simple-menu."
 (and (boundp poss-menu)
      poss-menu
      (get poss-menu 'items)
      (get poss-menu 'prompt-header)
      (get poss-menu 'help-header)
      t))

(defun sm-def-menu (name prompt help-header items)
 "Define a menu object."
 ;; check for errors on the way in and message args
 ;;*additional check for empty menu items list
 (cond (  (not (symbolp name))
          (error (format "%s, the first arg must be a symbol." name)))
       (  (null items)
          (error (format "%s must contain menu items." name)))
       (  (boundp name)
          nil)
       (t (put name 'items items)
          (set name (sm-menu-ized-items items))
          (put name 'prompt-header prompt)
          (put name 'help-header help-header))) )

;; Could set here whether items go on front or back.
(defun sm-add-to-menu (menu items)
 "Add to NAME the list of ITEMS."
 (mapc (function
           (lambda (item)
             (let ( (old-items (get menu 'items)) )
               (cond ( (member item old-items) )
                     (t (put menu 'items (append old-items items))
                        (set menu (sm-menu-ized-items (get menu 'items)))
                        (put menu 'full-prompt nil)))  )))
          items))


;;;
;;;	III.	Running functions
;;;
;;; The cursor-in-echo-area doesn't work on pmaxen with X windows,
;;; we don't know why.

;; a for-loop that emacs-lisp doesn't have.
(defun sm-for (from to fun)
  "For x = FROM to TO, funcall function FUN.
TO and FROM are ints, FUN is a symbol."
  (let ((x from))
    (while (<= x to)
      (funcall fun x)
      (setq x (1+ x))) ))

;;  (let ((x (1- from)))
;;    (while (<= (setq x (1+ x)) to)
;;      (funcall fun x))))

;; this bit of code sets up the sm-select-item-map, which is used
;; when reading the item selection from the user.
(defvar sm-select-item-map
  (let ((map (make-keymap)))
    (suppress-keymap map)
    (let ((set-key (lambda (k)
                     (define-key map (char-to-string k)
                       'exit-minibuffer))))
      (sm-for ?a ?z set-key)
      (sm-for ?A ?Z set-key)
      (sm-for ?0 ?9 set-key)
      (funcall set-key ?+)              ;*for window-sizing
      (funcall set-key ?-)              ;*for window-sizing
      (funcall set-key ?>)              ;*for window-sizing
      (funcall set-key ?<)              ;*for window-sizing
      (funcall set-key ?\C-d)  	        ;*should popup one level
      (funcall set-key ?\C-g)		;*should abort simple-menu
      (funcall set-key ?\r)             ; should accept default
      (funcall set-key ?\n)             ; should accept default
      (funcall set-key ?\t)             ; should accept default
      ;; modified in 1.4 to be ignored, b/c it is messy to use in general
      ;;  (funcall set-key ?\e)			; should abort
      (define-key map "?" 'sm-pop-up-help)
      (define-key map " " 'sm-pop-up-help)
      (define-key map "\C-h" 'sm-pop-up-help))
    map))

;; Set letters and digits to return from minibuffer

;;*rewrote key conditions
;;*remove \e as a key
;;*separated \C-d and \C-g
;;*where: \C-d for backing up one menu level
;;*       \C-g for aborting simple-menu

(defun sm-read-char-from-minibuffer (prompt)
  "Read input char for menu selection from minibuffer."
  (read-from-minibuffer prompt nil sm-select-item-map)
  (cond ;; for backing up one menu level
        (  (eq last-input-event ?\C-d)
           'pop-level)
        ;; for aborting menu (i.e. quit menu)
        (  (eq last-input-event ?\C-g)
           'abort)
        ;; for emacs 18.*
        (  (or (eq last-input-event ?\r)(eq last-input-event ?\n)
               (eq last-input-event ?\t)(eq last-input-event 'return))
           'default)
        (t last-input-event)) )

;; replaced in 1.4
;; (defun sm-read-char-from-minibuffer (prompt)
;;   (read-from-minibuffer prompt nil sm-select-item-map)
;;   (if (or (eq last-input-event ?\e) (eq last-input-event ?\C-g))
;;       'abort
;;     (if (or ;; for emacs 18.*
;;             (eq last-input-event ?\r) (eq last-input-event ?\n)
;; 	    (eq last-input-event ?\t)
;;             (eq last-input-event 'return))
;; 	'default
;;       last-input-event)))

(defvar sm-current-menu nil
  ;; Needed so sm-pop-up-help can find the right documentation
  "The current menu being run.")

(defvar sm-current-buffer nil
  ;; Needed so sm-find-binding can use the right keymap
  "Name of the buffer from which `sm-run-menu' was called.")

;; * changes by R. Ong, 6/94
;; prompt is the initial prompt
;; full prompt is what is actually shown to the user, includes choices
;; amenu is an atom.  Not necessary on top level, but this function
;; can be called recursively on the object of an item, which will be an atom.
(defun sm-run-menu (amenu &optional default)
  "Present AMENU.  DEFAULT will be selected on a CR."
  ;; get & present the prompt
  (if (= (length (symbol-value amenu)) 1)
      (sm-eval-single-menu amenu)
    (let* ((full-prompt (get amenu 'full-prompt))
           (items (symbol-value amenu))
           (sm-run-menu-flag t)
           results
           (the-prompt)
           (last-selection (get amenu 'last-selection))
           (string-default (cond (  (stringp default) default)
                                 (  (and default (symbolp default))
                                    (prin1-to-string default))
                                 (  last-selection
                                    (setq default t)
                                    (char-to-string last-selection))
                                 (t "")))
           opt) ;; FIXME: Should it be `default' initially?
      (setq sm-run-menu-flag t)
      (setq results nil)
      (if full-prompt
          (setq the-prompt (format full-prompt string-default))
        ;;*removed code for evaluating raw-prompt
        (setq the-prompt (sm-eval-raw-prompt amenu items string-default)))
      ;; read it in & process char choice
      (if sm-current-menu (error "A menu is already running!"))
      ;;*added a while loop to make simple-menu back up,
      ;;*it also loops when no default option exist, and
      ;;*when user type a non-existing option
      (while sm-run-menu-flag
        ;; (setq aa (cons (cons sm-run-menu-flag opt) aa))
        ;; if the user aborts while reading, be sure to clean up
        (unwind-protect
            (progn
	      (setq sm-current-menu amenu)
	      (setq sm-current-buffer (current-buffer))
	      (setq opt (sm-read-char-from-minibuffer the-prompt)))
          (setq sm-current-menu nil))
        ;; (message "about to get results for %s" opt) (sit-for 1)
        (cond ;;*for backing one level up
         (  (eq opt 'pop-level)
            (setq sm-run-menu-flag nil))
         ;;*quit simple-menu
         (  (eq opt 'abort)
            (setq sm-run-menu-flag nil)
            (sm-quit) )
         ;;*accept default option and evaluate
         (  (and (eq opt 'default) default)
            (setq opt (string-to-char string-default))
            (setq opt (downcase opt))
            (setq results (sm-eval-menu amenu opt)))
         ;;*no default option available
         (  (and (eq opt 'default) (not default))
            (message "No default - no action taken.")
            (beep))
         ;;*evaluate option
         (t (setq opt (downcase opt))
            (setq results (sm-eval-menu amenu opt)))))
      results )))

;; Created this function to reduce the length of sm-run-menu code -RO 6/94
(defun sm-eval-raw-prompt (amenu items string-default)
 "This makes a full prompt, & saves it for later use."
 (let ((raw-prompt (get amenu 'prompt-header))
       ;; (full-prompt (get amenu 'full-prompt))
       (prompt))
      (setq prompt
            (cond ;; it is something to be eval
                  (  (listp raw-prompt)
                     (eval raw-prompt))
                  ;; it is a function
                  (  (and (symbolp raw-prompt) (fboundp raw-prompt))
                     (funcall raw-prompt))
                  ;; it is a string
                  (  (stringp raw-prompt)
                     (if (not (string= raw-prompt ""))
                         (concat raw-prompt ": ")
                       raw-prompt))
                  ;; it is an invalid prompt
                  (t (sm-error (format "%s contains an invalid prompt." amenu)))))
      (mapc (lambda (x) (setq prompt (concat prompt x " ")))
            (mapcar #'sm-first-word items))
      (setq prompt (concat prompt sm-help-string
                           sm-default-string))
      (if (stringp raw-prompt)
          (put amenu 'full-prompt prompt))
      (format prompt string-default) ))

(defun sm-error (error-string)
  (save-excursion
    (pop-to-buffer (get-buffer-create "*SM-Errors*"))
    (goto-char 0)
    (insert error-string "\n\n"))
  (display-buffer "*SM-Errors*"))



;;;
;;; 	IV. 	Helper functions
;;;

(defun sm-clear-menu (name)
  "Completely clears out a menu.  Used only for debugging new menus."
  (put name 'items nil)
  (set name nil)
  (put name 'prompt-header nil)
  (put name 'raw-prompt nil)
  (put name 'full-prompt nil)
  (put name 'help-prompt nil)
  (put name 'last-selection nil)
  (makunbound name) )

(defun sm-eval-menu (amenu opt)
 "Find in AMENU the command corresponding to OPT, the char the user typed."
 (let ( (items (symbol-value amenu))
        (sm--current-key-map (current-local-map))
        (command nil)
        (results))
   (while items
      (let ((item (pop items)))
        (if (and (cl-third item) (= opt (cl-third item)))
            (progn (setq items nil)
                   (setq command (cl-second item))
                   (put amenu 'last-selection opt)
                   (setq results (sm-eval-command-item command))))))
   (if (not command) ; no match
       (progn (message "%c did not match a menu name" opt)
              (beep)))
  results) )

(defun sm-eval-single-menu (amenu)
  "Run in AMENU the single only command."
  ;;*removed checking if no option match
  ;;*since it is not possible to make a choice (i.e. an option)
  ;;*because only one menu item is to be run
  (let* ( (item (cl-first (symbol-value amenu)))
          (command (cl-second item))
          (sm--current-key-map (current-local-map)) )
    (sm-eval-command-item command)) )

;;*created this function for sm-eval-menu and sm-eval-single-menu
;;*as shared code
(defun sm-eval-command-item (command)
 "Evaluate the command (i.e. second item) of a menu item."
 (cond ;; it is another menu
       ;;*made additional checks for determining if command is another menu
       (  (and (symbolp command)
               (boundp  command)
               (consp (symbol-value command)))
          (sm-run-menu command))
       ;; it is a command
       (  (and (not (listp command))
               (symbolp command)
               (fboundp command))
          (call-interactively command)
          (setq sm-run-menu-flag nil)
          ;; (sm-quit)
          )
       ;;*removing this function call because key bindings
       ;;*could be easily seen in the help screen
       ;;*(sm-note-function-key command sm--current-key-map))
       ;; it is something to eval
       (  (listp command)
          (setq sm-run-menu-flag nil)
          (eval command)
          ;; (sm-quit)
          )
       ;; something to be returned
       (  (or (stringp command) (numberp command))
          command)
       ;; something different
       (t (error (format "%s is a BAD MENU ITEM." command))) ))

;; (defun sm-eval-menu (amenu opt)
;;  "Find in AMENU the command corresponding to OPT, the char the user typed."
;;  (let ( (items (symbol-value amenu)) results
;;         (sm--current-key-map (current-local-map))
;;         (command nil) )
;;   (while items
;;      (setq item (pop items))
;;      (cond ( (and (null (cl-third item))
;;                   (= opt (cl-second item)))
;;              (setq command t)
;;              (error "Menu item \"%c\" not implemented yet." opt))
;;            ( (and (cl-third item) (= opt (cl-third item)))
;;              (setq items nil)
;;              (setq command (cl-second item))
;; 	     (put amenu 'last-selection opt)
;;              (setq results
;;                (cond ;; something to be returned
;;                      ((or (stringp command) (numberp command))
;;                       command)
;;                      ;; its a command
;;                      ((and (not (listp command)) (fboundp command))
;;                       (call-interactively command)
;;                       (sm-note-function-key command sm--current-key-map))
;;                      ;; it is something to eval
;;                      ((listp command)
;;                       (eval command))
;;                      ((or (not (boundp command)) (not (eval command))
;;                           (not (listp (eval command))))
;;                       command)
;;                      ;; it is another menu, you hope...
;;                      (t (sm-run-menu command)))))))
;;   (if (not command) ; no match
;;       (progn (message "%c did not match a menu name" opt)
;;              (beep))) ; note that we lost
;;   results))
;;
;; (defun sm-eval-single-menu (amenu)
;;  "Run in AMENU the single only command."
;;  (let* ( (item (cl-first (symbol-value amenu)))
;;          (command (cl-second item))
;;          (sm--current-key-map (current-local-map)) )
;;    (cond ;; its a command
;;         ((and (not (listp command))
;;               (fboundp command))
;;          (call-interactively command)
;;          (sm-note-function-key command sm--current-key-map))
;;         ;; it is something to eval
;;         ((listp command)
;;          (eval command))
;;         ;; it is another menu, you hope...
;;         (t (sm-run-menu command)))
;;    (if (not command) ; no match
;;        (progn (message "%c did not match a menu name" opt)
;;               (beep)))     ;note we lost
;; ))

(defun sm-make-help (help-header name items)
 "Make a help string for a simple menu."
 (let ((result ""))
   (setq result
         (concat result
                 (if (string= "" help-header)
                     (format "%s %s:\n\n" sm-default-help-header name)
                   (concat help-header ":\n\n"))))
   (setq result (concat result (sm-make-help-body items)
                        "\n " sm-default-help-for-help
                        "\n " sm-default-help-footer))
   result) )

;;*created this function to construct the body of a help screen
;;*recursive procedure to run through each menu item
(defun sm-make-help-body (items)
 "Make a help string body for a simple menu."
 (if (null items)
     nil
   (let* ((item (car items))
          (bind-thing (sm-find-binding (car (cdr item))))
          (result "")
          (help-string (car item))  )
         (setq result (format "%s %s " result help-string))
         (if bind-thing
             (if (> (+ (length bind-thing) (length help-string)) fill-column)
                 (setq result (format "%s\n\t\t\t (%s)" result bind-thing))
               (setq result (format "%s (%s)" result bind-thing))))
         (concat result "\n" (sm-make-help-body (cdr items)))) ))


;; ;; bug fixed in here, found by 19.
;; (defun sm-make-help (help-header name items)
;;  "Make a help string for a simple menu."
;;  ;; this is a bit sloppy about how to make it....
;;  (let ((header nil) (result ""))
;;   (setq result
;;         (concat result
;;                (cond ((string= "" help-header)
;;                       (format "%s %s\n\n" sm-default-help-header name))
;;                      (t (concat help-header ":\n\n")))))
;;   (mapc
;;      (function
;;        (lambda (x)
;;           (let ((bind-thing (sm-find-binding (car (cdr x))))
;;                 (help-string (car x)) )
;;            (setq result (format "%s %s " result help-string))
;;            (if bind-thing
;;                (if (> (+ (length bind-thing) (length help-string)) fill-column)
;;                    (setq result
;;                          (format "%s\n\t\t\t (%s)" result bind-thing))
;;                    (setq result
;;                          (format "%s (%s)" result bind-thing))))
;;            (setq result (concat result "\n"))           )))
;;       items)
;;   (setq result (concat result "\n " sm-default-help-for-help
;;                               "\n " sm-default-help-footer))
;;   result))

(defun sm-find-binding (function &optional map)
  "Find keystroke binding of FUNCTION, looking at optional MAP
or the current-local-map."
  (if (and function (not (symbolp function)))
      nil
    (if (sm-menu-p function) nil
      (if (not map)
	  (setq map
		(with-current-buffer (or sm-current-buffer (current-buffer))
		  (current-local-map))))
      (substitute-command-keys
       (concat "\\<map>\\[" (symbol-name function) "\]")))))

(defun sm-menu-ized-items (items)
  "Strip the first letter off and make it the third item for ease and speed."
  (let* ((all-sm-first-letter (sm-first-letter-items items))
         (all-menu-letter (sm-first-letter-tidy all-sm-first-letter))
         (first-menu-letter))
    (mapcar (lambda (x)
              (setq first-menu-letter (sm-first-letter x))
              ;;*check if first letter of menu item has duplicate,
              ;;*and if menu item is valid (i.e., good)
              (if (and (member first-menu-letter all-menu-letter)
                       (sm-setup-menu-item x))
                  (progn
                    (setq all-menu-letter
                          (sm-remove-menu-item-letter first-menu-letter
                                                      all-menu-letter))
                    (append (sm-setup-menu-item x)
                            (list (string-to-char first-menu-letter))))
                (sm-error
                 (format "BAD MENU ITEM (doubled use of initial letter?): %s."
                         x))))
            items) ))

(defun sm-setup-menu-item (x)
 "Setup the menu item X, which should have a string and symbol or listp.
  If it doesn't, add a dummy function call."
 (let ((value (car (cdr x))))
;;*interchange the first 2 conditions
    (cond ;; given a null function
          (  (and (listp x)
                  (stringp (car x))
          ;;*change (car (cdr x)) to value
                  (null value))
             (append x (list sm-default-function)))
          (  (and (listp x)
                  (stringp (car x))
;;*made additional check for second item of a menu item
;;*but it is possible to remove the 'or' clause iff the only
;;*conditions that would make a bad menu item are
;;*(x is not a list) and ((car x) is not a string)
                  (or (stringp value) (numberp value)
                      (symbolp value) (listp value)))
             x)
          (t nil)) ))

;; (defun sm-setup-menu-item (x)
;;  "Setup the menu item X, which should have a string and symbol or listp.
;; If it doesn't, add a dummy function call."
;;  (let ((value (car (cdr x))))
;;  (cond ( (and (listp x)
;;               (stringp (car x))
;;               (or (symbolp value)
;;                   (stringp value)
;;                   (listp value)))
;;           x)
;;        ( (and (listp x)         ;given a null function
;;               (stringp (car x))
;;               (null value))
;;          (append x (list sm-default-function)))
;;        (t (error "Bad menu item: %s" x)))))

(defun sm-pop-up-help ()
  "Display help for the current menu."
  (interactive)
  (let ((menu sm-current-menu))
    (cond (  menu
             (put menu 'help (sm-make-help (get menu 'help-header)
		  		           menu
				           (get menu 'items)))
             (with-output-to-temp-buffer sm-help-buffer
               (princ (cond (  (get menu 'help))
		            ;; these had been switched to save cycles, but
		            ;; it looks like some menus are buffer sensitive
		            (t "not documented")))))
          (t (error "No menu running!"))) ))

;; (defun sm-pop-up-help ()
;;   "Display help for the current menu."
;;   (interactive)
;;   (let ((menu sm-current-menu))
;;     (if (not menu)
;;         (error "No menu running!"))
;;     (with-output-to-temp-buffer sm-help-buffer
;;       (princ (cond ((get menu 'help))
;; 		   ((put menu 'help
;; 			 (sm-make-help (get menu 'help-header)
;; 				       menu
;; 				       (get menu 'items))))
;; 		   ;; these had been switched to save cycles, but
;; 		   ;; it looks like some menus are buffer sensative
;; 		   (t "not documented"))))))

(defun sm-note-function-key (command keymap)
 "Note to the user any keybindings for Command."
 (let ( (key-binding (sm-find-binding command keymap)) )
  (if key-binding
      (progn
        (message "%s is also bound to \"%s\"."
                 command key-binding)
        ;; (sit-for dis-show-keybinding-time)
      )      ) ))


;;; HISTORY:
;; 1-3-97 - included defsubst, and cleaned up a bit.  version 1.7
;; 30-Aug-94 incorporated numerous changes by Roberto Ong.
;;           Can now backup a level.  Duplicate initial letters are caught.
;;           Generally cleaner and more robust code.
;;           * changes by R. Ong, 6/94
;; 8-10-93 - FER  fixed sm-read-char-from-minibuffer to read a return f/ 19.
;; 18-Nov-92 -DMS Simplified (and generalized) sm-find-binding, which
;;           now gives bindings in the same form as C-h w. Item selection
;;           is now done with the minibuffer instead of 'read-char, so
;;           you can scroll the help window, for example. Help pop-ups
;;           use 'with-output-to-temp-buffer, so works well with the
;;           popper package. If no default is specified, the last selection
;;           is provided as the default. def-menu now works like defvar,
;;           i.e. does nothing if the symbol is already bound. sm-clear-menu
;;           also makes its symbol unbound (so def-menu will then work).
;; Version 1.3 (not yet released)
;;  9-Sep-92 -FER no longer saves menu help, found to be buffer sensitive.
;;  9-Sep-92 -FER fixed bug if given nil commands.
;; 13-Jul-92 -FER replaced CR with \n
;; 18-Mar-92 -FER fixed default usage, added bytecomp information.
;; 12-Feb-92 -FER more robust in allowing user to move in pop-up help.
;; 11-Feb-92 -FER added optional default to running a menu.
;; 13-Jan-92 -FER added sm-clear-menu, and now run-menu returns values
;; 19-Nov-91 -FER added variable prompts
;;                f/ Christopher fernand@SPUNKY.CS.NYU.EDU
;; 28-Oct-91 release 1.2 to elisp archive  -FER
;;  3-oct-91 -FER TAB and M- replace "   " and ^[ in full help descriptions.
;; 16-Sep-91 -FER better help display
;; 6-12-91 - unbelievably better key search in sm-find-binding
;; 6-11-91 - even more robust key search in sm-find-binding
;; 6-10-91 - more robust key search in sm-find-binding
;; Version 1.1
;; 6-5-91 - added ability to show esc-x commands in help
;; 5-27-91 - added ability to show esc-x commands after command completion
;; 2 may 91 added (require 'cl) reported by dfreuden@govt.shearson.com,
;;   ne201ph@prism.gatech.edu (Halvorson,Peter J), rayv@revenge.sps.mot.com
;;   (Ray Voith), & Sara.Kalvala@computer-lab.cambridge.ac.uk
;; 30 may 91 - posted to gnu.emacs.sources version 1.0

(provide 'simple-menu)
;;; simple-menu.el ends here
