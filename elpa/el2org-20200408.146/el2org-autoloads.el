;;; el2org-autoloads.el --- automatically extracted autoloads (do not edit)   -*- lexical-binding: t -*-
;; Generated by the `loaddefs-generate' function.

;; This file is part of GNU Emacs.

;;; Code:

(add-to-list 'load-path (or (and load-file-name (file-name-directory load-file-name)) (car load-path)))



;;; Generated autoloads from el2org.el

(autoload 'el2org-generate-readme "el2org" "\
Generate README from current emacs-lisp file.

If BACKEND is set then use-it else use `el2org-default-backend'.
If FILE-EXT is nil deduce it from BACKEND.

(fn &optional BACKEND FILE-EXT)" t)
(autoload 'el2org-generate-html "el2org" "\
Generate html file from current elisp file and browse it." t)
(autoload 'el2org-generate-org "el2org" "\
Generate org file from current elisp file." t)
(register-definition-prefixes "el2org" '("el2org-"))

;;; End of scraped data

(provide 'el2org-autoloads)

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; no-native-compile: t
;; coding: utf-8-emacs-unix
;; End:

;;; el2org-autoloads.el ends here