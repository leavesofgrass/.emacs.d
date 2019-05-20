;;; i3wm-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "i3wm" "i3wm.el" (0 0 0 0))
;;; Generated autoloads from i3wm.el

(autoload 'i3wm-switch-to-workspace "i3wm" "\
Prompt for and switch to a WORKSPACE.

\(fn WORKSPACE)" t nil)

(autoload 'i3wm-switch-to-workspace-number "i3wm" "\
Prompt for and switch to the workspace numbered NUMBER.

\(fn NUMBER)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "i3wm" '("i3wm-")))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; i3wm-autoloads.el ends here
