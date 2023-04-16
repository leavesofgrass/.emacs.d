;;; auto-correct-autoloads.el --- automatically extracted autoloads (do not edit)   -*- lexical-binding: t -*-
;; Generated by the `loaddefs-generate' function.

;; This file is part of GNU Emacs.

;;; Code:

(add-to-list 'load-path (or (and load-file-name (file-name-directory load-file-name)) (car load-path)))



;;; Generated autoloads from auto-correct.el

(defvar auto-correct-mode nil "\
Non-nil if Auto-Correct mode is enabled.
See the `auto-correct-mode' command
for a description of this minor mode.")
(custom-autoload 'auto-correct-mode "auto-correct" nil)
(autoload 'auto-correct-mode "auto-correct" "\
Activate automatic corrections.

Auto correct expansions will only work when this mode is enabled,
but auto-correct can be trained with `auto-correct-fix-and-add'
even if this mode is disabled.

When this mode is enabled, corrections made with flyspell and
Ispell will be made automatically after fixing them once.

In order to add corrections to the auto-correct abbrev table in
flyspell (and thus have them corrected later), set
`flyspell-use-global-abbrev-table-p' to non-nil.

In order to set corrections as local using Ispell, use
the command `auto-correct-toggle-ispell-local'.

\\{auto-correct-mode-map}

This is a global minor mode.  If called interactively, toggle the
`Auto-Correct mode' mode.  If the prefix argument is positive,
enable the mode, and if it is zero or negative, disable the mode.

If called from Lisp, toggle the mode if ARG is `toggle'.  Enable
the mode if ARG is nil, omitted, or is a positive number.
Disable the mode if ARG is a negative number.

To check whether the minor mode is enabled in the current buffer,
evaluate `(default-value \\='auto-correct-mode)'.

The mode's hook is called both when the mode is enabled and when
it is disabled.

(fn &optional ARG)" t)
(autoload 'auto-correct-fix-and-add "auto-correct" "\
Use `ispell-word' to fix a misspelled word at point.

Once the misspelled word is fixed, auto-correct will remember the
fix and auto-correct it from then on, so long as
`auto-correct-mode' is enabled.

With a non-nil argument LOCAL (interactively, the prefix argument),
create a fix for the typo that will be auto-corrected for buffers
using the current local mode.

This is pointless to use when `auto-correct-mode' is enabled;
instead, use `ispell-word' and `auto-correct-toggle-ispell-local'
to use the local abbrev table.

(fn LOCAL)" t)
(autoload 'auto-correct-scan-buffer "auto-correct" "\
Scan current buffer for misspelled words.

When a misspelled word is found, offer to correct the misspelled
word and auto-correct the typo in the future.

When `auto-correct-mode' is enabled, use the `ispell' command
instead." t)
(autoload 'auto-correct-scan-region "auto-correct" "\
Scan the region between START and END for misspelled words.

Interactively, START and END are the current region.

When a misspelled word is found, offer to correct the misspelled
word and auto-correct the typo in the future.

When `auto-correct-mode' is enabled, use the `ispell' command
instead.

(fn START END)" t)
(autoload 'auto-correct-scan "auto-correct" "\
Scan the buffer or region for misspelled words.

When a misspelled word is found, offer to correct the misspelled
word and auto-correct the typo in the future.

When `auto-correct-mode' is enabled, use the `ispell' command
instead." t)
(register-definition-prefixes "auto-correct" '("auto-correct-"))

;;; End of scraped data

(provide 'auto-correct-autoloads)

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; no-native-compile: t
;; coding: utf-8-emacs-unix
;; End:

;;; auto-correct-autoloads.el ends here
