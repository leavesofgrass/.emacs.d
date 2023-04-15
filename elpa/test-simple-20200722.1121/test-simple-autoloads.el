;;; test-simple-autoloads.el --- automatically extracted autoloads (do not edit)   -*- lexical-binding: t -*-
;; Generated by the `loaddefs-generate' function.

;; This file is part of GNU Emacs.

;;; Code:

(add-to-list 'load-path (or (and load-file-name (file-name-directory load-file-name)) (car load-path)))



;;; Generated autoloads from test-simple.el

(autoload 'test-simple-start "test-simple" "\


(fn &optional TEST-START-MSG)" nil t)
(autoload 'test-simple-clear "test-simple" "\
Initialize and reset everything to run tests.
You should run this before running any assertions.  Running more than once
clears out information from the previous run.

(fn &optional TEST-INFO TEST-START-MSG)" t)
(autoload 'test-simple-run "test-simple" "\
Register command line to run tests non-interactively and bind key to run test.
After calling this function, you can run test by key specified by `test-simple-runner-key'.

It is preferable to write at the first line of test files as a comment, e.g,
;;;; (test-simple-run \"emacs -batch -L %s -l %s\" (file-name-directory (locate-library \"test-simple.elc\")) buffer-file-name)

Calling this function interactively, COMMAND-LINE-FORMATS is set above.

(fn &rest COMMAND-LINE-FORMATS)" t)
(register-definition-prefixes "test-simple" '("assert-" "end-tests" "note" "test-simple-"))

;;; End of scraped data

(provide 'test-simple-autoloads)

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; no-native-compile: t
;; coding: utf-8-emacs-unix
;; End:

;;; test-simple-autoloads.el ends here