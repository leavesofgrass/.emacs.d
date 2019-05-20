;;; helm-mt-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "helm-mt" "helm-mt.el" (0 0 0 0))
;;; Generated autoloads from helm-mt.el

(autoload 'helm-mt/reroute-terminal-functions "helm-mt" "\
Advise terminal functions to run `helm-mt' instead when called interactively.
If ARG is t, then activate the advice; otherwise, remove it.

\(fn ARG)" nil nil)

(autoload 'helm-mt "helm-mt" "\
Custom helm buffer for terminals only.
PREFIX is passed on to `helm-mt/term-source-terminal-not-found'.

\(fn &optional PREFIX)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "helm-mt" '("helm-mt/")))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; helm-mt-autoloads.el ends here
