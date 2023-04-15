;;; js2-refactor-autoloads.el --- automatically extracted autoloads (do not edit)   -*- lexical-binding: t -*-
;; Generated by the `loaddefs-generate' function.

;; This file is part of GNU Emacs.

;;; Code:

(add-to-list 'load-path (or (and load-file-name (file-name-directory load-file-name)) (car load-path)))



;;; Generated autoloads from js2-refactor.el

(autoload 'js2-refactor-mode "js2-refactor" "\
Minor mode providing JavaScript refactorings.

This is a minor mode.  If called interactively, toggle the
`Js2-Refactor mode' mode.  If the prefix argument is positive,
enable the mode, and if it is zero or negative, disable the mode.

If called from Lisp, toggle the mode if ARG is `toggle'.  Enable
the mode if ARG is nil, omitted, or is a positive number.
Disable the mode if ARG is a negative number.

To check whether the minor mode is enabled in the current buffer,
evaluate `js2-refactor-mode'.

The mode's hook is called both when the mode is enabled and when
it is disabled.

(fn &optional ARG)" t)
(autoload 'js2r-add-keybindings-with-prefix "js2-refactor" "\
Add js2r keybindings using the prefix PREFIX.

(fn PREFIX)")
(autoload 'js2r-add-keybindings-with-modifier "js2-refactor" "\
Add js2r keybindings using the modifier MODIFIER.

(fn MODIFIER)")
(register-definition-prefixes "js2-refactor" '("js2"))


;;; Generated autoloads from js2r-conditionals.el

(register-definition-prefixes "js2r-conditionals" '("js2r-ternary-to-if"))


;;; Generated autoloads from js2r-conveniences.el

(register-definition-prefixes "js2r-conveniences" '("js2r-" "move-line-"))


;;; Generated autoloads from js2r-formatting.el

(register-definition-prefixes "js2r-formatting" '("js2r-"))


;;; Generated autoloads from js2r-functions.el

(register-definition-prefixes "js2r-functions" '("js2r-"))


;;; Generated autoloads from js2r-helpers.el

(register-definition-prefixes "js2r-helpers" '("js2r--"))


;;; Generated autoloads from js2r-iife.el

(register-definition-prefixes "js2r-iife" '("js2r-"))


;;; Generated autoloads from js2r-paredit.el

(register-definition-prefixes "js2r-paredit" '("js2r-"))


;;; Generated autoloads from js2r-vars.el

(autoload 'js2r-rename-var "js2r-vars" "\
Renames the variable on point and all occurrences in its lexical scope." t)
(autoload 'js2r-extract-var "js2r-vars" nil t)
(autoload 'js2r-extract-let "js2r-vars" nil t)
(autoload 'js2r-extract-const "js2r-vars" nil t)
(register-definition-prefixes "js2r-vars" '("current-line-contents" "js2r-"))


;;; Generated autoloads from js2r-wrapping.el

(register-definition-prefixes "js2r-wrapping" '("js2r-"))

;;; End of scraped data

(provide 'js2-refactor-autoloads)

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; no-native-compile: t
;; coding: utf-8-emacs-unix
;; End:

;;; js2-refactor-autoloads.el ends here