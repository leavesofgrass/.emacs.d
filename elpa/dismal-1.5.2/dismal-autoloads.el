;;; dismal-autoloads.el --- automatically extracted autoloads (do not edit)   -*- lexical-binding: t -*-
;; Generated by the `loaddefs-generate' function.

;; This file is part of GNU Emacs.

;;; Code:

(add-to-list 'load-path (or (and load-file-name (file-name-directory load-file-name)) (car load-path)))



;;; Generated autoloads from auto-aligner.el

(register-definition-prefixes "auto-aligner" '("dis-"))


;;; Generated autoloads from dismal.el

(add-to-list 'auto-mode-alist '("\\.dis\\'" . dismal-mode))
(autoload 'dismal-mode "dismal" "\
A major mode for editing SpreadSheets.
A command menu is available by typing C-c C-m (C-m is also RET).
\\[dis-copy-to-dismal] will paste text from another buffer into dismal.
The left mouse button is bound to `dis-mouse-highlight-cell-or-range'
and right mouse button is bound to `dis-mouse-highlight-row'.

 Special commands:
\\{dismal-map}

 Special commands:
\\{dismal-minibuffer-map}
" t)
(register-definition-prefixes "dismal" '("dis"))


;;; Generated autoloads from dismal-data-structures.el

(register-definition-prefixes "dismal-data-structures" '("dis"))


;;; Generated autoloads from dismal-menu3.el

(register-definition-prefixes "dismal-menu3" '("dis"))


;;; Generated autoloads from dismal-metacolumn.el

(register-definition-prefixes "dismal-metacolumn" '("dis"))


;;; Generated autoloads from dismal-model-extensions.el

(register-definition-prefixes "dismal-model-extensions" '("dis-model-match"))


;;; Generated autoloads from dismal-mouse3.el

(register-definition-prefixes "dismal-mouse3" '("dis"))


;;; Generated autoloads from dismal-simple-menus.el

(register-definition-prefixes "dismal-simple-menus" '("dis-run-menu"))


;;; Generated autoloads from heaps.el

(register-definition-prefixes "heaps" '("heap-"))


;;; Generated autoloads from keystroke.el

(register-definition-prefixes "keystroke" '("klm-"))


;;; Generated autoloads from log.el

(defvar log-session-mode nil "\
Non-nil if Log-Session mode is enabled.
See the `log-session-mode' command
for a description of this minor mode.
Setting this variable directly does not take effect;
either customize it (see the info node `Easy Customization')
or call the function `log-session-mode'.")
(custom-autoload 'log-session-mode "log" nil)
(autoload 'log-session-mode "log" "\
Minor mode to log a session (keystrokes, timestamps etc).

This is a global minor mode.  If called interactively, toggle the
`Log-Session mode' mode.  If the prefix argument is positive,
enable the mode, and if it is zero or negative, disable the mode.

If called from Lisp, toggle the mode if ARG is `toggle'.  Enable
the mode if ARG is nil, omitted, or is a positive number.
Disable the mode if ARG is a negative number.

To check whether the minor mode is enabled in the current buffer,
evaluate `(default-value \\='log-session-mode)'.

The mode's hook is called both when the mode is enabled and when
it is disabled.

(fn &optional ARG)" t)
(register-definition-prefixes "log" '("*log-" "log-"))


;;; Generated autoloads from make-km-aliases.el

(register-definition-prefixes "make-km-aliases" '("dismal-"))


;;; Generated autoloads from rmatrix.el

(register-definition-prefixes "rmatrix" '("matrix-"))


;;; Generated autoloads from semi-coder.el

(register-definition-prefixes "semi-coder" '("dis-"))


;;; Generated autoloads from simple-menu.el

(register-definition-prefixes "simple-menu" '("sm-"))


;;; Generated autoloads from vectors.el

(register-definition-prefixes "vectors" '("vec"))

;;; End of scraped data

(provide 'dismal-autoloads)

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; no-native-compile: t
;; coding: utf-8-emacs-unix
;; End:

;;; dismal-autoloads.el ends here