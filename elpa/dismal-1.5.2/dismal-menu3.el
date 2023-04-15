;;; dismal-menu3.el --- Menu system for using with Dismal spreadsheet

;; Copyright (C) 2013-2021  Free Software Foundation, Inc.

;; Author: Nigel Jenkins, nej@cs.nott.ac.uk
;;                        lpyjnej@psyc.nott.ac.uk 
;; Created-On: 15th March 1996

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

;;	I.	Set up of menu ready for use in Dismal-mode buffer


;; (define-key dismal-mode-map [menu-bar edit] ())
;; (define-key dismal-mode-map [menu-bar file] ())

;; now done with the local map
;; Check if already in dismal-mode to put the correct menu up
;;(if (equal major-mode 'dismal-mode)
;;      (use-global-map dis-global-map)
;;    (use-global-map global-map))

;;; Code:

(require 'make-km-aliases)

(defvar dismal-menu-map (make-sparse-keymap))

(define-key dismal-menu-map [model]
  (cons "dModel" (make-sparse-keymap "Model")))

(define-key dismal-menu-map [model Utils]
  '("Utils" . dis-utils-menu))
(define-key dismal-menu-map [model Stats]
  '("Stats" . dis-stat))
(define-key dismal-menu-map [model Codes]
  '("Codes" . dis-code))
(define-key dismal-menu-map [model KLM]
  '("KL model" . dis-klm))


;; UTILS pop-up-menu
(defvar dis-utils-menu
  (let ((map (make-sparse-keymap "Utilities")))
    ;; This is a common idiom.  It makes the keymap available as a function 
    ;; call, somehow.  It is done for all the submenus.
    (fset 'dis-utils map)

    (define-key map [auto-align2]
      '("Auto-Align2" . dis-align-columns))
    (define-key map [auto-align]
      '("Auto-Align" . dis-auto-align-model))
    map))


;; STATS pop-up-menu
(defvar dis-stat-menu
  (let ((map (make-sparse-keymap "Statistics")))
    (fset 'dis-stat map)

    (define-key map [stats]
      '("Print Statistics (not defined yet)" . undefined))
    (define-key map [count]
      '("Count Codes (not defined yet)" . undefined))
    map))


;; CODES pop-up-menu
(defvar dis-code-menu
  (let ((map (make-sparse-keymap "Codes")))
    (fset 'dis-code map)

    (define-key map [init]
      '("Initialize" . dis-initialize-operator-codes))
    (define-key map [load]
      '("Load" . dis-load-op-codes))
    (define-key map [code]
      '("Code" . dis-op-code-segment))
    (define-key map [save]
      '("Save" . dis-save-op-code))
    map))

;; KLM pop-up-menu
(defvar dis-klm-menu
  (let ((map (make-sparse-keymap "KLM")))
    (fset 'dis-klm map)

    (define-key map [init]
      '("Initialize" . dismal-init-make-aliases))
    (define-key map [dups]
      '("Display dups" . dismal-display-dup-aliases))
    map))


;;;
;;;	II.b	 OPTIONS item on menu-bar and all sub-menus
;;;

(define-key dismal-menu-map [options]
  (cons "dOpts" (make-sparse-keymap "Dis Options")))

(define-key dismal-menu-map [options zrange]
  '("Redraw Range" . dis-redraw-range))
(define-key dismal-menu-map [options ruler-redraw]
  '("Ruler Redraw" . dis-update-ruler))
(define-key dismal-menu-map [options row-redraw]
  '("Redraw Row" . dis-hard-redraw-row))
(define-key dismal-menu-map [options column-redraw]
  '("Redraw Column" . dis-redraw-column))
(define-key dismal-menu-map [options screen-redraw]
  '("Redraw Screen" . dis-redraw))
(define-key dismal-menu-map [options set-vari-menu]
  '("Set dismal Variables" . dis-setv))

;; SetV pop-up-menu

(defvar dis-setv-menu
  (let ((map (make-sparse-keymap "Set Variables")))
    (fset 'dis-setv map)

    (define-key map [middle-col]
      '("Middle Column" . dis-set-metacolumn))
    (define-key map [auto-update]
      '("Auto Update" . dis-toggle-auto-update))
    (define-key map [2ruler]
      '("Toggle Ruler" . dis-set-ruler))
    (define-key map [ruler-row]
      '("Ruler Row" . dis-set-ruler-rows))
    (define-key map [auto-update]
      '("Show update" . dis-toggle-show-update))
    map))
;; changed to ruler-rowS, 25-May-96 -FER



;;;
;;;	II.c	DOC item on menu-bar and all sub-menus
;;;

(define-key dismal-menu-map [doc.]
  (cons "dDoc" (make-sparse-keymap "Dis Doc")))

(define-key dismal-menu-map [doc. show]
  '("Full Dismal Documentation" . dis-open-dis-manual))
(define-key dismal-menu-map [doc. about]
  '("About Dismal mode" . describe-mode))

(defun dis-open-dis-manual ()
  (interactive)
  (info "(dismal)"))


;;;
;;;	II.d	FORMAT item on menu-bar and all sub-menus
;;;

(define-key dismal-menu-map [format]
  (cons "dFormat" (make-sparse-keymap "Dis Format")))

(define-key dismal-menu-map [format update-r]
  '("Update Ruler" . dis-update-ruler))
(define-key dismal-menu-map [format fonts]
  '("Set Font" .  mouse-set-font))
(define-key dismal-menu-map [format auto-width]
  '("Automatic Width" . dis-auto-column-width))
(define-key dismal-menu-map [format width]
  '("Set Col Width" . dis-read-column-width))
(define-key dismal-menu-map [format align]
  '("Alignment" . dis-set-alignment))
(define-key dismal-menu-map [format number]
  '("Decimal width" . dis-set-column-decimal))


;; (fset 'msf 'mouse-set-font)
;; (msf)
;; (mouse-set-font x-fixed-font-alist)
;; (call-interactively 'mouse-set-font)


;;;
;;;	II.e	COMMANDS item on menu-bar and all sub-menus
;;;

(define-key dismal-menu-map [commands]
  (cons "dComms" (make-sparse-keymap "Dis Commands")))

(define-key dismal-menu-map [commands 0log]
  '("Logging-Off" . log-quit))
(define-key dismal-menu-map [commands 1log]
  '("Logging-On" . log-session-mode))
(define-key dismal-menu-map [commands deblnk]
  '("Del Blank Rows" . dis-delete-blank-rows))
(define-key dismal-menu-map [commands qrep]
  '("Query-Replace" . dis-query-replace))
(define-key dismal-menu-map [commands hupdt]
  '("Hard-Update" . dis-recalculate-matrix))
(define-key dismal-menu-map [commands updt]
  '("Update" . dis-update-matrix))
(define-key dismal-menu-map [commands lisfns]
  '("List dismal user functions" . dis-show-functions))
(define-key dismal-menu-map [commands filrng]
  '("Fill Range" . dis-fill-range))
(define-key dismal-menu-map [commands expand]
  '("Expand hidden cols in range" . dis-expand-cols-in-range))
(define-key dismal-menu-map [commands redrw]
  '("Redraw Display" . dis-redraw))
;;(define-key dismal-menu-map [commands dep-clean]
;;  '("Dependencies-clean" . dis-fix-dependencies))
(define-key dismal-menu-map [commands cp2dis]
  '("Copy text into Dismal" . dis-copy-to-dismal))
(define-key dismal-menu-map [commands align]
  '("Align Metacolumns" . dis-align-metacolumns))


;;;
;;;	II.f	GO item on menu-bar and all sub-menus
;;;

(define-key dismal-menu-map [go]
  (cons "dGo" (make-sparse-keymap "Dis Go")))
(define-key dismal-menu-map [go Jump]
  '("Jump to cell>" . dis-jump))
(define-key dismal-menu-map [go End]
  '("End of sheet" . dis-end-of-buffer))
(define-key dismal-menu-map [go Begin]
  '("Beginning of sheet" . dis-beginning-of-buffer))

;; These either don't work and/or aren't necessary
;; (define-key dismal-menu-map [go Scroll-Right]
;;   '("-->" . scroll-right))
;; (define-key dismal-menu-map [go Scroll-Left]
;;   '("<--" . scroll-left))
(define-key dismal-menu-map [go Row]
  '("Row" . dis-row))
(define-key dismal-menu-map [go Column]
  '("Column" . dis-column))


;; ROW pop-up-menu

(defvar dis-row-menu
  (let ((map (make-sparse-keymap "Row")))
    (fset 'dis-row map)

    (define-key map [back]
      '("Back a row" . dis-backward-row))
    (define-key map [forward]
      '("Forward a row" . dis-forward-row))
    (define-key map [last]
      '("Goto Last row" . dis-last-row))
    (define-key map [first]
      '("Goto First row" . dis-first-row))
    map))


;; COLUMN pop-up-menu

(defvar dis-column-menu
  (let ((map (make-sparse-keymap "Column")))
    (fset 'dis-column map)

    (define-key map [back]
      '("Back a column" . dis-backward-column))
    (define-key map [forward]
      '("Forward a column" . dis-forward-column))
    (define-key map [last]
      '("Goto Last column" . dis-end-of-col))
    (define-key map [first]
      '("Goto First column" . dis-start-of-col))
    map))


;;;
;;;	II.g	EDIT item on menu-bar and all sub-menus
;;;

;; Remove other edit, since it contains dangerous commands.
(define-key dismal-menu-map [edit] 'undefined)
(define-key dismal-menu-map [search] 'undefined)
(define-key dismal-menu-map [files] 'undefined)

(define-key dismal-menu-map [dedit]
  (cons "dEdit" (make-sparse-keymap "Dis Edit")))

(define-key dismal-menu-map [dedit modify]
  '("Modify cell justification" . dis-modify))
(define-key dismal-menu-map [dedit delete]
  '("Delete" . dis-delete))
(define-key dismal-menu-map [dedit insert]
  '("Insert" . dis-insert))
(define-key dismal-menu-map [dedit set]
  '("Edit cell" . dis-edit-cell-plain))
(define-key dismal-menu-map [dedit erase]
  '("Erase range" . dis-erase-range))
(define-key dismal-menu-map [dedit yank]
  '("Yank" . dis-paste-range))
(define-key dismal-menu-map [dedit copy]
  '("Copy range" . dis-copy-range))
(define-key dismal-menu-map [dedit kill]
  '("Kill range" . dis-kill-range))
;; (define-key dismal-menu-map [dedit undo]
;;  '("Undo" . undefined))


;; MODIFY pop-up-menu

(defvar dis-modify-menu 
  (let ((map (make-sparse-keymap "Modify")))
    (fset 'dis-modify map)

    (define-key map [e]
      '("Plain" . dis-edit-cell-plain))
    (define-key map [|]
      '("Center" . dis-edit-cell-center))
    (define-key map [=]
      '("Default" . dis-edit-cell-default))
    (define-key map [<]
      '("Left" . dis-edit-cell-leftjust))
    (define-key map [>]
      '("Right" . dis-edit-cell-rightjust))
    map))


;; DELETE pop-up-menu

(defvar dis-delete-menu
  (let ((map (make-sparse-keymap "Delete")))
    (fset 'dis-delete map)

    (define-key map [marked-range]
      '("Marked-range" . dis-delete-range))
    (define-key map [column]
      '("Column" . dis-delete-column))
    (define-key map [row]
      '("Row" . dis-delete-row))
    map))


;; INSERT pop-up-menu
(defvar dis-insert-menu
  (let ((map (make-sparse-keymap "Insert")))

    (fset 'dis-insert map)

    (define-key map [z-box]
      '("Z-Box" . dis-insert-z-box))
    (define-key map [marked-range]
      '("Marked-Range" . dis-insert-range))
    (define-key map [lcells]
      '("Cells" . dis-insert-cells))
    (define-key map [column]
      '("Column" . dis-insert-column))
    (define-key map [row]
      '("Row" . dis-insert-row))
    map))

;; SET pop-up-menu
(defvar dis-set-menu
  (let ((map (make-sparse-keymap "Set Cell Parameters")))
    (fset 'dis-set map)

    (define-key map [center]
      '("Center Justified" . dis-edit-cell-center))
    (define-key map [general]
      '("Plain" . dis-edit-cell))
    (define-key map [left]
      '("Left Justified" . dis-edit-cell-leftjust))
    (define-key map [right]
      '("Right Justified" . dis-edit-cell-rightjust))
    map))


;;;
;;;	II.h	File item on menu-bar and all sub-menus
;;;
;; These are pushed on, it appears.

(define-key dismal-menu-map [Dfile]
  (cons "dFile" (make-sparse-keymap "Dis File")))

(define-key dismal-menu-map [Dfile Quit]
  '("Kill current buffer" . kill-buffer))
(define-key dismal-menu-map [Dfile Unpage]
  '("Unpaginate dismal report" . dis-unpaginate))

(define-key dismal-menu-map [Dfile TeXdump1]
  '("TeX Dump file (raw)" . dis-tex-dump-range))
(define-key dismal-menu-map [Dfile TeXdump2]
  '("TeX Dump file (with TeX header)" . dis-tex-dump-range-file))

(define-key dismal-menu-map [Dfile htmldumprange]
  '("Dump range as HTML table" . dis-html-dump-range))
(define-key dismal-menu-map [Dfile htmldumpfile]
  '("Dump file as HTML table" . dis-html-dump-file))

(define-key dismal-menu-map [Dfile Rdump]
  '("Range-Dump (tabbed)" . dis-dump-range))
(define-key dismal-menu-map [Dfile Tdump]
  '("Tabbed-Dump file" . dis-write-tabbed-file))

(define-key dismal-menu-map [Dfile PPrin]
  '("Paper-Print" . dis-print-report))
(define-key dismal-menu-map [Dfile FPrin]
  '("File-Print" . dis-make-report))
(define-key dismal-menu-map [Dfile 2Prin]
  '("Print Setup" . dis-print-setup))
(define-key dismal-menu-map [Dfile insert-file]
  '("Insert File..." . dis-insert-file))
(define-key dismal-menu-map [Dfile Write]
  '("Save buffer as..." . dis-write-file))
(define-key dismal-menu-map [Dfile Save]
  '("Save" . dis-save-file))
(define-key dismal-menu-map [Dfile Open]
  '("Open file" . find-file))
(define-key dismal-menu-map [Dfile New]
  '("New sheet" . dis-find-file))

(provide 'dismal-menu3)
;;; dismal-menu3.el ends here
